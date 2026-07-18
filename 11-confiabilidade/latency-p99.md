# Latency P99

Latency P99 (percentil 99) é uma métrica de latência que representa o valor abaixo do qual 99% das requisições são completadas. É uma das métricas mais importantes de tail latency, pois captura a experiência dos 1% piores casos, que são frequentemente os usuários mais afetados por problemas de performance.

## Definição

P99 é o 99º percentil da distribuição de latência, significando que 99% das requisições têm latência menor ou igual a este valor.

```text
P99 = Valor de latência onde 99% das requisições são mais rápidas
```

## Por que P99 é Importante

### 1. Foco nos Piores Casos

- **Experiência do usuário**: Os 1% piores casos afetam usuários mais sensíveis
- **Outliers**: Captura anomalias e problemas extremos
- **SLAs**: Muitos SLAs são baseados em P99

### 2. Detecção de Problemas

- **Anomalias**: Problemas que afetam poucos usuários
- **Degradação**: Degradação gradual pode ser detectada
- **Cascading failures**: Falhas em cascata afetam P99 primeiro

### 3. Priorização de Melhorias

- **Impacto real**: Melhorias que reduzem P99 têm alto impacto
- **ROI**: Focar nos problemas que mais afetam usuários
- **Resource allocation**: Alocar recursos onde mais necessário

## Cálculo de P99

### 1. Método Simples

```python
# Exemplo de cálculo de P99 simples
import numpy as np

def calculate_p99(latencies):
    """
    Calcula P99 de uma lista de latências
    
    Args:
        latencies: Lista de latências em ms
    """
    return np.percentile(latencies, 99)

# Exemplo
latencies = [10, 20, 30, 40, 50, 100, 200, 500, 1000, 2000]
p99 = calculate_p99(latencies)
print(f"P99: {p99}ms")
```

### 2. Método com Histograma

```python
# Exemplo de cálculo de P99 com histograma
from collections import defaultdict

class P99Calculator:
    def __init__(self, buckets=[1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]):
        self.buckets = buckets
        self.counts = defaultdict(int)
        self.total = 0
    
    def observe(self, latency_ms):
        """Registra uma latência"""
        self.total += 1
        for bucket in self.buckets:
            if latency_ms <= bucket:
                self.counts[bucket] += 1
    
    def calculate_p99(self):
        """Calcula P99 aproximado"""
        target_count = self.total * 0.99
        cumulative = 0
        
        for bucket in sorted(self.buckets):
            cumulative += self.counts[bucket]
            if cumulative >= target_count:
                return bucket
        
        return float('inf')

# Uso
calculator = P99Calculator()

for latency in [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000]:
    calculator.observe(latency)

p99 = calculator.calculate_p99()
print(f"P99: {p99}ms")
```

### 3. Método com Prometheus

```python
# Exemplo com Prometheus Histogram
from prometheus_client import Histogram

# Define histogram com buckets apropriados para P99
REQUEST_LATENCY = Histogram(
    'http_request_latency_seconds',
    'HTTP request latency',
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 10.0)
)

def process_request():
    start = time.time()
    
    # Processa requisição
    result = do_work()
    
    # Registra latência
    REQUEST_LATENCY.observe(time.time() - start)
    
    return result

# Query Prometheus para calcular P99
# histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

## P99 vs Outros Percentis

### Comparação

```text
P50 (Mediana): 50% das requisições são mais rápidas
P90: 90% das requisições são mais rápidas
P95: 95% das requisições são mais rápidas
P99: 99% das requisições são mais rápidas
P99.9: 99.9% das requisições são mais rápidas
```

### Quando Usar Cada Um

- **P50**: Experiência típica do usuário
- **P90**: Performance da maioria dos usuários
- **P95**: Performance de quase todos os usuários
- **P99**: Performance dos piores casos (mais usado em SLAs)
- **P99.9**: Performance extrema (sistemas críticos)

## Causas de P99 Alto

### 1. Garbage Collection

```java
// Exemplo de GC pause causando P99 alto
public class LatencyExample {
    private List<byte[]> data = new ArrayList<>();
    
    public void processData() {
        // Aloca muitos objetos
        for (int i = 0; i < 1000; i++) {
            data.add(new byte[1024 * 1024]); // 1MB
        }
        
        // GC pause pode causar spike de latência afetando P99
        System.gc();
    }
}
```

### 2. Lock Contention

```python
# Exemplo de lock contention afetando P99
import threading
import time

class SharedResource:
    def __init__(self):
        self.lock = threading.Lock()
        self.data = []
    
    def add_data(self, item):
        with self.lock:
            # Se outra thread segurou o lock por muito tempo,
            # esta thread terá alta latência (afetando P99)
            time.sleep(0.1)
            self.data.append(item)
```

### 3. Network Issues

- **Packet loss**: Retransmissão aumenta latência
- **Congestionamento**: Pacotes ficam em buffers
- **Route changes**: Pacotes tomam rotas mais longas

### 4. Database Issues

```sql
-- Query sem índice (full table scan) afeta P99
SELECT * FROM orders 
WHERE customer_id = 12345 
AND created_at > '2024-01-01';

-- Com índice (muito mais rápido)
CREATE INDEX idx_customer_created ON orders(customer_id, created_at);
```

## Otimização de P99

### 1. Hedged Requests

```python
# Exemplo de hedged requests para reduzir P99
import concurrent.futures
import time

