# Micrometer

Micrometer é uma biblioteca de métricas que fornece uma fachada simples para múltiplos sistemas de monitoramento como Prometheus, Atlas, Datadog, Graphite e InfluxDB, facilitando a instrumentação de aplicações Java.

## Definição

Micrometer é uma biblioteca de métricas que fornece uma fachada simples para múltiplos sistemas de monitoramento como Prometheus, Atlas, Datadog, Graphite e InfluxDB, facilitando a instrumentação de aplicações Java com métricas como counters, gauges, timers e summaries.

```text
Micrometer = Métricas + Fachada + Múltiplos sistemas + Instrumentação + Observabilidade
```

## Como Funciona

### 1. Tipos de Métricas

```text
- Counter: Contador monotônico
- Gauge: Valor que sobe e desce
- Timer: Tempo de execução
- DistributionSummary: Distribuição de valores
```

### 2. Registry

```text
- MeterRegistry: Registro de métricas
- SimpleMeterRegistry: Simples, in-memory
- PrometheusMeterRegistry: Prometheus
- CompositeMeterRegistry: Múltiplos registries
```

### 3. Tags

```text
- Tags: Chave-valor para agrupar métricas
- Labels: Similar a tags
- Dimensions: Agrupamento de métricas
```

## Exemplo Prático

### Configurar Micrometer

```java
@Configuration
public class MicrometerConfig {

    @Bean
    public MeterRegistryCustomizer<MeterRegistry> metricsCommonTags() {
        return registry -> registry.config().commonTags(
            "application", "my-app",
            "environment", "production"
        );
    }
}
```

### Counter

```java
@Component
public class MetricsService {

    private final Counter requestCounter;

    public MetricsService(MeterRegistry meterRegistry) {
        this.requestCounter = Counter.builder("http.requests")
            .description("Number of HTTP requests")
            .tag("type", "api")
            .register(meterRegistry);
    }

    public void incrementRequest() {
        requestCounter.increment();
    }

    public void incrementRequestBy(double amount) {
        requestCounter.increment(amount);
    }
}
```

### Gauge

```java
@Component
public class MetricsService {

    private final AtomicInteger queueSize = new AtomicInteger(0);

    public MetricsService(MeterRegistry meterRegistry) {
        Gauge.builder("queue.size", queueSize, AtomicInteger::get)
            .description("Size of the queue")
            .register(meterRegistry);
    }

    public void addToQueue() {
        queueSize.incrementAndGet();
    }

    public void removeFromQueue() {
        queueSize.decrementAndGet();
    }
}
```

### Timer

```java
@Component
public class MetricsService {

    private final Timer requestTimer;

    public MetricsService(MeterRegistry meterRegistry) {
        this.requestTimer = Timer.builder("http.request.duration")
            .description("Duration of HTTP requests")
            .register(meterRegistry);
    }

    public void recordRequest(Runnable request) {
        requestTimer.record(request);
    }

    public <T> T recordRequest(Supplier<T> request) {
        return requestTimer.record(request);
    }
}
```

### DistributionSummary

```java
@Component
public class MetricsService {

    private final DistributionSummary responseSizeSummary;

    public MetricsService(MeterRegistry meterRegistry) {
        this.responseSizeSummary = DistributionSummary.builder("http.response.size")
            .description("Size of HTTP responses")
            .register(meterRegistry);
    }

    public void recordResponseSize(int size) {
        responseSizeSummary.record(size);
    }
}
```

### Prometheus Config

```java
@Configuration
public class PrometheusConfig {

    @Bean
    MeterRegistryCustomizer<PrometheusMeterRegistry> prometheusMetrics() {
        return registry -> registry.config().commonTags(
            "application", "my-app"
        );
    }
}
```

### Custom Metrics

```java
@Component
public class CustomMetrics {

    private final MeterRegistry meterRegistry;

    public CustomMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    public void recordCustomMetric(String name, double value, String... tags) {
        meterRegistry.counter(name, tags).increment(value);
    }
}
```

## Comandos Úteis

### Criar Counter

```java
Counter counter = Counter.builder("my.counter")
    .description("My counter")
    .register(meterRegistry);
```

### Criar Gauge

```java
Gauge.builder("my.gauge", value, () -> value.get())
    .register(meterRegistry);
```

### Criar Timer

```java
Timer timer = Timer.builder("my.timer")
    .description("My timer")
    .register(meterRegistry);
```

## Vantagens

### 1. Fachada

```text
- API simples
- Múltiplos sistemas
- Abstração consistente
```

### 2. Flexibilidade

```text
- Múltiplos tipos de métricas
- Tags customizadas
- Extensível
```

### 3. Integração

```text
- Integrado ao Spring Boot
- Suporte a Prometheus
- Suporte a múltiplos sistemas
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Tipos de métricas
- Configuração complexa
```

### 2. Performance

```text
- Overhead de métricas
- Memória adicional
- Performance reduzida
```

### 3. Limitações

```text
- Limitações de sistemas
- Configuração específica
- Debugging desafiador
```

## Melhores Práticas

### 1. Usar Tags

```java
Counter.builder("http.requests")
    .tag("method", "GET")
    .tag("status", "200")
    .register(meterRegistry);
```

### 2. Usar Common Tags

```java
registry.config().commonTags(
    "application", "my-app",
    "environment", "production"
);
```

### 3. Usar Descrições

```java
Counter.builder("my.counter")
    .description("Description of the counter")
    .register(meterRegistry);
```

### 4. Usar Timer para Operações

```java
timer.record(() -> {
    // Operação
});
```

## Trade-offs

### Counter vs Gauge

- **Counter**: Monotônico, incrementa
- **Gauge**: Sobe e desce, valor atual
- **Escolha**: Counter para contagem, Gauge para valor

### Timer vs DistributionSummary

- **Timer**: Tempo de execução
- **DistributionSummary**: Distribuição de valores
- **Escolha**: Timer para tempo, DistributionSummary para valores

### Prometheus vs Outros

- **Prometheus**: Pull-based, popular
- **Outros**: Push-based, específico
- **Escolha**: Prometheus para padrão, outros para específico

### _Links_

- <https://micrometer.io/docs>
- <https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics>
- <https://prometheus.io/docs/concepts/metric_types/>
