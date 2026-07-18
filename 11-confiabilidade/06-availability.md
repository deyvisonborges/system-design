# Availability

Availability (disponibilidade) é a medida de quanto tempo um sistema está operacional e acessível para uso. É uma das métricas mais importantes de confiabilidade de sistemas, especialmente para serviços críticos de negócio.

## Definição

Availability é geralmente medida como uma porcentagem do tempo que o sistema está operacional:

```text
Availability = (Tempo operacional / Tempo total) × 100%
```

## Níveis de Disponibilidade

### 1. Nove de Disponibilidade

A disponibilidade é frequentemente expressa em "noves":

- **90% (um nove)**: 36.5 dias de downtime por ano
- **99% (dois nove)**: 3.65 dias de downtime por ano
- **99.9% (três nove)**: 8.76 horas de downtime por ano
- **99.99% (quatro nove)**: 52.6 minutos de downtime por ano
- **99.999% (cinco nove)**: 5.26 minutos de downtime por ano
- **99.9999% (seis nove)**: 31.5 segundos de downtime por ano

### 2. Cálculo de Downtime

```python
# Exemplo de cálculo de downtime
def calculate_downtime(availability_percentage, period='year'):
    """
    Calcula downtime baseado na disponibilidade
    
    Args:
        availability_percentage: Porcentagem de disponibilidade (ex: 99.9)
        period: 'year', 'month', 'week', 'day'
    """
    periods = {
        'year': 365 * 24 * 60 * 60,
        'month': 30 * 24 * 60 * 60,
        'week': 7 * 24 * 60 * 60,
        'day': 24 * 60 * 60
    }
    
    total_seconds = periods[period]
    uptime_percentage = availability_percentage / 100
    downtime_percentage = 1 - uptime_percentage
    downtime_seconds = total_seconds * downtime_percentage
    
    # Converter para formato legível
    days = downtime_seconds // (24 * 60 * 60)
    hours = (downtime_seconds % (24 * 60 * 60)) // (60 * 60)
    minutes = (downtime_seconds % (60 * 60)) // 60
    seconds = downtime_seconds % 60
    
    return {
        'total_seconds': downtime_seconds,
        'formatted': f"{int(days)}d {int(hours)}h {int(minutes)}m {int(seconds)}s"
    }

# Exemplo
downtime_99_9 = calculate_downtime(99.9, 'year')
print(f"99.9% availability: {downtime_99_9['formatted']} downtime/year")

downtime_99_99 = calculate_downtime(99.99, 'year')
print(f"99.99% availability: {downtime_99_99['formatted']} downtime/year")
```

## Tipos de Disponibilidade

### 1. High Availability (HA)

Sistemas projetados para minimizar downtime através de redundância e failover automático.

- **Características**: Redundância de hardware/software, failover automático, monitoramento contínuo
- **Objetivo**: 99.9% a 99.99% de disponibilidade
- **Uso**: Serviços críticos como e-commerce, sistemas bancários

### 2. Continuous Availability (CA)

Sistemas projetados para zero downtime planejado.

- **Características**: Rolling updates, blue-green deployments, canary releases
- **Objetivo**: 99.99%+ de disponibilidade
- **Uso**: Sistemas que não podem ter downtime (ex: sistemas de trading)

### 3. Disaster Recovery (DR)

Capacidade de recuperar sistemas após desastres.

- **Características**: Backups, sites de recuperação, planos de recuperação
- **Objetivo**: RPO (Recovery Point Objective) e RTO (Recovery Time Objective) específicos
- **Uso**: Proteção contra desastres naturais, ataques cibernéticos

## Métricas de Disponibilidade

### 1. MTBF (Mean Time Between Failures)

Tempo médio entre falhas do sistema.

```text
MTBF = Tempo total de operação / Número de falhas
```

### 2. MTTR (Mean Time To Repair)

Tempo médio para reparar o sistema após uma falha.

```text
MTTR = Tempo total de reparo / Número de reparos
```

### 3. Relação entre MTBF e MTTR

```text
Availability = MTBF / (MTBF + MTTR)
```

```python
# Exemplo de cálculo de availability com MTBF e MTTR
def calculate_availability_mtbf_mttr(mtbf_hours, mttr_hours):
    """
    Calcula availability baseado em MTBF e MTTR
    
    Args:
        mtbf_hours: Mean Time Between Failures em horas
        mttr_hours: Mean Time To Repair em horas
    """
    availability = mtbf_hours / (mtbf_hours + mttr_hours)
    return availability * 100

# Exemplo
availability = calculate_availability_mtbf_mttr(8760, 4)  # 1 ano MTBF, 4h MTTR
print(f"Availability: {availability:.4f}%")
```

## Arquiteturas para Alta Disponibilidade

### 1. Active-Passive

Um nó ativo e um ou mais nós passivos de backup.

