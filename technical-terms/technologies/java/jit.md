# JIT

JIT (Just-In-Time Compiler) é um componente da JVM que compila bytecode em código nativo em tempo de execução, otimizando código frequentemente executado para melhorar performance através de análise de perfil e otimizações dinâmicas.

## Definição

JIT Compiler é um componente da JVM que compila bytecode Java em código nativo da máquina em tempo de execução, aplicando otimizações baseadas em perfil de execução para melhorar performance de código frequentemente executado (hot code).

```text
JIT = Compilação em tempo de execução + Otimizações dinâmicas + Código nativo
```

## Como Funciona

### 1. Tipos de JIT

```text
- C1 Compiler: Compilador client, rápido, menos otimizações
- C2 Compiler: Compilador server, lento, mais otimizações
- Graal: Compilador poliglota, mais otimizações
- Tiered Compilation: Combina C1 e C2
```

### 2. Processo

```text
- Interpreter: Executa bytecode inicialmente
- Profiling: Coleta dados de execução
- Compilation: Compila código hot
- Optimization: Aplica otimizações
- Deoptimization: Reverte se necessário
```

### 3. Otimizações

```text
- Inlining: Substitui chamadas de método
- Loop Unrolling: Expande loops
- Dead Code Elimination: Remove código morto
- Escape Analysis: Alocação no stack
```

## Exemplo Prático

### Configurar JIT

```bash
# Usar C1 apenas
java -client MyApp

# Usar C2 apenas
java -server MyApp

# Habilitar tiered compilation (padrão)
java -XX:+TieredCompilation MyApp

# Desabilitar tiered compilation
java -XX:-TieredCompilation MyApp

# Usar Graal
java -XX:+UnlockExperimentalVMOptions -XX:+UseJVMCICompiler MyApp
```

### Ver Compilação JIT

```bash
# Ver logs de compilação
java -XX:+PrintCompilation MyApp

# Ver detalhes de compilação
java -XX:+PrintCompilation -XX:+Verbose MyApp

# Ver inlining
java -XX:+PrintInlining MyApp
```

### Código para Monitorar JIT

```java
public class JITMonitor {
    public static void main(String[] args) {
        // Warmup
        for (int i = 0; i < 10000; i++) {
            compute(i);
        }
        
        // Medir performance após JIT
        long start = System.nanoTime();
        for (int i = 0; i < 1000000; i++) {
            compute(i);
        }
        long end = System.nanoTime();
        
        System.out.println("Time: " + (end - start) / 1000000 + " ms");
    }
    
    private static int compute(int n) {
        return n * n;
    }
}
```

### Forçar Compilação

```java
import java.lang.management.ManagementFactory;
import com.sun.management.HotSpotDiagnosticMXBean;

public class ForceCompilation {
    public static void main(String[] args) throws Exception {
        HotSpotDiagnosticMXBean mxBean = ManagementFactory.getPlatformMXBean(HotSpotDiagnosticMXBean.class);
        
        // Forçar compilação de método
        mxBean.setVMOption("CompileThreshold", "100");
    }
}
```

## Comandos Úteis

### Monitorar JIT

```bash
# Ver logs de compilação
java -XX:+PrintCompilation MyApp

# Ver métodos compilados
java -XX:+PrintCompilation -XX:+PrintInlining MyApp

# Ver estatísticas de JIT
java -XX:+PrintSafepointStatistics MyApp
```

### Debug

```bash
# Ver detalhes de compilação
java -XX:+UnlockDiagnosticVMOptions -XX:+PrintCompilation -XX:+PrintInlining MyApp

# Ver código nativo gerado
java -XX:+PrintAssembly MyApp

# Ver deoptimization
java -XX:+PrintDeoptimizationDetails MyApp
```

## Vantagens

### 1. Performance

```text
- Código nativo é mais rápido
- Otimizações dinâmicas
- Adaptação ao perfil
```

### 2. Adaptativo

```text
- Aprende com execução
- Otimiza código hot
- Reverte se necessário
```

### 3. Transparente

```text
- Automático
- Sem mudanças no código
- Melhora performance gradualmente
```

## Limitações

### 1. Warmup

```text
- Requer warmup para otimizar
- Performance inicial lenta
- Não ideal para curta duração
```

### 2. Complexidade

```text
- Compilação complexa
- Overhead de compilação
- Requer memória extra
```

### 3. Debugging

```text
- Difícil de debugar
- Comportamento não determinístico
- Requer ferramentas específicas
```

## Melhores Práticas

### 1. Permitir Warmup Adequado

```java
// Warmup antes de medir
for (int i = 0; i < 10000; i++) {
    compute(i);
}
```

### 2. Usar Tiered Compilation

```bash
-XX:+TieredCompilation
```

### 3. Evitar Microbenchmarks Sem JMH

```java
// Usar JMH para benchmarks
@Benchmark
public void benchmark() {
    compute(100);
}
```

### 4. Monitorar Compilação

```bash
# Ver logs de compilação
java -XX:+PrintCompilation MyApp
```

## Trade-offs

### C1 vs C2

- **C1**: Rápido, menos otimizações
- **C2**: Lento, mais otimizações
- **Escolha**: C1 para startup, C2 para throughput

### Tiered vs Single Tier

- **Tiered**: Warmup rápido, mais overhead
- **Single**: Warmup lento, menos overhead
- **Escolha**: Tiered para geral, single para específico

### Graal vs C2

- **Graal**: Mais otimizações, mais memória
- **C2**: Menos otimizações, menos memória
- **Escolha**: Graal para performance, C2 para compatibilidade

### _Links_

- <https://docs.oracle.com/javase/8/docs/technotes/guides/vm/performance/>
- <https://openjdk.org/groups/hotspot/docs/CompilerInterface.html>
- <https://www.baeldung.com/jvm-just-in-time-compiler>
