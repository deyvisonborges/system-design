# Jitter

Jitter é a variação no tempo de chegada de pacotes de dados em uma rede. É uma medida da inconsistência na latência, onde pacotes que deveriam chegar em intervalos regulares chegam em tempos variáveis.

## Definição

Jitter é geralmente medido em milissegundos (ms) e representa a variação no delay entre pacotes consecutivos.

```text
Jitter = |Latência do pacote N - Latência do pacote N-1|
```

## Jitter vs Latência

Embora relacionados, jitter e latência são conceitos diferentes:

- **Latência**: Tempo total para um pacote viajar do origem ao destino
- **Jitter**: Variação na latência entre pacotes consecutivos

```text
Exemplo:
- Pacote 1: 100ms de latência
- Pacote 2: 120ms de latência
- Pacote 3: 90ms de latência
- Pacote 4: 110ms de latência

Latência média: 105ms
Jitter: Variação de 90ms a 120ms (±15ms)
```

## Tipos de Jitter

### 1. Jitter de Rede (Network Jitter)

Variação no tempo de trânsito de pacotes através da rede.

- **Causas**: Congestionamento, roteamento dinâmico, variação no processamento de roteadores
- **Impacto**: Degradação de qualidade em aplicações sensíveis ao tempo
- **Exemplo**: Streaming de vídeo com frames chegando em tempos irregulares

### 2. Jitter de Buffer (Buffer Jitter)

Variação no tempo que pacotes passam em buffers intermediários.

- **Causas**: Tamanho de buffer variável, algoritmos de enfileiramento
- **Impacto**: Aumenta latência total e variação
- **Exemplo**: Pacotes ficando mais tempo em buffers durante congestionamento

### 3. Jitter de Aplicação (Application Jitter)

Variação no tempo de processamento de pacotes pela aplicação.

- **Causas**: CPU load, garbage collection, priorização de processos
- **Impacto**: Inconsistência no processamento de áudio/vídeo
- **Exemplo**: Aplicação de VoIP processando pacotes em tempos variáveis

## Fatores que Afetam o Jitter

### 1. Congestionamento de Rede

```python
# Exemplo de simulação de jitter devido a congestionamento
import random
import time

def simulate_network_jitter(base_latency, max_jitter, num_packets):
    """
    Simula jitter em rede com congestionamento
    
    Args:
        base_latency: Latência base em ms
        max_jitter: Jitter máximo em ms
        num_packets: Número de pacotes a simular
    """
    latencies = []
    for i in range(num_packets):
        # Simula variação aleatória na latência
        jitter = random.uniform(-max_jitter, max_jitter)
        latency = base_latency + jitter
        latencies.append(max(0, latency))
    
    # Calcular jitter médio
    jitter_values = [abs(latencies[i] - latencies[i-1]) 
                     for i in range(1, len(latencies))]
    avg_jitter = sum(jitter_values) / len(jitter_values)
    
    return latencies, avg_jitter

latencies, avg_jitter = simulate_network_jitter(100, 20, 100)
print(f"Jitter médio: {avg_jitter:.2f}ms")
```

### 2. Roteamento Dinâmico

- Pacotes podem tomar rotas diferentes
- Rotas diferentes têm tempos de trânsito diferentes
- Protocolos de roteamento podem mudar rotas dinamicamente

### 3. Processamento Variável

- Roteadores com load variável
- Switches processando pacotes em tempos diferentes
- Firewalls com regras complexas

### 4. Meio Físico

- Wireless é mais suscetível a jitter que fibra ótica
- Interferência em redes sem fio
- Variação na qualidade do sinal

## Impacto do Jitter

### 1. Aplicações de Tempo Real

#### VoIP (Voice over IP)

- **Jitter aceitável**: < 30ms
- **Jitter problemático**: > 50ms
- **Impacto**: Áudio cortado, eco, distorção

```python
# Exemplo de buffer de jitter para VoIP
class JitterBuffer:
    def __init__(self, buffer_size=5):
        self.buffer = []
        self.buffer_size = buffer_size
    
    def add_packet(self, packet, timestamp):
        self.buffer.append((packet, timestamp))
        
        # Manter buffer ordenado por timestamp
        self.buffer.sort(key=lambda x: x[1])
        
        # Remover pacotes antigos se buffer estiver cheio
        if len(self.buffer) > self.buffer_size:
            self.buffer = self.buffer[-self.buffer_size:]
    
    def get_packet(self):
        if self.buffer:
            return self.buffer.pop(0)[0]
        return None

# Uso do buffer de jitter
jitter_buffer = JitterBuffer(buffer_size=5)
```

#### Video Conferencing

- **Jitter aceitável**: < 50ms
- **Jitter problemático**: > 100ms
- **Impacto**: Vídeo travado, dessincronização áudio-vídeo

#### Streaming de Vídeo

- **Jitter aceitável**: < 100ms
- **Jitter problemático**: > 200ms
- **Impacto**: Buffering, qualidade variável

