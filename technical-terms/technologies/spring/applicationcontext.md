# ApplicationContext

ApplicationContext é uma extensão do BeanFactory que fornece recursos adicionais como internacionalização, carregamento de recursos, eventos de aplicação e integração com outros módulos do Spring, sendo o container preferido para aplicações Spring.

## Definição

ApplicationContext é uma extensão do BeanFactory que fornece recursos adicionais como internacionalização, carregamento de recursos, eventos de aplicação, integração com outros módulos do Spring e eager loading de beans, sendo o container preferido para aplicações Spring completas.

```text
ApplicationContext = BeanFactory + Recursos adicionais + Eventos + Internacionalização
```

## Como Funciona

### 1. Recursos Adicionais

```text
- Internacionalização: Suporte a múltiplos idiomas
- Carregamento de recursos: Acesso a arquivos de recursos
- Eventos de aplicação: Publicação e consumo de eventos
- Integração: Integração com outros módulos Spring
- Eager loading: Beans carregados na inicialização
```

### 2. Implementações

```text
- AnnotationConfigApplicationContext: Configuração via anotações
- ClassPathXmlApplicationContext: Configuração via XML no classpath
- FileSystemXmlApplicationContext: Configuração via XML no filesystem
- WebApplicationContext: Contexto para aplicações web
```

### 3. Hierarquia

```text
- ApplicationContext: Contexto raiz
- WebApplicationContext: Contexto web
- Hierarquia múltipla: Contextos pai e filho
```

## Exemplo Prático

### AnnotationConfigApplicationContext

```java
public class ApplicationContextExample {
    public static void main(String[] args) {
        // Criar contexto via anotações
        ApplicationContext context = 
            new AnnotationConfigApplicationContext(AppConfig.class);

        // Obter bean
        MyService service = context.getBean(MyService.class);
        service.doSomething();

        // Fechar contexto
        ((AnnotationConfigApplicationContext) context).close();
    }
}

@Configuration
@ComponentScan
class AppConfig {
    // Configuração
}
```

### ClassPathXmlApplicationContext

```java
public class XmlContextExample {
    public static void main(String[] args) {
        // Criar contexto via XML
        ApplicationContext context = 
            new ClassPathXmlApplicationContext("applicationContext.xml");

        // Obter bean
        MyService service = context.getBean(MyService.class);
        service.doSomething();

        // Fechar contexto
        ((ClassPathXmlApplicationContext) context).close();
    }
}
```

### applicationContext.xml

```xml
<beans xmlns="http://www.springframework.org/schema/beans">
    <bean id="myService" class="com.example.MyService"/>
</beans>
```

### Internacionalização

```java
public class I18nExample {
    public static void main(String[] args) {
        ApplicationContext context = 
            new AnnotationConfigApplicationContext(AppConfig.class);

        // Obter mensagem em português
        String message = context.getMessage("welcome", null, Locale.getDefault());
        System.out.println(message);

        // Obter mensagem em inglês
        String messageEn = context.getMessage("welcome", null, Locale.ENGLISH);
        System.out.println(messageEn);
    }
}
```

### messages.properties

```properties
welcome=Bem-vindo
```

### messages_en.properties

```properties
welcome=Welcome
```

### Eventos de Aplicação

```java
@Component
public class CustomEventPublisher implements ApplicationEventPublisherAware {
    
    private ApplicationEventPublisher publisher;

    @Override
    public void setApplicationEventPublisher(ApplicationEventPublisher publisher) {
        this.publisher = publisher;
    }

    public void publishEvent() {
        publisher.publishEvent(new CustomEvent("Custom event"));
    }
}

@Component
public class CustomEventListener {
    
    @EventListener
    public void handleCustomEvent(CustomEvent event) {
        System.out.println("Event received: " + event.getMessage());
    }
}

class CustomEvent extends ApplicationEvent {
    private final String message;

    public CustomEvent(String message) {
        super(message);
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
```

### Carregamento de Recursos

