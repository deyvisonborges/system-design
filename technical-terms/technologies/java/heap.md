# Heap

Heap é a área de memória da JVM onde objetos e arrays são alocados dinamicamente, gerenciada pelo Garbage Collector para coletar objetos não utilizados e liberar memória para reutilização.

## Definição

Heap é a área de memória da JVM usada para armazenar objetos e arrays alocados dinamicamente, gerenciada pelo Garbage Collector que identifica e coleta objetos inacessíveis, liberando memória para reutilização e prevenindo memory leaks.

```text
Heap = Alocação dinâmica + Objetos + Gerenciamento via GC
```

## Como Funciona

### 1. Estrutura

```text
- Young Generation: Objetos recém-criados
  - Eden Space: Novos objetos
  - Survivor Spaces: S0, S1
- Old Generation: Objetos de longa vida
  - Tenured Space: Objetos que sobreviveram GCs
- Metaspace: Metadados de classes (Java 8+)
```

### 2. Alocação

```text
- TLAB (Thread Local Allocation Buffer): Alocação rápida por thread
- Eden Space: Objetos novos alocados aqui
- Survivor: Objetos que sobreviveram GC
- Old Generation: Objetos de longa vida
```

### 3. Coleta

```text
- Minor GC: Coleta apenas Young Generation
- Major GC: Coleta Old Generation
- Full GC: Coleta todas as gerações
- Compactação: Reorganiza memória fragmentada
```

## Exemplo Prático

### Configurar Heap

```bash
# Configuração básica
java -Xms512m -Xmx2g MyApp

# Configuração com gerações
java -Xms512m -Xmx2g \
     -XX:NewRatio=2 \
     -XX:SurvivorRatio=8 \
     MyApp

# Configuração para G1
java -Xms512m -Xmx2g \
     -XX:+UseG1GC \
     -XX:G1HeapRegionSize=16m \
     MyApp
```

### Analisar Heap

```bash
# Ver heap dump
jmap -heap <pid>

# Gerar heap dump
jmap -dump:format=b,file=heap.hprof <pid>

# Ver histograma
jmap -histo <pid>
```

### Código para Monitorar Heap

```java
public class HeapMonitor {
    public static void printHeapInfo() {
        Runtime runtime = Runtime.getRuntime();
        long totalMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        long usedMemory = totalMemory - freeMemory;
        long maxMemory = runtime.maxMemory();

        System.out.println("Total Memory: " + (totalMemory / 1024 / 1024) + " MB");
        System.out.println("Free Memory: " + (freeMemory / 1024 / 1024) + " MB");
        System.out.println("Used Memory: " + (usedMemory / 1024 / 1024) + " MB");
        System.out.println("Max Memory: " + (maxMemory / 1024 / 1024) + " MB");
    }
}
```

### Evitar Memory Leak

```java
// Memory leak com static collection
public class MemoryLeakExample {
    private static final List<Object> cache = new ArrayList<>();

    public void addToCache(Object obj) {
        cache.add(obj);  // Nunca removido
    }
}

// Correção com WeakHashMap
public class MemoryLeakFixed {
    private static final Map<Object, Object> cache = new WeakHashMap<>();

    public void addToCache(Object obj) {
        cache.put(obj, obj);  // Pode ser coletado
    }
}
```

## Comandos Úteis

### Monitorar Heap

```bash
# Ver estatísticas de heap
jstat -gc <pid> 1s 10

# Ver detalhes do heap
jmap -heap <pid>

# Ver histograma de objetos
jmap -histo <pid>

# Gerar heap dump
jmap -dump:format=b,file=heap.hprof <pid>
```

### Analisar Heap Dump

```bash
# Analisar com jhat
jhat heap.hprof

# Analisar com Eclipse MAT
# Abrir heap.hprof no Eclipse MAT

# Analisar com VisualVM
jvisualvm
```

## Vantagens

### 1. Alocação Dinâmica

```text
- Alocação em tempo de execução
- Flexibilidade
- Sem tamanho fixo
```

### 2. Gerenciamento Automático

```text
- GC gerencia memória
- Sem gerenciamento manual
- Previne memory leaks
```

### 3. Eficiência

```text
- TLAB para alocação rápida
- Gerações para otimização
- Compactação para reduzir fragmentação
```

## Limitações

### 1. Fragmentação

```text
- Memória fragmentada
- Requer compactação
- Pode causar GCs frequentes
```

### 2. Performance

```text
- GC pausa threads
- Overhead de alocação
- Latência imprevisível
```

### 3. Tamanho Fixo

```text
- Heap size configurado na inicialização
- Não pode crescer além do máximo
- Requer tuning adequado
```

## Melhores Práticas

### 1. Configurar Heap Adequadamente

```bash
-Xms512m -Xmx2g
```

### 2. Usar TLAB

```bash
-XX:+UseTLAB
```

### 3. Evitar Memory Leaks

```java
// Usar WeakReference para cache
private static final Map<Object, Object> cache = new WeakHashMap<>();

// Limpar recursos manualmente
public void cleanup() {
    cache.clear();
}
```

### 4. Monitorar Regularmente

```bash
# Usar jstat
jstat -gc <pid> 1s 10

# Usar VisualVM
jvisualvm
```

## Trade-offs

### Young vs Old Generation

- **Young**: Alocação rápida, GCs frequentes
- **Old**: Menos GCs, mais overhead
- **Escolha**: Balancear com NewRatio

### Heap Size Pequeno vs Grande

- **Pequeno**: Menos memória, mais GC
- **Grande**: Mais memória, menos GC
- **Escolha**: Balancear entre memória e GC

### TLAB vs Sem TLAB

- **TLAB**: Alocação rápida, mais memória
- **Sem TLAB**: Menos memória, mais lento
- **Escolha**: TLAB para aplicações com alta alocação

### _Links_

- <https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/>
- <https://openjdk.org/groups/hotspot/docs/hotspot-gc-user-guide.html>
- <https://docs.oracle.com/en/java/javase/17/gctuning/>