### 2. Jogos Online

- **Jitter aceitável**: < 20ms
- **Jitter problemático**: > 50ms
- **Impacto**: Lag, teleportação, dessincronização

### 3. Aplicações Financeiras

- **Jitter aceitável**: < 10ms
- **Jitter problemático**: > 20ms
- **Impacto**: Perda de oportunidades, trades incorretos

## Medição de Jitter

### 1. Jitter Médio

Média das variações de latência entre pacotes consecutivos.

```python
def calculate_average_jitter(latencies):
    """
    Calcula jitter médio
    
    Args:
        latencies: Lista de latências em ms
    """
    jitter_values = []
    for i in range(1, len(latencies)):
        jitter = abs(latencies[i] - latencies[i-1])
        jitter_values.append(jitter)
    
    return sum(jitter_values) / len(jitter_values) if jitter_values else 0

# Exemplo
latencies = [100, 120, 90, 110, 105]
avg_jitter = calculate_average_jitter(latencies)
print(f"Jitter médio: {avg_jitter:.2f}ms")
```

### 2. Jitter Máximo

Maior variação de latência observada.

```python
def calculate_max_jitter(latencies):
    """
    Calcula jitter máximo
    """
    jitter_values = []
    for i in range(1, len(latencies)):
        jitter = abs(latencies[i] - latencies[i-1])
        jitter_values.append(jitter)
    
    return max(jitter_values) if jitter_values else 0

max_jitter = calculate_max_jitter(latencies)
print(f"Jitter máximo: {max_jitter:.2f}ms")
```

### 3. Jitter de Percentil

Percentil das variações de latência (similar a latência de percentil).

```python
import statistics

def calculate_percentile_jitter(latencies, percentile=95):
    """
    Calcula jitter de percentil
    """
    jitter_values = []
    for i in range(1, len(latencies)):
        jitter = abs(latencies[i] - latencies[i-1])
        jitter_values.append(jitter)
    
    return statistics.quantiles(jitter_values, n=100)[percentile-1]

p95_jitter = calculate_percentile_jitter(latencies, 95)
print(f"Jitter P95: {p95_jitter:.2f}ms")
```

## Mitigação de Jitter

### 1. Jitter Buffer

```python
# Exemplo avançado de jitter buffer adaptativo
class AdaptiveJitterBuffer:
    def __init__(self, initial_size=5, min_size=2, max_size=10):
        self.buffer = []
        self.buffer_size = initial_size
        self.min_size = min_size
        self.max_size = max_size
        self.late_packets = 0
        self.early_packets = 0
    
    def add_packet(self, packet, timestamp):
        current_time = time.time()
        
        # Verificar se pacote chegou muito tarde
        if timestamp < current_time - 0.1:  # 100ms de tolerância
            self.late_packets += 1
            return False
        
        # Verificar se pacote chegou muito cedo
        if timestamp > current_time + 0.1:
            self.early_packets += 1
        
        self.buffer.append((packet, timestamp))
        self.buffer.sort(key=lambda x: x[1])
        
        # Ajustar tamanho do buffer baseado em estatísticas
        self._adjust_buffer_size()
        
        return True
    
    def _adjust_buffer_size(self):
        # Aumentar buffer se muitos pacotes chegaram tarde
        if self.late_packets > 5 and self.buffer_size < self.max_size:
            self.buffer_size += 1
            self.late_packets = 0
        
        # Reduzir buffer se muitos pacotes chegaram cedo
        if self.early_packets > 5 and self.buffer_size > self.min_size:
            self.buffer_size -= 1
            self.early_packets = 0
    
    def get_packet(self):
        if len(self.buffer) >= self.buffer_size:
            return self.buffer.pop(0)[0]
        return None
```

### 2. QoS (Quality of Service)

```yaml
# Exemplo de configuração de QoS para reduzir jitter
qos_config:
  priority_queues:
    - name: voice
      priority: highest
      max_delay: 10ms
      bandwidth: 1Mbps
    
    - name: video
      priority: high
      max_delay: 50ms
      bandwidth: 10Mbps
    
    - name: data
      priority: normal
      max_delay: 100ms
      bandwidth: remaining
  
  traffic_shaping:
    enabled: true
    algorithm: token_bucket
    rate: 100Mbps
    burst: 10Mbps
```

### 3. Protocolos de Transporte

#### UDP vs TCP

- **UDP**: Sem controle de congestionamento, menor jitter mas pode perder pacotes
- **TCP**: Controle de congestionamento, maior jitter mas mais confiável

```python
# Exemplo de socket UDP para aplicações sensíveis a jitter
import socket

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Para reduzir jitter, usar timestamps nos pacotes
def send_with_timestamp(sock, data, address):
    timestamp = time.time()
    packet = f"{timestamp}:{data}"
    sock.sendto(packet.encode(), address)
```

### 4. Redundância

