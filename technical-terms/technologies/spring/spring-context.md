# Spring Context

Spring Context é o container central do Spring Framework que gerencia o ciclo de vida de beans, fornece injeção de dependências, resolução de recursos e configuração, sendo a implementação principal do padrão IoC (Inversion of Control).

## Definição

Spring Context é o container central do Spring Framework que implementa o padrão IoC (Inversion of Control), gerenciando o ciclo de vida de beans, fornecendo injeção de dependências, resolução de recursos, configuração e integração com outros módulos do Spring.

```text
Spring Context = IoC Container + DI + Gerenciamento de beans + Configuração
```

## Como Funciona

### 1. Componentes

```text
- BeanFactory: Interface base para containers
- ApplicationContext: Extensão com recursos adicionais
- BeanDefinition: Definição de bean
- BeanPostProcessor: Processamento de beans
- Environment: Configuração de ambiente
```

### 2. Ciclo de Vida

```text
- Instanciação: Bean é criado
- Propriedades: Dependências injetadas
- BeanNameAware: Nome do bean é setado
- BeanFactoryAware: BeanFactory é setado
- ApplicationContextAware: ApplicationContext é setado
- BeanPostProcessor: Pré-processamento
- InitializingBean: Inicialização
- Custom init: Método init customizado
- BeanPostProcessor: Pós-processamento
- Ready: Bean pronto para uso
- Destruction: Bean é destruído
```

### 3. Tipos de Context

```text
- AnnotationConfigApplicationContext: Configuração via anotações
- ClassPathXmlApplicationContext: Configuração via XML
- FileSystemXmlApplicationContext: Configuração via XML no filesystem
- WebApplicationContext: Contexto para aplicações web
```

## Exemplo Prático

### AnnotationConfigApplicationContext

```java
public class SpringContextExample {
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
class AppConfig {
    @Bean
    public MyService myService() {
        return new MyService();
    }
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

### Bean Lifecycle

```java
@Component
public class LifecycleBean implements InitializingBean, DisposableBean {
    
    @Autowired
    private ApplicationContext context;

    @PostConstruct
    public void postConstruct() {
        System.out.println("PostConstruct");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("afterPropertiesSet");
    }

    @PreDestroy
    public void preDestroy() {
        System.out.println("PreDestroy");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("destroy");
    }
}
```

### BeanPostProcessor

```java
@Component
public class CustomBeanPostProcessor implements BeanPostProcessor {
    
    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) {
        System.out.println("Before init: " + beanName);
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) {
        System.out.println("After init: " + beanName);
        return bean;
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

### Verificar Beans

```java
// Verificar se bean existe
boolean exists = context.containsBean("myService");

// Verificar se é singleton
boolean isSingleton = context.isSingleton("myService");

// Verificar se é prototype
boolean isPrototype = context.isPrototype("myService");
```

## Vantagens

### 1. IoC e DI

```text
- Inversão de controle
- Injeção de dependências
- Desacoplamento
```

### 2. Gerenciamento

```text
- Ciclo de vida automático
- Configuração centralizada
- Escopos de beans
```

### 3. Integração

```text
- Integração com outros módulos
- Suporte a AOP
- Eventos e listeners
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Muitas opções
- Debugging desafiador
```

### 2. Performance

```text
- Startup mais lento
- Overhead de reflexão
- Memória extra
```

### 3. Overhead

```text
- Overhead de container
- Não ideal para microserviços simples
- Requer JVM
```

## Melhores Práticas

### 1. Usar Anotações

```java
@Configuration
@ComponentScan
public class AppConfig {
    // ...
}
```

### 2. Usar @Autowired

```java
@Autowired
private MyService service;
```

### 3. Definir Escopos Adequados

```java
@Bean
@Scope("prototype")
public MyService myService() {
    return new MyService();
}
```

### 4. Fechar Contexto

```java
context.close();
```

## Trade-offs

### BeanFactory vs ApplicationContext

- **BeanFactory**: Leve, lazy loading
- **ApplicationContext**: Rico, eager loading
- **Escolha**: BeanFactory para simples, ApplicationContext para completo

### Singleton vs Prototype

- **Singleton**: Uma instância, padrão
- **Prototype**: Nova instância a cada request
- **Escolha**: Singleton para stateless, Prototype para stateful

### XML vs Java Config

- **XML**: Legado, verboso
- **Java**: Moderno, type-safe
- **Escolha**: Java config para novos projetos

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html>
- <https://www.baeldung.com/spring-applicationcontext>
