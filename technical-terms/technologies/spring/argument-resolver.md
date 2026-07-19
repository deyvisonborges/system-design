# Argument Resolver

Argument Resolver é um componente do Spring MVC que converte parâmetros de requisição HTTP em argumentos de métodos de controller, permitindo customização da resolução de parâmetros como path variables, request parameters, headers e bodies.

## Definição

Argument Resolver é um componente do Spring MVC que converte parâmetros de requisição HTTP em argumentos de métodos de controller através da interface HandlerMethodArgumentResolver, permitindo customização da resolução de parâmetros como path variables, request parameters, headers e bodies, simplificando o código dos controllers.

```text
Argument Resolver = HandlerMethodArgumentResolver + Resolução de parâmetros + Customização + Controllers
```

## Como Funciona

### 1. Interface

```text
- supportsParameter: Verifica se suporta o parâmetro
- resolveArgument: Resolve o valor do parâmetro
- WebDataBinder: Binding de dados
- ConversionService: Conversão de tipos
```

### 2. Tipos

```text
- @PathVariable: Variável de path
- @RequestParam: Parâmetro de request
- @RequestHeader: Header HTTP
- @RequestBody: Corpo da requisição
- Custom: Argument resolver customizado
```

### 3. Registro

```text
- WebMvcConfigurer: Interface para configurar resolvers
- addArgumentResolvers: Adiciona resolvers customizados
- ArgumentResolverRegistry: Registry de resolvers
```

## Exemplo Prático

### Argument Resolver Customizado

```java
public class UserArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.getParameterAnnotation(CurrentUser.class) != null;
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest, WebDataBinder binder) throws Exception {
        HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);
        String token = request.getHeader("Authorization");
        
        if (token != null) {
            return userService.getUserFromToken(token);
        }
        
        return null;
    }
}
```

### Anotação Customizada

```java
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface CurrentUser {
}
```

### Controller com Argument Resolver

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/profile")
    public User getProfile(@CurrentUser User user) {
        return user;
    }
}
```

### Configurar Argument Resolver

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private UserArgumentResolver userArgumentResolver;

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(userArgumentResolver);
    }
}
```

### Path Variable Resolver

```java
public class CustomPathVariableResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(PathVariable.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest, WebDataBinder binder) throws Exception {
        // Resolução customizada de path variable
        return null;
    }
}
```

### Request Body Resolver

```java
public class CustomRequestBodyResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(RequestBody.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest, WebDataBinder binder) throws Exception {
        // Resolução customizada de request body
        return null;
    }
}
```

## Comandos Úteis

### Adicionar Argument Resolver

```java
@Override
public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
    resolvers.add(new MyArgumentResolver());
}
```

### Configurar Ordem

```java
@Override
public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
    resolvers.add(0, new MyArgumentResolver());  // Primeiro
}
```

### Verificar Suporte

```java
@Override
public boolean supportsParameter(MethodParameter parameter) {
    return parameter.getParameterAnnotation(MyAnnotation.class) != null;
}
```

## Vantagens

### 1. Customização

```text
- Resolução customizada
- Lógica reutilizável
- Código limpo
```

### 2. Controllers

```text
- Controllers mais limpos
- Menos boilerplate
- Foco na lógica
```

### 3. Flexibilidade

```text
- Múltiplos resolvers
- Ordem configurável
- Extensível
```

## Limitações

### 1. Complexidade

```text
- Implementação complexa
- Curva de aprendizado
- Debugging desafiador
```

### 2. Performance

```text
- Overhead de resolução
- Múltiplas conversões
- Performance reduzida
```

### 3. Limitações

```text
- Apenas Spring MVC
- Não funciona com WebFlux
- Específico do Spring
```

## Melhores Práticas

### 1. Usar Anotações Customizadas

```java
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface CurrentUser {
}
```

### 2. Implementar supportsParameter

```java
@Override
public boolean supportsParameter(MethodParameter parameter) {
    return parameter.getParameterAnnotation(CurrentUser.class) != null;
}
```

### 3. Usar WebMvcConfigurer

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // ...
}
```

### 4. Configurar Ordem

```java
@Override
public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
    resolvers.add(0, new MyArgumentResolver());
}
```

## Trade-offs

### Custom vs Built-in

- **Custom**: Flexível, específico
- **Built-in**: Padrão, simples
- **Escolha**: Built-in para padrão, custom para específico

### Argument Resolver vs Filter

- **Argument Resolver**: Parâmetros de controller, Spring MVC
- **Filter**: Requisição/Resposta, Servlet API
- **Escolha**: Argument Resolver para parâmetros, Filter para cross-cutting

### @PathVariable vs Custom Resolver

- **@PathVariable**: Padrão, simples
- **Custom**: Flexível, complexo
- **Escolha**: @PathVariable para padrão, custom para específico

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-ann-arguments>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/method/HandlerMethodArgumentResolver.html>
- <https://www.baeldung.com/spring-mvc-custom-argument-resolver>
