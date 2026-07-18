# Fault Tolerance

Fault tolerance (tolerância a falhas) é a capacidade de um sistema de continuar operando corretamente mesmo quando ocorrem falhas em componentes individuais. Um sistema fault-tolerante pode lidar com falhas de hardware, software ou rede sem causar interrupção no serviço.

## Definição

Fault tolerance é a propriedade que permite que um sistema continue funcionando adequadamente mesmo na presença de falhas, garantindo que o sistema como um todo permanece operacional.

```text
Fault Tolerance = Capacidade de operar apesar de falhas
```

## Fault Tolerance vs High Availability

Embora relacionados, fault tolerance e high availability são conceitos diferentes:

- **Fault Tolerance**: Sistema continua operando mesmo com falhas (pode degradar)
- **High Availability**: Sistema está disponível a maior parte do tempo (pode ter downtime programado)

```text
Exemplo:
- Um sistema fault-tolerante pode continuar operando com um servidor falho
- Um sistema HA pode ter 99.9% uptime mas não tolera falhas durante operação
```

## Tipos de Falhas

### 1. Hardware Failures

Falhas em componentes físicos.

- **CPU**: Falhas de processador, overheating
- **Memória**: Módulos defeituosos, ECC errors
- **Disco**: Falhas de disco, bad blocks
- **Rede**: Falhas de switches, cabos, NICs

### 2. Software Failures

Falhas no software.

- **Bugs**: Erros no código
- **Memory leaks**: Uso excessivo de memória
- **Deadlocks**: Condições de corrida
- **Crashes**: Terminação inesperada

### 3. Network Failures

Falhas na rede.

- **Packet loss**: Perda de pacotes
- **Latency spikes**: Aumentos de latência
- **Partition**: Partição de rede
- **Congestion**: Congestionamento

### 4. Environmental Failures

Falhas no ambiente.

- **Power outages**: Falhas de energia
- **Cooling failures**: Falhas de refrigeração
- **Natural disasters**: Terremotos, incêndios
- **Human errors**: Erros operacionais

## Padrões de Fault Tolerance

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

## Estratégias de Fault Tolerance

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

### 3. Timeout Handling

Limitar tempo de espera para evitar bloqueios.

```python
# Exemplo de timeout handling
import signal
from contextlib import contextmanager

class TimeoutError(Exception):
    pass

@contextmanager
def time_limit(seconds):
    """Context manager para timeout"""
    def signal_handler(signum, frame):
        raise TimeoutError("Timed out")
    
    signal.signal(signal.SIGALRM, signal_handler)
    signal.alarm(seconds)
    
    try:
        yield
    finally:
        signal.alarm(0)

def operation_with_timeout(timeout_seconds=5):
    """Executa operação com timeout"""
    try:
        with time_limit(timeout_seconds):
            return slow_operation()
    except TimeoutError:
        print("Operation timed out")
        return fallback_operation()

def slow_operation():
    """Operação que pode demorar muito"""
    time.sleep(10)
    return "Success"

def fallback_operation():
    """Operação de fallback"""
    return "Fallback result"

# Uso
result = operation_with_timeout(timeout_seconds=2)
print(result)
```

### 4. Health Checks

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

## Exemplos Práticos

### Banco de Dados

```python
# Exemplo de banco de dados fault-tolerante
import psycopg2
from psycopg2 import pool

class FaultTolerantDatabase:
    def __init__(self, primary_config, replica_configs):
        self.primary_pool = psycopg2.pool.SimpleConnectionPool(
            minconn=1,
            maxconn=10,
            **primary_config
        )
        
        self.replica_pools = []
        for config in replica_configs:
            pool = psycopg2.pool.SimpleConnectionPool(
                minconn=1,
                maxconn=5,
                **config
            )
            self.replica_pools.append(pool)
    
    def execute_write(self, query, params=None):
        """Executa query de escrita com retry"""
        for attempt in range(3):
            try:
                conn = self.primary_pool.getconn()
                cursor = conn.cursor()
                cursor.execute(query, params or ())
                conn.commit()
                cursor.close()
                self.primary_pool.putconn(conn)
                return True
            except Exception as e:
                print(f"Write attempt {attempt + 1} failed: {e}")
                if attempt == 2:
                    raise e
    
    def execute_read(self, query, params=None):
        """Executa query de leitura com fallback para réplicas"""
        # Tenta primário primeiro
        try:
            return self._execute_on_pool(self.primary_pool, query, params)
        except Exception as e:
            print(f"Primary failed, trying replicas: {e}")
        
        # Tenta réplicas
        for replica_pool in self.replica_pools:
            try:
                return self._execute_on_pool(replica_pool, query, params)
            except Exception as e:
                print(f"Replica failed: {e}")
                continue
        
        raise Exception("All database connections failed")
    
    def _execute_on_pool(self, pool, query, params):
        """Executa query em um pool específico"""
        conn = pool.getconn()
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        result = cursor.fetchall()
        cursor.close()
        pool.putconn(conn)
        return result
```

