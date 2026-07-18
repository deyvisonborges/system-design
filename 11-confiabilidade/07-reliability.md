# Reliability

Reliability (confiabilidade) é a capacidade de um sistema de funcionar corretamente e consistentemente ao longo do tempo, mesmo na presença de falhas de hardware, software ou operacionais. É um aspecto fundamental da engenharia de sistemas que garante que os serviços continuem operando conforme esperado.

## Definição

Reliability é a probabilidade de que um sistema execute sua função pretendida sem falhas durante um período de tempo específico e sob condições operacionais definidas.

```text
Reliability = Probabilidade de operação sem falhas
```

## Reliability vs Availability

Embora relacionados, reliability e availability são conceitos diferentes:

- **Availability**: O sistema está operacional e acessível (pode estar operando com erros)
- **Reliability**: O sistema opera corretamente sem falhas (pode estar indisponível para manutenção)

```text
Exemplo:
- Um sistema com 99.9% availability pode ter bugs que causam erros
- Um sistema com 99.9% reliability pode ter downtime programado para manutenção
```

## Métricas de Reliability

### 1. MTBF (Mean Time Between Failures)

Tempo médio entre falhas do sistema.

```text
MTBF = Tempo total de operação / Número de falhas
```

### 2. MTTF (Mean Time To Failure)

Tempo médio até a primeira falha (para sistemas não reparáveis).

```text
MTTF = Tempo total de operação / Número de unidades
```

### 3. MTTR (Mean Time To Repair)

Tempo médio para reparar o sistema após uma falha.

```text
MTTR = Tempo total de reparo / Número de reparos
```

### 4. Failure Rate (Taxa de Falha)

Número de falhas por unidade de tempo.

```text
Failure Rate = 1 / MTBF
```

```python
# Exemplo de cálculo de métricas de reliability
def calculate_reliability_metrics(operational_time_hours, num_failures, repair_time_hours):
    """
    Calcula métricas de reliability
    
    Args:
        operational_time_hours: Tempo total de operação em horas
        num_failures: Número de falhas ocorridas
        repair_time_hours: Tempo total de reparo em horas
    """
    mtbf = operational_time_hours / num_failures if num_failures > 0 else float('inf')
    mttr = repair_time_hours / num_failures if num_failures > 0 else 0
    failure_rate = 1 / mtbf if mtbf != float('inf') else 0
    availability = mtbf / (mtbf + mttr) if mtbf != float('inf') else 0
    
    return {
        'mtbf_hours': mtbf,
        'mttr_hours': mttr,
        'failure_rate_per_hour': failure_rate,
        'availability_percentage': availability * 100
    }

# Exemplo: 1 ano de operação com 2 falhas, total de 4 horas de reparo
metrics = calculate_reliability_metrics(8760, 2, 4)
print(f"MTBF: {metrics['mtbf_hours']:.2f} horas")
print(f"MTTR: {metrics['mttr_hours']:.2f} horas")
print(f"Failure Rate: {metrics['failure_rate_per_hour']:.6f} falhas/hora")
print(f"Availability: {metrics['availability_percentage']:.4f}%")
```

## Tipos de Falhas

### 1. Hardware Failures

Falhas em componentes físicos do sistema.

- **Disco**: Falhas de disco são comuns (MTTF típico: 2-5 anos)
- **Memória**: Módulos de memória defeituosos (MTTF típico: 10-20 anos)
- **CPU**: Overheating, falhas de processador (MTTF típico: 15-20 anos)
- **Rede**: Falhas de switches, roteadores, cabos

### 2. Software Failures

Falhas no software que causam comportamento incorreto.

- **Bugs**: Erros no código que causam crashes
- **Memory leaks**: Uso excessivo de memória
- **Deadlocks**: Condições de corrida
- **Configuration errors**: Configurações incorretas

### 3. Network Failures

Falhas na rede que afetam a comunicação.

- **Packet loss**: Perda de pacotes
- **Latency spikes**: Aumentos súbitos de latência
- **Partition**: Partição de rede
- **Congestion**: Congestionamento de rede

