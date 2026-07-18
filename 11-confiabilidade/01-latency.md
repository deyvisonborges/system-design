# Latência

Latência é o tempo que leva para uma requisição viajar do cliente até o servidor e voltar com a resposta. É uma das métricas mais importantes para a experiência do usuário e para a performance de sistemas distribuídos.

## Definição

Latência é medida geralmente em milissegundos (ms) e representa o delay entre o envio de uma requisição e o recebimento da resposta correspondente.

```text
Cliente → [latência] → Servidor → [processamento] → Cliente
         ↑_____________round-trip time_____________↑
```

## Tipos de Latência

### 1. Latência de Rede (Network Latency)

Tempo que os dados levam para viajar pela rede entre cliente e servidor.

- **Fatores**: distância física, número de hops, qualidade da conexão, protocolo usado
- **Exemplo**: Uma requisição de São Paulo para um servidor em Nova York pode ter 100-200ms apenas de latência de rede
- **Otimização**: CDNs, edge computing, reduzir distância física

### 2. Latência de Processamento (Processing Latency)

Tempo que o servidor leva para processar a requisição e gerar a resposta.

- **Fatores**: complexidade da lógica de negócio, queries de banco de dados, cálculos computacionais
- **Exemplo**: Uma query complexa no banco de dados pode levar 50ms para processar
- **Otimização**: caching, índices de banco de dados, algoritmos mais eficientes

### 3. Latência de Serialização (Serialization Latency)

Tempo para converter dados entre diferentes formatos (JSON, XML, binary).

- **Fatores**: tamanho dos dados, formato de serialização, bibliotecas usadas
- **Exemplo**: Serializar um objeto grande para JSON pode levar 5-10ms
- **Otimização**: formatos binários (Protocol Buffers, Avro), compressão

### 4. Latência de I/O (Disk I/O Latency)

Tempo para ler ou escrever dados no disco.

- **Fatores**: tipo de disco (SSD vs HDD), velocidade do disco, fragmentação
- **Exemplo**: Leitura de SSD pode levar 0.1ms, HDD pode levar 10ms
- **Otimização**: SSD, buffer pools, caching em memória

## Métricas de Latência

### 1. Latência Média (Average Latency)

Média aritmética de todas as latências medidas.

- **Vantagem**: Fácil de calcular e entender
- **Desvantagem**: Pode esconder outliers e não refletir a experiência real do usuário
- **Uso**: Monitoramento geral, tendências ao longo do tempo

### 2. Latência Mediana (P50)

Valor que divide as requisições ao meio - 50% são mais rápidas, 50% mais lentas.

- **Vantagem**: Mais robusta que a média, menos afetada por outliers
- **Desvantagem**: Não captura a experiência dos usuários mais afetados
- **Uso**: Métrica de baseline para performance "normal"

### 3. Latência de Percentil (P95, P99, P99.9)

Percentil indica que X% das requisições são mais rápidas que esse valor.

- **P95**: 95% das requisições são mais rápidas - captura a experiência da maioria
- **P99**: 99% das requisições são mais rápidas - captura casos extremos
- **P99.9**: 99.9% das requisições são mais rápidas - captura outliers críticos
- **Uso**: SLAs, SLOs, identificar problemas de tail latency

## Exemplos Práticos

### E-commerce

- **Latência aceitável para página de produto**: < 500ms
- **Latência aceitável para checkout**: < 1s
- **Latência crítica para API de pagamento**: < 200ms

```python
# Exemplo de medição de latência em Python
import time

def measure_latency(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        latency_ms = (end - start) * 1000
        print(f"Latência: {latency_ms:.2f}ms")
        return result
    return wrapper

@measure_latency
def process_payment(user_id, amount):
    # Lógica de processamento de pagamento
    time.sleep(0.05)  # Simula 50ms de processamento
    return {"status": "success"}
```

### API REST

- **GET simples**: < 100ms
- **GET com joins complexos**: < 300ms
- **POST/PUT com validação**: < 200ms
- **DELETE**: < 100ms

### Streaming de Vídeo

- **Latência de buffer inicial**: < 2s
- **Latência de seek**: < 1s
- **Latência de troca de qualidade**: < 500ms

