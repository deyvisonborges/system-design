# Resilience4j — Bulkhead

## O que é

O Bulkhead do Resilience4j funciona como um limitador de concorrência por recurso. Ele isola o **acesso** a um serviço/dependência específica, não o serviço em si — o código do serviço consumido continua inalterado; o Bulkhead atua como uma barreira (proxy/decorator) antes da chamada real acontecer.

## Duas implementações

### SemaphoreBulkhead

- Mantém um contador (semáforo) de chamadas simultâneas para aquele recurso.
- A execução roda **na própria thread do chamador** — não cria pool próprio.
- Limita quantas chamadas passam ao mesmo tempo, mas não isola threads fisicamente: se a chamada travar, a thread do caller trava junto até o timeout do próprio recurso.
- Baixo overhead. Boa opção quando se usa Virtual Threads (Project Loom), já que o custo de bloquear uma virtual thread é praticamente zero.

```java
BulkheadConfig config = BulkheadConfig.custom()
    .maxConcurrentCalls(10)
    .maxWaitDuration(Duration.ofMillis(0))
    .build();

Bulkhead bulkhead = Bulkhead.of("recomendacoes", config);
```

### ThreadPoolBulkhead

- Usa um `ThreadPoolExecutor` próprio e isolado, com fila limitada, dedicado àquele recurso.
- A execução roda em **threads isoladas**, separadas do pool principal da aplicação (ex: Tomcat).
- Isolamento real: uma chamada travada não consome a thread do caller.
- Overhead maior (troca de contexto, gerenciamento de outro pool). Retorna `CompletableFuture` (assíncrono por natureza).

```java
ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
    .maxThreadPoolSize(15)
    .coreThreadPoolSize(5)
    .queueCapacity(10)
    .build();

ThreadPoolBulkhead bulkhead = ThreadPoolBulkhead.of("recomendacoes", config);
```

## Mecânica comum às duas implementações

Cada chamada tenta adquirir uma vaga (permit ou thread do pool):

- Se disponível → prossegue e libera a vaga ao terminar.
- Se o limite for atingido → rejeita imediatamente com `BulkheadFullException`, ou espera por uma vaga (`maxWaitDuration` no Semaphore, `queueCapacity` no ThreadPool).

## Onde exatamente o Bulkhead atua

O Bulkhead não remove nada do serviço, não move código, não modifica o serviço externo. Ele intercepta a chamada **antes** dela ser executada, perguntando ao pool/contador daquele recurso específico se há capacidade disponível.

```
Request chega → Tomcat pega 1 thread livre
       │
       ▼
Código chama buscarRecomendacoes(userId)
       │
       ▼
┌─────────────────────┐
│  BULKHEAD atua AQUI  │ ← ponto exato de interceptação
│  "recomendacoes"     │
└─────────────────────┘
       │
   tem vaga?
   SIM → executa a chamada real (rede)
   NÃO → rejeita na hora (BulkheadFullException)
```

Cada dependência externa (produtos, categorias, avaliações, recomendações) tem seu **próprio** Bulkhead, com seu próprio limite de concorrência. Isso é o que garante o isolamento: um serviço lento (ex: recomendações demorando 10s) satura apenas o seu próprio pool/contador, sem afetar a capacidade de resposta das chamadas aos outros serviços.

Analogia: 4 guichês de atendimento, cada um com sua própria fila e atendentes. Se um guichê trava, apenas a fila dele enche — os outros continuam atendendo normalmente.

## Instância singleton — o que é compartilhado de fato

O que é singleton a nível de aplicação é a **instância do Bulkhead em si** (gerenciada por um `BulkheadRegistry`, tipicamente um bean Spring), não o serviço consumidor.

```java
BulkheadRegistry registry = BulkheadRegistry.ofDefaults();
Bulkhead bulkhead = registry.bulkhead("recomendacoes", config);
```

Toda chamada com a mesma chave (`"recomendacoes"`) recebe a **mesma instância** de Bulkhead — o contador/pool é compartilhado entre todas as threads/requisições concorrentes que competem por aquele recurso. Se um Bulkhead novo fosse criado por request (sem passar pelo registry), cada chamada teria seu próprio contador isolado, e o limite de concorrência nunca seria respeitado de fato — erro comum de implementação.

No Spring Boot, a anotação `@Bulkhead` já garante isso automaticamente via `BulkheadRegistry` gerenciado no contexto:

```java
@Bulkhead(name = "recomendacoes", type = Bulkhead.Type.THREADPOOL)
public CreditResult analyze(CreditRequest request) {
    return creditService.analyze(request);
}
```

## A pegadinha: a thread da requisição original ainda pode ficar bloqueada

Mesmo usando `ThreadPoolBulkhead` (isolamento real de threads), se a chamada às dependências for feita de forma síncrona — usando `.join()` ou `.get()` sobre os `CompletableFuture` — a thread original (ex: do Tomcat) **fica bloqueada esperando** o resultado, mesmo que a execução real esteja rodando em pools separados.

```java
@GetMapping("/produto/{id}/completo")
public ProdutoCompletoDTO buscarCompleto(@PathVariable String id, @PathVariable String userId) {
    CompletableFuture<Produto> produtoFuture = buscarProduto(id);
    CompletableFuture<List<Categoria>> categoriasFuture = buscarCategorias(id);
    CompletableFuture<List<Avaliacao>> avaliacoesFuture = buscarAvaliacoes(id);
    CompletableFuture<List<Recomendacao>> recomendacoesFuture = buscarRecomendacoes(userId);

    // a thread do Tomcat FICA AQUI, bloqueada, esperando os 4 futures
    CompletableFuture.allOf(produtoFuture, categoriasFuture, avaliacoesFuture, recomendacoesFuture).join();

    return montarDTO(produtoFuture.join(), categoriasFuture.join(), avaliacoesFuture.join(), recomendacoesFuture.join());
}
```

Ou seja: o Bulkhead isolou o **esgotamento do pool da dependência lenta**, mas não elimina o bloqueio da thread chamadora, a menos que:

- se configure um **timeout curto** (via `TimeLimiter`) para não deixar a espera indefinida;
- ou se adote um modelo **totalmente reativo/assíncrono** (WebFlux), onde a thread do caller não fica presa esperando, e sim é liberada para outras requisições enquanto o resultado não chega.

## Resumo comparativo

| Aspecto | SemaphoreBulkhead | ThreadPoolBulkhead |
|---|---|---|
| Mecanismo | Contador (semáforo) | Pool de threads dedicado |
| Isolamento real de threads | Não | Sim |
| Execução | Thread do chamador | Thread própria do pool |
| Overhead | Baixo | Médio/Alto |
| Retorno | Síncrono | `CompletableFuture` (assíncrono) |
| Bom para | Chamadas rápidas, Virtual Threads | Chamadas lentas/instáveis, isolamento genuíno |

## Combinando com Circuit Breaker

```java
Supplier<CreditResult> decorated = Decorators.ofSupplier(() -> creditService.analyze(request))
    .withBulkhead(bulkhead)
    .withCircuitBreaker(circuitBreaker)
    .withRetry(retry)
    .decorate();
```

A ordem importa: o Bulkhead deve envolver a chamada mais interna (mais próxima do recurso), com o CircuitBreaker por fora, para que o circuito abra baseado em falhas reais e não em rejeições do próprio Bulkhead.

___

# Resilience4j: Backpressure, Bulkhead e Padrões Combinados

## 1. Backpressure no Resilience4j — não existe módulo com esse nome

Resilience4j **não é reativo por natureza** — foi pensado pra chamadas síncronas/bloqueantes. Ele simula proteção contra sobrecarga limitando **concorrência** e **taxa**, não fazendo controle de demanda como no Reactive Streams (Reactor/RxJava, onde o consumidor pede `request(n)` ao produtor).

| Conceito | O que faz | Pergunta que responde |
|---|---|---|
| **Bulkhead** | Limita chamadas concorrentes | "Quantos em paralelo agora?" |
| **RateLimiter** | Limita chamadas por janela de tempo | "Quantos no último segundo?" |
| **CircuitBreaker** | Fail-fast quando downstream está doente | "Devo nem tentar?" |
| **Backpressure real** (Reactive Streams/Kafka poll) | Consumidor controla quanto puxa do produtor | "Quanto eu aceito receber?" |

Resilience4j faz **admission control** (aceita/rejeita na entrada). Reactive Streams faz **demand signaling** (negocia volume). São estratégias diferentes pro mesmo problema.

No cenário de consumer Kafka: `max.poll.records` é o backpressure real (controla o que entra); Bulkhead/RateLimiter protegem o que fazer com o que já entrou.

