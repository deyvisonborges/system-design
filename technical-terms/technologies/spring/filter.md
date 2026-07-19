# Filter

Filter é um componente do Servlet API que intercepta requisições e respostas HTTP antes que cheguem ao DispatcherServlet ou após saírem dele, permitindo processamento cross-cutting como autenticação, logging, compressão e modificação de headers.

## Definição

Filter é um componente do Servlet API que intercepta requisições e respostas HTTP antes que cheguem ao DispatcherServlet ou após saírem dele, permitindo processamento cross-cutting como autenticação, logging, compressão e modificação de headers, sendo executado na cadeia de filtros (filter chain).

```text
Filter = Interceptação + Requisição/Resposta + Cross-cutting concerns + Filter chain
```

## Como Funciona

### 1. Ciclo de Vida

```text
- Init: Filter é inicializado
- DoFilter: Requisição é interceptada
- Chain: Próximo filter é chamado
- Response: Resposta é interceptada
- Destroy: Filter é destruído
```

### 2. Cadeia de Filtros

```text
- Request: Requisição chega
- Filter 1: Primeiro filter intercepta
- Filter 2: Segundo filter intercepta
- DispatcherServlet: Requisição chega no servlet
- Response: Resposta retorna
- Filter 2: Segundo filter intercepta resposta
- Filter 1: Primeiro filter intercepta resposta
- Client: Resposta enviada
```

### 3. Tipos

```text
- OncePerRequestFilter: Executa uma vez por requisição
- GenericFilterBean: Filter genérico do Spring
- CharacterEncodingFilter: Configura encoding
- HiddenHttpMethodFilter: Suporta métodos HTTP adicionais
```

## Exemplo Prático

### Filter Básico

```java
@Component
public class LoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        
        System.out.println("Request: " + httpRequest.getMethod() + " " + httpRequest.getRequestURI());
        
        chain.doFilter(request, response);
        
        System.out.println("Response: " + ((HttpServletResponse) response).getStatus());
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("Filter initialized");
    }

    @Override
    public void destroy() {
        System.out.println("Filter destroyed");
    }
}
```

### OncePerRequestFilter

```java
@Component
public class CustomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
            FilterChain filterChain) throws ServletException, IOException {
        System.out.println("Filter executed once per request");
        filterChain.doFilter(request, response);
    }
}
```

### Filter com Ordem

```java
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class FirstFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        System.out.println("First filter");
        chain.doFilter(request, response);
    }
}

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
public class LastFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        System.out.println("Last filter");
        chain.doFilter(request, response);
    }
}
```

### FilterRegistrationBean

```java
@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<LoggingFilter> loggingFilterRegistration() {
        FilterRegistrationBean<LoggingFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new LoggingFilter());
        registration.addUrlPatterns("/api/*");
        registration.setOrder(1);
        return registration;
    }
}
```

### CORS Filter

```java
@Component
public class CorsFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        httpResponse.setHeader("Access-Control-Allow-Origin", "*");
        httpResponse.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        httpResponse.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        chain.doFilter(request, response);
    }
}
```

### Authentication Filter

```java
@Component
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String token = httpRequest.getHeader("Authorization");
        
        if (token == null || !isValidToken(token)) {
            httpResponse.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }
        
        chain.doFilter(request, response);
    }

    private boolean isValidToken(String token) {
        // Validar token
        return true;
    }
}
```

## Comandos Úteis

### Configurar Filter

```java
@Bean
public FilterRegistrationBean<MyFilter> myFilterRegistration() {
    FilterRegistrationBean<MyFilter> registration = new FilterRegistrationBean<>();
    registration.setFilter(new MyFilter());
    registration.addUrlPatterns("/*");
    registration.setOrder(1);
    return registration;
}
```

### Configurar URL Patterns

```java
registration.addUrlPatterns("/api/*");
registration.addUrlPatterns("/public/*");
```

### Configurar Ordem

```java
registration.setOrder(1);
```

## Vantagens

### 1. Interceptação

```text
- Intercepta requisições e respostas
- Cross-cutting concerns
- Reutilizável
```

### 2. Flexibilidade

```text
- Múltiplos filtros
- Ordem configurável
- URL patterns
```

### 3. Padrão

```text
- Padrão Servlet API
- Padronizado
- Bem documentado
```

## Limitações

### 1. Complexidade

```text
- Cadeia de filtros
- Ordem não trivial
- Debugging desafiador
```

### 2. Performance

```text
- Overhead de interceptação
- Múltiplas camadas
- Performance reduzida
```

### 3. Limitações

```text
- Não acessa beans Spring facilmente
- Requer configuração manual
- Menos integrado que Interceptors
```

## Melhores Práticas

### 1. Usar @Component

```java
@Component
public class MyFilter implements Filter {
    // ...
}
```

### 2. Usar OncePerRequestFilter

```java
@Component
public class MyFilter extends OncePerRequestFilter {
    // ...
}
```

### 3. Configurar Ordem

```java
@Component
@Order(1)
public class MyFilter implements Filter {
    // ...
}
```

### 4. Usar FilterRegistrationBean

```java
@Bean
public FilterRegistrationBean<MyFilter> myFilterRegistration() {
    // ...
}
```

## Trade-offs

### Filter vs Interceptor

- **Filter**: Servlet API, antes do DispatcherServlet, cross-cutting
- **Interceptor**: Spring MVC, após DispatcherServlet, específico do Spring
- **Escolha**: Filter para cross-cutting, Interceptor para Spring MVC

### @Component vs FilterRegistrationBean

- **@Component**: Simples, automático
- **FilterRegistrationBean**: Mais controle, manual
- **Escolha**: @Component para simples, FilterRegistrationBean para controle

### OncePerRequestFilter vs Filter

- **OncePerRequestFilter**: Executa uma vez, Spring
- **Filter**: Pode executar múltiplas vezes, Servlet API
- **Escolha**: OncePerRequestFilter para Spring, Filter para padrão

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#filters>
- <https://docs.oracle.com/javaee/7/api/javax/servlet/Filter.html>
- <https://www.baeldung.com/spring-boot-add-filter>
