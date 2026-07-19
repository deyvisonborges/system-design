# Memory Model

Java Memory Model (JMM) define como threads interagem através da memória compartilhada, especificando regras de visibilidade, atomicidade e ordenação para garantir comportamento consistente em ambientes multi-threaded.

## Definição

Java Memory Model é uma especificação que define como threads interagem através da memória compartilhada, garantindo visibilidade, atomicidade e ordenação de operações em ambientes multi-threaded, prevenindo race conditions e garantindo consistência.

```text
Memory Model = Visibilidade + Atomicidade + Ordenação + Consistência
```

## Como Funciona

### 1. Conceitos

```text
- Happens-before: Relação de ordenação entre operações
- Volatile: Garante visibilidade imediata
- Synchronized: Garante atomicidade e visibilidade
- Final: Garante segurança de inicialização
```

### 2. Regras

```text
- Regra do monitor: Unlock happens-before lock
- Regra do volatile: Write happens-before read
- Regra do thread: Start happens-before actions
- Regra da interrupção: Interrupt happens-before catch
```

### 3. Memória

```text
- Main Memory: Memória compartilhada
- Working Memory: Cache local de thread
- Atomic Actions: Operações indivisíveis
- Lock Actions: Operações de bloqueio
```

## Exemplo Prático

### Volatile para Visibilidade

```java
public class VolatileExample {
    private volatile boolean flag = false;

    public void stop() {
        flag = true;  // Visível imediatamente para outras threads
    }

    public void run() {
        while (!flag) {
            // Faz algo
        }
    }
}
```

### Synchronized para Atomicidade

```java
public class Counter {
    private int count = 0;

    public synchronized void increment() {
        count++;  // Atômico
    }

    public synchronized int getCount() {
        return count;  // Visível
    }
}
```

### Happens-Before com Thread

```java
public class HappensBeforeExample {
    private static int x = 0;

    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            x = 1;  // Happens-before join
        });
        thread.start();
        thread.join();
        System.out.println(x);  // Garantido ser 1
    }
}
```

### Double-Checked Locking

```java
public class Singleton {
    private static volatile Singleton instance;

    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

## Comandos Úteis

### Debug Concorrência

```bash
# Usar JConsole para monitorar threads
jconsole

# Usar JVisualVM para profiling
jvisualvm

# Usar jstack para ver threads
jstack <pid>
```

### Ferramentas

```bash
# FindBugs para detectar problemas de concorrência
findbugs MyApp.jar

# SpotBugs (sucessor do FindBugs)
spotbugs MyApp.jar

# PMD para análise de código
pmd check MyApp.java
```

## Vantagens

### 1. Consistência

```text
- Comportamento previsível
- Sem race conditions
- Garante ordenação
```

### 2. Portabilidade

```text
- Comportamento consistente entre JVMs
- Independente de hardware
- Especificação clara
```

### 3. Segurança

```text
- Previne bugs de concorrência
- Garante atomicidade
- Protege dados compartilhados
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado íngreme
- Conceitos abstratos
- Debugging desafiador
```

### 2. Performance

```text
- Overhead de sincronização
- Volatile pode impactar performance
- Synchronized é caro
```

### 3. Erros Sutis

```text
- Race conditions difíceis de detectar
- Deadlocks
- Memory visibility issues
```

## Melhores Práticas

### 1. Usar Volatile para Flags

```java
private volatile boolean running = true;
```

### 2. Usar Synchronized para Críticas

```java
public synchronized void update() {
    // Código crítico
}
```

### 3. Usar Concurrent Collections

```java
ConcurrentHashMap<String, String> map = new ConcurrentHashMap<>();
```

### 4. Evitar Lock Fine-Grained

```java
// Evitar
synchronized(obj1) { ... }
synchronized(obj2) { ... }

// Preferir
synchronized(this) { ... }
```

## Trade-offs

### Volatile vs Synchronized

- **Volatile**: Visibilidade, sem atomicidade
- **Synchronized**: Visibilidade + atomicidade
- **Escolha**: Volatile para flags, synchronized para críticas

### Synchronized vs Lock

- **Synchronized**: Simples, implícito
- **Lock**: Flexível, explícito
- **Escolha**: Synchronized para simples, Lock para complexo

### Happens-Before vs Memory Barriers

- **Happens-before**: Conceitual, Java
- **Memory barriers**: Hardware, baixo nível
- **Escolha**: Happens-before para Java, barriers para nativo

### _Links_

- <https://docs.oracle.com/javase/specs/jls/se17/html/jls-17.html>
- <https://docs.oracle.com/javase/tutorial/essential/concurrency/>
- <https://www.baeldung.com/java-volatile>
