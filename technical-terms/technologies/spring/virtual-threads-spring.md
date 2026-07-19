# Virtual Threads Spring

Virtual Threads Spring é o suporte a Virtual Threads no Spring Framework, permitindo aplicações Spring Boot usar virtual threads para melhorar escalabilidade e throughput, especialmente em aplicações I/O-bound.

## Definição

Virtual Threads Spring é o suporte a Virtual Threads no Spring Framework, permitindo aplicações Spring Boot usar virtual threads (Project Loom) para melhorar escalabilidade e throughput, especialmente em aplicações I/O-bound, com suporte em Spring MVC, WebFlux e componentes assíncronos.

```text
Virtual Threads Spring = Virtual Threads + Spring Boot + Escalabilidade + I/O-bound + Throughput
```

## Como Funciona

### 1. Habilitação

```text
- Java 21+: Requer Java 21 ou superior
- Spring Boot 3.2+: Suporte nativo
- Configuração: Habilitar virtual threads
- Executor: ThreadPoolExecutor virtual
```

### 2. Componentes

```text
- Spring MVC: Suporte a virtual threads
- WebFlux: Suporte a virtual threads
- @Async: Suporte a virtual threads
- WebClient: Suporte a virtual threads
```

### 3. Benefícios

```text
- Escalabilidade: Milhões de threads
- Throughput: Maior throughput
- Simplicidade: Código síncrono
- I/O-bound: Ideal para I/O
```

## Exemplo Prático

### Habilitar Virtual Threads

```java
@Configuration
public class VirtualThreadConfig {

    @Bean
    public Executor taskExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }
}
```

### application.properties

```properties
# Habilitar virtual threads
spring.threads.virtual.enabled=true

# Configurar virtual thread executor
spring.task.execution.pool.core-size=1
spring.task.execution.pool.max-size=1
spring.task.execution.pool.queue-capacity=100
spring.task.execution.thread-name-prefix=virtual-
```

### @Async com Virtual Threads

```java
@Service
public class AsyncService {

    @Async
    public CompletableFuture<String> asyncMethod() {
        // Executado em virtual thread
        return CompletableFuture.completedFuture("Result");
    }
}
```

### Controller com Virtual Threads

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public CompletableFuture<User> getUser(@PathVariable Long id) {
        // Executado em virtual thread
        return userService.findByIdAsync(id);
    }
}
```

### WebClient com Virtual Threads

```java
@Configuration
public class WebClientConfig {

    @Bean
    public WebClient webClient(Executor taskExecutor) {
        return WebClient.builder()
            .clientConnector(new ReactorClientHttpConnector(
                HttpClient.create()
                    .executor((Runnable task) -> taskExecutor.execute(task))
            ))
            .build();
    }
}
```

### JPA com Virtual Threads

```java
@Configuration
public class JpaConfig {

    @Bean
    public Executor taskExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }

    @Bean
    public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager(entityManagerFactory);
        transactionManager.setAsyncTaskExecutor(taskExecutor());
        return transactionManager;
    }
}
```

### Custom Virtual Thread Executor

```java
@Configuration
public class CustomVirtualThreadConfig {

    @Bean
    public Executor customVirtualThreadExecutor() {
        ThreadFactory factory = Thread.ofVirtual()
            .name("custom-virtual-")
            .factory();
        
        return new ThreadPoolExecutor(
            1, 1,
            0L, TimeUnit.MILLISECONDS,
            new LinkedBlockingQueue<>(),
            factory
        );
    }
}
```

## Comandos Úteis

### Habilitar Virtual Threads via Properties

```properties
spring.threads.virtual.enabled=true
```

### Criar Virtual Thread Executor

```java
Executor executor = Executors.newVirtualThreadPerTaskExecutor();
```

### Usar @Async

```java
@Async
public CompletableFuture<String> asyncMethod() {
    // ...
}
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
- Código síncrono
- Fácil de entender
- Menos complexidade
```

### 3. Performance

```text
- Maior throughput
- I/O-bound eficiente
- Melhor utilização
```

## Limitações

### 1. CPU-bound

```text
- Não ideal para CPU-bound
- Threads bloqueantes
- Performance reduzida
```

### 2. Compatibilidade

```text
- Requer Java 21+
- Requer Spring Boot 3.2+
- Bibliotecas incompatíveis
```

### 3. Debugging

```text
- Debugging desafiador
- Ferramentas limitadas
- Curva de aprendizado
```

## Melhores Práticas

### 1. Usar para I/O-bound

```java
@Async
public CompletableFuture<String> asyncIoOperation() {
    // I/O-bound operation
}
```

### 2. Evitar CPU-bound

```java
// Não usar virtual threads para CPU-bound
public void cpuBoundOperation() {
    // Use platform threads
}
```

### 3. Usar com Spring MVC

```java
@GetMapping("/api/users/{id}")
public CompletableFuture<User> getUser(@PathVariable Long id) {
    // Virtual thread
}
```

### 4. Configurar Executor

```java
@Bean
public Executor taskExecutor() {
    return Executors.newVirtualThreadPerTaskExecutor();
}
```

## Trade-offs

### Virtual vs Platform Threads

- **Virtual**: Leve, escalável, I/O-bound
- **Platform**: Pesado, limitado, CPU-bound
- **Escolha**: Virtual para I/O-bound, Platform para CPU-bound

### Virtual Threads vs WebFlux

- **Virtual Threads**: Síncrono, simples, blocking
- **WebFlux**: Reativo, complexo, non-blocking
- **Escolha**: Virtual threads para simplicidade, WebFlux para reativo

### @Async vs Virtual Threads

- **@Async**: Assíncrono tradicional, platform threads
- **Virtual Threads**: Assíncrono moderno, virtual threads
- **Escolha**: @Async com virtual threads para melhor performance

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#threads>
- <https://openjdk.org/jeps/444>
- <https://www.baeldung.com/spring-boot-virtual-threads>