### API REST

```python
# Exemplo de API fault-tolerante
from flask import Flask, jsonify
import requests

app = Flask(__name__)

class FaultTolerantClient:
    def __init__(self, endpoints):
        self.endpoints = endpoints
        self.current_index = 0
    
    def call(self, path, method='GET', data=None):
        """Chama API com redundância"""
        for attempt in range(len(self.endpoints)):
            try:
                endpoint = self.endpoints[self.current_index]
                url = f"{endpoint}{path}"
                
                if method == 'GET':
                    response = requests.get(url, timeout=5)
                elif method == 'POST':
                    response = requests.post(url, json=data, timeout=5)
                
                if response.status_code == 200:
                    return response.json()
                
                self.current_index = (self.current_index + 1) % len(self.endpoints)
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                self.current_index = (self.current_index + 1) % len(self.endpoints)
        
        raise Exception("All endpoints failed")

client = FaultTolerantClient(['http://api1.example.com', 'http://api2.example.com'])

@app.route('/api/data')
def get_data():
    try:
        result = client.call('/data')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 503
```

## Monitoramento de Fault Tolerance

### Métricas Importantes

- **Failure Rate**: Taxa de falhas do sistema
- **Recovery Time**: Tempo para recuperar de falhas
- **Circuit Breaker State**: Estado dos circuit breakers
- **Retry Rate**: Taxa de retries
- **Fallback Rate**: Taxa de uso de fallbacks

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de fault tolerance
from collections import defaultdict
import time

class FaultToleranceMonitor:
    def __init__(self):
        self.failures = defaultdict(int)
        self.retries = defaultdict(int)
        self.fallbacks = defaultdict(int)
        self.recovery_times = defaultdict(list)
    
    def record_failure(self, component):
        """Registra falha de componente"""
        self.failures[component] += 1
    
    def record_retry(self, component):
        """Registra retry de componente"""
        self.retries[component] += 1
    
    def record_fallback(self, component):
        """Registra fallback de componente"""
        self.fallbacks[component] += 1
    
    def record_recovery(self, component, recovery_time):
        """Registra tempo de recuperação"""
        self.recovery_times[component].append(recovery_time)
    
    def get_summary(self):
        """Retorna resumo de métricas"""
        summary = {}
        
        for component in self.failures:
            avg_recovery = (
                sum(self.recovery_times[component]) / len(self.recovery_times[component])
                if self.recovery_times[component]
                else 0
            )
            
            summary[component] = {
                'failures': self.failures[component],
                'retries': self.retries[component],
                'fallbacks': self.fallbacks[component],
                'avg_recovery_time': avg_recovery
            }
        
        return summary

# Uso
monitor = FaultToleranceMonitor()

monitor.record_failure('database')
monitor.record_retry('database')
monitor.record_fallback('database')
monitor.record_recovery('database', 5.2)

summary = monitor.get_summary()
print(f"Fault tolerance summary: {summary}")
```

## Exemplo de SLA de Fault Tolerance

```text
Requisitos de negócio:
- Sistema de pagamentos crítico
- Não pode perder transações
- Deve tolerar falhas de componentes

SLA de fault tolerance:
- Tolerância a falhas de servidor: 1 de 3 servidores pode falhar
- Tolerância a falhas de banco: 1 de 3 réplicas pode falhar
- Tempo de failover: < 30 segundos
- Tempo de recuperação: < 5 minutos
- Perda de dados: 0%

Monitoramento:
- Alerta se failover demorar > 45 segundos
- Alerta se recuperação demorar > 10 minutos
- Alerta se houver qualquer perda de dados
- Alerta se taxa de falhas > 1% por hora

Penalidades:
- Crédito de 10% se failover > 60 segundos
- Crédito de 25% se recuperação > 15 minutos
- Crédito de 50% se houver perda de dados
```

## Trade-offs

### Fault Tolerance vs Custo

- Alta fault tolerance aumenta custo significativamente
- Avaliar custo de falhas vs custo de redundância
- Níveis diferentes de fault tolerance para diferentes serviços

### Fault Tolerance vs Complexity

- Sistemas fault-tolerantes são mais complexos
- Complexidade pode introduzir novos pontos de falha
- Manter simplicidade quando possível

### Fault Tolerance vs Performance

- Redundância pode adicionar latência
- Sincronização entre nós pode impactar performance
- Encontrar balanceamento adequado

### Fault Tolerance vs Consistency

- Fault tolerance pode sacrificar consistência (CAP theorem)
- Sistemas eventualmente consistentes podem ser mais fault-tolerantes
- Escolha baseada nos requisitos do negócio

### _Links_

- <https://sre.google/sre-book/engineering-for-reliability/>
- <https://aws.amazon.com/builders-library/implementing-fault-tolerance/>
- <https://azure.microsoft.com/en-us/overview/fault-tolerance/>
