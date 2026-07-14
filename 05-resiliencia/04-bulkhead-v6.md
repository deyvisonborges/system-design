
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

___

O fluxo real, passo a passo

1. Uma das 200 threads do Tomcat (chamada thread-A) recebe a requisição HTTP e chega no método anotado com @Bulkhead(type=THREADPOOL).
2. Thread-A não executa nada do serviço lento. Ela só empacota a tarefa e entrega pro pool isolado (10 threads dedicadas).
3. Thread-A recebe de volta um CompletableFuture vazio (ainda não completo) e morre/retorna pro pool do Tomcat — ela está livre agora, pronta pra atender outra requisição HTTP qualquer.
4. Uma thread do pool isolado (chamada thread-B, uma das 10) pega essa tarefa da fila e executa de fato a chamada ao serviço lento.
5. Quando thread-B termina, ela mesma chama future.complete(resultado) — é a própria thread-B fazendo isso, não uma comunicação entre threads. Ela está literalmente executando a linha de código que marca a promise como pronta.