### 4. Human Errors

Erros cometidos por pessoas.

- **Mistakes**: Erros de operação
- **Misconfiguration**: Configurações incorretas
- **Accidental deletion**: Deleção acidental de dados
- **Incomplete testing**: Testes insuficientes

## Padrões de Reliability

### 1. Redundancy

Ter múltiplas cópias de componentes críticos.

```python
# Exemplo de redundância de serviço
import random

class RedundantService:
    def __init__(self, endpoints):
        self.endpoints = endpoints
        self.current_index = 0
    
    def call(self, operation, max_retries=3):
        """
        Chama operação com redundância
        """
        for attempt in range(max_retries):
            try:
                endpoint = self.endpoints[self.current_index]
                result = self._call_endpoint(endpoint, operation)
                return result
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                # Tenta próximo endpoint
                self.current_index = (self.current_index + 1) % len(self.endpoints)
        
        raise Exception("All endpoints failed")
    
    def _call_endpoint(self, endpoint, operation):
        """Simula chamada a endpoint"""
        # Simula falha aleatória
        if random.random() < 0.3:
            raise Exception("Endpoint unavailable")
        return f"Result from {endpoint}"

# Uso
services = RedundantService(['service1', 'service2', 'service3'])
result = services.call("get_data")
print(result)
```

### 2. Replication

Ter múltiplas cópias de dados.

```yaml
# Exemplo de configuração de replicação
replication_config:
  mode: async
  factor: 3  # 3 réplicas
  
  primary:
    region: us-east-1
    node: primary-1
  
  replicas:
    - region: us-east-1
      node: replica-1
    - region: us-west-2
      node: replica-2
  
  consistency:
    read: quorum
    write: all
  
  failover:
    enabled: true
    automatic: true
```

### 3. Circuit Breaker

Padrão para evitar cascading failures.

```python
# Exemplo de circuit breaker
import time
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
    
    def call(self, func, *args, **kwargs):
        """Chama função com circuit breaker"""
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time > self.timeout:
                self.state = CircuitState.HALF_OPEN
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            
            if self.state == CircuitState.HALF_OPEN:
                self.state = CircuitState.CLOSED
                self.failures = 0
            
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = time.time()
            
            if self.failures >= self.failure_threshold:
                self.state = CircuitState.OPEN
            
            raise e

# Uso
breaker = CircuitBreaker(failure_threshold=3, timeout=30)

def risky_operation():
    # Simula operação que pode falhar
    if random.random() < 0.5:
        raise Exception("Operation failed")
    return "Success"

try:
    result = breaker.call(risky_operation)
    print(result)
except Exception as e:
    print(f"Error: {e}")
```

### 4. Retry with Backoff

Tentar novamente com espera exponencial.

```python
# Exemplo de retry com exponential backoff
import time
import random

def retry_with_backoff(func, max_retries=3, base_delay=1, max_delay=32):
    """
    Executa função com retry e exponential backoff
    
    Args:
        func: Função a executar
        max_retries: Número máximo de tentativas
        base_delay: Delay base em segundos
        max_delay: Delay máximo em segundos
    """
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            
            # Calcula delay com jitter
            delay = min(base_delay * (2 ** attempt) + random.uniform(0, 1), max_delay)
            print(f"Attempt {attempt + 1} failed, retrying in {delay:.2f}s")
            time.sleep(delay)

# Uso
def flaky_operation():
    if random.random() < 0.7:
        raise Exception("Temporary failure")
    return "Success"

result = retry_with_backoff(flaky_operation, max_retries=5)
print(result)
```

### 5. Bulkhead Pattern

Isolar falhas para evitar propagação.

