# Scalability

Scalability (escalabilidade) é a capacidade de um sistema de crescer e gerenciar quantidades crescentes de trabalho. Um sistema escalável pode lidar com mais usuários, mais dados ou mais transações sem degradação significativa de performance.

## Definição

Scalability é a capacidade de um sistema de aumentar sua capacidade de processamento para lidar com cargas crescentes, adicionando recursos (hardware ou software) sem alterar fundamentalmente sua arquitetura.

```text
Scalability = Capacidade de crescer com a demanda
```

## Tipos de Escalabilidade

### 1. Vertical Scaling (Scaling Up)

Aumentar a capacidade de um único servidor adicionando mais recursos (CPU, memória, disco).

```yaml
# Exemplo de vertical scaling
vertical_scaling:
  before:
    cpu: 4 cores
    memory: 16 GB
    disk: 500 GB
  
  after:
    cpu: 16 cores
    memory: 64 GB
    disk: 2 TB
```

**Vantagens**:

- Implementação mais simples
- Não requer alterações na arquitetura
- Menor complexidade de gerenciamento

**Desvantagens**:

- Limite físico de hardware
- Single point of failure
- Custo aumenta exponencialmente
- Downtime durante upgrade

### 2. Horizontal Scaling (Scaling Out)

Adicionar mais servidores para distribuir a carga.

```yaml
# Exemplo de horizontal scaling
horizontal_scaling:
  before:
    servers: 1
    cpu_per_server: 4 cores
    memory_per_server: 16 GB
  
  after:
    servers: 4
    cpu_per_server: 4 cores
    memory_per_server: 16 GB
```

**Vantagens**:

- Teoricamente ilimitado
- Melhor fault tolerance
- Custo mais previsível
- Pode escalar gradualmente

**Desvantagens**:

- Complexidade de arquitetura
- Requer balanceamento de carga
- Consistência de dados mais complexa
- Maior overhead de coordenação

## Dimensões de Escalabilidade

### 1. Scale Up (Vertical)

- **CPU**: Mais processadores ou núcleos
- **Memória**: Mais RAM
- **Disco**: Mais espaço de armazenamento
- **Rede**: Mais bandwidth

### 2. Scale Out (Horizontal)

- **Servidores**: Mais instâncias
- **Banco de dados**: Sharding, replicação
- **Cache**: Mais nós de cache
- **CDN**: Mais edge locations

### 3. Scale Deep

Otimizar para usar recursos existentes de forma mais eficiente.

- **Algoritmos**: Algoritmos mais eficientes
- **Caching**: Reduzir carga em recursos
- **Compressão**: Reduzir tamanho de dados
- **Lazy loading**: Carregar dados sob demanda

## Padrões de Escalabilidade

### 1. Load Balancing

Distribuir carga entre múltiplos servidores.

```python
# Exemplo de load balancing
import random

class LoadBalancer:
    def __init__(self, servers):
        self.servers = servers
        self.current_index = 0
    
    def round_robin(self):
        """Round-robin load balancing"""
        server = self.servers[self.current_index]
        self.current_index = (self.current_index + 1) % len(self.servers)
        return server
    
    def random_selection(self):
        """Random load balancing"""
        return random.choice(self.servers)
    
    def least_connections(self, connections):
        """Least connections load balancing"""
        return min(connections.items(), key=lambda x: x[1])[0]
    
    def weighted_round_robin(self, weights):
        """Weighted round-robin para servidores com capacidades diferentes"""
        total_weight = sum(weights.values())
        rand = random.uniform(0, total_weight)
        
        cumulative = 0
        for server, weight in weights.items():
            cumulative += weight
            if rand <= cumulative:
                return server
        
        return list(weights.keys())[-1]

# Uso
servers = ['server1', 'server2', 'server3']
lb = LoadBalancer(servers)

for i in range(10):
    server = lb.round_robin()
    print(f"Request {i+1} -> {server}")
```

### 2. Database Sharding

