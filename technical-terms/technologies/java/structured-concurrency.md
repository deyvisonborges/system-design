# Structured Concurrency

Structured Concurrency é um modelo de programação concorrente introduzido no Java 21 que organiza tarefas assíncronas em uma hierarquia de escopos, simplificando o gerenciamento de threads, tratamento de erros e cancelamento.

## Definição

Structured Concurrency é um modelo de programação concorrente introduzido no Java 21 (JEP 453) que organiza tarefas assíncronas em uma hierarquia de escopos, onde tarefas filhas são gerenciadas automaticamente pelo escopo pai, simplificando o gerenciamento de threads, tratamento de erros e cancelamento.

```text
Structured Concurrency = Escopos hierárquicos + Gerenciamento automático + Cancelamento propaga
```

## Como Funciona

### 1. Escopos

```text
- StructuredTaskScope: Escopo para tarefas
- ShutdownOnSuccess: Cancela outras tarefas quando uma tem sucesso
- ShutdownOnFailure: Cancela outras tarefas quando uma falha
- Join: Aguarda todas as tarefas completarem
```

### 2. Hierarquia

```text
- Tarefa pai cria escopo
- Tarefas filhas são lançadas no escopo
- Escopo gerencia ciclo de vida das filhas
- Erros e cancelamento propagam
```

### 3. Ciclo de Vida

```text
- Criação: Escopo é criado
- Fork: Tarefas filhas são lançadas
- Join: Aguarda completion
- Shutdown: Cancela tarefas pendentes
- Close: Libera recursos
```

## Exemplo Prático

### StructuredTaskScope Básico

```java
public class StructuredConcurrencyExample {
    public static void main(String[] args) throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            // Lançar tarefas
            Supplier<String> task1 = scope.fork(() -> fetchUser());
            Supplier<Integer> task2 = scope.fork(() -> fetchOrder());

            // Aguardar completion
            scope.join();  // Aguarda todas as tarefas
            scope.throwIfFailed();  // Lança exceção se alguma falhou

            // Usar resultados
            String user = task1.get();
            Integer order = task2.get();
            System.out.println("User: " + user + ", Order: " + order);
        }
    }

    private static String fetchUser() {
        return "John Doe";
    }

    private static Integer fetchOrder() {
        return 12345;
    }
}
```

### ShutdownOnSuccess

```java
public class ShutdownOnSuccessExample {
    public static void main(String[] args) throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnSuccess<String>()) {
            // Lançar tarefas que retornam o mesmo tipo
            scope.fork(() -> fetchFromPrimary());
            scope.fork(() -> fetchFromSecondary());
            scope.fork(() -> fetchFromTertiary());

            // Aguarda primeira tarefa com sucesso
            String result = scope.join().result();
            System.out.println("First successful result: " + result);
        }
    }

    private static String fetchFromPrimary() {
        try {
            Thread.sleep(1000);
            return "Primary";
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    private static String fetchFromSecondary() {
        try {
            Thread.sleep(2000);
            return "Secondary";
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    private static String fetchFromTertiary() {
        try {
            Thread.sleep(3000);
            return "Tertiary";
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
```

### ShutdownOnFailure

```java
public class ShutdownOnFailureExample {
    public static void main(String[] args) throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            // Lançar tarefas
            Supplier<String> task1 = scope.fork(() -> fetchUser());
            Supplier<Integer> task2 = scope.fork(() -> fetchOrder());

            // Aguarda completion
            scope.join();
            scope.throwIfFailed();  // Lança exceção se alguma falhou

            // Usar resultados
            String user = task1.get();
            Integer order = task2.get();
            System.out.println("User: " + user + ", Order: " + order);
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

### Custom Scope

```java
public class CustomScopeExample {
    public static void main(String[] args) throws Exception {
        try (var scope = new CustomTaskScope()) {
            scope.fork(() -> task1());
            scope.fork(() -> task2());
            
            scope.join();
            System.out.println("All tasks completed");
        }
    }

    static class CustomTaskScope extends StructuredTaskScope<Object> {
        @Override
        protected void handleComplete(Subtask<? extends Object> subtask) {
            switch (subtask.state()) {
                case SUCCESS:
                    System.out.println("Task completed: " + subtask.get());
                    break;
                case FAILED:
                    System.out.println("Task failed: " + subtask.exception());
                    break;
                case UNAVAILABLE:
                    break;
            }
        }
    }
}
```

## Comandos Úteis

### Habilitar Structured Concurrency

```bash
# Java 21+ tem suporte nativo
java --enable-preview MyApp.java

# Para versões anteriores, usar incubator
java --add-modules jdk.incubator.concurrent MyApp.java
```

### Compilar

```bash
javac --enable-preview --release 21 MyApp.java
```

## Vantagens

### 1. Simplicidade

```text
- Código mais legível
- Escopos explícitos
- Gerenciamento automático
```

### 2. Segurança

```text
- Cancelamento propaga
- Erros não são ignorados
- Sem thread leaks
```

### 3. Manutenibilidade

```text
- Debugging mais fácil
- Ciclo de vida claro
- Observabilidade melhor
```

## Limitações

### 1. Java 21+

```text
- Requer Java 21+
- Recurso preview em versões anteriores
- Não disponível em versões antigas
```

### 2. Curva de Aprendizado

```text
- Novo paradigma
- Diferente de CompletableFuture
- Requer adaptação
```

### 3. Performance

```text
- Overhead de escopos
- Context switching
- Não ideal para todos os casos
```

## Melhores Práticas

### 1. Usar try-with-resources

```java
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    // Código
}
```

### 2. Tratar Exceções

```java
scope.join();
scope.throwIfFailed();
```

### 3. Escolher Scope Adequado

```java
// ShutdownOnSuccess para primeira resposta bem-sucedida
var scope = new StructuredTaskScope.ShutdownOnSuccess<String>();

// ShutdownOnFailure para todas as tarefas
var scope = new StructuredTaskScope.ShutdownOnFailure();
```

### 4. Evitar Blocking

```java
// Preferir join() com timeout
scope.joinUntil(Instant.now().plusSeconds(5));
```

## Trade-offs

### Structured Concurrency vs CompletableFuture

- **Structured**: Escopos explícitos, gerenciamento automático
- **CompletableFuture**: Mais flexível, menos estruturado
- **Escolha**: Structured para complexidade, CompletableFuture para simplicidade

### ShutdownOnSuccess vs ShutdownOnFailure

- **Success**: Primeira tarefa com sucesso
- **Failure**: Todas as tarefas devem ter sucesso
- **Escolha**: Success para fallback, Failure para agregação

### Structured vs Virtual Threads

- **Structured**: Gerenciamento de tarefas
- **Virtual Threads**: Execução leve
- **Escolha**: Usar juntos para melhor resultado

### _Links_

- <https://openjdk.org/jeps/453>
- <https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html>
- <https://inside.java/2023/01/07/loom/>