## Fatores que Afetam a Latência

### 1. Arquitetura do Sistema

- **Monolito**: Menos hops de rede, mas pode ter mais processamento
- **Microserviços**: Mais hops de rede, mas processamento distribuído
- **Serverless**: Cold start pode adicionar latência significativa

### 2. Banco de Dados

- **Queries não otimizadas**: Podem adicionar centenas de milissegundos
- **Falta de índices**: Full table scans são muito lentos
- **N+1 queries**: Múltiplas round trips ao banco

### 3. Rede

- **Distância física**: A luz viaja ~200km/ms em fibra ótica
- **Protocolo**: TCP adiciona overhead de handshake
- **Congestionamento**: Tráfego de rede pode causar delays

### 4. Hardware

- **CPU**: Processamento lento aumenta latência
- **Memória**: Page faults para swap aumentam latência drasticamente
- **Disco**: I/O é geralmente o gargalo

## Otimização de Latência

### 1. Caching

```python
# Exemplo de caching com Redis
import redis
import json

redis_client = redis.Redis(host='localhost', port=6379, db=0)

def get_user(user_id):
    # Tenta do cache primeiro
    cached = redis_client.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    
    # Se não está no cache, busca do banco
    user = db.query("SELECT * FROM users WHERE id = ?", user_id)
    
    # Armazena no cache por 1 hora
    redis_client.setex(f"user:{user_id}", 3600, json.dumps(user))
    return user
```

### 2. Compressão de Dados

- Comprimir respostas grandes (gzip, brotli)
- Usar formatos binários em vez de texto
- Minificar JavaScript/CSS em frontends

### 3. Paralelismo

```python
# Exemplo de requisições paralelas
import asyncio
import aiohttp

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

async def fetch_url(session, url):
    async with session.get(url) as response:
        return await response.text()
```

### 4. Índices de Banco de Dados

```sql
-- Adicionar índice para acelerar queries
CREATE INDEX idx_user_email ON users(email);

-- Query que se beneficia do índice
SELECT * FROM users WHERE email = 'user@example.com';
```

### 5. Edge Computing e CDNs

- Distribuir conteúdo geograficamente
- Processar requisições mais perto do usuário
- Reduzir distância física

## Monitoramento de Latência

### Ferramentas

- **APM**: New Relic, Datadog, Dynatrace
- **Synthetic monitoring**: Pingdom, Uptrends
- **RUM (Real User Monitoring)**: Google Analytics, Hotjar
- **Prometheus + Grafana**: Monitoramento customizado

### Alertas

```yaml
# Exemplo de alerta no Prometheus
- alert: HighLatency
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
  for: 5m
  annotations:
    summary: "Latência P95 acima de 500ms"
```

## Trade-offs

### Latência vs Throughput

- Otimizar para latência pode reduzir throughput
- Otimizar para throughput pode aumentar latência
- Encontrar o balanceamento correto para o caso de uso

### Latência vs Consistência

- Sistemas fortemente consistentes geralmente têm maior latência
- Sistemas eventualmente consistentes podem ter menor latência
- Escolha baseada nos requisitos do negócio

### Latência vs Custo

- Reduzir latência geralmente aumenta custo (mais hardware, CDNs)
- Avaliar ROI das otimizações de latência
- Priorizar otimizações com maior impacto

## Exemplo de Cálculo de SLA de Latência

```text
Requisitos de negócio:
- 95% dos usuários devem ter experiência "boa"
- Experiência "boa" = página carrega em < 1s

SLA de latência:
- P95 < 1000ms (1 segundo)
- P99 < 2000ms (2 segundos)
- P99.9 < 5000ms (5 segundos)

Monitoramento:
- Alerta se P95 > 1200ms por 5 minutos
- Alerta se P99 > 3000ms por 2 minutos
- Alerta se P99.9 > 10000ms por 1 minuto
```

### _Links_

- <https://sre.google/sre-book/service-level-objectives/>
- <https://www.cloudflare.com/learning/performance/what-is-latency/>
- <https://aws.amazon.com/what-is-latency/>