```yaml
# Exemplo de configuração Active-Passive
ha_config:
  mode: active-passive
  nodes:
    - name: primary
      role: active
      ip: 10.0.0.1
    
    - name: secondary
      role: passive
      ip: 10.0.0.2
  
  failover:
    enabled: true
    method: heartbeat
    timeout: 30s
```

**Vantagens**:

- Implementação mais simples
- Menor custo (menos recursos ativos)

**Desvantagens**:

- Recursos passivos não são utilizados
- Failover pode causar downtime

### 2. Active-Active

Múltiplos nós ativos processando requisições simultaneamente.

```yaml
# Exemplo de configuração Active-Active
ha_config:
  mode: active-active
  nodes:
    - name: node1
      role: active
      ip: 10.0.0.1
    
    - name: node2
      role: active
      ip: 10.0.0.2
    
    - name: node3
      role: active
      ip: 10.0.0.3
  
  load_balancer:
    algorithm: round_robin
    health_check:
      enabled: true
      interval: 10s
      timeout: 5s
```

**Vantagens**:

- Melhor utilização de recursos
- Failover sem downtime
- Maior throughput

**Desvantagens**:

- Implementação mais complexa
- Maior custo
- Consistência de dados mais complexa

### 3. Multi-Region

Sistemas distribuídos em múltiplas regiões geográficas.

```yaml
# Exemplo de configuração Multi-Region
multi_region_config:
  regions:
    - name: us-east-1
      role: primary
      datacenters:
        - name: dc1
          nodes: 3
    
    - name: us-west-2
      role: secondary
      datacenters:
        - name: dc2
          nodes: 3
    
    - name: eu-west-1
      role: tertiary
      datacenters:
        - name: dc3
          nodes: 2
  
  replication:
    mode: async
    lag_target: 1s
  
  dns:
    routing: geo_dns
    failover: automatic
```

**Vantagens**:

- Proteção contra desastres regionais
- Melhor performance global
- Compliance com regulamentações locais

**Desvantagens**:

- Complexidade significativa
- Custo muito alto
- Latência entre regiões

## Estratégias de Alta Disponibilidade

### 1. Redundância

```python
# Exemplo de redundância de banco de dados
import psycopg2
from psycopg2 import pool

class DatabaseConnectionPool:
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
    
    def get_connection(self, read_only=False):
        """Obtém conexão do pool apropriado"""
        if read_only and self.replica_pools:
            # Usa réplica para leitura
            pool = self.replica_pools[0]
        else:
            # Usa primário para escrita
            pool = self.primary_pool
        
        return pool.getconn()
    
    def put_connection(self, conn, read_only=False):
        """Retorna conexão ao pool"""
        if read_only and self.replica_pools:
            pool = self.replica_pools[0]
        else:
            pool = self.primary_pool
        
        pool.putconn(conn)
```

### 2. Load Balancing

```python
# Exemplo de load balancing simples
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

# Uso
servers = ['server1', 'server2', 'server3']
lb = LoadBalancer(servers)

for i in range(10):
    server = lb.round_robin()
    print(f"Request {i+1} -> {server}")
```

### 3. Health Checks

```python
# Exemplo de health check
import requests
import time
from datetime import datetime

class HealthChecker:
    def __init__(self, endpoints):
        self.endpoints = endpoints
        self.status = {}
    
    def check_endpoint(self, endpoint):
        """Verifica saúde de um endpoint"""
        try:
            response = requests.get(endpoint['url'], timeout=5)
            is_healthy = response.status_code == 200
        except Exception as e:
            is_healthy = False
        
        self.status[endpoint['name']] = {
            'healthy': is_healthy,
            'last_check': datetime.now(),
            'url': endpoint['url']
        }
        
        return is_healthy
    
    def check_all(self):
        """Verifica saúde de todos os endpoints"""
        results = {}
        for endpoint in self.endpoints:
            results[endpoint['name']] = self.check_endpoint(endpoint)
        return results

# Uso
endpoints = [
    {'name': 'api', 'url': 'http://api.example.com/health'},
    {'name': 'db', 'url': 'http://db.example.com/health'},
    {'name': 'cache', 'url': 'http://cache.example.com/health'}
]

checker = HealthChecker(endpoints)
status = checker.check_all()
print(f"Health status: {status}")
```

### 4. Auto-scaling

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
  maxReplicas: 10
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
```

## Causas de Downtime

### 1. Hardware Failures

- **Disco**: Falhas de disco são comuns
- **Memória**: Módulos de memória defeituosos
- **CPU**: Overheating, falhas de processador
- **Rede**: Falhas de switches, roteadores, cabos

### 2. Software Failures

- **Bugs**: Erros no código que causam crashes
- **Memory leaks**: Uso excessivo de memória
- **Deadlocks**: Condições de corrida
- **Configuration errors**: Configurações incorretas

### 3. Human Errors

- **Mistakes**: Erros de operação
- **Misconfiguration**: Configurações incorretas
- **Accidental deletion**: Deleção acidental de dados
- **Incomplete testing**: Testes insuficientes

### 4. External Factors

- **Power outages**: Falhas de energia
- **Network issues**: Problemas de provedor de internet
- **Natural disasters**: Terremotos, furacões, etc.
- **Cyber attacks**: DDoS, ransomware, etc.

## Monitoramento de Disponibilidade

### 1. Uptime Monitoring

```python
# Exemplo de monitoramento de uptime
import requests
import time
from datetime import datetime, timedelta

