# JVM

JVM (Java Virtual Machine) é uma máquina virtual que permite executar bytecode Java em qualquer plataforma, fornecendo abstração de hardware, gerenciamento de memória automático e segurança através de sandbox.

## Definição

JVM é uma máquina virtual que executa bytecode Java, fornecendo independência de plataforma através da abstração de hardware, gerenciamento automático de memória via Garbage Collector e segurança através de sandbox e verificação de bytecode.

```text
JVM = Máquina virtual + Bytecode + Gerenciamento de memória + Independência de plataforma
```

## Como Funciona

### 1. Componentes

```text
- Class Loader: Carrega classes dinamicamente
- Memory Area: Heap, Stack, Method Area, PC Register
- Execution Engine: Interpreter, JIT Compiler, GC
- Native Interface: JNI para código nativo
```

### 2. Ciclo de Execução

```text
- Class Loader carrega bytecode
- Verificador valida bytecode
- Interpreter executa bytecode
- JIT compila código hot
- GC gerencia memória
```

### 3. Memória

```text
- Heap: Objetos e arrays
- Stack: Frames de métodos
- Method Area: Metadados de classes
- PC Register: Contador de programa
```

## Exemplo Prático

### Configuração de JVM

```bash
# Configuração básica
java -Xms512m -Xmx2g -XX:+UseG1GC MyApp

# Configuração avançada
java -Xms512m -Xmx2g \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:G1HeapRegionSize=16m \
     -XX:+PrintGCDetails \
     -XX:+PrintGCDateStamps \
     -Xloggc:/path/to/gc.log \
     MyApp
```

### Flags Comuns

```bash
# Heap
-Xms512m           # Heap inicial
-Xmx2g             # Heap máximo
-XX:NewRatio=2     # Ratio young/old

# GC
-XX:+UseG1GC       # Usar G1 GC
-XX:+UseZGC        # Usar ZGC (Java 11+)
-XX:+UseShenandoahGC # Usar Shenandoah (Java 12+)

# Logging
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-Xloggc:gc.log

# Performance
-XX:+UseCompressedOops
-XX:+UseStringDeduplication
```

### Ver Informações da JVM

```bash
# Ver versão da JVM
java -version

# Ver propriedades da JVM
java -XshowSettings:properties

# Ver VM settings
java -XshowSettings:vm

# Ver flags
java -XX:+PrintFlagsFinal -version
```

## Comandos Úteis

### Monitorar JVM

```bash
# Ver processos Java
jps

# Ver heap dump
jmap -heap <pid>

# Gerar heap dump
jmap -dump:format=b,file=heap.hprof <pid>

# Ver threads
jstack <pid>

# Ver estatísticas
jstat -gc <pid> 1s 10

# Ver GC logs
tail -f gc.log
```

### Debug

```bash
# Habilitar debug
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 MyApp

# Habilitar JMX
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9010 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     MyApp
```

## Vantagens

### 1. Independência de Plataforma

```text
- Write Once, Run Anywhere
- Abstração de hardware
- Portabilidade
```

### 2. Gerenciamento de Memória

```text
- Garbage Collector automático
- Sem memory leaks manuais
- Simplifica desenvolvimento
```

### 3. Segurança

```text
- Sandbox
- Verificação de bytecode
- Proteção de memória
```

## Limitações

### 1. Performance

```text
- Overhead de JVM
- Startup lento
- Consumo de memória
```

### 2. Complexidade

```text
- Tuning complexo
- Múltiplos GCs
- Flags numerosas
```

### 3. Debugging

```text
- Abstração de hardware
- Debugging desafiador
- Requer ferramentas específicas
```

## Melhores Práticas

### 1. Configurar Heap Adequadamente

```bash
-Xms512m -Xmx2g
```

### 2. Escolher GC Adequado

```bash
# G1 para geral
-XX:+UseG1GC

# ZGC para low latency (Java 11+)
-XX:+UseZGC

# Shenandoah para low latency (Java 12+)
-XX:+UseShenandoahGC
```

### 3. Habilitar GC Logging

```bash
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-Xloggc:gc.log
```

### 4. Monitorar Regularmente

```bash
# Usar JConsole
jconsole

# Usar VisualVM
jvisualvm

# Usar JMX
-Dcom.sun.management.jmxremote
```

## Trade-offs

### G1 vs ZGC vs Shenandoah

- **G1**: Balanceado, padrão
- **ZGC**: Low latency, mais memória
- **Shenandoah**: Low latency, mais CPU
- **Escolha**: G1 para geral, ZGC/Shenandoah para low latency

### Client vs Server JVM

- **Client**: Startup rápido, menos memória
- **Server**: Performance otimizada, mais memória
- **Escolha**: Server para produção, Client para desktop

### Heap Size Pequeno vs Grande

- **Pequeno**: Menos memória, mais GC
- **Grande**: Mais memória, menos GC
- **Escolha**: Balancear entre memória e GC

### _Links_

- <https://docs.oracle.com/javase/specs/jvms/se17/html/>
- <https://docs.oracle.com/javase/8/docs/technotes/guides/vm/>
- <https://openjdk.org/groups/hotspot/docs/hotspot-gc-user-guide.html>
