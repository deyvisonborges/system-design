# ForkJoinPool

ForkJoinPool é um ExecutorService implementado com work-stealing, ideal para tarefas recursivas que podem ser divididas em subtarefas menores, otimizando o uso de threads em aplicações com alto paralelismo.

## Definição

ForkJoinPool é um ExecutorService implementado com algoritmo work-stealing, projetado para executar tarefas recursivas que podem ser divididas em subtarefas menores (fork) e cujos resultados são combinados (join), otimizando o uso de threads em aplicações com alto paralelismo.

```text
ForkJoinPool = Work-stealing + Tarefas recursivas + Fork/Join + Alto paralelismo
```

## Como Funciona

### 1. Algoritmo Work-Stealing

```text
- Cada thread tem sua própria fila de tarefas
- Threads ociosas roubam tarefas de outras filas
- Reduz contenção e melhora throughput
- Ideal para tarefas recursivas
```

### 2. Fork/Join

```text
- Fork: Divide tarefa em subtarefas
- Join: Aguarda resultado das subtarefas
- RecursiveTask: Tarefa com retorno
- RecursiveAction: Tarefa sem retorno
```

### 3. Estrutura

```text
- Pool: Conjunto de threads
- Queues: Filas de tarefas por thread
- Work-stealing: Threads roubam tarefas
- Common Pool: Pool compartilhado (ForkJoinPool.commonPool())
```

## Exemplo Prático

### RecursiveTask

```java
public class ForkJoinExample {
    public static void main(String[] args) {
        ForkJoinPool pool = new ForkJoinPool();
        
        int[] array = new int[1000000];
        Arrays.fill(array, 1);
        
        SumTask task = new SumTask(array, 0, array.length);
        Long result = pool.invoke(task);
        
        System.out.println("Sum: " + result);
    }

    static class SumTask extends RecursiveTask<Long> {
        private final int[] array;
        private final int start;
        private final int end;
        private static final int THRESHOLD = 10000;

        SumTask(int[] array, int start, int end) {
            this.array = array;
            this.start = start;
            this.end = end;
        }

        @Override
        protected Long compute() {
            if (end - start <= THRESHOLD) {
                long sum = 0;
                for (int i = start; i < end; i++) {
                    sum += array[i];
                }
                return sum;
            } else {
                int mid = (start + end) / 2;
                SumTask left = new SumTask(array, start, mid);
                SumTask right = new SumTask(array, mid, end);
                
                left.fork();
                Long rightResult = right.compute();
                Long leftResult = left.join();
                
                return leftResult + rightResult;
            }
        }
    }
}
```

### RecursiveAction

```java
public class ForkJoinActionExample {
    public static void main(String[] args) {
        ForkJoinPool pool = new ForkJoinPool();
        
        int[] array = new int[1000000];
        Arrays.fill(array, 1);
        
        IncrementTask task = new IncrementTask(array, 0, array.length);
        pool.invoke(task);
        
        System.out.println("First element: " + array[0]);
    }

    static class IncrementTask extends RecursiveAction {
        private final int[] array;
        private final int start;
        private final int end;
        private static final int THRESHOLD = 10000;

        IncrementTask(int[] array, int start, int end) {
            this.array = array;
            this.start = start;
            this.end = end;
        }

        @Override
        protected void compute() {
            if (end - start <= THRESHOLD) {
                for (int i = start; i < end; i++) {
                    array[i]++;
                }
            } else {
                int mid = (start + end) / 2;
                IncrementTask left = new IncrementTask(array, start, mid);
                IncrementTask right = new IncrementTask(array, mid, end);
                
                invokeAll(left, right);
            }
        }
    }
}
```

### Common Pool

```java
public class CommonPoolExample {
    public static void main(String[] args) {
        // Usar common pool
        ForkJoinPool commonPool = ForkJoinPool.commonPool();
        
        System.out.println("Parallelism: " + commonPool.getParallelism());
        
        // Submeter tarefa
        commonPool.submit(() -> {
            System.out.println("Task in common pool");
        }).join();
    }
}
```

### Custom Parallelism

```java
public class CustomParallelismExample {
    public static void main(String[] args) {
        // Criar pool com paralelismo customizado
        ForkJoinPool pool = new ForkJoinPool(4);
        
        try {
            pool.submit(() -> {
                System.out.println("Task in custom pool");
            }).join();
        } finally {
            pool.shutdown();
        }
    }
}
```

## Comandos Úteis

### Configurar Parallelism

```bash
# Configurar paralelismo do common pool
-Djava.util.concurrent.ForkJoinPool.common.parallelism=8
```

### Monitorar Pool

```java
ForkJoinPool pool = ForkJoinPool.commonPool();

// Ver estatísticas
System.out.println("Parallelism: " + pool.getParallelism());
System.out.println("Pool size: " + pool.getPoolSize());
System.out.println("Active threads: " + pool.getActiveThreadCount());
System.out.println("Queued tasks: " + pool.getQueuedTaskCount());
```

## Vantagens

### 1. Work-Stealing Eficiente

```text
- Threads ociosas roubam tarefas
- Menos contenção
- Melhor throughput
```

### 2. Eficiência

```text
- Ideal para tarefas recursivas
- Divisão automática
- Combinação eficiente
```

### 3. Common Pool

```text
- Pool compartilhado
- Sem criação manual
- Otimizado para streams paralelos
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Debugging desafiador
- Requer entendimento de recursão
```

### 2. Overhead

```text
- Overhead de criação de tarefas
- Não ideal para tarefas simples
- Context switching
```

### 3. Blocking

```text
- Blocking pode causar starvation
- Não ideal para I/O-bound
- Requer tarefas CPU-bound
```

## Melhores Práticas

### 1. Usar Common Pool para Streams

```java
list.parallelStream().forEach(item -> process(item));
```

### 2. Definir Threshold Adequado

```java
private static final int THRESHOLD = 10000;
```

### 3. Evitar Blocking

```java
// Evitar blocking em tarefas
// Preferir tarefas CPU-bound
```

### 4. Usar invokeAll

```java
invokeAll(left, right);  // Executa ambas e aguarda
```

## Trade-offs

### ForkJoinPool vs ThreadPoolExecutor

- **ForkJoin**: Work-stealing, recursivo, CPU-bound
- **ThreadPoolExecutor**: Fila compartilhada, geral, I/O-bound
- **Escolha**: ForkJoin para recursivo, ThreadPoolExecutor para geral

### RecursiveTask vs RecursiveAction

- **RecursiveTask**: Com retorno, combina resultados
- **RecursiveAction**: Sem retorno, efeito colateral
- **Escolha**: Task para resultado, Action para efeito

### Common Pool vs Custom Pool

- **Common**: Compartilhado, simples
- **Custom**: Controlado, específico
- **Escolha**: Common para geral, custom para específico

### _Links_

- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ForkJoinPool.html>
- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/RecursiveTask.html>
- <https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/RecursiveAction.html>
