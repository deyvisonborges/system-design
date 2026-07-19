# Proxy JDK

Proxy JDK é o mecanismo de proxy dinâmico do Java que implementa interfaces em tempo de execução, usado pelo Spring AOP para criar proxies de beans que implementam interfaces, permitindo interceptação de métodos sem modificar o código original.

## Definição

Proxy JDK é o mecanismo de proxy dinâmico do Java que implementa interfaces em tempo de execução, usado pelo Spring AOP para criar proxies de beans que implementam interfaces, permitindo interceptação de métodos sem modificar o código original, sendo a implementação padrão do Spring quando o bean implementa interfaces.

```text
Proxy JDK = Proxy dinâmico + Interfaces + Interceptação + Runtime
```

## Como Funciona

### 1. Mecanismo

```text
- Proxy.newProxyInstance: Cria proxy dinâmico
- InvocationHandler: Intercepta chamadas de método
- Interfaces: Bean deve implementar interfaces
- Runtime: Proxy criado em tempo de execução
```

### 2. Limitações

```text
- Apenas interfaces: Bean deve implementar interfaces
- Métodos públicos: Apenas métodos públicos são interceptados
- Não suporta classes: Não funciona com classes concretas
```

### 3. Uso no Spring

```text
- Spring AOP: Usa Proxy JDK por padrão
- @Transactional: Cria proxy para gerenciar transações
- @Async: Cria proxy para execução assíncrona
- @Cacheable: Cria proxy para cache
```

## Exemplo Prático

### Proxy JDK Básico

```java
public class JdkProxyExample {
    public static void main(String[] args) {
        MyInterface target = new MyInterfaceImpl();
        
        MyInterface proxy = (MyInterface) Proxy.newProxyInstance(
            JdkProxyExample.class.getClassLoader(),
            new Class<?>[]{MyInterface.class},
            new MyInvocationHandler(target)
        );
        
        proxy.doSomething();
    }
}

interface MyInterface {
    void doSomething();
}

class MyInterfaceImpl implements MyInterface {
    @Override
    public void doSomething() {
        System.out.println("Original method");
    }
}

class MyInvocationHandler implements InvocationHandler {
    private final Object target;

    public MyInvocationHandler(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("Before method");
        Object result = method.invoke(target, args);
        System.out.println("After method");
        return result;
    }
}
```

### Spring AOP com Proxy JDK

```java
@Service
public class MyService implements MyServiceInterface {
    
    @Override
    public void doSomething() {
        System.out.println("Original method");
    }
}

interface MyServiceInterface {
    void doSomething();
}

@Aspect
@Component
public class LoggingAspect {

    @Before("execution(* com.example.service.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Before: " + joinPoint.getSignature().getName());
    }
}
```

### @Transactional com Proxy JDK

```java
@Service
public class TransactionalService implements TransactionalServiceInterface {
    
    @Override
    @Transactional
    public void transferMoney(Long fromId, Long toId, BigDecimal amount) {
        // Código transacional
    }
}

interface TransactionalServiceInterface {
    void transferMoney(Long fromId, Long toId, BigDecimal amount);
}
```

### Limitação do Proxy JDK

```java
// Não funciona - classe não implementa interface
@Service
public class NoInterfaceService {
    
    @Transactional
    public void doSomething() {
        // Spring usará CGLIB
    }
}

// Funciona - implementa interface
@Service
public class WithInterfaceService implements MyInterface {
    
    @Transactional
    public void doSomething() {
        // Spring usará Proxy JDK
    }
}
```

## Comandos Úteis

### Forçar Proxy JDK

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = false)
public class ProxyConfig {
    // proxyTargetClass = false força Proxy JDK
}
```

### Forçar CGLIB

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class ProxyConfig {
    // proxyTargetClass = true força CGLIB
}
```

### Verificar Proxy

```java
@Service
public class MyService implements MyInterface {
    
    @PostConstruct
    public void checkProxy() {
        System.out.println(getClass().getName());
        // Se for Proxy JDK: com.sun.proxy.$Proxy
        // Se for CGLIB: com.example.MyService$$EnhancerBySGCGLIB
    }
}
```

## Vantagens

### 1. Padrão

```text
- Padrão Java
- Nativo
- Sem dependências externas
```

### 2. Simples

```text
- API simples
- Fácil de usar
- Bem documentado
```

### 3. Performance

```text
- Leve
- Menos overhead que CGLIB
- Boa performance
```

## Limitações

### 1. Interfaces

```text
- Requer interfaces
- Não funciona com classes
- Limitado a métodos públicos
```

### 2. Internos

```text
- Chamadas internas não são interceptadas
- Self-invocation não funciona
- Requer proxy externo
```

### 3. Final

```text
- Não funciona com métodos final
- Não funciona com classes final
- Limitações do Java
```

## Melhores Práticas

### 1. Implementar Interfaces

```java
@Service
public class MyService implements MyServiceInterface {
    // ...
}
```

### 2. Usar Interfaces para Serviços

```java
public interface MyServiceInterface {
    void doSomething();
}

@Service
public class MyService implements MyServiceInterface {
    // ...
}
```

### 3. Evitar Self-Invocation

```java
// Evitar
@Service
public class MyService implements MyInterface {
    
    @Transactional
    public void method1() {
        method2();  // Não funciona
    }
    
    @Transactional
    public void method2() {
        // ...
    }
}

// Preferir
@Service
public class MyService implements MyInterface {
    
    @Autowired
    private MyService self;
    
    @Transactional
    public void method1() {
        self.method2();  // Funciona
    }
    
    @Transactional
    public void method2() {
        // ...
    }
}
```

### 4. Configurar Proxy Adequadamente

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = false)
public class ProxyConfig {
    // proxyTargetClass = false para Proxy JDK
}
```

## Trade-offs

### Proxy JDK vs CGLIB

- **Proxy JDK**: Interfaces, leve, padrão Java
- **CGLIB**: Classes, mais poderoso, bytecode manipulation
- **Escolha**: Proxy JDK para interfaces, CGLIB para classes

### proxyTargetClass = false vs true

- **False**: Proxy JDK, interfaces
- **True**: CGLIB, classes
- **Escolha**: False para interfaces, true para classes

### Self-Invocation vs External

- **Self**: Não funciona com proxy
- **External**: Funciona com proxy
- **Escolha**: External para AOP funcionar

### _Links_

- <https://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Proxy.html>
- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#aop-proxies>
- <https://www.baeldung.com/spring-aop>
