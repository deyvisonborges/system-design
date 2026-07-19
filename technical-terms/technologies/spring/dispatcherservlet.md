# DispatcherServlet

DispatcherServlet é o front controller central do Spring MVC que recebe todas as requisições HTTP, as delega para handlers apropriados, coordena o processamento e retorna a resposta, sendo o ponto de entrada principal para aplicações web Spring.

## Definição

DispatcherServlet é o front controller central do Spring MVC que recebe todas as requisições HTTP, as delega para handlers apropriados através de HandlerMapping, coordena o processamento com HandlerAdapter, ViewResolver e View, e retorna a resposta HTTP, sendo o ponto de entrada principal para aplicações web Spring.

```text
DispatcherServlet = Front controller + HandlerMapping + HandlerAdapter + ViewResolver + View
```

## Como Funciona

### 1. Ciclo de Vida

```text
- Init: Servlet é inicializado
- Request: Requisição HTTP chega
- Process: Requisição é processada
- Response: Resposta HTTP enviada
- Destroy: Servlet é destruído
```

### 2. Processamento

```text
- Request: Requisição chega no DispatcherServlet
- HandlerMapping: Mapeia URL para handler
- HandlerAdapter: Adapta handler para execução
- Controller: Processa requisição
- ViewResolver: Resolve view
- View: Renderiza resposta
- Response: Resposta enviada
```

### 3. Componentes

```text
- HandlerMapping: Mapeamento de URLs
- HandlerAdapter: Adaptação de handlers
- ViewResolver: Resolução de views
- View: Renderização
- LocaleResolver: Resolução de locale
- ThemeResolver: Resolução de tema
```

## Exemplo Prático

### Configuração Básica

```java
public class MyWebInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class<?>[]{RootConfig.class};
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[]{WebConfig.class};
    }

    @Override
    protected String[] getServletMappings() {
        return new String[]{"/"};
    }
}
```

### Configuração XML

```xml
<web-app>
    <servlet>
        <servlet-name>dispatcher</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/spring-mvc.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatcher</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```

### Configuração Spring Boot

```java
@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}

// Spring Boot configura DispatcherServlet automaticamente
```

### Customizar DispatcherServlet

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Bean
    public DispatcherServlet dispatcherServlet(WebApplicationContext webApplicationContext) {
        return new DispatcherServlet(webApplicationContext);
    }

    @Bean
    public ServletRegistrationBean<DispatcherServlet> dispatcherServletRegistration(
            DispatcherServlet dispatcherServlet) {
        ServletRegistrationBean<DispatcherServlet> registration = new ServletRegistrationBean<>();
        registration.setServlet(dispatcherServlet);
        registration.addUrlMappings("/");
        registration.setLoadOnStartup(1);
        return registration;
    }
}
```

### HandlerMapping Customizado

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoggingInterceptor());
    }
}
```

### Exception Resolver

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void configureHandlerExceptionResolvers(List<HandlerExceptionResolver> resolvers) {
        resolvers.add(new CustomExceptionResolver());
    }
}
```

## Comandos Úteis

### Configurar Mapeamento

```java
@Override
protected String[] getServletMappings() {
    return new String[]{"/"};
}
```

### Configurar Load-on-Startup

```java
@Override
protected void customizeRegistration(ServletRegistration.Dynamic registration) {
    registration.setLoadOnStartup(1);
}
```

### Configurar Init Parameters

```java
@Override
protected void customizeRegistration(ServletRegistration.Dynamic registration) {
    registration.setInitParameter("contextConfigLocation", "/WEB-INF/spring-mvc.xml");
}
```

## Vantagens

### 1. Centralização

```text
- Ponto único de entrada
- Controle centralizado
- Consistência
```

### 2. Flexibilidade

```text
- Configuração customizada
- Múltiplos handlers
- Extensível
```

### 3. Integração

```text
- Integração com Spring
- Suporte a múltiplas views
- Fácil configuração
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
- Múltiplas configurações
- Boilerplate
```

## Melhores Práticas

### 1. Usar Spring Boot

```java
@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}
```

### 2. Configurar Mapeamento Adequado

```java
@Override
protected String[] getServletMappings() {
    return new String[]{"/"};
}
```

### 3. Usar WebMvcConfigurer

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // ...
}
```

### 4. Customizar Quando Necessário

```java
@Bean
public DispatcherServlet dispatcherServlet(WebApplicationContext webApplicationContext) {
    return new DispatcherServlet(webApplicationContext);
}
```

## Trade-offs

### DispatcherServlet vs Custom Servlet

- **DispatcherServlet**: Padrão Spring, completo
- **Custom**: Flexível, mais trabalho
- **Escolha**: DispatcherServlet para padrão, custom para específico

### XML vs Java Config

- **XML**: Legado, verboso
- **Java**: Moderno, type-safe
- **Escolha**: Java config para novos projetos

### Spring Boot vs Manual

- **Spring Boot**: Auto-configuração, simples
- **Manual**: Controle total, complexo
- **Escolha**: Spring Boot para novos projetos

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-servlet>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/servlet/DispatcherServlet.html>
- <https://www.baeldung.com/spring-dispatcher-servlet>
