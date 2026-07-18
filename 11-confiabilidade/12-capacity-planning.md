# Capacity Planning

Capacity Planning (planejamento de capacidade) é o processo de determinar a capacidade de infraestrutura necessária para atender à demanda atual e futura de um sistema, garantindo que os recursos sejam suficientes para manter a performance e disponibilidade desejadas sem desperdício.

## Definição

Capacity Planning é o processo de prever e provisionar a capacidade de recursos necessários para atender à demanda de serviço, equilibrando custo, performance e disponibilidade.

```text
Capacity Planning = Previsão de demanda + Provisionamento de recursos
```

## Por que Capacity Planning é Importante

### 1. Prevenção de Problemas

- **Evita downtime**: Sistema fica disponível mesmo em picos de carga
- **Evita degradação**: Performance mantida sob carga
- **Evita custos excessivos**: Não provisiona recursos desnecessários

### 2. Otimização de Custos

- **Custo justo**: Paga apenas pelo necessário
- **Previsibilidade**: Custos previsíveis
- **Eficiência**: Uso eficiente de recursos

### 3. Planejamento Estratégico

- **Crescimento**: Planeja crescimento do negócio
- **Investimentos**: Planeja investimentos em infraestrutura
- **SLAs**: Garante cumprimento de SLAs

## Componentes do Capacity Planning

### 1. Análise de Demanda

Entender a demanda atual e futura.

```python
# Exemplo de análise de demanda
import pandas as pd
import numpy as np

class DemandAnalyzer:
    def __init__(self, historical_data):
        self.historical_data = historical_data
    
    def analyze_trends(self):
        """Analisa tendências de demanda"""
        # Calcula média móvel
        moving_avg = self.historical_data['requests'].rolling(window=7).mean()
        
        # Calcula crescimento
        growth_rate = self.historical_data['requests'].pct_change().mean()
        
        # Calcula sazonalidade
        seasonality = self._calculate_seasonality()
        
        return {
            'moving_average': moving_avg,
            'growth_rate': growth_rate,
            'seasonality': seasonality
        }
    
    def _calculate_seasonality(self):
        """Calcula sazonalidade"""
        # Simplificado - na prática usar métodos mais complexos
        weekly_pattern = self.historical_data.groupby(
            self.historical_data.index.dayofweek
        )['requests'].mean()
        return weekly_pattern
    
    def forecast_demand(self, periods=30):
        """Prevê demanda futura"""
        # Simplificado - usar modelos mais sofisticados em produção
        last_value = self.historical_data['requests'].iloc[-1]
        growth_rate = self.historical_data['requests'].pct_change().mean()
        
        forecast = []
        for i in range(periods):
            forecast.append(last_value * (1 + growth_rate) ** (i + 1))
        
        return forecast

# Uso
data = pd.DataFrame({
    'requests': np.random.normal(1000, 100, 100)
})

analyzer = DemandAnalyzer(data)
trends = analyzer.analyze_trends()
forecast = analyzer.forecast_demand(periods=30)

print(f"Growth rate: {trends['growth_rate']:.2%}")
print(f"Forecast for next month: {forecast[-1]:.0f} requests")
```

### 2. Análise de Capacidade

Entender a capacidade atual dos recursos.