---

## 2. Bulkhead — isolamento de recursos, não singleton

O nome vem de compartimentos estanques de navio: cada serviço tem seu próprio "compartimento" de concorrência, isolado dos demais.

```java
Bulkhead bulkheadServicoA = registry.bulkhead("servico-a");
Bulkhead bulkheadServicoB = registry.bulkhead("servico-b");
```

- Cada instância de `Bulkhead` mantém um único semáforo/contador **compartilhado** entre todas as threads que o usam — isso é necessário pro controle funcionar.
- O `Registry` (Spring bean singleton) garante que pedir o mesmo nome sempre retorna a mesma instância, preservando o estado real de ocupação.
- Sem isso (criando `Bulkhead.of(...)` a cada chamada), o contador nunca acumula e o limite não existe de fato.

---

## 3. SemaphoreBulkhead vs. ThreadPoolBulkhead

### SemaphoreBulkhead (default)

Por baixo, é literalmente um `java.util.concurrent.Semaphore`. A própria thread que chegou (ex: thread do Tomcat) executa a chamada e **fica bloqueada** se não houver vaga.

```java
BulkheadConfig.custom()
    .maxConcurrentCalls(10)
    .maxWaitDuration(Duration.ofMillis(0)) // 0 = rejeita na hora; >0 = espera até o timeout
    .build();
```

- Das 20 chamadas, 10 executam; as outras 10 **esperam bloqueadas** (se `maxWaitDuration > 0`) ou falham na hora (`BulkheadFullException`).
- Threads que esperam continuam ocupando slot do pool de origem (ex: Tomcat) — não protege o pool principal, só o serviço downstream.

### ThreadPoolBulkhead

A chamada **não roda na thread que chegou**. Ela é empacotada e submetida a um pool de threads dedicado e isolado.

```java
ThreadPoolBulkheadConfig.custom()
    .maxThreadPoolSize(10)
    .coreThreadPoolSize(5)
    .queueCapacity(20)
    .build();
```

Fluxo:

1. Thread do Tomcat (thread-A) empacota a chamada e submete ao pool isolado.
2. Recebe de volta um `CompletableFuture` **vazio** e é liberada imediatamente — volta pro pool do Tomcat.
3. Uma thread do pool isolado (thread-B) pega a tarefa da fila e executa do início ao fim, **inteiramente dentro do próprio pool isolado**.
4. Ao terminar, thread-B chama `future.complete(resultado)` ou `future.completeExceptionally(erro)` — ela mesma marca a promise como pronta.
5. Callbacks registrados (`.thenApply()`, `.whenComplete()`) dispararam nesse momento — geralmente executados pela própria thread-B ou por uma thread do `ForkJoinPool.commonPool()`.

**Importante:** thread-A e thread-B nunca se comunicam diretamente. thread-A já pode estar atendendo outra requisição quando thread-B termina. A comunicação é via objeto compartilhado (`CompletableFuture`), não uma "ligação de volta".

Se o endpoint força `.get()` no Future, você **perde parte do benefício**: a thread volta a bloquear, só que esperando o Future em vez do serviço diretamente.

### Comparativo

| | SemaphoreBulkhead | ThreadPoolBulkhead |
|---|---|---|
| Thread original | Fica bloqueada (ou falha na hora) | Liberada imediatamente |
| Quem executa | A própria thread que chegou | Thread de pool separado |
| Isolamento | Parcial (só o serviço) | Total (protege até o pool principal) |
| Overhead | Baixo (só semáforo) | Maior (fila, troca de contexto, `Future`) |
| Combina bem com | Virtual Threads (bloquear é barato) | Platform Threads clássicas |

---

## 4. Custo de recurso do ThreadPoolBulkhead

- **Memória**: cada thread nova consome stack (~512KB–1MB, via `-Xss`). É custo adicional que não existia antes — soma-se ao pool do Tomcat.
- **CPU**: troca de contexto entre thread de origem e thread do pool isolado, mais overhead de sincronização do `CompletableFuture`. Em compensação, evita threads do pool principal ficarem "penduradas" esperando I/O lento.
- **GC**: mais objetos de curta duração (tarefas, futures, callbacks) — geralmente cai na Young Generation, barato, mas mensurável em alta escala.
- Em alto volume, vale medir com APM (Dynatrace/Grafana) antes de escolher entre ThreadPoolBulkhead (platform threads) ou SemaphoreBulkhead + Virtual Threads (bloquear fica barato, sem overhead de fila).

