# ThreadPoolExecutor

ThreadPoolExecutor é uma implementação de ExecutorService que gerencia um pool de threads reutilizáveis, controlando o número de threads ativas, fila de tarefas e política de rejeição para otimizar o uso de recursos em aplicações concorrentes.

## Definição

ThreadPoolExecutor é uma implementação de ExecutorService que gerencia um pool de threads reutilizáveis, controlando o número de threads ativas (core e max), fila de tarefas e política de rejeição para otimizar o uso de recursos em aplicações concorrentes.

```text
ThreadPoolExecutor = Pool de threads + Fila de tarefas + Política de rejeição + Gerenciamento
```

## Como Funciona

### 1. Componentes

```text
- Core Pool Size: Número mínimo de threads
- Maximum Pool Size: Número máximo de threads
- Keep Alive Time: Tempo para threads ociosas
- Work Queue: Fila de tarefas
- Rejection Policy: Política para tarefas rejeitadas
```

### 2. Ciclo de Vida

```text
- Criação: Threads criadas até core pool size
- Escalonamento: Novas threads até max pool size
- Fila: Tarefas enfileiradas quando threads ocupadas
- Rejeição: Tarefas rejeitadas quando fila cheia
- Terminação: Threads ociosas são terminadas
```

### 3. Políticas de Rejeição

```text
- AbortPolicy: Lança RejectedExecutionException
- CallerRunsPolicy: Executor executa a tarefa
- DiscardPolicy: Descarta tarefa silenciosamente
- DiscardOldestPolicy: Descarta tarefa mais antiga
```

## Exemplo Prático

### Criação Básica

```java
public class ThreadPoolExample {
    public static void main(String[] args) {
        // Criar pool básico
        ExecutorService executor = Executors.newFixedThreadPool(10);

        // Submeter tarefas
        for (int i = 0; i < 100; i++) {
            executor.submit(() -> {
                System.out.println("Task: " + Thread.currentThread());
            });
        }

        // Shutdown
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### ThreadPoolExecutor Customizado

```java
public class CustomThreadPoolExample {
    public static void main(String[] args) {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            5,                          // Core pool size
            10,                         // Max pool size
            60, TimeUnit.SECONDS,       // Keep alive time
            new LinkedBlockingQueue<>(100),  // Work queue
            new ThreadPoolExecutor.CallerRunsPolicy()  // Rejection policy
        );

        // Submeter tarefas
        for (int i = 0; i < 200; i++) {
            executor.submit(() -> {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }

        // Shutdown
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### Cached ThreadPool

```java
public class CachedThreadPoolExample {
    public static void main(String[] args) {
        // Cached thread pool: cria threads conforme necessário
        ExecutorService executor = Executors.newCachedThreadPool();

        // Submeter tarefas
        for (int i = 0; i < 100; i++) {
            executor.submit(() -> {
                System.out.println("Task: " + Thread.currentThread());
            });
        }

        // Shutdown
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### Scheduled ThreadPool

```java
public class ScheduledThreadPoolExample {
    public static void main(String[] args) {
        // Scheduled thread pool para tarefas agendadas
        ScheduledExecutorService executor = Executors.newScheduledThreadPool(5);

        // Tarefa agendada
        executor.schedule(() -> {
            System.out.println("Delayed task");
        }, 5, TimeUnit.SECONDS);

        // Tarefa periódica
        executor.scheduleAtFixedRate(() -> {
            System.out.println("Periodic task");
        }, 0, 1, TimeUnit.SECONDS);

        // Shutdown
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### Monitorar Pool

```java
public class MonitorThreadPoolExample {
    public static void main(String[] args) {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            5, 10, 60, TimeUnit.SECONDS,
            new LinkedBlockingQueue<>(100)
        );

        // Submeter tarefas
        for (int i = 0; i < 50; i++) {
            executor.submit(() -> {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }

        // Monitorar
        System.out.println("Core pool size: " + executor.getCorePoolSize());
        System.out.println("Pool size: " + executor.getPoolSize());
        System.out.println("Active threads: " + executor.getActiveThreadCount());
        System.out.println("Completed tasks: " + executor.getCompletedTaskCount());
        System.out.println("Queue size: " + executor.getQueue().size());

        executor.shutdown();
    }
}
```

## Comandos Úteis

### Configurar Pool

```java
ThreadPoolExecutor executor = new ThreadPoolExecutor(
    corePoolSize,           // Core pool size
    maximumPoolSize,       // Max pool size
    keepAliveTime,          // Keep alive time
    TimeUnit.SECONDS,       // Time unit
    workQueue,              // Work queue
    threadFactory,          // Thread factory
    handler                 // Rejection policy
);
```

### Shutdown

```java
// Shutdown gracioso
executor.shutdown();

// Shutdown forçado
executor.shutdownNow();

// Aguardar terminação
executor.awaitTermination(1, TimeUnit.MINUTES);
```

## Vantagens

### 1. Reutilização

```text
- Threads reutilizadas
- Menos overhead de criação
- Melhor performance
```

### 2. Controle

```text
- Controle de número de threads
- Gerenciamento de recursos
- Prevenção de overload
```

### 3. Flexibilidade

```text
- Configuração customizada
- Múltiplas políticas
- Adaptável a diferentes cenários
```

## Limitações

### 1. Complexidade

```text
- Configuração complexa
- Requer tuning
- Erros sutis
```

### 2. Overhead

```text
- Overhead de gerenciamento
- Memória extra
- Context switching
```

### 3. Deadlocks

```text
- Possibilidade de deadlocks
- Starvation
- Requer cuidadoso design
```

## Melhores Práticas

### 1. Escolher Pool Adequado

```java
// Fixed pool para tarefas CPU-bound
Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());

// Cached pool para tarefas I/O-bound
Executors.newCachedThreadPool();

// Scheduled pool para tarefas agendadas
Executors.newScheduledThreadPool(5);
```

### 2. Definir Tamanho Adequado

```java
// CPU-bound: número de cores
int cores = Runtime.getRuntime().availableProcessors();

// I/O-bound: maior número de threads
int threads = cores * 2;
```

### 3. Usar ThreadFactory

```java
ThreadFactory factory = r -> {
    Thread t = new Thread(r);
    t.setName("MyThread-" + t.getId());
    return t;
};

ExecutorService executor = new ThreadPoolExecutor(
    5, 10, 60, TimeUnit.SECONDS,
    new LinkedBlockingQueue<>(100),
    factory
);
```

### 4. Sempre Shutdown

```java
executor.shutdown();
executor.awaitTermination(1, TimeUnit.MINUTES);
```

## Trade-offs

### Fixed vs Cached vs Scheduled

- **Fixed**: Tamanho fixo, CPU-bound
- **Cached**: Tamanho dinâmico, I/O-bound
- **Scheduled**: Tarefas agendadas
- **Escolha**: Fixed para CPU, Cached para I/O, Scheduled para agendamento

### LinkedBlockingQueue vs SynchronousQueue

- **Linked**: Fila ilimitada, mais tarefas
- **Synchronous**: Sem fila, rejeição imediata
- **Escolha**: Linked para buffer, Synchronous para throughput

### AbortPolicy vs CallerRunsPolicy

- **Abort**: Lança exceção, falha rápida
- **CallerRuns**: Executor executa, fallback
- **Escolha**: Abort para críticas, CallerRuns para tolerância

### _Links_

- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ThreadPoolExecutor.html>
- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html>
- <https://docs.oracle.com/javase/tutorial/essential/concurrency/pools.html>