```python
# Exemplo de análise de capacidade
import psutil

class CapacityAnalyzer:
    def __init__(self):
        self.metrics = {}
    
    def collect_metrics(self):
        """Coleta métricas de capacidade"""
        self.metrics = {
            'cpu': {
                'total': psutil.cpu_count(),
                'used_percent': psutil.cpu_percent(interval=1),
                'load_avg': psutil.getloadavg()
            },
            'memory': {
                'total': psutil.virtual_memory().total,
                'available': psutil.virtual_memory().available,
                'used_percent': psutil.virtual_memory().percent
            },
            'disk': {
                'total': psutil.disk_usage('/').total,
                'used': psutil.disk_usage('/').used,
                'used_percent': psutil.disk_usage('/').percent
            },
            'network': {
                'bytes_sent': psutil.net_io_counters().bytes_sent,
                'bytes_recv': psutil.net_io_counters().bytes_recv
            }
        }
        return self.metrics
    
    def calculate_utilization(self):
        """Calcula utilização de recursos"""
        return {
            'cpu_utilization': self.metrics['cpu']['used_percent'],
            'memory_utilization': self.metrics['memory']['used_percent'],
            'disk_utilization': self.metrics['disk']['used_percent']
        }
    
    def identify_bottlenecks(self, threshold=80):
        """Identifica gargalos"""
        bottlenecks = []
        
        if self.metrics['cpu']['used_percent'] > threshold:
            bottlenecks.append('CPU')
        
        if self.metrics['memory']['used_percent'] > threshold:
            bottlenecks.append('Memory')
        
        if self.metrics['disk']['used_percent'] > threshold:
            bottlenecks.append('Disk')
        
        return bottlenecks

# Uso
analyzer = CapacityAnalyzer()
metrics = analyzer.collect_metrics()
utilization = analyzer.calculate_utilization()
bottlenecks = analyzer.identify_bottlenecks()

print(f"Utilization: {utilization}")
print(f"Bottlenecks: {bottlenecks}")
```

### 3. Dimensionamento

Determinar a capacidade necessária.

```python
# Exemplo de dimensionamento
class CapacityPlanner:
    def __init__(self):
        self.resource_requirements = {}
    
    def calculate_cpu_requirements(self, requests_per_second, cpu_per_request):
        """Calcula requisitos de CPU"""
        total_cpu = requests_per_second * cpu_per_request
        cores_needed = total_cpu / 0.8  # 80% utilization target
        return {
            'total_cpu': total_cpu,
            'cores_needed': max(1, int(cores_needed))
        }
    
    def calculate_memory_requirements(self, concurrent_users, memory_per_user):
        """Calcula requisitos de memória"""
        total_memory = concurrent_users * memory_per_user
        memory_gb = total_memory / (1024 ** 3)
        return {
            'total_memory_bytes': total_memory,
            'memory_gb': memory_gb
        }
    
    def calculate_storage_requirements(self, data_growth_rate, retention_period):
        """Calcula requisitos de armazenamento"""
        current_size = 1e12  # 1 TB inicial
        growth_per_day = current_size * (data_growth_rate / 365)
        total_growth = growth_per_day * retention_period
        total_storage = current_size + total_growth
        storage_tb = total_storage / (1024 ** 4)
        
        return {
            'current_size_tb': current_size / (1024 ** 4),
            'growth_per_day_tb': growth_per_day / (1024 ** 4),
            'total_storage_tb': storage_tb
        }
    
    def calculate_bandwidth_requirements(self, requests_per_second, avg_response_size):
        """Calcula requisitos de bandwidth"""
        bandwidth_bps = requests_per_second * avg_response_size * 8
        bandwidth_mbps = bandwidth_bps / 1e6
        bandwidth_gbps = bandwidth_bps / 1e9
        
        return {
            'bandwidth_bps': bandwidth_bps,
            'bandwidth_mbps': bandwidth_mbps,
            'bandwidth_gbps': bandwidth_gbps
        }

# Uso
planner = CapacityPlanner()

# Exemplo: 10.000 RPS, 0.01 CPU por requisição
cpu_req = planner.calculate_cpu_requirements(10000, 0.01)
print(f"CPU requirements: {cpu_req}")

# Exemplo: 1.000 usuários concorrentes, 100 MB por usuário
mem_req = planner.calculate_memory_requirements(1000, 100 * 1024 * 1024)
print(f"Memory requirements: {mem_req}")

# Exemplo: 50% crescimento anual, retenção de 1 ano
storage_req = planner.calculate_storage_requirements(0.5, 365)
print(f"Storage requirements: {storage_req}")

# Exemplo: 10.000 RPS, 10 KB média de resposta
bandwidth_req = planner.calculate_bandwidth_requirements(10000, 10 * 1024)
print(f"Bandwidth requirements: {bandwidth_req}")
```

## Estratégias de Capacity Planning

### 1. Vertical Scaling

Aumentar capacidade de recursos existentes.

