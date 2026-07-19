# Bean Lifecycle

Bean Lifecycle é o processo pelo qual um bean Spring passa desde sua criação até sua destruição, incluindo instanciação, injeção de dependências, inicialização, uso e destruição, com callbacks e interceptors em cada fase.

## Definição

Bean Lifecycle é o processo gerenciado pelo Spring Context que define as fases pelas quais um bean passa desde sua criação até sua destruição, incluindo instanciação, injeção de dependências, inicialização, uso e destruição, com callbacks e interceptors em cada fase para customização.

```text
Bean Lifecycle = Instanciação + Injeção + Inicialização + Uso + Destruição
```

## Como Funciona

### 1. Fases

```text
- Instanciação: Bean é criado
- Propriedades: Dependências são injetadas
- Aware: Interfaces de aware são chamadas
- Post-Processors: BeanPostProcessors são aplicados
- Inicialização: Métodos de inicialização são chamados
- Ready: Bean está pronto para uso
- Destruição: Bean é destruído
```

### 2. Callbacks

```text
- @PostConstruct: Após injeção de dependências
- InitializingBean.afterPropertiesSet(): Após propriedades
- @PreDestroy: Antes de destruição
- DisposableBean.destroy(): Durante destruição
```

### 3. Post-Processors

```text
- BeanPostProcessor: Pré e pós inicialização
- InstantiationAwareBeanPostProcessor: Pré instanciação
- DestructionAwareBeanPostProcessor: Pré destruição
```

## Exemplo Prático

### Bean com Lifecycle Callbacks

```java
@Component
public class LifecycleBean implements InitializingBean, DisposableBean {
    
    @Autowired
    private ApplicationContext context;

    @PostConstruct
    public void postConstruct() {
        System.out.println("1. @PostConstruct");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("2. afterPropertiesSet");
    }

    @PreDestroy
    public void preDestroy() {
        System.out.println("3. @PreDestroy");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("4. destroy");
    }
}
```

### Custom Init e Destroy Methods

```java
@Component
public class CustomLifecycleBean {
    
    @Autowired
    private Dependency dependency;

    public void init() {
        System.out.println("Custom init method");
    }

    public void destroy() {
        System.out.println("Custom destroy method");
    }
}
```

### Configuração

```java
@Configuration
public class BeanConfig {
    
    @Bean(initMethod = "init", destroyMethod = "destroy")
    public CustomLifecycleBean customLifecycleBean(Dependency dependency) {
        return new CustomLifecycleBean(dependency);
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

### InstantiationAwareBeanPostProcessor

```java
@Component
public class CustomInstantiationAwareBeanPostProcessor 
    implements InstantiationAwareBeanPostProcessor {
    
    @Override
    public Object postProcessBeforeInstantiation(Class<?> beanClass, String beanName) {
        System.out.println("Before instantiation: " + beanName);
        return null;  // Return null para usar instanciação padrão
    }

    @Override
    public boolean postProcessAfterInstantiation(Object bean, String beanName) {
        System.out.println("After instantiation: " + beanName);
        return true;  // True para continuar com injeção de propriedades
    }
}
```

### DestructionAwareBeanPostProcessor

```java
@Component
public class CustomDestructionAwareBeanPostProcessor 
    implements DestructionAwareBeanPostProcessor {
    
    @Override
    public void postProcessBeforeDestruction(Object bean, String beanName) {
        System.out.println("Before destruction: " + beanName);
    }
}
```

## Comandos Úteis

### Verificar Lifecycle

```java
@Component
public class LifecycleLogger implements BeanPostProcessor {
    
    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) {
        System.out.println("Bean created: " + beanName);
        return bean;
    }
}
```

### Escopos de Bean

```java
@Bean
@Scope("singleton")  // Padrão
public MyBean myBean() {
    return new MyBean();
}

@Bean
@Scope("prototype")  // Nova instância a cada request
public MyBean prototypeBean() {
    return new MyBean();
}
```

## Vantagens

### 1. Controle

```text
- Controle total do ciclo de vida
- Callbacks customizados
- Interceptores em cada fase
```

### 2. Flexibilidade

```text
- Múltiplas formas de customização
- Post-processors poderosos
- Escopos configuráveis
```

### 3. Padrões

```text
- Padrões de inicialização
- Padrões de destruição
- Consistência
```

## Limitações

### 1. Complexidade

```text
- Muitas fases
- Difícil de debugar
- Ordem não trivial
```

### 2. Performance

```text
- Overhead de post-processors
- Múltiplas chamadas
- Startup mais lento
```

### 3. Erros

```text
- Erros em callbacks
- Exceções em inicialização
- Destruição não garantida
```

## Melhores Práticas

### 1. Usar @PostConstruct e @PreDestroy

```java
@PostConstruct
public void init() {
    // Inicialização
}

@PreDestroy
public void cleanup() {
    // Limpeza
}
```

### 2. Evitar Interfaces

```java
// Preferir anotações a interfaces
// InitializingBean e DisposableBean são menos flexíveis
```

### 3. Usar Post-Processors com Cuidado

```java
// Post-processors afetam todos os beans
// Use @Order para controlar ordem
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CustomPostProcessor implements BeanPostProcessor {
    // ...
}
```

### 4. Definir Escopos Adequados

```java
@Bean
@Scope("singleton")
public MyBean singletonBean() {
    return new MyBean();
}
```

## Trade-offs

### @PostConstruct vs InitializingBean

- **@PostConstruct**: Anotação, flexível, padrão
- **InitializingBean**: Interface, menos flexível
- **Escolha**: @PostConstruct para novo código

### @PreDestroy vs DisposableBean

- **@PreDestroy**: Anotação, flexível, padrão
- **DisposableBean**: Interface, menos flexível
- **Escolha**: @PreDestroy para novo código

### Singleton vs Prototype

- **Singleton**: Uma instância, compartilhado
- **Prototype**: Nova instância, isolado
- **Escolha**: Singleton para stateless, Prototype para stateful

### BeanPostProcessor vs Custom Callbacks

- **PostProcessor**: Global, afeta todos os beans
- **Callbacks**: Local, específico do bean
- **Escolha**: PostProcessor para global, callbacks para local

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-factory-lifecycle>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/config/BeanPostProcessor.html>
- <https://www.baeldung.com/spring-bean>