```python
# Exemplo de bulkhead pattern
from concurrent.futures import ThreadPoolExecutor
import queue

class Bulkhead:
    def __init__(self, max_workers=10, max_queue_size=100):
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
        self.queue = queue.Queue(maxsize=max_queue_size)
        self.max_workers = max_workers
    
    def submit(self, func, *args, **kwargs):
        """Submete tarefa com bulkhead"""
        try:
            future = self.executor.submit(func, *args, **kwargs)
            return future
        except Exception as e:
            raise Exception("Bulkhead queue full") from e
    
    def shutdown(self):
        """Encerra executor"""
        self.executor.shutdown(wait=True)

# Uso
bulkhead = Bulkhead(max_workers=5, max_queue_size=10)

def process_request(request_id):
    time.sleep(1)  # Simula processamento
    return f"Processed {request_id}"

# Submete múltiplas requisições
futures = []
for i in range(20):
    try:
        future = bulkhead.submit(process_request, i)
        futures.append(future)
    except Exception as e:
        print(f"Request {i} rejected: {e}")

# Coleta resultados
for future in futures:
    print(future.result())
```

## Estratégias de Reliability

### 1. Graceful Degradation

Sistema continua operando com funcionalidade reduzida.

```python
# Exemplo de graceful degradation
class FeatureFlags:
    def __init__(self):
        self.features = {
            'advanced_search': True,
            'recommendations': True,
            'analytics': True
        }
    
    def is_enabled(self, feature):
        """Verifica se feature está habilitada"""
        return self.features.get(feature, False)
    
    def disable_feature(self, feature):
        """Desabilita feature"""
        self.features[feature] = False
    
    def enable_feature(self, feature):
        """Habilita feature"""
        self.features[feature] = True

class ProductService:
    def __init__(self, feature_flags):
        self.feature_flags = feature_flags
        self.cache = {}
    
    def search_products(self, query):
        """Busca produtos com graceful degradation"""
        try:
            if self.feature_flags.is_enabled('advanced_search'):
                return self._advanced_search(query)
            else:
                return self._basic_search(query)
        except Exception as e:
            print(f"Advanced search failed: {e}")
            # Degrada para busca básica
            self.feature_flags.disable_feature('advanced_search')
            return self._basic_search(query)
    
    def _advanced_search(self, query):
        """Busca avançada"""
        # Simula operação complexa que pode falhar
        if random.random() < 0.3:
            raise Exception("Search service unavailable")
        return f"Advanced results for: {query}"
    
    def _basic_search(self, query):
        """Busca básica"""
        return f"Basic results for: {query}"

# Uso
flags = FeatureFlags()
service = ProductService(flags)

for i in range(10):
    result = service.search_products(f"query_{i}")
    print(result)
```

### 2. Idempotency

Operações podem ser executadas múltiplas vezes sem efeitos colaterais.

```python
# Exemplo de operações idempotentes
class IdempotentService:
    def __init__(self):
        self.processed_requests = set()
    
    def process_payment(self, request_id, amount):
        """
        Processa pagamento de forma idempotente
        """
        # Verifica se já foi processado
        if request_id in self.processed_requests:
            return {"status": "already_processed", "request_id": request_id}
        
        # Processa pagamento
        result = self._execute_payment(amount)
        
        # Marca como processado
        self.processed_requests.add(request_id)
        
        return result
    
    def _execute_payment(self, amount):
        """Executa pagamento"""
        return {"status": "success", "amount": amount}

# Uso
service = IdempotentService()

# Primeira chamada
result1 = service.process_payment("req_123", 100)
print(result1)

# Segunda chamada (idempotente)
result2 = service.process_payment("req_123", 100)
print(result2)
```

### 3. Health Checks

Monitoramento contínuo da saúde do sistema.