```yaml
# Exemplo de vertical scaling
vertical_scaling_plan:
  current:
    cpu: 4 cores
    memory: 16 GB
    disk: 500 GB
  
  phase_1:
    cpu: 8 cores
    memory: 32 GB
    disk: 1 TB
    trigger: cpu_utilization > 70%
  
  phase_2:
    cpu: 16 cores
    memory: 64 GB
    disk: 2 TB
    trigger: cpu_utilization > 80% or memory_utilization > 80%
```

### 2. Horizontal Scaling

Adicionar mais instâncias.

```yaml
# Exemplo de horizontal scaling
horizontal_scaling_plan:
  current:
    instances: 3
    cpu_per_instance: 4 cores
    memory_per_instance: 16 GB
  
  phase_1:
    instances: 5
    trigger: requests_per_second > 5000
  
  phase_2:
    instances: 10
    trigger: requests_per_second > 10000
  
  phase_3:
    instances: 20
    trigger: requests_per_second > 20000
```

### 3. Auto-scaling

Escalar automaticamente baseado em métricas.

```yaml
# Exemplo de auto-scaling
auto_scaling_policy:
  scale_up:
    trigger: cpu_utilization > 70% for 5 minutes
    action: add 2 instances
    max_instances: 20
  
  scale_down:
    trigger: cpu_utilization < 30% for 15 minutes
    action: remove 1 instance
    min_instances: 3
  
  predictive:
    enabled: true
    lookback_period: 7 days
    prediction_horizon: 1 hour
```

### 4. Right-sizing

Ajustar recursos para o tamanho correto.

```python
# Exemplo de right-sizing
class RightSizingAnalyzer:
    def __init__(self, resource_usage_data):
        self.usage_data = resource_usage_data
    
    def analyze_usage_patterns(self):
        """Analisa padrões de uso"""
        # Calcula percentis de uso
        p50 = self.usage_data['cpu'].quantile(0.50)
        p90 = self.usage_data['cpu'].quantile(0.90)
        p95 = self.usage_data['cpu'].quantile(0.95)
        p99 = self.usage_data['cpu'].quantile(0.99)
        
        return {
            'p50': p50,
            'p90': p90,
            'p95': p95,
            'p99': p99
        }
    
    def recommend_instance_type(self, current_type):
        """Recomenda tipo de instância"""
        patterns = self.analyze_usage_patterns()
        
        # Baseado no P95, recomenda tipo apropriado
        if patterns['p95'] < 20:
            return 'small'
        elif patterns['p95'] < 50:
            return 'medium'
        elif patterns['p95'] < 80:
            return 'large'
        else:
            return 'xlarge'
    
    def calculate_savings(self, current_type, recommended_type):
        """Calcula economia potencial"""
        prices = {
            'small': 50,
            'medium': 100,
            'large': 200,
            'xlarge': 400
        }
        
        current_cost = prices.get(current_type, 0)
        recommended_cost = prices.get(recommended_type, 0)
        
        savings = current_cost - recommended_cost
        savings_percentage = (savings / current_cost) * 100 if current_cost > 0 else 0
        
        return {
            'current_cost': current_cost,
            'recommended_cost': recommended_cost,
            'savings': savings,
            'savings_percentage': savings_percentage
        }

# Uso
import pandas as pd

usage_data = pd.DataFrame({
    'cpu': np.random.uniform(10, 90, 1000)
})

analyzer = RightSizingAnalyzer(usage_data)
patterns = analyzer.analyze_usage_patterns()
recommended = analyzer.recommend_instance_type('large')
savings = analyzer.calculate_savings('large', recommended)

print(f"Usage patterns: {patterns}")
print(f"Recommended type: {recommended}")
print(f"Potential savings: {savings}")
```

## Monitoramento de Capacity

### Métricas Importantes

- **CPU Utilization**: Porcentagem de uso de CPU
- **Memory Utilization**: Porcentagem de uso de memória
- **Disk Utilization**: Porcentagem de uso de disco
- **Network Utilization**: Porcentagem de uso de rede
- **Request Rate**: Requisições por segundo
- **Response Time**: Tempo de resposta

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de capacity
import time
from collections import deque

