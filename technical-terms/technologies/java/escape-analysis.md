# Escape Analysis

Escape Analysis é uma otimização do JIT Compiler que determina se objetos alocados em um método podem escapar para fora do escopo do método, permitindo alocação no stack em vez do heap para melhorar performance.

## Definição

Escape Analysis é uma otimização do JIT Compiler que analisa o escopo de objetos para determinar se eles podem escapar do método onde foram criados, permitindo alocação no stack em vez do heap, reduzindo pressão no GC e melhorando performance.

```text
Escape Analysis = Análise de escopo + Alocação no stack + Otimização de GC
```

## Como Funciona

### 1. Tipos de Escape

```text
- No Escape: Objeto não escapa do método
- Argument Escape: Objeto passado como parâmetro
- Return Escape: Objeto retornado do método
- Global Escape: Objeto atribuído a campo estático
```

### 2. Análise

```text
- JIT analisa bytecode
- Determina escopo do objeto
- Decide local de alocação
- Aplica otimizações
```

### 3. Otimizações

```text
- Stack Allocation: Alocação no stack
- Scalar Replacement: Substituição por escalares
- Lock Elision: Eliminação de sincronização
```

## Exemplo Prático

### Objeto sem Escape

```java
public class NoEscapeExample {
    public void method() {
        MyObject obj = new MyObject();  // Não escapa
        obj.doSomething();
        // Objeto pode ser alocado no stack
    }
}
```

### Objeto com Escape

```java
public class EscapeExample {
    private MyObject globalObj;

    public void method() {
        MyObject obj = new MyObject();
        globalObj = obj;  // Global escape - alocação no heap
    }
}
```

### Scalar Replacement

```java
public class ScalarReplacementExample {
    public int sum(int a, int b) {
        Point p = new Point(a, b);  // Pode ser substituído por escalares
        return p.x + p.y;
    }
}
```

### Lock Elision

```java
public class LockElisionExample {
    public void method() {
        synchronized (new Object()) {  // Lock pode ser eliminado
            // Código sincronizado
        }
    }
}
```

## Comandos Úteis

### Habilitar Escape Analysis

```bash
# Escape analysis é habilitado por padrão
# Para desabilitar:
java -XX:-DoEscapeAnalysis MyApp

# Para habilitar explicitamente:
java -XX:+DoEscapeAnalysis MyApp
```

### Ver Otimizações

```bash
# Ver detalhes de compilação JIT
java -XX:+PrintCompilation MyApp

# Ver escape analysis
java -XX:+PrintEscapeAnalysis MyApp

# Ver eliminação de locks
java -XX:+EliminateAllocations MyApp
```

### Debug

```bash
# Ver logs de JIT
java -XX:+PrintCompilation -XX:+PrintInlining MyApp

# Ver detalhes de escape analysis
java -XX:+PrintEscapeAnalysis -XX:+PrintEliminateAllocations MyApp
```

## Vantagens

### 1. Performance

```text
- Alocação no stack é mais rápida
- Reduz pressão no GC
- Menos pausas de GC
```

### 2. Eficiência

```text
- Menos overhead de alocação
- Melhor localidade de cache
- Reduz fragmentação
```

### 3. Automático

```text
- Otimização automática do JIT
- Sem mudanças no código
- Transparente para desenvolvedor
```

## Limitações

### 1. Complexidade

```text
- Análise complexa
- Nem sempre possível
- Requer JIT warmup
```

### 2. Limitações

```text
- Apenas objetos sem escape
- Não funciona com todos os objetos
- Depende de análise estática
```

### 3. Debugging

```text
- Difícil de debugar
- Comportamento não determinístico
- Requer ferramentas específicas
```

## Melhores Práticas

### 1. Minimizar Escape de Objetos

```java
// Evitar
public MyObject createObject() {
    return new MyObject();  // Escape
}

// Preferir
public void useObject() {
    MyObject obj = new MyObject();  // No escape
    obj.doSomething();
}
```

### 2. Usar Objetos Locais

```java
public void process() {
    MyObject obj = new MyObject();  // Local
    obj.process();
}
```

### 3. Evitar Sincronização Desnecessária

```java
// Evitar
synchronized (new Object()) {
    // Código
}

// Preferir
private final Object lock = new Object();
synchronized (lock) {
    // Código
}
```

### 4. Monitorar Otimizações

```bash
# Ver logs de JIT
java -XX:+PrintCompilation MyApp

# Ver escape analysis
java -XX:+PrintEscapeAnalysis MyApp
```

## Trade-offs

### Stack vs Heap Allocation

- **Stack**: Rápido, limitado, sem GC
- **Heap**: Lento, ilimitado, com GC
- **Escolha**: Stack para locais, heap para escape

### Scalar Replacement vs Object

- **Scalar**: Mais rápido, sem objeto
- **Object**: Mais flexível, overhead
- **Escolha**: Scalar quando possível

### Lock Elision vs Sincronização

- **Elision**: Sem overhead, automático
- **Sincronização**: Overhead, necessário
- **Escolha**: Elision para locks locais, sincronização para compartilhado

### _Links_

- <https://docs.oracle.com/javase/8/docs/technotes/guides/vm/performance/>
- <https://openjdk.org/groups/hotspot/docs/EscapeAnalysis.html>
- <https://www.baeldung.com/jvm-escape-analysis>