class UptimeMonitor:
    def __init__(self, url, check_interval=60):
        self.url = url
        self.check_interval = check_interval
        self.downtime_periods = []
        self.last_check = None
    
    def check(self):
        """Verifica se o serviço está disponível"""
        try:
            response = requests.get(self.url, timeout=10)
            is_up = response.status_code == 200
            
            if is_up and self.last_check and not self.last_check['up']:
                # Serviço voltou a ficar disponível
                downtime_end = datetime.now()
                downtime_duration = downtime_end - self.last_check['time']
                self.downtime_periods.append({
                    'start': self.last_check['time'],
                    'end': downtime_end,
                    'duration': downtime_duration
                })
            
            self.last_check = {
                'up': is_up,
                'time': datetime.now()
            }
            
            return is_up
        except Exception as e:
            if self.last_check and self.last_check['up']:
                # Serviço ficou indisponível
                self.last_check['up'] = False
                self.last_check['time'] = datetime.now()
            
            return False
    
    def calculate_uptime(self, period_hours=24):
        """Calcula uptime percentual no período"""
        start_time = datetime.now() - timedelta(hours=period_hours)
        
        total_downtime = timedelta()
        for period in self.downtime_periods:
            if period['start'] >= start_time:
                total_downtime += period['duration']
        
        total_time = timedelta(hours=period_hours)
        uptime_percentage = ((total_time - total_downtime) / total_time) * 100
        
        return uptime_percentage

# Uso
monitor = UptimeMonitor('http://example.com')
while True:
    is_up = monitor.check()
    print(f"Service is {'up' if is_up else 'down'}")
    time.sleep(60)
```

### 2. Synthetic Monitoring

```python
# Exemplo de synthetic monitoring
from selenium import webdriver
from selenium.webdriver.common.by import By

class SyntheticMonitor:
    def __init__(self, url):
        self.url = url
        self.driver = webdriver.Chrome()
    
    def check_page_load(self):
        """Verifica se a página carrega corretamente"""
        try:
            self.driver.get(self.url)
            
            # Verifica se elemento importante está presente
            element = self.driver.find_element(By.ID, 'main-content')
            
            # Verifica se título está correto
            title = self.driver.title
            
            return {
                'success': True,
                'title': title,
                'load_time': self.driver.execute_script('return performance.timing.loadEventEnd - performance.timing.navigationStart')
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
        finally:
            self.driver.quit()
```

## Exemplo de SLA de Disponibilidade

```text
Requisitos de negócio:
- Sistema de e-commerce com faturamento de R$ 1M/mês
- Downtime custa R$ 500/hora
- Necessita alta disponibilidade para não perder vendas

SLA de disponibilidade:
- Disponibilidade mensal: 99.9% (43.2 minutos de downtime/mês)
- Disponibilidade anual: 99.95% (4.38 horas de downtime/ano)
- Tempo máximo de downtime contínuo: 15 minutos
- Tempo de recuperação (RTO): 5 minutos
- Perda máxima de dados (RPO): 1 minuto

Monitoramento:
- Alerta se disponibilidade < 99.9% no mês
- Alerta se downtime contínuo > 10 minutos
- Alerta se tempo de recuperação > 5 minutos
- Alerta se perda de dados > 1 minuto

Penalidades:
- Crédito de 10% se disponibilidade < 99.9%
- Crédito de 25% se disponibilidade < 99.5%
- Crédito de 50% se disponibilidade < 99.0%
```

## Trade-offs

### Availability vs Custo

- Alta disponibilidade geralmente aumenta custo significativamente
- Avaliar custo de downtime vs custo de redundância
- Níveis diferentes de disponibilidade para diferentes serviços

### Availability vs Complexity

- Sistemas HA são mais complexos
- Complexidade pode introduzir novos pontos de falha
- Manter simplicidade quando possível

### Availability vs Consistency

- Alta disponibilidade pode sacrificar consistência (CAP theorem)
- Sistemas eventualmente consistentes podem ter maior disponibilidade
- Escolha baseada nos requisitos do negócio

### Availability vs Performance

- Redundância pode adicionar latência
- Sincronização entre nós pode impactar performance
- Encontrar balanceamento adequado

### _Links_

- <https://sre.google/sre-book/engineering-for-release/>
- <https://aws.amazon.com/builders-library/operational-excellence-high-availability/>
- <https://azure.microsoft.com/en-us/overview/high-availability/>
