# Stack

Stack é a área de memória da JVM usada para armazenar frames de métodos, variáveis locais e referências de objetos, organizada em estrutura LIFO (Last In, First Out) para gerenciar chamadas de métodos e recursão.

## Definição

Stack é a área de memória da JVM que armazena frames de métodos, variáveis locais e referências de objetos, organizada em estrutura LIFO para gerenciar chamadas de métodos, recursão e contexto de execução de cada thread.

```text
Stack = Frames de métodos + Variáveis locais + LIFO + Recursão
```

## Como Funciona

### 1. Estrutura

```text
- Stack Frame: Contexto de um método
  - Local Variables: Variáveis locais
  - Operand Stack: Pilha de operandos
  - Frame Data: Dados do frame
- LIFO: Last In, First Out
- Per Thread: Cada thread tem sua própria stack
```

### 2. Operações

```text
- Push: Adiciona frame quando método é chamado
- Pop: Remove frame quando método retorna
- Peek: Lê frame sem remover
- Overflow: Quando stack excede tamanho máximo
```

### 3. Conteúdo

```text
- Variáveis locais: parâmetros e variáveis
- Operand stack: para bytecode
- Return address: para retorno
- Dynamic linking: para resolução de métodos
```

## Exemplo Prático

### Stack Overflow

```java
// Causa StackOverflowError
public class StackOverflowExample {
    public static void recursiveMethod() {
        recursiveMethod();  // Recursão infinita
    }

    public static void main(String[] args) {
        recursiveMethod();
    }
}
```

### Configurar Stack Size

```bash
# Configurar stack size
java -Xss512k MyApp

# Configurar stack size maior
java -Xss2m MyApp
```

### Analisar Stack Trace

```java
public class StackTraceExample {
    public static void methodA() {
        methodB();
    }

    public static void methodB() {
        methodC();
    }

    public static void methodC() {
        // Imprime stack trace
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (StackTraceElement element : stackTrace) {
            System.out.println(element);
        }
    }

    public static void main(String[] args) {
        methodA();
    }
}
```

### Recursão com Tail Recursion

```java
// Recursão normal (pode causar stack overflow)
public class RecursionExample {
    public static int factorial(int n) {
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    }
}

// Tail recursion (melhor para stack)
public class TailRecursionExample {
    public static int factorial(int n) {
        return factorialHelper(n, 1);
    }

    private static int factorialHelper(int n, int acc) {
        if (n <= 1) return acc;
        return factorialHelper(n - 1, n * acc);
    }
}
```

## Comandos Úteis

### Monitorar Stack

```bash
# Ver stack trace de thread
jstack <pid>

# Ver threads
jps -l

# Ver stack size
java -XX:+PrintFlagsFinal -version | grep StackSize
```

### Debug

```bash
# Usar jstack para ver stack
jstack <pid>

# Usar jconsole para monitorar threads
jconsole

# Usar VisualVM para profiling
jvisualvm
```

## Vantagens

### 1. Eficiência

```text
- Alocação rápida
- Sem overhead de GC
- Acesso direto
```

### 2. Simplicidade

```text
- Estrutura LIFO simples
- Gerenciamento automático
- Contexto claro
```

### 3. Isolamento

```text
- Cada thread tem sua stack
- Sem compartilhamento
- Thread-safe
```

## Limitações

### 1. Tamanho Fixo

```text
- Stack size configurado na inicialização
- Não pode crescer dinamicamente
- StackOverflowError se excedido
```

### 2. Recursão

```text
- Recursão profunda causa overflow
- Tail recursion não otimizada em Java
- Requer iterativo para profundidade
```

### 3. Debugging

```text
- Stack overflow difícil de debugar
- Recursão complexa
- Requer análise cuidadosa
```

## Melhores Práticas

### 1. Configurar Stack Size Adequadamente

```bash
-Xss512k
```

### 2. Evitar Recursão Profunda

```java
// Evitar
public void deepRecursion(int n) {
    if (n > 0) deepRecursion(n - 1);
}

// Preferir iterativo
public void iterative(int n) {
    for (int i = 0; i < n; i++) {
        // Faz algo
    }
}
```

### 3. Usar Tail Recursion Quando Possível

```java
private static int factorialHelper(int n, int acc) {
    if (n <= 1) return acc;
    return factorialHelper(n - 1, n * acc);
}
```

### 4. Monitorar Stack Usage

```bash
# Usar jstack
jstack <pid>

# Usar VisualVM
jvisualvm
```

## Trade-offs

### Stack Size Pequeno vs Grande

- **Pequeno**: Menos memória, mais risco de overflow
- **Grande**: Mais memória, menos risco
- **Escolha**: Balancear entre memória e segurança

### Recursão vs Iteração

- **Recursão**: Código limpo, risco de overflow
- **Iteração**: Mais código, sem risco
- **Escolha**: Iteração para profundidade, recursão para simplicidade

### Stack vs Heap

- **Stack**: Rápido, limitado, sem GC
- **Heap**: Lento, ilimitado, com GC
- **Escolha**: Stack para locais, heap para objetos

### _Links_

- <https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-2.html>
- <https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-4.html>
- <https://www.baeldung.com/jvm-stack-heap>
