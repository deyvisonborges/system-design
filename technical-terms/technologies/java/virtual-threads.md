# Virtual Threads

Virtual Threads são threads leves introduzidas no Java 21 (Project Loom) que são gerenciadas pela JVM em vez do SO, permitindo criar milhões de threads com baixo overhead, ideal para aplicações I/O-bound.

## Definição

Virtual Threads são threads leves introduzidas no Java 21 (Project Loom, JEP 444) que são gerenciadas pela JVM em vez do sistema operacional, permitindo criar milhões de threads com baixo overhead de memória e CPU, ideais para aplicações I/O-bound e concorrentes.

```text
Virtual Threads = Threads leves + Gerenciadas pela JVM + Baixo overhead + Escalabilidade
```

## Como Funciona

### 1. Arquitetura

```text
- Virtual Thread: Thread leve gerenciada pela JVM
- Carrier Thread: Thread do SO que executa virtual threads
- Scheduler: Gerencia agendamento de virtual threads
- M:N Model: M virtual threads em N carrier threads
```

### 2. Ciclo de Vida

```text
- Criação: Thread.ofVirtual().start()
- Execução: Executa código como thread normal
- Blocking: Quando bloqueia, libera carrier thread
- Desbloqueio: Retoma execução quando disponível
- Terminação: Completa execução
```

### 3. Agendamento

```text
- FIFO: First In, First Out
- Non-blocking: Não bloqueia carrier thread
- Work-stealing: Carrier threads roubam trabalho
- Yield: Virtual thread pode ceder controle
```

## Exemplo Prático

### Criar Virtual Thread

```java
public class VirtualThreadExample {
    public static void main(String[] args) {
        // Criar e iniciar virtual thread
        Thread vThread = Thread.ofVirtual().start(() -> {
            System.out.println("Virtual thread: " + Thread.currentThread());
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println("Virtual thread completed");
        });

        // Aguardar completion
        try {
            vThread.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

### Executor com Virtual Threads

```java
public class VirtualThreadExecutorExample {
    public static void main(String[] args) throws Exception {
        // Criar executor com virtual threads
        ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

        // Submeter tarefas
        for (int i = 0; i < 100000; i++) {
            executor.submit(() -> {
                System.out.println("Task: " + Thread.currentThread());
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }

        // Shutdown executor
        executor.shutdown();
        executor.awaitTermination(1, TimeUnit.MINUTES);
    }
}
```

### Virtual Thread com Blocking

```java
public class VirtualThreadBlockingExample {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

        // Tarefa com blocking I/O
        executor.submit(() -> {
            try (Socket socket = new Socket("example.com", 80)) {
                // Blocking I/O não bloqueia carrier thread
                InputStream in = socket.getInputStream();
                // Processar dados
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        executor.shutdown();
        executor.awaitTermination(1, TimeUnit.MINUTES);
    }
}
```

### Comparação Platform vs Virtual

```java
public class ComparisonExample {
    public static void main(String[] args) throws Exception {
        long start = System.currentTimeMillis();

        // Platform threads
        try (ExecutorService executor = Executors.newFixedThreadPool(100)) {
            for (int i = 0; i < 10000; i++) {
                executor.submit(() -> {
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                });
            }
        }

        long platformTime = System.currentTimeMillis() - start;
        System.out.println("Platform threads time: " + platformTime + "ms");

        // Virtual threads
        start = System.currentTimeMillis();
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 0; i < 10000; i++) {
                executor.submit(() -> {
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                });
            }
        }

        long virtualTime = System.currentTimeMillis() - start;
        System.out.println("Virtual threads time: " + virtualTime + "ms");
    }
}
```

## Comandos Úteis

### Habilitar Virtual Threads

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

### Monitorar Virtual Threads

```bash
# Ver threads com jcmd
jcmd <pid> Thread.dump_to_file -format=json threads.json

# Ver detalhes de virtual threads
jcmd <pid> VM.native_memory
```

## Vantagens

### 1. Escalabilidade

```text
- Milhões de threads
- Baixo overhead
- Alta concorrência
```

### 2. Simplicidade

```text
- API simples
- Mesmo modelo de programação
- Sem callbacks complexos
```

### 3. Performance

```text
- Melhor para I/O-bound
- Menos context switching
- Melhor utilização de CPU
```

## Limitações

### 1. CPU-bound

```text
- Não ideal para CPU-bound
- Platform threads melhor para CPU
- Overhead para computação intensiva
```

### 2. Java 21+

```text
- Requer Java 21+
- Recurso preview em versões anteriores
- Não disponível em versões antigas
```

### 3. Sincronização

```text
- synchronized bloqueia carrier thread
- Requer usar ReentrantLock
- Pinned virtual threads
```

## Melhores Práticas

### 1. Usar newVirtualThreadPerTaskExecutor

```java
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
```

### 2. Evitar synchronized

```java
// Evitar
synchronized (lock) {
    // Código
}

// Preferir
ReentrantLock lock = new ReentrantLock();
lock.lock();
try {
    // Código
} finally {
    lock.unlock();
}
```

### 3. Usar para I/O-bound

```java
// Ideal para I/O
executor.submit(() -> fetchFromDatabase());

// Não ideal para CPU
executor.submit(() -> heavyComputation());
```

### 4. Monitorar Pinned Threads

```bash
# Ver pinned threads
jcmd <pid> Thread.dump_to_file -format=json threads.json
```

## Trade-offs

### Virtual vs Platform Threads

- **Virtual**: Leves, milhões, I/O-bound
- **Platform**: Pesadas, limitadas, CPU-bound
- **Escolha**: Virtual para I/O, Platform para CPU

### Virtual Threads vs Reactive

- **Virtual**: Síncrono, simples, blocking OK
- **Reactive**: Assíncrono, complexo, non-blocking
- **Escolha**: Virtual para simplicidade, Reactive para performance extrema

### Virtual Threads vs CompletableFuture

- **Virtual**: Threads leves, blocking OK
- **CompletableFuture**: Callbacks, composição
- **Escolha**: Virtual para simplicidade, CompletableFuture para composição

### _Links_

- <https://openjdk.org/jeps/444>
- <https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html>
- <https://inside.java/2022/03/09/loom-performance/>
