# Tail Latency

Tail latency (latência de cauda) refere-se à latência experimentada pelos piores casos - os percentis mais altos de latência (P95, P99, P99.9, etc.). Diferente da latência média ou mediana, que representa a experiência "típica", a tail latency captura a experiência dos usuários mais afetados por problemas de performance.

## Definição

Tail latency é medida através de percentis de latência:

- **P50 (Mediana)**: 50% das requisições são mais rápidas que este valor
- **P95**: 95% das requisições são mais rápidas que este valor
- **P99**: 99% das requisições são mais rápidas que este valor
- **P99.9**: 99.9% das requisições são mais rápidas que este valor

```text
Tail Latency = Latência dos percentis mais altos (P95, P99, P99.9)
```

## Por que Tail Latency Importa

### 1. Impacto no Usuário

- **Experiência do usuário**: Os usuários mais afetados são os que mais notam problemas
- **Retenção**: Usuários com experiência ruim tendem a abandonar o serviço
- **Reputação**: Problemas de performance afetam a percepção da marca

### 2. Efeito de Long Tail

```python
# Exemplo de distribuição de latência
import numpy as np

# Simula 10.000 requisições com distribuição log-normal
latencies = np.random.lognormal(mean=4, sigma=0.5, size=10000)

# Calcular percentis
p50 = np.percentile(latencies, 50)
p95 = np.percentile(latencies, 95)
p99 = np.percentile(latencies, 99)
p99_9 = np.percentile(latencies, 99.9)

print(f"P50: {p50:.2f}ms")
print(f"P95: {p95:.2f}ms")
print(f"P99: {p99:.2f}ms")
print(f"P99.9: {p99_9:.2f}ms")

# P99.9 pode ser 10x ou mais que P50
print(f"Ratio P99.9/P50: {p99_9/p50:.2f}x")
```

### 3. SLAs e SLOs

Muitos SLAs são baseados em percentis de latência:

```text
SLA típico:
- 95% das requisições < 200ms (P95)
- 99% das requisições < 500ms (P99)
- 99.9% das requisições < 1000ms (P99.9)
```

## Causas de Tail Latency

### 1. Garbage Collection

```java
// Exemplo de GC pause causando tail latency
public class LatencyExample {
    private List<byte[]> data = new ArrayList<>();
    
    public void processData() {
        // Aloca muitos objetos
        for (int i = 0; i < 1000; i++) {
            data.add(new byte[1024 * 1024]); // 1MB
        }
        
        // GC pause pode causar spike de latência
        System.gc();
    }
}
```

### 2. Lock Contention

```python
# Exemplo de lock contention causando tail latency
import threading
import time

class SharedResource:
    def __init__(self):
        self.lock = threading.Lock()
        self.data = []
    
    def add_data(self, item):
        with self.lock:
            # Se outra thread segurou o lock por muito tempo,
            # esta thread terá alta latência
            time.sleep(0.1)  # Simula operação demorada
            self.data.append(item)

# Múltiplas threads competindo pelo mesmo lock
resource = SharedResource()
threads = [threading.Thread(target=resource.add_data, args=(i,)) 
           for i in range(100)]

for thread in threads:
    thread.start()
for thread in threads:
    thread.join()
```

### 3. Network Issues

- **Packet loss**: Retransmissão aumenta latência
- **Congestionamento**: Pacotes ficam em buffers
- **Route changes**: Pacotes tomam rotas mais longas

### 4. Database Issues

```sql
-- Exemplo de query lenta causando tail latency
-- Query sem índice (full table scan)
SELECT * FROM orders 
WHERE customer_id = 12345 
AND created_at > '2024-01-01';

-- Com índice (muito mais rápido)
CREATE INDEX idx_customer_created ON orders(customer_id, created_at);
```

### 5. Cascading Failures

```python
# Exemplo de cascading failure
def process_request(request):
    try:
        # Se serviço dependente está lento, este serviço também fica lento
        response = dependent_service.call(request)
        return process_response(response)
    except TimeoutError:
        # Retry pode aumentar latência ainda mais
        return retry_with_backoff(request)
```

## Medição de Tail Latency

### 1. Histogramas

