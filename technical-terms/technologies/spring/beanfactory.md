# BeanFactory

BeanFactory é a interface raiz do container IoC do Spring, fornecendo a capacidade de instanciar, configurar e gerenciar beans, sendo a implementação mais leve e básica do container Spring.

## Definição

BeanFactory é a interface raiz do container IoC do Spring que fornece a capacidade de instanciar, configurar e gerenciar beans, sendo a implementação mais leve e básica do container Spring, com lazy loading de beans por padrão.

```text
BeanFactory = Container IoC básico + Lazy loading + Leve + Gerenciamento de beans
```

## Como Funciona

### 1. Responsabilidades

```text
- Instanciar beans
- Configurar beans
- Gerenciar ciclo de vida
- Resolver dependências
- Escopos de beans
```

### 2. Implementações

```text
- XmlBeanFactory: Configuração via XML (deprecated)
- DefaultListableBeanFactory: Implementação padrão
- ApplicationContext: Extensão com recursos adicionais
```

### 3. Características

```text
- Lazy loading: Beans são carregados sob demanda
- Leve: Menos overhead que ApplicationContext
- Básico: Recursos essenciais apenas
- Manual: Requer uso explícito
```

## Exemplo Prático

### DefaultListableBeanFactory

```java
public class BeanFactoryExample {
    public static void main(String[] args) {
        // Criar BeanFactory
        DefaultListableBeanFactory beanFactory = new DefaultListableBeanFactory();
        
        // Registrar bean
        beanFactory.registerSingleton("myService", new MyService());
        
        // Obter bean
        MyService service = beanFactory.getBean("myService", MyService.class);
        service.doSomething();
    }
}
```

### BeanDefinition

```java
public class BeanDefinitionExample {
    public static void main(String[] args) {
        DefaultListableBeanFactory beanFactory = new DefaultListableBeanFactory();
        
        // Criar BeanDefinition
        BeanDefinition beanDefinition = BeanDefinitionBuilder
            .genericBeanDefinition(MyService.class)
            .addPropertyValue("name", "MyService")
            .setScope("singleton")
            .getBeanDefinition();
        
        // Registrar BeanDefinition
        beanFactory.registerBeanDefinition("myService", beanDefinition);
        
        // Obter bean
        MyService service = beanFactory.getBean("myService", MyService.class);
        service.doSomething();
    }
}
```

### XmlBeanFactory (Deprecated)

```java
public class XmlBeanFactoryExample {
    public static void main(String[] args) {
        // Criar XmlBeanFactory (deprecated)
        Resource resource = new ClassPathResource("applicationContext.xml");
        BeanFactory beanFactory = new XmlBeanFactory(resource);
        
        // Obter bean
        MyService service = beanFactory.getBean("myService", MyService.class);
        service.doSomething();
    }
}
```

### applicationContext.xml

```xml
<beans xmlns="http://www.springframework.org/schema/beans">
    <bean id="myService" class="com.example.MyService">
        <property name="name" value="MyService"/>
    </bean>
</beans>
```

### Exemplo Lazy vs Eager Loading

```java
public class LoadingExample {
    public static void main(String[] args) {
        // BeanFactory: lazy loading
        BeanFactory beanFactory = new DefaultListableBeanFactory();
        beanFactory.registerSingleton("myService", new MyService());
        // Bean não é instanciado até getBean()
        
        // ApplicationContext: eager loading
        ApplicationContext context = 
            new AnnotationConfigApplicationContext(AppConfig.class);
        // Beans são instanciados na inicialização
    }
}
```

## Comandos Úteis

### Obter Beans

```java
// Por nome
MyService service = (MyService) beanFactory.getBean("myService");

// Por tipo
MyService service = beanFactory.getBean(MyService.class);

// Por nome e tipo
MyService service = beanFactory.getBean("myService", MyService.class);

// Todos os beans de um tipo
Map<String, MyService> beans = beanFactory.getBeansOfType(MyService.class);
```

### Verificar Beans

```java
// Verificar se bean existe
boolean exists = beanFactory.containsBean("myService");

// Verificar se é singleton
boolean isSingleton = beanFactory.isSingleton("myService");

// Verificar se é prototype
boolean isPrototype = beanFactory.isPrototype("myService");

// Verificar tipo
boolean isType = beanFactory.isTypeMatch("myService", MyService.class);
```

### Aliases

```java
// Registrar alias
beanFactory.registerAlias("myService", "service");

// Obter aliases
String[] aliases = beanFactory.getAliases("myService");
```

## Vantagens

### 1. Leve

```text
- Menos overhead
- Startup rápido
- Memória reduzida
```

### 2. Lazy Loading

```text
- Beans carregados sob demanda
- Melhor performance inicial
- Menos recursos iniciais
```

### 3. Simples

```text
- API simples
- Foco essencial
- Menos complexidade
```

## Limitações

### 1. Recursos Limitados

```text
- Sem internacionalização
- Sem eventos
- Sem recursos de aplicação
```

### 2. Manual

```text
- Requer uso manual
- Menos conveniente
- Mais código
```

### 3. Deprecated

```text
- XmlBeanFactory deprecated
- ApplicationContext preferido
- Menos suporte
```

## Melhores Práticas

### 1. Usar ApplicationContext

```java
// Preferir ApplicationContext para aplicações completas
ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
```

### 2. Usar BeanFactory para Testes

```java
// BeanFactory é útil para testes unitários
DefaultListableBeanFactory beanFactory = new DefaultListableBeanFactory();
beanFactory.registerSingleton("myService", new MyService());
```

### 3. Usar BeanDefinitionBuilder

```java
BeanDefinition beanDefinition = BeanDefinitionBuilder
    .genericBeanDefinition(MyService.class)
    .addPropertyValue("name", "MyService")
    .getBeanDefinition();
```

### 4. Evitar XmlBeanFactory

```java
// XmlBeanFactory é deprecated
// Usar ApplicationContext com Java config
```

## Trade-offs

### BeanFactory vs ApplicationContext

- **BeanFactory**: Leve, lazy loading, básico
- **ApplicationContext**: Rico, eager loading, completo
- **Escolha**: BeanFactory para testes, ApplicationContext para produção

### Lazy vs Eager Loading

- **Lazy**: Carregado sob demanda, startup rápido
- **Eager**: Carregado na inicialização, beans pronto
- **Escolha**: Lazy para testes, Eager para produção

### Singleton vs Prototype

- **Singleton**: Uma instância, compartilhado
- **Prototype**: Nova instância, isolado
- **Escolha**: Singleton para stateless, Prototype para stateful

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-beanfactory>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/BeanFactory.html>
- <https://www.baeldung.com/spring-beanfactory>
