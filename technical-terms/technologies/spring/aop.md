# AOP

AOP (Aspect-Oriented Programming) é um paradigma de programação que permite separar preocupações transversais (cross-cutting concerns) como logging, segurança e transações da lógica de negócio, usando aspectos, join points, pointcuts e advice.

## Definição

AOP (Aspect-Oriented Programming) é um paradigma de programação que permite separar preocupações transversais (cross-cutting concerns) como logging, segurança e transações da lógica de negócio, usando aspectos, join points, pointcuts e advice para modularizar código repetitivo.

```text
AOP = Aspectos + Join Points + Pointcuts + Advice + Cross-cutting concerns
```

## Como Funciona

### 1. Conceitos

```text
- Aspect: Módulo que encapsula cross-cutting concerns
- Join Point: Ponto específico na execução do programa
- Pointcut: Expressão que seleciona join points
- Advice: Ação executada em um join point
- Weaving: Processo de aplicar aspectos ao código
```

### 2. Tipos de Advice

```text
- Before: Executa antes do join point
- After: Executa após o join point (normalmente)
- After Returning: Executa após retorno bem-sucedido
- After Throwing: Executa após exceção
- Around: Executa antes e após o join point
```

### 3. Weaving

```text
- Compile-time: Durante compilação
- Class-load-time: Durante carregamento de classe
- Runtime: Durante execução (Spring AOP)
```

## Exemplo Prático

### Aspect Básico

```java
@Aspect
@Component
public class LoggingAspect {

    @Before("execution(* com.example.service.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Before: " + joinPoint.getSignature().getName());
    }

    @After("execution(* com.example.service.*.*(..))")
    public void logAfter(JoinPoint joinPoint) {
        System.out.println("After: " + joinPoint.getSignature().getName());
    }
}
```

### Around Advice

```java
@Aspect
@Component
public class PerformanceAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object logPerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long duration = System.currentTimeMillis() - start;
            System.out.println("Method " + joinPoint.getSignature().getName() + 
                " took " + duration + "ms");
            return result;
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            System.out.println("Method " + joinPoint.getSignature().getName() + 
                " failed after " + duration + "ms");
            throw e;
        }
    }
}
```

### After Returning

```java
@Aspect
@Component
public class AfterReturningAspect {

    @AfterReturning(
        pointcut = "execution(* com.example.service.*.*(..))",
        returning = "result"
    )
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        System.out.println("Method " + joinPoint.getSignature().getName() + 
            " returned: " + result);
    }
}
```

### After Throwing

```java
@Aspect
@Component
public class AfterThrowingAspect {

    @AfterThrowing(
        pointcut = "execution(* com.example.service.*.*(..))",
        throwing = "ex"
    )
    public void logAfterThrowing(JoinPoint joinPoint, Exception ex) {
        System.out.println("Method " + joinPoint.getSignature().getName() + 
            " threw: " + ex.getMessage());
    }
}
```

### Custom Annotation

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Loggable {
}

@Aspect
@Component
public class CustomAnnotationAspect {

    @Around("@annotation(loggable)")
    public Object logCustom(ProceedingJoinPoint joinPoint, Loggable loggable) throws Throwable {
        System.out.println("Custom logging for: " + joinPoint.getSignature().getName());
        return joinPoint.proceed();
    }
}

@Service
public class MyService {
    
    @Loggable
    public void doSomething() {
        // ...
    }
}
```

### Pointcut Reutilizável

```java
@Aspect
@Component
public class ReusableAspect {

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceMethods() {}

    @Before("serviceMethods()")
    public void logBeforeService(JoinPoint joinPoint) {
        System.out.println("Before service: " + joinPoint.getSignature().getName());
    }

    @After("serviceMethods()")
    public void logAfterService(JoinPoint joinPoint) {
        System.out.println("After service: " + joinPoint.getSignature().getName());
    }
}
```

## Comandos Úteis

### Habilitar AOP

```java
@Configuration
@EnableAspectJAutoProxy
public class AopConfig {
    // Configuração
}
```

### Expressões Pointcut

```java
// Execução de método
execution(* com.example.service.*.*(..))

// Execução de método específico
execution(* com.example.service.MyService.doSomething(..))

// Execução de todos os métodos de uma classe
execution(* com.example.service.MyService.*(..))

// Execução de métodos com anotação
@annotation(com.example.Loggable)

// Execução de métodos em classes com anOTAÇÃO
@within(org.springframework.stereotype.Service)
```

## Vantagens

### 1. Separação

```text
- Separação de concerns
- Código mais limpo
- Manutenibilidade
```

### 2. Reutilização

```text
- Código reutilizável
- DRY (Don't Repeat Yourself)
- Centralização
```

### 3. Flexibilidade

```text
- Configuração flexível
- Múltiplos aspectos
- Composição
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Debugging desafiador
- Erros sutis
```

### 2. Performance

```text
- Overhead de proxy
- Reflexão
- Performance reduzida
```

### 3. Limitações

```text
- Apenas métodos públicos
- Não suporta todos os tipos
- Limitações do proxy
```

## Melhores Práticas

### 1. Usar Anotações Customizadas

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Loggable {
}

@Around("@annotation(loggable)")
public Object log(ProceedingJoinPoint joinPoint, Loggable loggable) throws Throwable {
    // ...
}
```

### 2. Definir Pointcuts Reutilizáveis

```java
@Pointcut("execution(* com.example.service.*.*(..))")
public void serviceMethods() {}
```

### 3. Evitar Around Advice Quando Possível

```java
// Preferir Before/After quando Around não é necessário
@Before("serviceMethods()")
public void logBefore(JoinPoint joinPoint) {
    // ...
}
```

### 4. Usar @EnableAspectJAutoProxy

```java
@Configuration
@EnableAspectJAutoProxy
public class AopConfig {
    // ...
}
```

## Trade-offs

### Spring AOP vs AspectJ

- **Spring AOP**: Runtime weaving, proxy-based, simples
- **AspectJ**: Compile-time weaving, mais poderoso, complexo
- **Escolha**: Spring AOP para casos simples, AspectJ para avançados

### Before vs Around

- **Before**: Executa antes, simples
- **Around**: Executa antes e após, pode modificar resultado
- **Escolha**: Before para logging, Around para performance

### Annotation vs Execution Pointcut

- **Annotation**: Mais flexível, declarativo
- **Execution**: Mais específico, imperativo
- **Escolha**: Annotation para custom, Execution para padrão

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#aop>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/aop/package-summary.html>
- <https://www.baeldung.com/spring-aop>
