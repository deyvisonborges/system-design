# CompletableFuture

CompletableFuture é uma classe do Java 8+ que permite programação assíncrona com composição de operações, facilitando o desenvolvimento de código não-bloqueante com callbacks, encadeamento e tratamento de exceções.

## Definição

CompletableFuture é uma classe do Java 8+ que implementa Future e CompletionStage, permitindo programação assíncrona com composição de operações, callbacks, encadeamento e tratamento de exceções, facilitando o desenvolvimento de código não-bloqueante.

```text
CompletableFuture = Assíncrono + Composição + Callbacks + Não-bloqueante
```

## Como Funciona

### 1. Criação

```text
- supplyAsync: Executa tarefa assíncrona com retorno
- runAsync: Executa tarefa assíncrona sem retorno
- completedFuture: Cria Future já completado
- allOf: Aguarda múltiplos Futures
```

### 2. Composição

```text
- thenApply: Transforma resultado
- thenAccept: Consome resultado
- thenRun: Executa após completar
- thenCompose: Encadeia Futures
```

### 3. Combinação

```text
- thenCombine: Combina dois Futures
- thenAcceptBoth: Consome dois resultados
- applyToEither: Usa o primeiro a completar
```

## Exemplo Prático

### Criação Básica

```java
public class CompletableFutureExample {
    public static void main(String[] args) throws Exception {
        // Criar CompletableFuture assíncrono
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return "Hello";
        });

        // Adicionar callback
        future.thenAccept(result -> System.out.println("Result: " + result));

        // Aguardar resultado
        String result = future.get();
        System.out.println(result);
    }
}
```

### Encadeamento

```java
public class ChainingExample {
    public static void main(String[] args) throws Exception {
        CompletableFuture.supplyAsync(() -> "Hello")
            .thenApply(String::toUpperCase)
            .thenApply(s -> s + " WORLD")
            .thenAccept(System.out::println);
    }
}
```

### Combinação

```java
public class CombinationExample {
    public static void main(String[] args) throws Exception {
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> "Hello");
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "World");

        CompletableFuture<String> combined = future1.thenCombine(future2, (s1, s2) -> s1 + " " + s2);
        
        System.out.println(combined.get());  // Hello World
    }
}
```

### Tratamento de Exceções

```java
public class ExceptionHandlingExample {
    public static void main(String[] args) throws Exception {
        CompletableFuture.supplyAsync(() -> {
            if (true) throw new RuntimeException("Error");
            return "Success";
        })
        .exceptionally(ex -> "Fallback: " + ex.getMessage())
        .thenAccept(System.out::println);
    }
}
```

### Timeout

```java
public class TimeoutExample {
    public static void main(String[] args) throws Exception {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return "Done";
        });

        try {
            String result = future.orTimeout(1, TimeUnit.SECONDS).get();
            System.out.println(result);
        } catch (TimeoutException e) {
            System.out.println("Timeout");
        }
    }
}
```

## Comandos Úteis

### Executor Customizado

```java
Executor executor = Executors.newFixedThreadPool(10);

CompletableFuture.supplyAsync(() -> "Hello", executor)
    .thenAccept(System.out::println);
```

### 3. Múltiplos Futures

```java
CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> "A");
CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "B");
CompletableFuture<String> future3 = CompletableFuture.supplyAsync(() -> "C");

// Aguardar todos
CompletableFuture<Void> all = CompletableFuture.allOf(future1, future2, future3);
all.join();

// Aguardar qualquer um
CompletableFuture<Object> any = CompletableFuture.anyOf(future1, future2, future3);
any.join();
```

## Vantagens

### 1. Assíncrono

```text
- Não-bloqueante
- Melhor utilização de threads
- Alta escalabilidade
```

### 2. Flexibilidade de Composição

```text
- Encadeamento de operações
- Combinação de Futures
- Código declarativo
```

### 3. Flexibilidade

```text
- Callbacks
- Tratamento de exceções
- Timeout
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Debugging desafiador
- Erros sutis
```

### 2. Overhead

```text
- Overhead de criação
- Memória extra
- Context switching
```

### 3. Erros

```text
- CompletionException
- ExecutionException
- TimeoutException
```

## Melhores Práticas

### 1. Usar Executor Customizado

```java
Executor executor = Executors.newFixedThreadPool(10);
CompletableFuture.supplyAsync(() -> task(), executor);
```

### 2. Tratar Exceções

```java
future.exceptionally(ex -> {
    log.error("Error", ex);
    return fallback;
});
```

### 3. Evitar Blocking

```java
// Evitar
future.get();

// Preferir
future.thenAccept(result -> process(result));
```

### 4. Usar Timeout

```java
future.orTimeout(5, TimeUnit.SECONDS);
```

## Trade-offs

### thenApply vs thenAccept vs thenRun

- **thenApply**: Transforma resultado, retorna Future
- **thenAccept**: Consome resultado, retorna Future sem retorno
- **thenRun**: Executa ação, retorna Future sem retorno
- **Escolha**: thenApply para transformação, thenAccept para consumo, thenRun para ação

### supplyAsync vs runAsync

- **supplyAsync**: Com retorno, CompletableFuture com tipo
- **runAsync**: Sem retorno, CompletableFuture sem retorno
- **Escolha**: supplyAsync para resultado, runAsync para ação

### get vs join

- **get**: Lança exceções checked, bloqueante
- **join**: Lança exceções unchecked, bloqueante
- **Escolha**: get para tratamento, join para simples

### _Links_

- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html>
- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletionStage.html>
- <https://www.baeldung.com/java-completablefuture>
