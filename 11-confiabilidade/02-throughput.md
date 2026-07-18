# Throughput

Throughput (vazão) é a quantidade de trabalho que um sistema pode processar em um determinado período de tempo. Diferente da latência (que mede o tempo de uma única requisição), o throughput mede a capacidade total do sistema de processar múltiplas requisições simultaneamente.

## Definição

Throughput é geralmente medido em:

- **Requisições por segundo (RPS)**: Número de requisições processadas por segundo
- **Transações por segundo (TPS)**: Número de transações completadas por segundo
- **Operações por segundo (OPS)**: Número de operações executadas por segundo
- **Bytes por segundo**: Taxa de transferência de dados

```text
Throughput = Número de requisições processadas / Tempo total
```

## Relação com Latência

Throughput e latência estão relacionados, mas são métricas diferentes:

- **Latência**: Tempo para processar uma requisição individual
- **Throughput**: Quantidade de requisições processadas por unidade de tempo

```text
Throughput ≈ 1 / Latência (para um único processo sequencial)
```

Em sistemas concorrentes, o throughput pode ser muito maior que 1/latência devido ao processamento paralelo.

## Tipos de Throughput

### 1. Throughput de Rede (Network Throughput)

Quantidade de dados que podem ser transmitidos pela rede por unidade de tempo.

- **Medido em**: Mbps, Gbps, MB/s
- **Fatores**: largura de banda, latência, perda de pacotes, protocolo
- **Exemplo**: Uma conexão de 1 Gbps pode teoricamente transferir 125 MB/s

### 2. Throughput de Aplicação (Application Throughput)

Número de requisições que uma aplicação pode processar por segundo.

- **Medido em**: RPS, TPS
- **Fatores**: CPU, memória, I/O, algoritmos, arquitetura
- **Exemplo**: Uma API REST pode processar 10.000 RPS

### 3. Throughput de Banco de Dados (Database Throughput)

Número de operações que um banco de dados pode executar por segundo.

- **Medido em**: OPS, TPS
- **Fatores**: índices, locks, configuração, hardware
- **Exemplo**: PostgreSQL pode processar 50.000 TPS em hardware adequado

### 4. Throughput de Disco (Disk Throughput)

Quantidade de dados que podem ser lidos/escritos no disco por segundo.

- **Medido em**: MB/s, GB/s, IOPS
- **Fatores**: tipo de disco (SSD vs HDD), velocidade, interface
- **Exemplo**: SSD NVMe pode alcançar 3.000 MB/s de leitura

## Fatores que Afetam o Throughput

### 1. Concorrência

```python
# Exemplo de throughput com concorrência
import asyncio
import time

async def process_request(request_id):
    await asyncio.sleep(0.01)  # Simula 10ms de processamento
    return f"Processed {request_id}"

async def measure_throughput(num_requests, concurrency):
    start = time.time()
    
    # Cria múltiplas tarefas concorrentes
    tasks = [process_request(i) for i in range(num_requests)]
    await asyncio.gather(*tasks)
    
    end = time.time()
    throughput = num_requests / (end - start)
    return throughput

# 1000 requisições com 100 tarefas concorrentes
throughput = asyncio.run(measure_throughput(1000, 100))
print(f"Throughput: {throughput:.2f} RPS")
```

### 2. Recursos de Hardware

- **CPU**: Mais cores permitem mais processamento paralelo
- **Memória**: Mais memória permite mais cache e menos I/O
- **Disco**: SSDs têm throughput muito maior que HDDs
- **Rede**: Largura de banda limita throughput de rede

### 3. Arquitetura do Sistema

- **Monolito**: Pode ter bottleneck em componentes únicos
- **Microserviços**: Permite escalar componentes independentemente
- **Serverless**: Auto-scaling pode aumentar throughput dinamicamente

### 4. Otimizações de Software

- **Algoritmos eficientes**: Reduzem tempo de processamento
- **Caching**: Reduz carga em recursos lentos
- **Connection pooling**: Reutiliza conexões, reduz overhead
- **Batch processing**: Processa múltiplas operações juntas

## Exemplos Práticos

### API REST

```python
# Exemplo de medição de throughput com locust
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(0.1, 0.5)
    
    @task
    def get_users(self):
        self.client.get("/api/users")
    
    @task(3)
    def get_products(self):
        self.client.get("/api/products")
```

Comando para executar:

```bash
locust -f locustfile.py --host=https://api.example.com --users=1000 --spawn-rate=100
```

### Banco de Dados

```sql
-- Exemplo de throughput de inserts em lote
-- Insert individual (baixo throughput)
INSERT INTO logs (message, timestamp) VALUES ('Error 1', NOW());
INSERT INTO logs (message, timestamp) VALUES ('Error 2', NOW());
INSERT INTO logs (message, timestamp) VALUES ('Error 3', NOW());

-- Insert em lote (alto throughput)
INSERT INTO logs (message, timestamp) VALUES 
    ('Error 1', NOW()),
    ('Error 2', NOW()),
    ('Error 3', NOW());
```

### Sistema de Mensagens

```python
# Exemplo de throughput com Kafka
from kafka import KafkaProducer
import time
import json

producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def measure_throughput(num_messages):
    start = time.time()
    
    for i in range(num_messages):
        producer.send('events', {'id': i, 'data': f'message {i}'})
    
    producer.flush()
    end = time.time()
    
    throughput = num_messages / (end - start)
    return throughput

throughput = measure_throughput(10000)
print(f"Throughput: {throughput:.2f} messages/second")
```

## Otimização de Throughput

### 1. Connection Pooling

