# CGLIB

CGLIB (Code Generation Library) é uma biblioteca de geração de bytecode que cria subclasses dinâmicas em tempo de execução, usada pelo Spring AOP quando o bean não implementa interfaces, permitindo interceptação de métodos em classes concretas.

## Definição

CGLIB (Code Generation Library) é uma biblioteca de geração de bytecode que cria subclasses dinâmicas em tempo de execução, usada pelo Spring AOP quando o bean não implementa interfaces, permitindo interceptação de métodos em classes concretas sem modificar o código original.

```text
CGLIB = Geração de bytecode + Subclasses dinâmicas + Classes concretas + Interceptação
```

## Como Funciona

### 1. Mecanismo

```text
- Enhancer: Cria subclasses dinâmicas
- MethodInterceptor: Intercepta chamadas de método
- Bytecode: Manipulação de bytecode em runtime
- Subclasse: Cria subclasse do target
```

### 2. Vantagens

```text
- Classes concretas: Funciona com classes sem interfaces
- Métodos finais: Não funciona com métodos final
- Performance: Mais overhead que Proxy JDK
```

### 3. Uso no Spring

```text
- Spring AOP: Usa CGLIB quando bean não implementa interfaces
- @Transactional: Cria proxy para classes sem interfaces
- @Async: Cria proxy para execução assíncrona
- proxyTargetClass: Força uso de CGLIB
```

## Exemplo Prático

### CGLIB Básico

```java
public class CglibExample {
    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(MyClass.class);
        enhancer.setCallback(new MyMethodInterceptor());
        
        MyClass proxy = (MyClass) enhancer.create();
        proxy.doSomething();
    }
}

class MyClass {
    public void doSomething() {
        System.out.println("Original method");
    }
}

class MyMethodInterceptor implements MethodInterceptor {
    @Override
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("Before method");
        Object result = proxy.invokeSuper(obj, args);
        System.out.println("After method");
        return result;
    }
}
```

### Spring AOP com CGLIB

```java
@Service
public class MyService {
    
    public void doSomething() {
        System.out.println("Original method");
    }
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

### Forçar CGLIB

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class ProxyConfig {
    // proxyTargetClass = true força CGLIB
}
```

### Limitação do CGLIB

```java
// Funciona - classe sem interface
@Service
public class NoInterfaceService {
    
    @Transactional
    public void doSomething() {
        // Spring usará CGLIB
    }
}

// Não funciona - método final
@Service
public class FinalMethodService {
    
    @Transactional
    public final void doSomething() {
        // CGLIB não funciona com métodos final
    }
}
```

## Comandos Úteis

### Forçar CGLIB via Configuração

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class ProxyConfig {
    // proxyTargetClass = true força CGLIB
}
```

### Configurar CGLIB

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class CglibConfig {
    // proxyTargetClass = true força CGLIB
}
```

### Verificar Proxy

```java
@Service
public class MyService {
    
    @PostConstruct
    public void checkProxy() {
        System.out.println(getClass().getName());
        // Se for CGLIB: com.example.MyService$$EnhancerBySGCGLIB
        // Se for Proxy JDK: com.sun.proxy.$Proxy
    }
}
```

## Vantagens

### 1. Classes Concretas

```text
- Funciona com classes sem interfaces
- Não requer interfaces
- Mais flexível
```

### 2. Spring

```text
- Integrado ao Spring
- Configuração simples
- Transparente
```

### 3. Poderoso

```text
- Manipulação de bytecode
- Interceptação avançada
- Mais recursos
```

## Limitações

### 1. Final

```text
- Não funciona com métodos final
- Não funciona com classes final
- Limitações do Java
```

### 2. Performance

```text
- Mais overhead que Proxy JDK
- Geração de bytecode
- Startup mais lento
```

### 3. Construtor

```text
- Requer construtor padrão
- Não funciona com construtores complexos
- Limitações de instanciação
```

## Melhores Práticas

### 1. Usar Interfaces Quando Possível

```java
@Service
public class MyService implements MyServiceInterface {
    // Spring usará Proxy JDK
}
```

### 2. Forçar CGLIB Quando Necessário

```java
@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class ProxyConfig {
    // Força CGLIB
}
```

### 3. Evitar Métodos Final

```java
@Service
public class MyService {
    
    @Transactional
    public void doSomething() {  // Não final
        // ...
    }
}
```

### 4. Usar Construtor Padrão

```java
@Service
public class MyService {
    
    public MyService() {
        // Construtor padrão
    }
}
```

## Trade-offs

### CGLIB vs Proxy JDK

- **CGLIB**: Classes, mais poderoso, bytecode manipulation
- **Proxy JDK**: Interfaces, leve, padrão Java
- **Escolha**: Proxy JDK para interfaces, CGLIB para classes

### proxyTargetClass = true vs false

- **True**: CGLIB, classes
- **False**: Proxy JDK, interfaces
- **Escolha**: True para classes, false para interfaces

### Interfaces vs Classes

- **Interfaces**: Proxy JDK, leve, padrão
- **Classes**: CGLIB, mais overhead
- **Escolha**: Interfaces quando possível, classes quando necessário

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#aop-proxies>
- <https://cglib.sourceforge.net/>
- <https://www.baeldung.com/spring-aop>