```python
# Exemplo de medição com histograma
import numpy as np
from collections import defaultdict

class LatencyHistogram:
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
    
    def percentile(self, percentile):
        """Calcula percentil aproximado"""
        target_count = self.total * percentile / 100
        cumulative = 0
        for bucket in sorted(self.buckets):
            cumulative += self.counts[bucket]
            if cumulative >= target_count:
                return bucket
        return float('inf')

# Uso
histogram = LatencyHistogram()
for latency in [10, 20, 50, 100, 200, 500, 1000, 2000]:
    histogram.observe(latency)

print(f"P95: {histogram.percentile(95)}ms")
print(f"P99: {histogram.percentile(99)}ms")
```

### 2. Prometheus Histogram

```python
# Exemplo com Prometheus client
from prometheus_client import Histogram

# Define histogram com buckets apropriados
REQUEST_LATENCY = Histogram(
    'http_request_latency_seconds',
    'HTTP request latency',
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0)
)

def process_request():
    start = time.time()
    
    # Processa requisição
    result = do_work()
    
    # Registra latência
    REQUEST_LATENCY.observe(time.time() - start)
    
    return result
```

### 3. Percentil Exato

```python
# Exemplo de cálculo de percentil exato
import numpy as np

def calculate_percentile(latencies, percentile):
    """
    Calcula percentil exato
    
    Args:
        latencies: Lista de latências em ms
        percentile: Percentil desejado (0-100)
    """
    return np.percentile(latencies, percentile)

# Exemplo
latencies = [10, 20, 30, 40, 50, 100, 200, 500, 1000, 2000]
p95 = calculate_percentile(latencies, 95)
p99 = calculate_percentile(latencies, 99)

print(f"P95: {p95}ms")
print(f"P99: {p99}ms")
```

## Mitigação de Tail Latency

### 1. Hedged Requests

```python
# Exemplo de hedged requests
import concurrent.futures
import time

def make_request(service_url, timeout=1.0):
    """Faz requisição com timeout"""
    try:
        response = requests.get(service_url, timeout=timeout)
        return response
    except requests.Timeout:
        return None

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
# Exemplo de caching para reduzir tail latency
from functools import lru_cache
import time

@lru_cache(maxsize=1000)
def expensive_operation(key):
    """Operação cara com cache"""
    time.sleep(0.1)  # Simula operação demorada
    return f"result_{key}"

# Primeira chamada: 100ms
start = time.time()
result1 = expensive_operation("key1")
print(f"First call: {(time.time() - start) * 1000:.2f}ms")

# Segunda chamada: < 1ms (cache hit)
start = time.time()
result2 = expensive_operation("key1")
print(f"Second call: {(time.time() - start) * 1000:.2f}ms")
```

### 3. Connection Pooling

```python
# Exemplo de connection pooling
from concurrent.futures import ThreadPoolExecutor
import queue

class ConnectionPool:
    def __init__(self, max_connections=10):
        self.pool = queue.Queue(max_connections)
        self.max_connections = max_connections
        
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

def create_connection():
    """Cria nova conexão"""
    time.sleep(0.1)  # Simula criação demorada
    return {"connection": "new"}
```

### 4. Rate Limiting

```python
# Exemplo de rate limiting
import time
from collections import deque

class RateLimiter:
    def __init__(self, max_requests, time_window):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = deque()
    
    def allow_request(self):
        """Verifica se requisição é permitida"""
        now = time.time()
        
        # Remove requisições antigas
        while self.requests and self.requests[0] < now - self.time_window:
            self.requests.popleft()
        
        # Verifica se limite foi atingido
        if len(self.requests) >= self.max_requests:
            return False
        
        self.requests.append(now)
        return True

# Uso
limiter = RateLimiter(max_requests=100, time_window=1.0)

if limiter.allow_request():
    process_request()
else:
    return "Rate limit exceeded"
```

### 5. Circuit Breaker

