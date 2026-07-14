# Como o Resilience4j aplica o Bulkhead

O Resilience4j implementa o padrão Bulkhead de duas formas distintas, cada uma com um mecanismo interno diferente. Vale entender as duas porque a escolha entre elas afeta diretamente como seu serviço de crédito se comporta sob carga.

## 1. SemaphoreBulkhead

É a implementação mais simples, baseada em um contador (semáforo).
Como funciona internamente:

- Mantém um contador de permits (maxConcurrentCalls)
- Cada chamada tenta adquirir um permit antes de executar
- Se não houver permit disponível, a chamada falha imediatamente (ou espera até maxWaitDuration) lançando BulkheadFullException
- Ao final da execução (sucesso ou falha), o permit é liberado

```java
BulkheadConfig config = BulkheadConfig.custom()
    .maxConcurrentCalls(10)
    .maxWaitDuration(Duration.ofMillis(0)) // não espera, falha rápido
    .build();

Bulkhead bulkhead = Bulkhead.of("creditAnalysis", config);

Supplier<CreditResult> decorated = Bulkhead
    .decorateSupplier(bulkhead, () -> creditService.analyze(request));
```

### Características

- Executa na mesma thread do chamador (não cria pool próprio)
- Não isola threads de fato — apenas limita a concorrência lógica
- Baixíssimo overhead
- Não protege contra threads travadas (se a chamada trava, o permit não é liberado até o timeout do próprio recurso)

## 2. ThreadPoolBulkhead

Implementação mais "clássica" no sentido do padrão original de Michael Nygard (Release It!).

### Como funciona internamente

- Usa um ThreadPoolExecutor próprio e isolado, com fila limitada (BoundedQueue)
- Cada chamada decorada é submetida como uma Task para esse pool
- Retorna um CompletableFuture (é assíncrono por natureza)
- Se a fila estiver cheia e o pool saturado, lança BulkheadFullException imediatamente

```java
ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
    .maxThreadPoolSize(10)
    .coreThreadPoolSize(5)
    .queueCapacity(20)
    .build();

ThreadPoolBulkhead bulkhead = ThreadPoolBulkhead.of("creditAnalysis", config);

CompletableFuture<CreditResult> future = ThreadPoolBulkhead
    .decorateSupplier(bulkhead, () -> creditService.analyze(request))
    .get();
```

#### Características

- Isolamento real de threads — uma chamada travada não consome a thread do caller
- Overhead maior (troca de contexto, gerenciamento do pool)
- Protege genuinamente contra "thread starvation" em cascata

Um ponto importante: se você está rodando em Virtual Threads (Project Loom), o SemaphoreBulkhead tende a fazer mais sentido na maioria dos casos, porque o custo de bloquear uma virtual thread é praticamente zero — diferente de bloquear uma thread de plataforma no Tomcat clássico. Já o ThreadPoolBulkhead cria overhead adicional de gerenciar outro pool de threads, o que pode ser redundante quando as próprias virtual threads já resolvem o problema de esgotamento.

___

# O que realmente é singleton

O que é singleton (a nível de aplicação) é a instância do Bulkhead/CircuitBreaker em si, não o serviço que está sendo protegido. Ou seja:

```java
BulkheadRegistry registry = BulkheadRegistry.ofDefaults();
Bulkhead bulkhead = registry.bulkhead("creditAnalysis", config);
```

Esse bulkhead é um objeto único, geralmente gerenciado por um BulkheadRegistry (que por sua vez costuma ser um bean Spring singleton). Toda vez que você chama registry.bulkhead("creditAnalysis", config) com a mesma chave ("creditAnalysis"), você recebe a mesma instância — ela não é recriada por chamada.

## O que isso significa na prática

O Bulkhead não "encapsula" o serviço consumidor como um proxy transparente automático. Ele é um objeto contador/limitador compartilhado que múltiplas threads/requisições concorrentes vão consultar antes de executar a chamada real.

```md
Thread 1 ──┐
Thread 2 ──┼──► [Bulkhead "creditAnalysis"] ──► tryAcquirePermission() ──► creditService.analyze()
Thread 3 ──┘         (instância única,
                      contador compartilhado)
```