Dividir dados em múltiplos bancos de dados.

```python
# Exemplo de sharding simples
class ShardedDatabase:
    def __init__(self, shards):
        self.shards = shards
    
    def get_shard(self, key):
        """Determina qual shard usar baseado na chave"""
        shard_index = hash(key) % len(self.shards)
        return self.shards[shard_index]
    
    def get(self, key):
        """Obtém valor do shard apropriado"""
        shard = self.get_shard(key)
        return shard.get(key)
    
    def set(self, key, value):
        """Define valor no shard apropriado"""
        shard = self.get_shard(key)
        shard.set(key, value)

# Uso
shards = [
    {'name': 'shard1', 'db': DatabaseConnection('db1')},
    {'name': 'shard2', 'db': DatabaseConnection('db2')},
    {'name': 'shard3', 'db': DatabaseConnection('db3')}
]

sharded_db = ShardedDatabase(shards)

# Dados são distribuídos automaticamente entre shards
sharded_db.set('user:123', {'name': 'Alice'})
sharded_db.set('user:456', {'name': 'Bob'})
```

### 3. Caching

Armazenar dados frequentemente acessados em memória.

```python
# Exemplo de caching distribuído
import redis
import json

class DistributedCache:
    def __init__(self, redis_hosts):
        self.clients = []
        for host in redis_hosts:
            client = redis.Redis(host=host, port=6379, db=0)
            self.clients.append(client)
    
    def get_client(self, key):
        """Seleciona cliente Redis baseado na chave"""
        client_index = hash(key) % len(self.clients)
        return self.clients[client_index]
    
    def get(self, key):
        """Obtém valor do cache"""
        client = self.get_client(key)
        value = client.get(key)
        return json.loads(value) if value else None
    
    def set(self, key, value, ttl=3600):
        """Define valor no cache"""
        client = self.get_client(key)
        client.setex(key, ttl, json.dumps(value))
    
    def delete(self, key):
        """Remove valor do cache"""
        client = self.get_client(key)
        client.delete(key)

# Uso
cache = DistributedCache(['redis1', 'redis2', 'redis3'])

cache.set('user:123', {'name': 'Alice', 'email': 'alice@example.com'})
user = cache.get('user:123')
```

### 4. Microservices

Dividir aplicação em serviços menores e independentes.

```yaml
# Exemplo de arquitetura de microservices
microservices:
  - name: user-service
    replicas: 3
    resources:
      cpu: 500m
      memory: 512Mi
  
  - name: order-service
    replicas: 5
    resources:
      cpu: 1000m
      memory: 1Gi
  
  - name: payment-service
    replicas: 2
    resources:
      cpu: 2000m
      memory: 2Gi
  
  - name: notification-service
    replicas: 2
    resources:
      cpu: 250m
      memory: 256Mi
```

## Estratégias de Escalabilidade

### 1. Stateless Design

Sistemas sem estado permitem escalar horizontalmente facilmente.

```python
# Exemplo de aplicação stateless
class StatelessAPI:
    def __init__(self, database):
        self.database = database
        # Sem estado local - todo estado está no banco de dados
    
    def handle_request(self, request):
        # Cada requisição é independente
        user_id = request.get('user_id')
        
        # Busca estado do banco
        user = self.database.get_user(user_id)
        
        # Processa requisição
        result = self._process(request, user)
        
        # Salva estado no banco
        self.database.update_user(user_id, result)
        
        return result
    
    def _process(self, request, user):
        """Processamento sem depender de estado local"""
        return {"status": "success"}
```

### 2. Asynchronous Processing

Processar tarefas de forma assíncrona para não bloquear requisições.