class CapacityMonitor:
    def __init__(self, window_size=100):
        self.window_size = window_size
        self.metrics = {
            'cpu': deque(maxlen=window_size),
            'memory': deque(maxlen=window_size),
            'disk': deque(maxlen=window_size),
            'requests': deque(maxlen=window_size)
        }
    
    def collect_metrics(self):
        """Coleta métricas"""
        self.metrics['cpu'].append(psutil.cpu_percent())
        self.metrics['memory'].append(psutil.virtual_memory().percent)
        self.metrics['disk'].append(psutil.disk_usage('/').percent)
        self.metrics['requests'].append(self._get_request_rate())
    
    def _get_request_rate(self):
        """Simula taxa de requisições"""
        return random.randint(100, 1000)
    
    def get_average_metrics(self):
        """Calcula métricas médias"""
        return {
            'avg_cpu': sum(self.metrics['cpu']) / len(self.metrics['cpu']),
            'avg_memory': sum(self.metrics['memory']) / len(self.metrics['memory']),
            'avg_disk': sum(self.metrics['disk']) / len(self.metrics['disk']),
            'avg_requests': sum(self.metrics['requests']) / len(self.metrics['requests'])
        }
    
    def check_capacity_alerts(self, thresholds):
        """Verifica alertas de capacidade"""
        alerts = []
        avg_metrics = self.get_average_metrics()
        
        if avg_metrics['avg_cpu'] > thresholds['cpu']:
            alerts.append(f"High CPU usage: {avg_metrics['avg_cpu']:.1f}%")
        
        if avg_metrics['avg_memory'] > thresholds['memory']:
            alerts.append(f"High memory usage: {avg_metrics['avg_memory']:.1f}%")
        
        if avg_metrics['avg_disk'] > thresholds['disk']:
            alerts.append(f"High disk usage: {avg_metrics['avg_disk']:.1f}%")
        
        return alerts

# Uso
monitor = CapacityMonitor()

for i in range(100):
    monitor.collect_metrics()
    time.sleep(1)

avg_metrics = monitor.get_average_metrics()
alerts = monitor.check_capacity_alerts({'cpu': 80, 'memory': 80, 'disk': 80})

print(f"Average metrics: {avg_metrics}")
print(f"Alerts: {alerts}")
```

## Exemplo de SLA de Capacity Planning

```text
Requisitos de negócio:
- Sistema de e-commerce com crescimento de 20% ao ano
- Pico de Black Friday: 10x o tráfego normal
- Tráfego normal: 10.000 RPS
- SLA de disponibilidade: 99.9%

SLA de capacity planning:
- Capacidade provisionada: 15.000 RPS (50% acima do normal)
- Capacidade de pico: 100.000 RPS (10x o normal)
- Auto-scaling: 3 a 20 instâncias
- Lead time para scaling: < 2 minutos
- Buffer de capacidade: 30%

Monitoramento:
- Alerta se utilização de CPU > 70% por 5 minutos
- Alerta se utilização de memória > 80% por 5 minutos
- Alerta se utilização de disco > 70%
- Alerta se capacidade provisionada < demanda prevista por 1 semana

Planejamento:
- Revisão mensal de capacidade
- Revisão trimestral de previsão
- Revisão anual de estratégia
- Buffer de emergência: 20% adicional
```

## Trade-offs

### Capacity vs Custo

- Mais capacidade aumenta custo
- Menos capacidade reduz custo mas aumenta risco
- Encontrar balanceamento adequado

### Capacity vs Performance

- Capacidade insuficiente degrada performance
- Capacidade excessiva desperdiça recursos
- Otimizar para SLAs específicos

### Capacity vs Lead Time

- Provisionar antecipadamente aumenta custo
- Provisionar sob demanda pode causar downtime
- Planejar lead times de fornecedores

### Over-provisioning vs Under-provisioning

- **Over-provisioning**: Custo mais alto, menor risco
- **Under-provisioning**: Custo menor, maior risco
- Escolha baseada na criticidade do sistema

### _Links_

- <https://aws.amazon.com/blogs/architecture/capacity-planning/>
- <https://cloud.google.com/architecture/capacity-planning>
- <https://azure.microsoft.com/en-us/overview/capacity-planning/>