```python
# Exemplo de envio redundante para mitigar jitter
def send_redundant(sock, data, address, num_copies=3):
    """
    Envia múltiplas cópias do mesmo pacote
    """
    for _ in range(num_copies):
        sock.sendto(data, address)
    
    # No receptor, usar a primeira cópia que chegar
```

## Monitoramento de Jitter

### Ferramentas

- **ping**: Com opção para medir jitter
- **iperf3**: Ferramenta de medição de rede com jitter
- **Wireshark**: Análise de pacotes com cálculo de jitter
- **Prometheus**: Métricas customizadas de jitter

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de jitter com ping
import subprocess
import re

def measure_jitter(host, count=10):
    """
    Mede jitter usando ping
    """
    result = subprocess.run(
        ['ping', '-c', str(count), host],
        capture_output=True,
        text=True
    )
    
    # Extrair tempos de resposta
    times = re.findall(r'time=([\d.]+)ms', result.stdout)
    latencies = [float(time) for time in times]
    
    # Calcular jitter
    jitter = calculate_average_jitter(latencies)
    
    return jitter, latencies

jitter, latencies = measure_jitter('google.com')
print(f"Jitter: {jitter:.2f}ms")
print(f"Latências: {latencies}")
```

## Exemplos Práticos

### VoIP

```python
# Exemplo de cálculo de MOS (Mean Opinion Score) baseado em jitter
def calculate_mos(latency, jitter, packet_loss):
    """
    Calcula MOS baseado em latência, jitter e perda de pacotes
    
    MOS varia de 1 (ruim) a 5 (excelente)
    """
    # Fator de latência
    if latency < 150:
        r_latency = 93.2
    elif latency < 250:
        r_latency = 93.2 - (latency - 150) * 0.4
    else:
        r_latency = 93.2 - 100 - (latency - 250) * 0.1
    
    # Fator de jitter
    r_jitter = max(0, r_latency - jitter * 2)
    
    # Fator de perda de pacotes
    r_loss = r_jitter - packet_loss * 2.5
    
    # Converter para MOS
    if r_loss < 0:
        mos = 1
    else:
        mos = 1 + (0.035 * r_loss) + (7e-6 * r_loss * (r_loss - 60) * (100 - r_loss))
    
    return min(5, max(1, mos))

# Exemplo
mos = calculate_mos(latency=100, jitter=15, packet_loss=0.5)
print(f"MOS: {mos:.2f}/5.0")
```

### Streaming de Vídeo (Adaptação de Bitrate)

```python
# Exemplo de adaptação de bitrate baseado em jitter
def adapt_bitrate(current_bitrate, jitter, packet_loss):
    """
    Adapta bitrate baseado em jitter e perda de pacotes
    """
    bitrates = [300, 500, 1000, 2000, 4000, 8000]  # kbps
    
    # Reduzir bitrate se jitter ou perda de pacotes for alto
    if jitter > 100 or packet_loss > 2:
        current_index = bitrates.index(current_bitrate)
        if current_index > 0:
            return bitrates[current_index - 1]
    
    # Aumentar bitrate se jitter e perda de pacotes forem baixos
    if jitter < 30 and packet_loss < 0.5:
        current_index = bitrates.index(current_bitrate)
        if current_index < len(bitrates) - 1:
            return bitrates[current_index + 1]
    
    return current_bitrate
```

## Exemplo de SLA de Jitter

```text
Requisitos de negócio:
- Sistema de VoIP para 1.000 usuários simultâneos
- Qualidade de áudio deve ser "boa" ou "excelente"
- MOS mínimo de 4.0

SLA de jitter:
- Jitter médio: < 30ms
- Jitter P95: < 50ms
- Jitter P99: < 100ms

Monitoramento:
- Alerta se jitter médio > 40ms por 5 minutos
- Alerta se jitter P95 > 60ms por 2 minutos
- Alerta se jitter P99 > 120ms por 1 minuto
- Alerta se MOS < 3.5 por 5 minutos
```

## Trade-offs

### Jitter vs Latência (Trade-off)

- Reduzir jitter pode aumentar latência (ex: jitter buffer maior)
- Encontrar balanceamento para aplicação específica
- VoIP prefere jitter baixo mesmo com latência maior

### Jitter vs Perda de Pacotes

- Reduzir jitter pode aumentar perda de pacotes (ex: descartar pacotes atrasados)
- Aplicações diferentes têm tolerâncias diferentes
- Streaming de vídeo tolera mais perda que VoIP

### Jitter vs Custo

- Reduzir jitter geralmente aumenta custo (hardware melhor, QoS)
- Avaliar custo-benefício para aplicação
- Priorizar redução de jitter em aplicações críticas

### _Links_

- <https://www.cloudflare.com/learning/network-layer/what-is-jitter/>
- <https://aws.amazon.com/blogs/networking-and-content-delivery/understanding-jitter-in-network-performance/>
- <https://www.voip-info.org/jitter/>