Cada thread que quer chamar creditService.analyze() primeiro pergunta pro mesmo objeto Bulkhead: "tem permit disponível?". Se sim, decrementa o contador e segue. Se não, rejeita.

Não é o serviço que vira singleton — é o mecanismo de controle de concorrência que é singleton e compartilhado entre todas as chamadas àquele recurso identificado pela chave ("creditAnalysis").

### Por que isso importa na prática

Se você criar um Bulkhead novo por request (Bulkhead.of("x", config) dentro de um método, sem usar o registry), cada chamada teria seu próprio contador isolado — e o limite de concorrência nunca seria respeitado de verdade, porque cada instância começaria do zero. Esse é um erro comum.

No Spring Boot com anotação @Bulkhead, o framework já garante isso automaticamente via BulkheadRegistry gerenciado no contexto:

```java
@Bulkhead(name = "creditAnalysis", type = Bulkhead.Type.THREADPOOL)
public CreditResult analyze(CreditRequest request) {
    return creditService.analyze(request);
}
```

### O problema sem Bulkhead

```md
200 threads do Tomcat, todas processando requisições que chamam:
  → produtos (rápido, ~50ms)
  → categorias (rápido, ~80ms)
  → avaliações (rápido, ~100ms)
  → recomendações (LENTO, ~10s) ← aqui está o problema
```

Se as 200 threads disponíveis do Tomcat vão, em algum momento, todas parar numa chamada a recomendacoes, travadas por 10s cada, o efeito é este: mesmo as requisições que só precisavam de produtos/categorias/avaliações (rápidas) ficam sem thread disponível pra serem atendidas, porque o pool inteiro está bloqueado esperando o serviço lento.

Isso se chama thread starvation em cascata — um serviço lento "contamina" a capacidade de resposta de todos os outros, mesmo os que não têm nada a ver com o problema.

#### Com Bulkhead (isolando por serviço externo)

Você cria um Bulkhead por serviço externo, com limites de concorrência separados:

```yaml
// application.yml
resilience4j:
  thread-pool-bulkhead:
    instances:
      produtos:
        maxThreadPoolSize: 20
        coreThreadPoolSize: 10
        queueCapacity: 20
      categorias:
        maxThreadPoolSize: 20
        coreThreadPoolSize: 10
        queueCapacity: 20
      avaliacoes:
        maxThreadPoolSize: 20
        coreThreadPoolSize: 10
        queueCapacity: 20
      recomendacoes:
        maxThreadPoolSize: 15
        coreThreadPoolSize: 5
        queueCapacity: 10   # fila pequena de propósito
```

```java
@ThreadPoolBulkhead(name = "recomendacoes")
public CompletableFuture<List<Recomendacao>> buscarRecomendacoes(String userId) {
    return CompletableFuture.supplyAsync(() -> recomendacoesClient.buscar(userId));
}

@ThreadPoolBulkhead(name = "produtos")
public CompletableFuture<Produto> buscarProduto(String id) {
    return CompletableFuture.supplyAsync(() -> produtosClient.buscar(id));
}
// idem para categorias e avaliacoes
```

#### O que acontece agora quando recomendações trava em 10s

```md
200 threads do Tomcat continuam livres para receber requisições HTTP.

Chamada a recomendacoes() → vai pro pool ISOLADO "recomendacoes" (15 threads)
Chamada a produtos()      → vai pro pool ISOLADO "produtos" (20 threads)
Chamada a categorias()    → vai pro pool ISOLADO "categorias" (20 threads)
Chamada a avaliacoes()    → vai pro pool ISOLADO "avaliacoes" (20 threads)
```

Quando recomendacoes demora 10s, só as 15 threads daquele pool específico ficam saturadas. A fila (queueCapacity: 10) segura mais um pouco, e depois disso o Bulkhead começa a rejeitar rápido com BulkheadFullException em vez de deixar a requisição travada indefinidamente.

Enquanto isso, os pools de produtos, categorias e avaliacoes continuam operando normalmente — essas partes da resposta continuam rápidas.

#### O ponto chave que resolve seu cenário

A pergunta que sobra é: e a requisição original, que precisa dos 4 resultados pra montar a resposta completa?

Aqui você tem duas escolhas de design, que valem a pena você decidir conscientemente:

1. Degradar graciosamente: se recomendacoes falhar/rejeitar, você responde ao usuário sem a seção de recomendações (fallback vazio), mas com produtos/categorias/avaliações normalmente.

```java
CompletableFuture<List<Recomendacao>> recomendacoesFuture = buscarRecomendacoes(userId)
    .exceptionally(ex -> Collections.emptyList()); // fallback
```

1. Falhar a requisição inteira: se recomendações é obrigatório no seu domínio de negócio, aí o isolamento não evita a falha da request, mas evita que ela contamine outras requisições que não dependiam de recomendações.

___

> O Bulkhead controla quantas chamadas simultâneas podem acessar um determinado recurso.

### Então existe um contador global?

Sim, dentro daquela instância da aplicação (JVM).

O Bulkhead não mede latência.

```md
Pod A
Bulkhead
contador = 13

Pod B
Bulkhead
contador = 4

Pod C
Bulkhead
contador = 20
```

Cada pod possui seu próprio contador.
Não existe sincronização entre pods.
É um controle local da JVM.

O Bulkhead do Resilience4j funciona como um limitador de concorrência por recurso. Ele mantém um contador local na JVM das chamadas simultâneas em execução para aquele recurso. Cada nova chamada tenta adquirir uma vaga; se houver disponibilidade, prossegue e libera a vaga ao terminar. Se o limite de concorrência for atingido, a chamada é rejeitada imediatamente (ou espera por uma vaga, se configurado), evitando que um serviço lento consuma todas as threads da aplicação.

O Bulkhead limita a quantidade de requisições que podem executar simultaneamente um trecho específico do código. Quando sabemos que um serviço externo é lento ou instável, isolamos esse acesso para impedir que ele consuma todas as threads da aplicação. Assim, apenas uma quantidade controlada de requisições fica esperando por esse recurso, enquanto o restante da aplicação continua responsivo

```md
O Bulkhead do Resilience4j funciona como um limitador de concorrência por recurso, e tem duas implementações:

- SemaphoreBulkhead: mantém um contador (semáforo) de chamadas simultâneas. A execução roda na própria thread do chamador — limita quantas passam ao mesmo tempo, mas não isola threads fisicamente.
- ThreadPoolBulkhead: usa um pool de threads dedicado por recurso. A execução roda em threads isoladas, separadas do pool principal da aplicação (ex: Tomcat).

Em ambos os casos, cada chamada tenta adquirir uma vaga (permit ou thread do pool); se disponível, prossegue e libera a vaga ao terminar. Se o limite for atingido, a chamada é rejeitada imediatamente (ou espera, se configurado via maxWaitDuration/queueCapacity).

Quando um serviço externo é lento ou instável, isolamos o acesso a ele em um bulkhead próprio, para que o esgotamento desse recurso específico não contamine as chamadas a outros serviços. Com ThreadPoolBulkhead, isso protege genuinamente as threads do pool principal da aplicação — mas se a chamada for feita de forma síncrona (.join()/.get()), a thread original ainda fica bloqueada esperando o resultado, a menos que se use timeout ou um modelo totalmente reativo/assíncrono.
```

Exemplo bem didatico:

Uma sala de reuniões do time de recomendações só comporta 20 pessoas.

```md
Empresa

200 funcionários
  Sala Recomendações
    capacidade = 20

Os funcionários continuam existindo.

Quer entrar na sala?
  Quer entrar na sala?
    Sim → entra
    Não → vai embora

Não é a empresa que diminuiu.
É a capacidade daquela sala.
```

## Por que normalmente recomendamos SemaphoreBulkhead no Spring MVC?

Porque o Spring MVC já possui um pool de threads (o do Tomcat).

Criar outro pool geralmente adiciona:

- troca de contexto (context switch);
- mais consumo de memória;
- mais complexidade.

Mas a thread do Tomcat continua esperando se você fizer .get() ou .join().
Então, em muitos casos, você só adicionou mais um pool sem resolver o problema principal.

Por isso é comum ver recomendações como:

- Spring MVC síncrono → SemaphoreBulkhead
- WebFlux / programação assíncrona → ThreadPoolBulkhead, quando faz sentido isolar um recurso.