---

## 5. Combinando estratégias

**Pode e é recomendado:**

- Múltiplos Bulkheads (um por serviço/dependência) — é o uso correto do padrão de compartimentos isolados.
- Bulkhead + RateLimiter + CircuitBreaker no mesmo ponto — cada um resolve uma dimensão diferente e complementar.

**Não recomendado:**

- Empilhar Semaphore e ThreadPool no mesmo ponto de proteção — escolha um tipo por ponto, sem ganho real em combinar os dois ali.

### Ordem real de execução (fixa, independente da ordem das anotações no código)

```
CircuitBreaker → RateLimiter → Bulkhead → (chamada real)
```

```java
@RateLimiter(name = "score-externo")
@Bulkhead(name = "score-externo", type = Bulkhead.Type.THREADPOOL)
@CircuitBreaker(name = "score-externo", fallbackMethod = "fallbackScore")
public ScoreResponse consultarScoreExterno(String cpf) { ... }
```

1. **CircuitBreaker** checa primeiro — se OPEN, nem prossegue, vai direto pro fallback.
2. **RateLimiter** checa taxa — se estourou, rejeita (`RequestNotPermitted`) → fallback.
3. **Bulkhead** submete ao pool/semáforo — se cheio, rejeita (`BulkheadFullException`) → fallback.
4. Chamada real executa.
5. Resultado (ou falha) sobe: falhas alimentam as métricas do CircuitBreaker; qualquer rejeição/erro cai no mesmo `fallbackScore`.

O `fallback` precisa tratar genericamente todos os casos, a menos que você inspecione o tipo da exceção recebida.

Motivo da ordem: fail-fast no ponto mais barato — se o circuito já está sabidamente aberto, não vale gastar RateLimiter nem ocupar vaga de Bulkhead.

---

## 6. Cuidados antes de aplicar esses padrões em produção

1. **Timeout do cliente HTTP configurado e coerente** — sem isso, Bulkhead/CircuitBreaker não têm o que proteger; a thread fica presa esperando indefinidamente e as métricas de falha nunca disparam. Regra: timeout do HTTP client < slow-call-threshold do CircuitBreaker < timeout de camadas acima.

2. **Filtrar o que conta como falha** — respostas de negócio (404, 422) não são falha de infraestrutura. Sem esse filtro, o CircuitBreaker pode abrir por erro de validação, não por serviço doente.

   ```java
   CircuitBreakerConfig.custom()
       .recordException(e -> e instanceof ServiceUnavailableException || e instanceof TimeoutException)
       .ignoreExceptions(BusinessValidationException.class, NotFoundException.class)
       .build();
   ```

3. **Fallback com decisão de negócio real**, acordada com o time de produto: negar crédito por padrão? Aprovar com limite reduzido? Enfileirar pra reprocessamento? Usar score em cache?

4. **Dimensionamento correto do Bulkhead** — baseado em throughput esperado × latência típica (Little's Law), não em chute. Subdimensionado cria gargalo artificial; superdimensionado perde a proteção.

5. **Ordem de decorators e interação com Retry** — CircuitBreaker deve ver o resultado já esgotadas as tentativas de Retry, não o contrário, ou o circuito nunca "descansa".

6. **Retry só em operações idempotentes** — se a chamada cria/muda estado no serviço externo, Retry automático pode duplicar a operação.

7. **Half-Open bem calibrado** — `minimumNumberOfCalls` baixo demais gera falso positivo de abertura; alto demais atrasa a reação a um problema real.

8. **Observabilidade desde o dia 1** — métricas de Bulkhead/CircuitBreaker/RateLimiter integradas ao Micrometer/Grafana, pra saber exatamente por que uma chamada caiu no fallback (rate limit? bulkhead cheio? circuito aberto?).

9. **Teste de caos** — validar com falha induzida (Toxiproxy, endpoint com delay/erro configurável) antes que um incidente real valide (ou desminta) a configuração.

**Prioridade prática para um serviço de crédito (Crédito Gateway PF):**

1. Timeout do HTTP client bem configurado.
2. Fallback com decisão de negócio clara.
3. Filtrar exceções de negócio vs. infraestrutura no CircuitBreaker.

Sem esses três, o resto é configuração decorativa sem efeito real.