```python
# Exemplo de connection pooling com SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Pool de conexões com PostgreSQL
engine = create_engine(
    'postgresql://user:password@localhost/db',
    pool_size=20,          # Número de conexões permanentes
    max_overflow=10,       # Conexões extras permitidas
    pool_timeout=30,       # Timeout para obter conexão
    pool_recycle=3600      # Reciclar conexões após 1 hora
)

Session = sessionmaker(bind=engine)
```

### 2. Caching

```python
# Exemplo de caching para aumentar throughput
from functools import lru_cache
import time

@lru_cache(maxsize=1000)
def expensive_computation(x):
    time.sleep(0.1)  # Simula operação cara
    return x * x

# Primeira chamada: 100ms
start = time.time()
result1 = expensive_computation(5)
print(f"First call: {(time.time() - start) * 1000:.2f}ms")

# Segunda chamada: < 1ms (cache hit)
start = time.time()
result2 = expensive_computation(5)
print(f"Second call: {(time.time() - start) * 1000:.2f}ms")
```

### 3. Processamento em Lote

```python
# Exemplo de batch processing
def process_items_batch(items, batch_size=100):
    results = []
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        # Processa lote inteiro de uma vez
        batch_results = process_batch(batch)
        results.extend(batch_results)
    return results

def process_batch(batch):
    # Processamento em lote é mais eficiente
    return [item * 2 for item in batch]
```

### 4. Horizontal Scaling

```yaml
# Exemplo de horizontal scaling com Kubernetes
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 10  # 10 réplicas para aumentar throughput
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api-server
        image: api-server:latest
        resources:
          requests:
            cpu: "500m"
            memory: "512Mi"
          limits:
            cpu: "1000m"
            memory: "1Gi"
```

### 5. Async I/O

```python
# Exemplo de async I/O para aumentar throughput
import aiohttp
import asyncio

async def fetch_url(session, url):
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

# Processa múltiplas requisições concorrentemente
urls = [f"https://api.example.com/data/{i}" for i in range(100)]
results = asyncio.run(fetch_multiple_urls(urls))
```

## Monitoramento de Throughput

### Métricas Importantes

- **RPS/TPS atual**: Throughput em tempo real
- **RPS/TPS pico**: Máximo throughput alcançado
- **RPS/TPS médio**: Throughput médio ao longo do tempo
- **Taxa de erro**: Requisições que falharam
- **Utilização de recursos**: CPU, memória, I/O

### Ferramentas

- **Prometheus + Grafana**: Monitoramento customizado
- **Datadog/New Relic**: APM com métricas de throughput
- **Locust/K6**: Load testing para medir throughput
- **Apache Bench (ab)**: Teste de carga simples

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de throughput com Prometheus
from prometheus_client import Counter, Histogram, start_http_server
import time

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests')
REQUEST_LATENCY = Histogram('http_request_latency_seconds', 'HTTP request latency')

def process_request():
    start = time.time()
    
    # Processa requisição
    time.sleep(0.01)
    
    # Registra métricas
    REQUEST_COUNT.inc()
    REQUEST_LATENCY.observe(time.time() - start)
    
    return {"status": "success"}

# Inicia servidor de métricas na porta 8000
start_http_server(8000)
```

## Limites de Throughput

### 1. Bottlenecks Comuns

- **CPU bound**: Processamento é limitado pela CPU
- **I/O bound**: Processamento é limitado por I/O (disco, rede)
- **Memory bound**: Processamento é limitado pela memória
- **Network bound**: Processamento é limitado pela rede

### 2. Lei de Amdahl

```text
Speedup = 1 / ((1 - P) + (P / N))

Onde:
- P = proporção do código que pode ser paralelizado
- N = número de processadores
```

Exemplo: Se 50% do código pode ser paralelizado e temos 4 processadores:

```text
Speedup = 1 / ((1 - 0.5) + (0.5 / 4)) = 1 / (0.5 + 0.125) = 1.6x
```

### 3. Lei de Little

```text
L = λ × W

Onde:
- L = número médio de itens no sistema
- λ = taxa de chegada (throughput)
- W = tempo médio no sistema (latência)
```

Isso mostra que aumentar throughput (λ) sem reduzir latência (W) aumenta o número de itens no sistema (L).

## Exemplo de Cálculo de SLA de Throughput

```text
Requisitos de negócio:
- Sistema deve suportar Black Friday com 10x o tráfego normal
- Tráfego normal = 1.000 RPS
- Tráfego de pico = 10.000 RPS

SLA de throughput:
- Throughput mínimo: 1.000 RPS (baseline)
- Throughput de pico: 10.000 RPS (Black Friday)
- Throughput aceitável: 5.000 RPS (dia normal movimentado)

Monitoramento:
- Alerta se throughput < 900 RPS por 5 minutos
- Alerta se throughput < 8.000 RPS durante Black Friday
- Alerta se taxa de erro > 1% com throughput alto
```

## Trade-offs

### Throughput vs Latência

- Aumentar throughput pode aumentar latência (ex: batching)
- Reduzir latência pode reduzir throughput (ex: processamento individual)
- Encontrar balanceamento para o caso de uso

### Throughput vs Custo

- Aumentar throughput geralmente aumenta custo (mais hardware)
- Avaliar custo por RPS/TPS
- Priorizar otimizações com melhor ROI

### Throughput vs Consistência

- Sistemas eventualmente consistentes podem ter maior throughput
- Sistemas fortemente consistentes podem ter menor throughput
- Escolha baseada nos requisitos do negócio

### _Links_

- <https://sre.google/sre-book/measuring-and-improving-reliability/>
- <https://aws.amazon.com/what-is-throughput/>
- <https://www.nginx.com/blog/tuning-nginx-for-high-performance-loads/>