```python
# Exemplo de circuit breaker
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = 'closed'  # closed, open, half-open
    
    def call(self, func, *args, **kwargs):
        """Chama função com circuit breaker"""
        if self.state == 'open':
            if time.time() - self.last_failure_time > self.timeout:
                self.state = 'half-open'
            else:
                raise Exception("Circuit breaker is open")
        
        try:
            result = func(*args, **kwargs)
            
            if self.state == 'half-open':
                self.state = 'closed'
                self.failures = 0
            
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = time.time()
            
            if self.failures >= self.failure_threshold:
                self.state = 'open'
            
            raise e
```

## Exemplos Práticos

### API REST

```python
# Exemplo de middleware para medir tail latency
from flask import Flask, request, g
import time
import numpy as np

app = Flask(__name__)
latencies = []

@app.before_request
def before_request():
    g.start_time = time.time()

@app.after_request
def after_request(response):
    latency = (time.time() - g.start_time) * 1000
    latencies.append(latency)
    
    # Calcular percentis
    if len(latencies) > 100:
        p95 = np.percentile(latencies, 95)
        p99 = np.percentile(latencies, 99)
        
        response.headers['X-Latency-P95'] = f"{p95:.2f}ms"
        response.headers['X-Latency-P99'] = f"{p99:.2f}ms"
    
    return response

@app.route('/api/data')
def get_data():
    time.sleep(0.01)  # Simula processamento
    return {"data": "example"}
```

### Microserviços

```yaml
# Exemplo de configuração para reduzir tail latency
apiVersion: v1
kind: ConfigMap
metadata:
  name: performance-config
data:
  # Timeout para evitar requisições pendentes
  request_timeout: "5s"
  
  # Hedged requests
  hedge_requests: "true"
  hedge_delay: "100ms"
  
  # Connection pool
  connection_pool_size: "20"
  connection_pool_timeout: "1s"
  
  # Circuit breaker
  circuit_breaker_enabled: "true"
  circuit_breaker_threshold: "5"
  circuit_breaker_timeout: "60s"
```

## Monitoramento de Tail Latency

### Métricas Importantes

- **P50, P95, P99, P99.9**: Percentis de latência
- **Max Latency**: Latência máxima observada
- **Outlier Ratio**: Porcentagem de requisições com latência anormal
- **SLA Compliance**: Porcentagem de requisições dentro do SLA

### Alertas

```yaml
# Exemplo de alertas no Prometheus
groups:
  - name: tail_latency_alerts
    rules:
      - alert: HighTailLatency
        expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 1.0
        for: 5m
        annotations:
          summary: "P99 latency acima de 1s"
      
      - alert: SLABreach
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 10m
        annotations:
          summary: "SLA de P95 < 500ms violado"
```

## Exemplo de SLA de Tail Latency

```text
Requisitos de negócio:
- API de e-commerce com 1.000.000 requisições/dia
- 95% dos usuários devem ter experiência "boa"
- Experiência "boa" = resposta < 500ms

SLA de tail latency:
- P50 < 100ms (latência típica)
- P95 < 500ms (experiência da maioria)
- P99 < 1000ms (casos extremos)
- P99.9 < 5000ms (outliers críticos)

Monitoramento:
- Alerta se P95 > 600ms por 5 minutos
- Alerta se P99 > 1500ms por 2 minutos
- Alerta se P99.9 > 10000ms por 1 minuto
- Alerta se max latency > 30000ms instantaneamente
```

## Trade-offs

### Tail Latency vs Throughput

- Reduzir tail latency pode reduzir throughput (ex: timeouts mais agressivos)
- Aumentar throughput pode aumentar tail latency (ex: mais carga no sistema)
- Encontrar balanceamento para o caso de uso

### Tail Latency vs Custo

- Reduzir tail latency geralmente aumenta custo (mais hardware, redundância)
- Avaliar custo por percentil de latência
- Priorizar redução onde tem maior impacto no negócio

### Tail Latency vs Complexidade

- Soluções como hedged requests aumentam complexidade
- Circuit breakers adicionam pontos de falha
- Avaliar se complexidade vale o benefício

### _Links_

- <https://sre.google/sre-book/addressing-latency/>
- <https://aws.amazon.com/blogs/architecture/improving-tail-latency-with-hedged-requests/>
- <https://www.nginx.com/blog/tuning-tcp-for-tcp-latency-and-throughput/>