def hedged_request(service_url, hedge_delay=0.1, max_attempts=2):
    """
    Faz requisição com hedge - envia segunda requisição se primeira demorar
    """
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        # Primeira requisição
        future1 = executor.submit(make_request, service_url)
        
        # Espera um pouco antes de fazer hedge
        time.sleep(hedge_delay)
        
        # Se primeira não completou, faz segunda requisição
        if not future1.done():
            future2 = executor.submit(make_request, service_url)
            
            # Retorna a primeira que completar
            done, _ = concurrent.futures.wait(
                [future1, future2],
                return_when=concurrent.futures.FIRST_COMPLETED
            )
            return done[0].result()
        
        return future1.result()
```

### 2. Caching

```python
# Exemplo de caching para reduzir P99
from functools import lru_cache
import time

@lru_cache(maxsize=1000)
def expensive_operation(key):
    """Operação cara com cache"""
    time.sleep(0.1)
    return f"result_{key}"

# Primeira chamada: 100ms
start = time.time()
result1 = expensive_operation("key1")
print(f"First call: {(time.time() - start) * 1000:.2f}ms")

# Segunda chamada: < 1ms (cache hit) - reduz P99
start = time.time()
result2 = expensive_operation("key1")
print(f"Second call: {(time.time() - start) * 1000:.2f}ms")
```

### 3. Connection Pooling

```python
# Exemplo de connection pooling para reduzir P99
from concurrent.futures import ThreadPoolExecutor
import queue

class ConnectionPool:
    def __init__(self, max_connections=10):
        self.pool = queue.Queue(max_connections)
        
        # Inicializa pool
        for _ in range(max_connections):
            self.pool.put(create_connection())
    
    def get_connection(self, timeout=1.0):
        """Obtém conexão do pool com timeout"""
        try:
            return self.pool.get(timeout=timeout)
        except queue.Empty:
            raise TimeoutError("No connection available")
    
    def return_connection(self, connection):
        """Retorna conexão ao pool"""
        self.pool.put(connection)
```

## Monitoramento de P99

### Métricas Importantes

- **P99 Latency**: Valor do 99º percentil
- **P99 Trend**: Tendência do P99 ao longo do tempo
- **P99/P50 Ratio**: Razão entre P99 e mediana
- **P99 Violations**: Número de violações do SLO de P99

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de P99
import numpy as np
from collections import deque

class P99Monitor:
    def __init__(self, window_size=1000):
        self.window_size = window_size
        self.latencies = deque(maxlen=window_size)
    
    def observe(self, latency_ms):
        """Registra uma latência"""
        self.latencies.append(latency_ms)
    
    def calculate_p99(self):
        """Calcula P99 atual"""
        if len(self.latencies) < 100:
            return None
        return np.percentile(self.latencies, 99)
    
    def calculate_p99_p50_ratio(self):
        """Calcula razão P99/P50"""
        if len(self.latencies) < 100:
            return None
        p50 = np.percentile(self.latencies, 50)
        p99 = np.percentile(self.latencies, 99)
        return p99 / p50 if p50 > 0 else float('inf')
    
    def check_slo_violation(self, slo_p99):
        """Verifica violação do SLO"""
        p99 = self.calculate_p99()
        if p99 is None:
            return False
        return p99 > slo_p99

# Uso
monitor = P99Monitor()

for i in range(1000):
    latency = np.random.lognormal(4, 0.5)  # Distribuição log-normal
    monitor.observe(latency)

p99 = monitor.calculate_p99()
ratio = monitor.calculate_p99_p50_ratio()
violation = monitor.check_slo_violation(1000)

print(f"P99: {p99:.2f}ms")
print(f"P99/P50 Ratio: {ratio:.2f}")
print(f"SLO Violation: {violation}")
```

## Exemplo de SLA de P99

```text
Requisitos de negócio:
- API de e-commerce com 1.000.000 requisições/dia
- 99% dos usuários devem ter experiência "boa"
- Experiência "boa" = resposta < 500ms

SLA de P99:
- P99 < 500ms para 95% do mês
- P99 < 1000ms para 99% do mês
- P99 < 2000ms para 99.9% do mês

Monitoramento:
- Alerta se P99 > 600ms por 5 minutos
- Alerta se P99 > 1000ms por 2 minutos
- Alerta se P99 > 2000ms por 1 minuto
- Alerta se P99/P50 ratio > 10 por 5 minutos

Penalidades:
- Crédito de 10% se P99 > 500ms por mais de 5% do mês
- Crédito de 25% se P99 > 1000ms por mais de 1% do mês
- Crédito de 50% se P99 > 2000ms por mais de 0.1% do mês
```

## Trade-offs

### P99 vs Custo

- Reduzir P99 geralmente aumenta custo
- Avaliar custo por melhoria de P99
- Priorizar redução onde tem maior impacto no negócio

### P99 vs Throughput

- Reduzir P99 pode reduzir throughput
- Encontrar balanceamento adequado
- Avaliar trade-off baseado nos requisitos

### P99 vs Complexidade

- Soluções para reduzir P99 aumentam complecidade
- Manter simplicidade quando possível
- Avaliar se complexidade vale o benefício

### _Links_

- <https://sre.google/sre-book/addressing-latency/>
- <https://aws.amazon.com/blogs/architecture/improving-tail-latency-with-hedged-requests/>
- <https://www.nginx.com/blog/tuning-tcp-for-tcp-latency-and-throughput/>
