# GC

GC (Garbage Collector) é o componente da JVM responsável pelo gerenciamento automático de memória, identificando e removendo objetos que não são mais utilizados, prevenindo memory leaks e simplificando o desenvolvimento.

## Definição

GC é o mecanismo de gerenciamento automático de memória da JVM que identifica e coleta objetos inacessíveis, liberando memória para reutilização, prevenindo memory leaks e simplificando o desenvolvimento ao eliminar a necessidade de gerenciamento manual de memória.

```text
GC = Gerenciamento automático de memória + Coleta de objetos + Prevenção de leaks
```

## Como Funciona

### 1. Tipos de GC

```text
- Serial: Single-threaded, para pequenas aplicações
- Parallel: Multi-threaded, para throughput
- G1: Region-based, balanceado
- ZGC: Low latency, escalável
- Shenandoah: Low latency, concurrent
```

### 2. Fases

```text
- Mark: Identifica objetos alcançáveis
- Sweep: Remove objetos não alcançáveis
- Compact: Reorganiza memória fragmentada
- Copy: Move objetos entre regiões
```

### 3. Gerações

```text
- Young Generation: Objetos recém-criados
- Old Generation: Objetos de longa vida
- Survivor Space: Objetos que sobreviveram GC
```

## Exemplo Prático

### Configurar G1 GC

```bash
java -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:G1HeapRegionSize=16m \
     -XX:InitiatingHeapOccupancyPercent=45 \
     MyApp
```

### Configurar ZGC

```bash
java -XX:+UseZGC \
     -XX:ZCollectionInterval=5 \
     MyApp
```

### Configurar Parallel GC

```bash
java -XX:+UseParallelGC \
     -XX:ParallelGCThreads=4 \
     MyApp
```

### Habilitar GC Logging

```bash
java -XX:+PrintGCDetails \
     -XX:+PrintGCDateStamps \
     -Xloggc:/path/to/gc.log \
     -XX:+UseGCLogFileRotation \
     -XX:NumberOfGCLogFiles=5 \
     -XX:GCLogFileSize=10M \
     MyApp
```

### Analisar Heap Dump

```bash
# Gerar heap dump
jmap -dump:format=b,file=heap.hprof <pid>

# Analisar com jhat
jhat heap.hprof

# Analisar com Eclipse MAT
# Abrir heap.hprof no Eclipse MAT
```

## Comandos Úteis

### Monitorar GC

```bash
# Ver estatísticas de GC
jstat -gc <pid> 1s 10

# Ver detalhes do heap
jmap -heap <pid>

# Ver histograma de objetos
jmap -histo <pid>

# Ver GC logs
tail -f gc.log
```

### Debug

```bash
# Ver flags de GC
java -XX:+PrintFlagsFinal -version | grep GC

# Ver GC em tempo real
jvisualvm

# Ver detalhes de GC
jconsole
```

## Vantagens

### 1. Automático

```text
- Sem gerenciamento manual
- Simplifica desenvolvimento
- Reduz erros
```

### 2. Prevenção de Leaks

```text
- Coleta objetos não utilizados
- Previne memory leaks
- Libera memória automaticamente
```

### 3. Flexibilidade

```text
- Múltiplos algoritmos
- Configurável
- Adaptável a diferentes cenários
```

## Limitações

### 1. Performance

```text
- Pausas de GC (Stop-the-world)
- Overhead de CPU
- Latência imprevisível
```

### 2. Complexidade

```text
- Tuning complexo
- Múltiplos parâmetros
- Requer entendimento profundo
```

### 3. Debugging

```text
- Debugging de memory leaks desafiador
- Requer ferramentas específicas
- Análise de heap dumps complexa
```

## Melhores Práticas

### 1. Escolher GC Adequado

```bash
# G1 para geral (padrão Java 9+)
-XX:+UseG1GC

# ZGC para low latency (Java 11+)
-XX:+UseZGC

# Parallel para throughput
-XX:+UseParallelGC
```

### 2. Configurar Heap Adequadamente

```bash
-Xms512m -Xmx2g
```

### 3. Habilitar GC Logging

```bash
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-Xloggc:gc.log
```

### 4. Monitorar Regularmente

```bash
# Usar jstat
jstat -gc <pid> 1s 10

# Usar VisualVM
jvisualvm

# Usar JConsole
jconsole
```

## Trade-offs

### G1 vs ZGC vs Shenandoah

- **G1**: Balanceado, padrão
- **ZGC**: Low latency, mais memória
- **Shenandoah**: Low latency, mais CPU
- **Escolha**: G1 para geral, ZGC/Shenandoah para low latency

### Serial vs Parallel

- **Serial**: Single-threaded, simples
- **Parallel**: Multi-threaded, mais rápido
- **Escolha**: Serial para pequenas, Parallel para grandes

### Throughput vs Latency

- **Throughput**: Maximiza throughput, mais GC
- **Latency**: Minimiza pausas, mais overhead
- **Escolha**: Throughput para batch, Latency para interativo

### _Links_

- <https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/>
- <https://openjdk.org/groups/hotspot/docs/hotspot-gc-user-guide.html>
- <https://docs.oracle.com/en/java/javase/17/gctuning/>