```python
# Exemplo de health checks
import requests
from datetime import datetime

class HealthChecker:
    def __init__(self, services):
        self.services = services
        self.health_status = {}
    
    def check_service(self, service):
        """Verifica saúde de um serviço"""
        try:
            response = requests.get(service['health_url'], timeout=5)
            is_healthy = response.status_code == 200
            
            self.health_status[service['name']] = {
                'healthy': is_healthy,
                'last_check': datetime.now(),
                'status_code': response.status_code
            }
            
            return is_healthy
        except Exception as e:
            self.health_status[service['name']] = {
                'healthy': False,
                'last_check': datetime.now(),
                'error': str(e)
            }
            return False
    
    def check_all(self):
        """Verifica saúde de todos os serviços"""
        results = {}
        for service in self.services:
            results[service['name']] = self.check_service(service)
        return results
    
    def get_healthy_services(self):
        """Retorna serviços saudáveis"""
        return [
            name for name, status in self.health_status.items()
            if status.get('healthy', False)
        ]

# Uso
services = [
    {'name': 'api', 'health_url': 'http://api.example.com/health'},
    {'name': 'db', 'health_url': 'http://db.example.com/health'},
    {'name': 'cache', 'health_url': 'http://cache.example.com/health'}
]

checker = HealthChecker(services)
status = checker.check_all()
print(f"Health status: {status}")
```

## Monitoramento de Reliability

### 1. Error Rate

Taxa de erros do sistema.

```python
# Exemplo de monitoramento de error rate
from collections import defaultdict
import time

class ErrorRateMonitor:
    def __init__(self, window_seconds=60):
        self.window_seconds = window_seconds
        self.errors = defaultdict(list)
        self.requests = defaultdict(list)
    
    def record_request(self, service, success=True):
        """Registra requisição"""
        timestamp = time.time()
        self.requests[service].append(timestamp)
        
        if not success:
            self.errors[service].append(timestamp)
        
        # Remove registros antigos
        self._cleanup(service)
    
    def _cleanup(self, service):
        """Remove registros fora da janela"""
        cutoff = time.time() - self.window_seconds
        self.requests[service] = [t for t in self.requests[service] if t > cutoff]
        self.errors[service] = [t for t in self.errors[service] if t > cutoff]
    
    def get_error_rate(self, service):
        """Calcula taxa de erro"""
        self._cleanup(service)
        total_requests = len(self.requests[service])
        total_errors = len(self.errors[service])
        
        if total_requests == 0:
            return 0
        
        return (total_errors / total_requests) * 100

# Uso
monitor = ErrorRateMonitor(window_seconds=60)

for i in range(100):
    success = random.random() > 0.1  # 10% de erro
    monitor.record_request('api', success)

error_rate = monitor.get_error_rate('api')
print(f"Error rate: {error_rate:.2f}%")
```

### 2. Uptime

Tempo que o sistema está operacional.

### 3. SLA Compliance

Porcentagem de tempo dentro do SLA.

## Exemplo de SLA de Reliability

```text
Requisitos de negócio:
- Sistema de pagamentos crítico
- Não pode perder transações
- Deve ser altamente confiável

SLA de reliability:
- MTBF: 8760 horas (1 ano sem falhas)
- MTTR: 15 minutos
- Error rate: < 0.01%
- Data loss: 0%
- Consistency: 100%

Monitoramento:
- Alerta se error rate > 0.05% porhora
- Alerta se MTTR > 30 minutos
- Alerta se houver qualquer perda de dados
- Alerta se consistência < 100%

Penalidades:
- Crédito de 10% se error rate > 0.1%
- Crédito de 25% se error rate > 0.5%
- Crédito de 50% se houver perda de dados
```

## Trade-offs

### Reliability vs Custo

- Alta reliability geralmente aumenta custo significativamente
- Avaliar custo de falhas vs custo de redundância
- Níveis diferentes de reliability para diferentes serviços

### Reliability vs Complexity

- Sistemas altamente confiáveis são mais complexos
- Complexidade pode introduzir novos pontos de falha
- Manter simplicidade quando possível

### Reliability vs Performance

- Redundância pode adicionar latência
- Sincronização entre nós pode impactar performance
- Encontrar balanceamento adequado

### Reliability vs Development Speed

- Sistemas confiáveis requerem mais testes
- Processos mais rigorosos podem reduzir velocidade
- Encontrar equilíbrio entre velocidade e qualidade

### _Links_

- <https://sre.google/sre-book/monitoring-distributed-systems/>
- <https://aws.amazon.com/builders-library/improving-reliability/>
- <https://azure.microsoft.com/en-us/overview/reliability/>
