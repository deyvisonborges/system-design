# WebFlux

Spring WebFlux é um framework web reativo do Spring que suporta programação reativa com Project Reactor, usando Netty como servidor padrão, permitindo aplicações não-bloqueantes e escaláveis com poucos threads.

## Definição

Spring WebFlux é um framework web reativo do Spring que suporta programação reativa com Project Reactor (Mono e Flux), usando Netty como servidor padrão, permitindo aplicações não-bloqueantes e escaláveis com poucos threads, ideal para I/O-bound e alta concorrência.

```text
WebFlux = Reativo + Não-bloqueante + Project Reactor + Netty + Alta escalabilidade
```

## Como Funciona

### 1. Programação Reativa

```text
- Mono: Stream de 0 ou 1 elemento
- Flux: Stream de 0 a N elementos
- Não-bloqueante: Operações assíncronas
- Backpressure: Controle de fluxo
```

### 2. Servidores

```text
- Netty: Servidor padrão, não-bloqueante
- Tomcat: Suportado, blocking
- Undertow: Suportado, não-bloqueante
- Jetty: Suportado
```

### 3. Anotações

```text
- @RestController: Controller reativo
- @GetMapping: Mapeia GET
- @PostMapping: Mapeia POST
- @RequestMapping: Mapeia geral
```

## Exemplo Prático

### Controller Reativo

```java
@RestController
@RequestMapping("/api/users")
public class UserReactiveController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public Flux<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/{id}")
    public Mono<User> getUser(@PathVariable Long id) {
        return userRepository.findById(id);
    }

    @PostMapping
    public Mono<User> createUser(@RequestBody User user) {
        return userRepository.save(user);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> deleteUser(@PathVariable Long id) {
        return userRepository.deleteById(id);
    }
}
```

### Repository Reativo

```java
public interface UserRepository extends ReactiveCrudRepository<User, Long> {
    // Herda métodos: save, findAll, findById, delete, etc.
    
    Flux<User> findByNomeContaining(String nome);
    
    Mono<User> findByEmail(String email);
}
```

### WebFlux Config

```java
@Configuration
@EnableWebFlux
public class WebFluxConfig implements WebFluxConfigurer {

    @Override
    public void configureHttpMessageCodecs(ServerCodecConfigurer configurer) {
        configurer.defaultCodecs().maxInMemorySize(16 * 1024 * 1024);
    }
}
```

### Functional Endpoints

```java
@Configuration
public class RouterConfig {

    @Bean
    public RouterFunction<ServerResponse> userRouter(UserHandler userHandler) {
        return RouterFunctions.route()
            .GET("/api/users", userHandler::getAllUsers)
            .GET("/api/users/{id}", userHandler::getUser)
            .POST("/api/users", userHandler::createUser)
            .build();
    }

    @Bean
    public UserHandler userHandler(UserRepository userRepository) {
        return new UserHandler(userRepository);
    }
}

@Component
public class UserHandler {

    private final UserRepository userRepository;

    public UserHandler(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public Mono<ServerResponse> getAllUsers(ServerRequest request) {
        return ServerResponse.ok()
            .body(userRepository.findAll(), User.class);
    }

    public Mono<ServerResponse> getUser(ServerRequest request) {
        Long id = Long.parseLong(request.pathVariable("id"));
        return userRepository.findById(id)
            .flatMap(user -> ServerResponse.ok().body(Mono.just(user), User.class))
            .switchIfEmpty(ServerResponse.notFound().build());
    }
}
```

### WebClient

```java
@Service
public class ExternalApiService {

    private final WebClient webClient;

    public ExternalApiService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder
            .baseUrl("https://api.example.com")
            .build();
    }

    public Mono<User> getUser(Long id) {
        return webClient.get()
            .uri("/users/{id}", id)
            .retrieve()
            .bodyToMono(User.class);
    }

    public Flux<User> getAllUsers() {
        return webClient.get()
            .uri("/users")
            .retrieve()
            .bodyToFlux(User.class);
    }
}
```

### Exception Handling

```java
@Configuration
public class WebFluxConfig implements WebFluxConfigurer {

    @Override
    public void configureExceptionHandler(ExceptionHandlerRegistry registry) {
        registry.addHandler(new GlobalExceptionHandler());
    }
}

@Component
public class GlobalExceptionHandler extends AbstractErrorWebExceptionHandler {

    @Override
    protected RouterFunction<ServerResponse> getRoutingFunction(ErrorAttributes errorAttributes) {
        return RouterFunctions.route(RequestPredicates.all(), this::renderErrorResponse);
    }

    private Mono<ServerResponse> renderErrorResponse(ServerRequest request) {
        return ServerResponse.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .bodyValue("Internal Server Error");
    }
}
```

## Comandos Úteis

### Habilitar WebFlux

```java
@Configuration
@EnableWebFlux
public class WebFluxConfig {
    // ...
}
```

### Configurar WebClient

```java
@Bean
public WebClient webClient() {
    return WebClient.builder()
        .baseUrl("https://api.example.com")
        .build();
}
```

### Usar Mono e Flux

```java
Mono<User> userMono = userRepository.findById(id);
Flux<User> userFlux = userRepository.findAll();
```

## Vantagens

### 1. Escalabilidade

```text
- Poucos threads
- Alta concorrência
- Não-bloqueante
```

### 2. Performance

```text
- I/O-bound eficiente
- Backpressure
- Baixo overhead
```

### 3. Reativo

```text
- Programação reativa
- Streams reativos
- Composição
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Debugging desafiador
- Paradigma diferente
```

### 2. Ecosistema

```text
- Menos bibliotecas
- Suporte limitado
- Comunidade menor
```

### 3. CPU-bound

```text
- Não ideal para CPU-bound
- Threads bloqueantes
- Performance reduzida
```

## Melhores Práticas

### 1. Usar Reactive Repositories

```java
public interface UserRepository extends ReactiveCrudRepository<User, Long> {
    // ...
}
```

### 2. Usar WebClient

```java
@Bean
public WebClient webClient() {
    return WebClient.builder().build();
}
```

### 3. Usar Functional Endpoints

```java
@Bean
public RouterFunction<ServerResponse> router() {
    return RouterFunctions.route()
        .GET("/api/users", handler::getAllUsers)
        .build();
}
```

### 4. Usar Netty

```java
@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}
```

## Trade-offs

### WebFlux vs Spring MVC

- **WebFlux**: Reativo, não-bloqueante, escalável
- **Spring MVC**: Blocking, tradicional, simples
- **Escolha**: WebFlux para alta concorrência, Spring MVC para tradicional

### Mono vs Flux

- **Mono**: 0 ou 1 elemento
- **Flux**: 0 a N elementos
- **Escolha**: Mono para único, Flux para múltiplos

### Functional vs Annotated

- **Functional**: Funcional, flexível, complexo
- **Annotated**: Anotado, simples, familiar
- **Escolha**: Annotated para padrão, Functional para avançado

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html>
- <https://projectreactor.io/docs>
- <https://www.baeldung.com/spring-webflux>