```python
# Exemplo de processamento assíncrono
import asyncio
from concurrent.futures import ThreadPoolExecutor

class AsyncProcessor:
    def __init__(self, max_workers=10):
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
    
    async def process_request(self, request):
        """Processa requisição de forma assíncrona"""
        # Tarefa rápida é processada imediatamente
        quick_result = await self._quick_process(request)
        
        # Tarefa lenta é processada em background
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(
            self.executor,
            self._slow_process,
            request
        )
        
        return quick_result
    
    async def _quick_process(self, request):
        """Processamento rápido"""
        await asyncio.sleep(0.01)
        return {"quick": "result"}
    
    def _slow_process(self, request):
        """Processamento lento (executado em thread separada)"""
        time.sleep(1)
        return {"slow": "result"}

# Uso
processor = AsyncProcessor(max_workers=10)
result = asyncio.run(processor.process_request({"data": "test"}))
```

### 3. Partitioning

Dividir dados em partições para distribuir carga.

```python
# Exemplo de partitioning
class PartitionedStorage:
    def __init__(self, num_partitions):
        self.partitions = {i: [] for i in range(num_partitions)}
        self.num_partitions = num_partitions
    
    def get_partition(self, key):
        """Determina partição baseado na chave"""
        return hash(key) % self.num_partitions
    
    def add(self, key, value):
        """Adiciona valor à partição apropriada"""
        partition_id = self.get_partition(key)
        self.partitions[partition_id].append((key, value))
    
    def get(self, key):
        """Obtém valor da partição apropriada"""
        partition_id = self.get_partition(key)
        for k, v in self.partitions[partition_id]:
            if k == key:
                return v
        return None
    
    def get_partition_size(self, partition_id):
        """Retorna tamanho de uma partição"""
        return len(self.partitions[partition_id])

# Uso
storage = PartitionedStorage(num_partitions=4)

for i in range(1000):
    storage.add(f"key_{i}", f"value_{i}")

# Verifica distribuição de dados
for i in range(4):
    print(f"Partition {i}: {storage.get_partition_size(i)} items")
```

### 4. Auto-scaling

Escalar automaticamente baseado na carga.

```yaml
# Exemplo de auto-scaling com Kubernetes
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-server-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-server
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 30
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
```

## Exemplos Práticos

### API REST

```python
# Exemplo de API escalável com Flask
from flask import Flask, jsonify
import redis
import json

app = Flask(__name__)

# Cache distribuído
cache = redis.Redis(host='redis-cluster', port=6379, db=0)

@app.route('/api/users/<user_id>')
def get_user(user_id):
    # Tenta do cache primeiro
    cached = cache.get(f"user:{user_id}")
    if cached:
        return jsonify(json.loads(cached))
    
    # Se não está no cache, busca do banco
    user = database.get_user(user_id)
    
    # Armazena no cache por 1 hora
    cache.setex(f"user:{user_id}", 3600, json.dumps(user))
    
    return jsonify(user)

if __name__ == '__main__':
    # Executa com múltiplos workers (Gunicorn)
    # gunicorn -w 4 -b 0.0.0.0:8000 app:app
    app.run(host='0.0.0.0', port=8000)
```

### Banco de Dados

```sql
-- Exemplo de sharding de banco de dados
-- Tabela de usuários shardada por user_id
CREATE TABLE users_shard_0 (
    user_id BIGINT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
) PARTITION BY HASH(user_id);

CREATE TABLE users_shard_1 (
    user_id BIGINT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
) PARTITION BY HASH(user_id);

-- Query roteada para o shard correto
-- SELECT * FROM users_shard_{user_id % 2} WHERE user_id = ?;
```

### Sistema de Mensagens

```python
# Exemplo de sistema de mensagens escalável com Kafka
from kafka import KafkaProducer, KafkaConsumer
import json

producer = KafkaProducer(
    bootstrap_servers=['kafka1:9092', 'kafka2:9092', 'kafka3:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Producer escalável - pode ter múltiplas instâncias
def send_message(topic, message):
    producer.send(topic, value=message)
    producer.flush()

# Consumer escalável - pode ter múltiplos consumer groups
consumer = KafkaConsumer(
    'events',
    bootstrap_servers=['kafka1:9092', 'kafka2:9092', 'kafka3:9092'],
    group_id='consumer-group-1',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

for message in consumer:
    process_message(message.value)
```

