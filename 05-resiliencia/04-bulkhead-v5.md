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
