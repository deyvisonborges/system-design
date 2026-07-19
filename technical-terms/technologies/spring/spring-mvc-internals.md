# Spring MVC Internals

Spring MVC Internals é o framework web do Spring que implementa o padrão MVC (Model-View-Controller), usando DispatcherServlet, HandlerMapping, Controller, ViewResolver e View para processar requisições HTTP e gerar respostas.

## Definição

Spring MVC Internals é o framework web do Spring que implementa o padrão MVC (Model-View-Controller), usando DispatcherServlet como front controller, HandlerMapping para roteamento, Controller para lógica de negócio, ViewResolver para resolução de views e View para renderização, processando requisições HTTP e gerando respostas.

```text
Spring MVC = DispatcherServlet + HandlerMapping + Controller + ViewResolver + View
```

## Como Funciona

### 1. Fluxo

```text
- Request: Requisição HTTP chega
- DispatcherServlet: Front controller recebe
- HandlerMapping: Mapeia para controller
- Controller: Processa requisição
- ViewResolver: Resolve view
- View: Renderiza resposta
- Response: Resposta HTTP enviada
```

### 2. Componentes

```text
- DispatcherServlet: Front controller
- HandlerMapping: Mapeamento de URLs
- Controller: Lógica de negócio
- ViewResolver: Resolução de views
- View: Renderização
```

### 3. Anotações

```text
- @Controller: Marca classe como controller
- @RequestMapping: Mapeia URL
- @GetMapping: Mapeia GET
- @PostMapping: Mapeia POST
- @ResponseBody: Retorna JSON
```

## Exemplo Prático

### Controller Básico

```java
@Controller
@RequestMapping("/users")
public class UserController {

    @GetMapping
    public String listUsers(Model model) {
        model.addAttribute("users", userService.findAll());
        return "users/list";
    }

    @GetMapping("/{id}")
    public String getUser(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.findById(id));
        return "users/detail";
    }

    @PostMapping
    public String createUser(@ModelAttribute User user) {
        userService.save(user);
        return "redirect:/users";
    }
}
```

### REST Controller

```java
@RestController
@RequestMapping("/api/users")
public class UserRestController {

    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }

    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }

    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

### HandlerMapping Customizado

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/").setViewName("home");
        registry.addViewController("/login").setViewName("login");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")
            .addResourceLocations("classpath:/static/");
    }
}
```

### ViewResolver Customizado

```java
@Configuration
public class ViewResolverConfig {

    @Bean
    public ViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setPrefix("/WEB-INF/views/");
        resolver.setSuffix(".jsp");
        return resolver;
    }
}
```

### Exception Handler

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<String> handleUserNotFound(UserNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal error");
    }
}
```

## Comandos Úteis

### Habilitar Spring MVC

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {
    // Configuração
}
```

### Configurar ViewResolver

```java
@Bean
public ViewResolver viewResolver() {
    InternalResourceViewResolver resolver = new InternalResourceViewResolver();
    resolver.setPrefix("/WEB-INF/views/");
    resolver.setSuffix(".jsp");
    return resolver;
}
```

### Configurar Resource Handlers

```java
@Override
public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry.addResourceHandler("/static/**")
        .addResourceLocations("classpath:/static/");
}
```

## Vantagens

### 1. Padrão MVC

```text
- Separação de concerns
- Organização clara
- Manutenibilidade
```

### 2. Flexibilidade

```text
- Múltiplas views
- Configuração customizada
- Extensível
```

### 3. Integração

```text
- Integração com Spring
- Suporte a REST
- Validação
```

## Limitações

### 1. Complexidade

```text
- Múltiplos componentes
- Configuração complexa
- Curva de aprendizado
```

### 2. Performance

```text
- Overhead de framework
- Múltiplas camadas
- Performance reduzida
```

### 3. Verbosidade

```text
- Muito código
- Múltiplas anotações
- Boilerplate
```

## Melhores Práticas

### 1. Usar @RestController para APIs

```java
@RestController
@RequestMapping("/api/users")
public class UserRestController {
    // ...
}
```

### 2. Usar @Controller para Views

```java
@Controller
@RequestMapping("/users")
public class UserController {
    // ...
}
```

### 3. Usar @ControllerAdvice para Exceções

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    // ...
}
```

### 4. Usar WebMvcConfigurer para Configuração

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // ...
}
```

## Trade-offs

### @Controller vs @RestController

- **@Controller**: Retorna views, HTML
- **@RestController**: Retorna JSON, APIs
- **Escolha**: @Controller para web, @RestController para APIs

### JSP vs Thymeleaf

- **JSP**: Legado, verboso
- **Thymeleaf**: Moderno, natural templates
- **Escolha**: Thymeleaf para novos projetos

### XML vs Java Config

- **XML**: Legado, verboso
- **Java**: Moderno, type-safe
- **Escolha**: Java config para novos projetos

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/servlet/DispatcherServlet.html>
- <https://www.baeldung.com/spring-mvc>