## Monitoramento de Escalabilidade

### Métricas Importantes

- **CPU Utilization**: Porcentagem de uso de CPU
- **Memory Utilization**: Porcentagem de uso de memória
- **Request Rate**: Requisições por segundo
- **Response Time**: Tempo de resposta
- **Queue Length**: Tamanho da fila de requisições
- **Error Rate**: Taxa de erros

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de escalabilidade
import psutil
import time

class ScalabilityMonitor:
    def __init__(self):
        self.metrics = []
    
    def collect_metrics(self):
        """Coleta métricas do sistema"""
        metrics = {
            'timestamp': time.time(),
            'cpu_percent': psutil.cpu_percent(),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_percent': psutil.disk_usage('/').percent,
            'network_sent': psutil.net_io_counters().bytes_sent,
            'network_recv': psutil.net_io_counters().bytes_recv
        }
        
        self.metrics.append(metrics)
        return metrics
    
    def get_average_metrics(self, window_seconds=60):
        """Calcula métricas médias na janela"""
        cutoff = time.time() - window_seconds
        recent_metrics = [m for m in self.metrics if m['timestamp'] > cutoff]
        
        if not recent_metrics:
            return None
        
        avg_cpu = sum(m['cpu_percent'] for m in recent_metrics) / len(recent_metrics)
        avg_memory = sum(m['memory_percent'] for m in recent_metrics) / len(recent_metrics)
        
        return {
            'avg_cpu': avg_cpu,
            'avg_memory': avg_memory,
            'samples': len(recent_metrics)
        }

# Uso
monitor = ScalabilityMonitor()

while True:
    metrics = monitor.collect_metrics()
    print(f"CPU: {metrics['cpu_percent']}%, Memory: {metrics['memory_percent']}%")
    
    avg = monitor.get_average_metrics(window_seconds=60)
    if avg and avg['avg_cpu'] > 70:
        print("High CPU usage - consider scaling out")
    
    time.sleep(10)
```

## Exemplo de SLA de Escalabilidade

```text
Requisitos de negócio:
- Sistema deve suportar crescimento de 10x em 1 ano
- Pico de Black Friday: 100x o tráfego normal
- Tráfego normal: 10.000 RPS
- Tráfego de pico: 1.000.000 RPS

SLA de escalabilidade:
- Escala horizontal automática: 3 a 100 réplicas
- Escala vertical: até 32 cores, 128 GB RAM por réplica
- Tempo de scale-up: < 2 minutos
- Tempo de scale-down: < 10 minutos
- Zero downtime durante scaling

Monitoramento:
- Alerta se CPU > 70% por 5 minutos
- Alerta se Memory > 80% por 5 minutos
- Alerta se Queue length > 100 por 1 minuto
- Alerta se scale-up demorar > 3 minutos
```

## Trade-offs

### Scalability vs Cost

- Alta escalabilidade aumenta custo
- Avaliar custo por unidade de capacidade
- Auto-scaling pode otimizar custo

### Scalability vs Complexity

- Sistemas escaláveis são mais complexos
- Complexidade pode introduzir bugs
- Manter simplicidade quando possível

### Scalability vs Consistency

- Escalabilidade pode sacrificar consistência (CAP theorem)
- Sistemas eventualmente consistentes escalam melhor
- Escolha baseada nos requisitos do negócio

### Scalability vs Latency

- Escalabilidade horizontal pode aumentar latência
- Coordenação entre nós adiciona overhead
- Encontrar balanceamento adequado

### Vertical vs Horizontal Scaling

- **Vertical**: Simples mas limitado
- **Horizontal**: Complexo mas ilimitado
- Muitos sistemas usam combinação de ambos

### _Links_

- <https://aws.amazon.com/blogs/architecture/fundamental-scaling-patterns/>
- <https://cloud.google.com/architecture/scalability>
- <https://azure.microsoft.com/en-us/overview/scalability/>