```java
public class ResourceExample {
    public static void main(String[] args) throws IOException {
        ApplicationContext context = 
            new AnnotationConfigApplicationContext(AppConfig.class);

        // Carregar recurso do classpath
        Resource resource = context.getResource("classpath:config.properties");
        
        // Carregar recurso do filesystem
        Resource fileResource = context.getResource("file:/path/to/file.txt");
        
        // Ler conteúdo
        try (InputStream in = resource.getInputStream()) {
            Properties props = new Properties();
            props.load(in);
        }
    }
}
```

### Hierarquia de Contextos

```java
public class HierarchyExample {
    public static void main(String[] args) {
        // Contexto pai
        ApplicationContext parentContext = 
            new AnnotationConfigApplicationContext(ParentConfig.class);

        // Contexto filho
        AnnotationConfigApplicationContext childContext = 
            new AnnotationConfigApplicationContext();
        childContext.setParent(parentContext);
        childContext.register(ChildConfig.class);
        childContext.refresh();

        // Beans do contexto filho podem acessar beans do pai
        MyService service = childContext.getBean(MyService.class);
    }
}
```

## Comandos Úteis

### Obter Beans

```java
// Por tipo
MyService service = context.getBean(MyService.class);

// Por nome
MyService service = (MyService) context.getBean("myService");

// Por nome e tipo
MyService service = context.getBean("myService", MyService.class);

// Todos os beans de um tipo
Map<String, MyService> beans = context.getBeansOfType(MyService.class);
```

### Internacionalização de Mensagens

```java
// Obter mensagem
String message = context.getMessage("key", null, Locale.getDefault());

// Obter mensagem com parâmetros
String message = context.getMessage("key", new Object[]{"param"}, Locale.getDefault());

// Obter mensagem com default
String message = context.getMessage("key", null, "default", Locale.getDefault());
```

### Recursos

```java
// Carregar recurso do classpath
Resource resource = context.getResource("classpath:file.txt");

// Carregar recurso do filesystem
Resource resource = context.getResource("file:/path/to/file.txt");

// Carregar recurso de URL
Resource resource = context.getResource("https://example.com/file.txt");
```

## Vantagens

### 1. Recursos Adicionais Avançados

```text
- Internacionalização
- Carregamento de recursos
- Eventos de aplicação
```

### 2. Integração

```text
- Integração com outros módulos
- Suporte a AOP
- Suporte a transações
```

### 3. Eager Loading

```text
- Beans carregados na inicialização
- Erros detectados cedo
- Beans prontos para uso
```

## Limitações

### 1. Overhead

```text
- Mais overhead que BeanFactory
- Startup mais lento
- Memória extra
```

### 2. Complexidade

```text
- Mais recursos
- Curva de aprendizado
- Configuração mais complexa
```

### 3. Eager Loading de Beans

```text
- Todos os beans carregados
- Startup mais lento
- Não ideal para todos os casos
```

## Melhores Práticas

### 1. Usar ApplicationContext

```java
// Preferir ApplicationContext para aplicações completas
ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
```

### 2. Usar Anotações

```java
@Configuration
@ComponentScan
public class AppConfig {
    // Configuração
}
```

### 3. Usar Eventos

```java
@EventListener
public void handleEvent(CustomEvent event) {
    // Tratar evento
}
```

### 4. Fechar Contexto

```java
context.close();
```

## Trade-offs

### ApplicationContext vs BeanFactory

- **ApplicationContext**: Rico, eager loading, completo
- **BeanFactory**: Leve, lazy loading, básico
- **Escolha**: ApplicationContext para produção, BeanFactory para testes

### AnnotationConfig vs XML

- **AnnotationConfig**: Moderno, type-safe
- **XML**: Legado, verboso
- **Escolha**: AnnotationConfig para novos projetos

### Hierarquia vs Contexto Único

- **Hierarquia**: Múltiplos contextos, isolamento
- **Único**: Um contexto, simples
- **Escolha**: Hierarquia para modular, único para simples

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-context>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html>
- <https://www.baeldung.com/spring-applicationcontext>
