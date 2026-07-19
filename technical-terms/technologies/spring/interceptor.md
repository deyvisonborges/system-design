# Interceptor

Interceptor é um componente do Spring MVC que intercepta requisições HTTP após passarem pelo DispatcherServlet, permitindo processamento cross-cutting como logging, autenticação e modificação de handlers, sendo executado antes e após a execução do controller.

## Definição

Interceptor é um componente do Spring MVC que intercepta requisições HTTP após passarem pelo DispatcherServlet, permitindo processamento cross-cutting como logging, autenticação e modificação de handlers, sendo executado antes e após a execução do controller através da interface HandlerInterceptor.

```text
Interceptor = HandlerInterceptor + Pre/Post processing + Spring MVC + Cross-cutting
```

## Como Funciona

### 1. Ciclo de Vida

```text
- preHandle: Executado antes do handler
- Handler: Controller é executado
- postHandle: Executado após handler, antes da view
- afterCompletion: Executado após renderização da view
```

### 2. Métodos

```text
- preHandle: Pré-processamento, return true para continuar
- postHandle: Pós-processamento, pode modificar ModelAndView
- afterCompletion: Cleanup, executado mesmo após exceção
```

### 3. Registro

```text
- WebMvcConfigurer: Interface para configurar interceptors
- addInterceptors: Adiciona interceptors ao registry
- InterceptorRegistry: Registry de interceptors
```

## Exemplo Prático

### Interceptor Básico

```java
@Component
public class LoggingInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) 
            throws Exception {
        System.out.println("Pre-handle: " + request.getRequestURI());
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, 
            ModelAndView modelAndView) throws Exception {
        System.out.println("Post-handle: " + request.getRequestURI());
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, 
            Exception ex) throws Exception {
        System.out.println("After-completion: " + request.getRequestURI());
    }
}
```

### Configurar Interceptor

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private LoggingInterceptor loggingInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loggingInterceptor)
            .addPathPatterns("/**")
            .excludePathPatterns("/public/**");
    }
}
```

### Interceptor com Ordem

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new FirstInterceptor())
            .order(1)
            .addPathPatterns("/**");
        
        registry.addInterceptor(new SecondInterceptor())
            .order(2)
            .addPathPatterns("/api/**");
    }
}
```

### Authentication Interceptor

```java
@Component
public class AuthenticationInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) 
            throws Exception {
        String token = request.getHeader("Authorization");
        
        if (token == null || !isValidToken(token)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return false;
        }
        
        return true;
    }

    private boolean isValidToken(String token) {
        // Validar token
        return true;
    }
}
```

### Performance Interceptor

```java
@Component
public class PerformanceInterceptor implements HandlerInterceptor {

    private static final ThreadLocal<Long> startTime = new ThreadLocal<>();

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) 
            throws Exception {
        startTime.set(System.currentTimeMillis());
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, 
            Exception ex) throws Exception {
        long duration = System.currentTimeMillis() - startTime.get();
        System.out.println("Request took: " + duration + "ms");
        startTime.remove();
    }
}
```

### Interceptor com HandlerMethod

```java
@Component
public class MethodInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) 
            throws Exception {
        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            System.out.println("Method: " + handlerMethod.getMethod().getName());
        }
        return true;
    }
}
```

## Comandos Úteis

### Adicionar Interceptor

```java
@Override
public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new MyInterceptor());
}
```

### Configurar Path Patterns

```java
registry.addInterceptor(new MyInterceptor())
    .addPathPatterns("/api/**")
    .excludePathPatterns("/public/**");
```

### Configurar Ordem

```java
registry.addInterceptor(new MyInterceptor())
    .order(1);
```

## Vantagens

### 1. Spring MVC

```text
- Integrado ao Spring MVC
- Acesso a ModelAndView
- Acesso a HandlerMethod
```

### 2. Flexibilidade

```text
- Path patterns configuráveis
- Ordem configurável
- Exclusão de paths
```

### 3. Contexto

```text
- Acesso a beans Spring
- Acesso ao contexto
- Injeção de dependências
```

## Limitações

### 1. Limitação do Spring MVC

```text
- Apenas Spring MVC
- Não funciona com WebFlux
- Específico do Spring
```

### 2. DispatcherServlet

```text
- Após DispatcherServlet
- Não intercepta antes do servlet
- Menos abrangente que Filter
```

### 3. Complexidade

```text
- Múltiplos interceptors
- Ordem não trivial
- Debugging desafiador
```

## Melhores Práticas

### 1. Usar @Component

```java
@Component
public class MyInterceptor implements HandlerInterceptor {
    // ...
}
```

### 2. Configurar Path Patterns

```java
registry.addInterceptor(new MyInterceptor())
    .addPathPatterns("/api/**")
    .excludePathPatterns("/public/**");
```

### 3. Configurar Ordem

```java
registry.addInterceptor(new MyInterceptor())
    .order(1);
```

### 4. Usar WebMvcConfigurer

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // ...
}
```

## Trade-offs

### Interceptor vs Filter

- **Interceptor**: Spring MVC, após DispatcherServlet, acesso a ModelAndView
- **Filter**: Servlet API, antes do DispatcherServlet, cross-cutting
- **Escolha**: Interceptor para Spring MVC, Filter para cross-cutting

### preHandle vs postHandle

- **preHandle**: Antes do handler, pode bloquear
- **postHandle**: Após handler, pode modificar ModelAndView
- **Escolha**: preHandle para validação, postHandle para modificação

### addPathPatterns vs excludePathPatterns

- **addPathPatterns**: Inclui paths
- **excludePathPatterns**: Exclui paths
- **Escolha**: addPathPatterns para inclusão, excludePathPatterns para exclusão

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-interceptors>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/servlet/HandlerInterceptor.html>
- <https://www.baeldung.com/spring-mvc-handlerinterceptor>
