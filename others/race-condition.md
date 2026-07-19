# Race Condition

Race Condition é uma condição de corrida que ocorre quando múltiplas threads acessam e modificam dados compartilhados simultaneamente sem sincronização adequada, resultando em comportamento imprevisível e inconsistente.

## Definição

Race Condition é uma condição de corrida que ocorre quando múltiplas threads acessam e modificam dados compartilhados simultaneamente sem sincronização adequada, resultando em comportamento imprevisível, inconsistência de dados e bugs difíceis de reproduzir, sendo um problema comum em programação concorrente.

```text
Race Condition = Concorrência + Dados compartilhados + Sem sincronização + Comportamento imprevisível
```

## Como Funciona

### 1. Causa

```text
- Múltiplas threads: Execução concorrente
- Dados compartilhados: Acesso ao mesmo dado
- Sem sincronização: Falta de coordenação
- Ordem não determinística: Ordem de execução variável
```

### 2. Tipos

```text
- Read-Modify-Write: Leitura, modificação, escrita
- Check-Then-Act: Verificação, ação
- Lost Update: Atualização perdida
- Dirty Read: Leitura de dado inconsistente
```

### 3. Consequências

```text
- Inconsistência: Dados inconsistentes
- Bugs intermitentes: Difíceis de reproduzir
- Corrupção de dados: Dados corrompidos
- Deadlocks: Bloqueios
```

## Exemplo Prático

### Race Condition Simples

```java
public class Counter {
    private int count = 0;

    public void increment() {
        count++;  // Race condition: não é atômico
    }

    public int getCount() {
        return count;
    }
}
```

### Race Condition com Múltiplas Threads

```java
public class RaceConditionExample {
    private static int counter = 0;

    public static void main(String[] args) throws InterruptedException {
        Runnable task = () -> {
            for (int i = 0; i < 1000; i++) {
                counter++;  // Race condition
            }
        };

        Thread thread1 = new Thread(task);
        Thread thread2 = new Thread(task);

        thread1.start();
        thread2.start();

        thread1.join();
        thread2.join();

        System.out.println("Counter: " + counter);  // Resultado imprevisível (< 2000)
    }
}
```

### Solução com synchronized

```java
public class Counter {
    private int count = 0;

    public synchronized void increment() {
        count++;  // Thread-safe
    }

    public synchronized int getCount() {
        return count;
    }
}
```

### Solução com AtomicInteger

```java
import java.util.concurrent.atomic.AtomicInteger;

public class Counter {
    private AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();  // Thread-safe
    }

    public int getCount() {
        return count.get();
    }
}
```

### Check-Then-Act Race Condition

```java
public class LazyInit {
    private static Instance instance;

    public static Instance getInstance() {
        if (instance == null) {  // Check
            instance = new Instance();  // Act - Race condition
        }
        return instance;
    }
}
```

### Solução com Double-Checked Locking

```java
public class LazyInit {
    private static volatile Instance instance;

    public static Instance getInstance() {
        if (instance == null) {  // Primeiro check
            synchronized (LazyInit.class) {
                if (instance == null) {  // Segundo check
                    instance = new Instance();
                }
            }
        }
        return instance;
    }
}
```

## Comandos Úteis

### Usar synchronized

```java
public synchronized void method() {
    // Código thread-safe
}
```

### Usar ReentrantLock

```java
private final ReentrantLock lock = new ReentrantLock();

public void method() {
    lock.lock();
    try {
        // Código thread-safe
    } finally {
        lock.unlock();
    }
}
```

### Usar AtomicInteger

```java
private AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();
```

## Vantagens

### 1. Concorrência

```text
- Execução paralela
- Melhor performance
- Alta throughput
```

### 2. Recursos

```text
- Melhor utilização
- Compartilhamento
- Eficiência
```

### 3. Responsividade

```text
- Aplicação responsiva
- Não-bloqueante
- Melhor UX
```

## Limitações

### 1. Complexidade

```text
- Difícil de debugar
- Bugs intermitentes
- Curva de aprendizado
```

### 2. Performance

```text
- Overhead de sincronização
- Contenção
- Performance reduzida
```

### 3. Deadlocks

```text
- Possibilidade de deadlocks
- Bloqueios
- Aplicação travada
```

## Melhores Práticas

### 1. Usar Sincronização

```java
public synchronized void method() {
    // Código thread-safe
}
```

### 2. Usar Classes Atômicas

```java
private AtomicInteger counter = new AtomicInteger(0);
```

### 3. Usar Collections Thread-Safe

```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
```

### 4. Usar Immutable Objects

```java
public final class ImmutableUser {
    private final String name;
    // Thread-safe por imutabilidade
}
```

## Trade-offs

### synchronized vs ReentrantLock

- **synchronized**: Simples, automático, menos controle
- **ReentrantLock**: Flexível, manual, mais controle
- **Escolha**: synchronized para simples, ReentrantLock para avançado

### AtomicInteger vs synchronized

- **AtomicInteger**: Atômico, leve, específico
- **synchronized**: Geral, pesado, flexível
- **Escolha**: AtomicInteger para contadores, synchronized para geral

### Immutable vs Mutable

- **Immutable**: Thread-safe, simples, imutável
- **Mutable**: Flexível, complexo, requer sincronização
- **Escolha**: Immutable quando possível, Mutable com sincronização

### _Links_

- <https://docs.oracle.com/javase/tutorial/essential/concurrency/>
- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/package-summary.html>
- <https://www.baeldung.com/java-race-condition>
