# Actuator

Spring Boot Actuator fornece endpoints de produção para monitoramento e gerenciamento de aplicações Spring Boot, incluindo health checks, metrics, info, env e outros, facilitando operações e observabilidade.

## Definição

Spring Boot Actuator fornece endpoints de produção para monitoramento e gerenciamento de aplicações Spring Boot, incluindo health checks, metrics, info, env, loggers, heapdump e outros, facilitando operações e observabilidade através de endpoints HTTP e JMX.

```text
Actuator = Monitoramento + Gerenciamento + Health + Metrics + Observabilidade
```

## Como Funciona

### 1. Endpoints

```text
- /health: Health check
- /metrics: Métricas da aplicação
- /info: Informações da aplicação
- /env: Propriedades do ambiente
- /loggers: Configuração de loggers
- /heapdump: Heap dump
```

### 2. Configuração

```text
- management.endpoints: Configuração de endpoints
- management.endpoint: Configuração específica
- management.health: Configuração de health
- management.metrics: Configuração de metrics
```

### 3. Integração

```text
- Micrometer: Métricas
- Prometheus: Exportação de métricas
- Grafana: Visualização
- JMX: Java Management Extensions
```

## Exemplo Prático

### Habilitar Actuator

```java
@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}
```

### application.properties

```properties
# Habilitar todos os endpoints
management.endpoints.web.exposure.include=*

# Habilitar endpoints específicos
management.endpoints.web.exposure.include=health,info,metrics

# Habilitar health details
management.endpoint.health.show-details=always

# Configurar base path
management.endpoints.web.base-path=/actuator
```

### Custom Health Indicator

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        // Lógica customizada de health check
        boolean isHealthy = checkHealth();
        
        if (isHealthy) {
            return Health.up()
                .withDetail("service", "custom")
                .withDetail("status", "OK")
                .build();
        } else {
            return Health.down()
                .withDetail("service", "custom")
                .withDetail("status", "ERROR")
                .build();
        }
    }

    private boolean checkHealth() {
        // Lógica de verificação
        return true;
    }
}
```

### Custom Info Contributor

```java
@Component
public class CustomInfoContributor implements InfoContributor {

    @Override
    public void contribute(Info.Builder builder) {
        builder.withDetail("app", Map.of(
            "name", "My App",
            "version", "1.0.0",
            "description", "Custom application"
        ));
    }
}
```

### Custom Metrics

```java
@Component
public class CustomMetrics {

    private final Counter customCounter;
    private final Gauge<Integer> customGauge;

    public CustomMetrics(MeterRegistry meterRegistry) {
        customCounter = Counter.builder("custom.counter")
            .description("Custom counter")
            .register(meterRegistry);
        
        customGauge = Gauge.builder("custom.gauge", () -> 42)
            .description("Custom gauge")
            .register(meterRegistry);
    }

    public void incrementCounter() {
        customCounter.increment();
    }
}
```

### Prometheus Config

```properties
# Habilitar Prometheus endpoint
management.endpoints.web.exposure.include=prometheus

# Configurar tags
management.metrics.tags.application=my-app
```

### Security Config

```java
@Configuration
public class ActuatorSecurityConfig {

    @Bean
    public SecurityFilterChain actuatorSecurityFilterChain(HttpSecurity http) throws Exception {
        http
            .securityMatcher("/actuator/**")
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/actuator/info").permitAll()
                .anyRequest().authenticated()
            )
            .httpBasic(Customizer.withDefaults());
        return http.build();
    }
}
```

## Comandos Úteis

### Habilitar Endpoints

```properties
management.endpoints.web.exposure.include=health,info,metrics
```

### Habilitar Health Details

```properties
management.endpoint.health.show-details=always
```

### Configurar Base Path

```properties
management.endpoints.web.base-path=/actuator
```

## Vantagens

### 1. Monitoramento

```text
- Health checks
- Métricas
- Informações
```

### 2. Gerenciamento

```text
- Loggers
- Environment
- Threads
```

### 3. Observabilidade

```text
- Integração com Prometheus
- Integração com Grafana
- Exportação de métricas
```

## Limitações

### 1. Security

```text
- Endpoints sensíveis
- Requer autenticação
- Configuração necessária
```

### 2. Performance

```text
- Overhead de métricas
- Heap dump pesado
- Performance reduzida
```

### 3. Complexidade

```text
- Múltiplos endpoints
- Configuração complexa
- Curva de aprendizado
```

## Melhores Práticas

### 1. Habilitar Apenas Endpoints Necessários

```properties
management.endpoints.web.exposure.include=health,info,metrics
```

### 2. Configurar Security

```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/actuator/health").permitAll()
    .anyRequest().authenticated()
)
```

### 3. Usar Custom Health Indicators

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {
    // ...
}
```

### 4. Usar Micrometer

```java
@Component
public class CustomMetrics {
    // ...
}
```

## Trade-offs

### Todos vs Específicos

- **Todos**: Todos os endpoints, completo, inseguro
- **Específicos**: Apenas necessários, seguro, limitado
- **Escolha**: Específicos para produção, todos para desenvolvimento

### HTTP vs JMX

- **HTTP**: Web, simples, padronizado
- **JMX**: Java, complexo, específico
- **Escolha**: HTTP para web, JMX para Java

### Prometheus vs Outros

- **Prometheus**: Popular, pull-based
- **Outros**: Push-based, específico
- **Escolha**: Prometheus para padrão, outros para específico

### _Links_

- <https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html>
- <https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/actuate/package-summary.html>
- <https://www.baeldung.com/spring-boot-actuator>
