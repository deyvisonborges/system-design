# Bandwidth

Bandwidth (largura de banda) é a capacidade máxima de transferência de dados através de um canal de comunicação em um determinado período de tempo. É uma medida teórica da capacidade de um link de rede ou sistema de processar dados.

## Definição

Bandwidth é geralmente medido em:

- **Bits por segundo (bps)**: Unidade fundamental
- **Kilobits por segundo (Kbps)**: 1.000 bps
- **Megabits por segundo (Mbps)**: 1.000.000 bps
- **Gigabits por segundo (Gbps)**: 1.000.000.000 bps
- **Bytes por segundo (B/s)**: 8 bits = 1 byte

```text
Bandwidth = Capacidade máxima de transferência de dados
```

## Bandwidth vs Throughput

Embora relacionados, bandwidth e throughput são conceitos diferentes:

- **Bandwidth**: Capacidade teórica máxima do canal (o que é possível)
- **Throughput**: Taxa real de transferência de dados (o que é alcançado)

```text
Throughput ≤ Bandwidth
```

Exemplo: Uma conexão de 1 Gbps pode ter throughput real de 800 Mbps devido a overhead de protocolo, congestionamento, etc.

## Tipos de Bandwidth

### 1. Bandwidth de Rede (Network Bandwidth)

Capacidade de transferência de dados através de uma rede.

- **Medido em**: Mbps, Gbps
- **Exemplos**:
  - Conexão residencial: 100 Mbps - 1 Gbps
  - Conexão empresarial: 1 Gbps - 10 Gbps
  - Backbone de datacenter: 40 Gbps - 100 Gbps
- **Fatores**: tipo de conexão (fibra, cobre, wireless), qualidade do equipamento, distância

### 2. Bandwidth de Sistema (System Bandwidth)

Capacidade de transferência de dados dentro de um sistema computacional.

- **Medido em**: MB/s, GB/s
- **Exemplos**:
  - RAM DDR4: 25.6 GB/s
  - SSD SATA: 600 MB/s
  - SSD NVMe: 3.000+ MB/s
  - PCIe 4.0: 32 GB/s
- **Fatores**: tipo de hardware, arquitetura do sistema, configuração

### 3. Bandwidth de Aplicação (Application Bandwidth)

Quantidade de dados que uma aplicação pode processar por unidade de tempo.

- **Medido em**: MB/s, GB/s
- **Exemplos**:
  - Servidor web: 100 MB/s - 1 GB/s
  - Banco de dados: 500 MB/s - 5 GB/s
  - Servidor de streaming: 1 GB/s - 10 GB/s
- **Fatores**: algoritmos, otimizações, recursos disponíveis

## Fatores que Afetam o Bandwidth

### 1. Meio Físico

```python
# Exemplo de diferentes meios físicos e suas capacidades
network_types = {
    "Cobre (Cat5e)": "1 Gbps",
    "Cobre (Cat6)": "10 Gbps",
    "Fibra Ótica (Single-mode)": "100+ Gbps",
    "Fibra Ótica (Multi-mode)": "10 Gbps",
    "Wireless (Wi-Fi 6)": "9.6 Gbps",
    "Wireless (5G)": "10 Gbps"
}
```

### 2. Distância

- Sinais degradam com a distância
- Fibra ótica tem menos degradação que cobre
- Wireless é mais sensível à distância

### 3. Protocolo e Overhead

```python
# Exemplo de overhead de protocolo
def calculate_effective_bandwidth(nominal_bandwidth, protocol_overhead):
    """
    Calcula bandwidth efetivo considerando overhead de protocolo
    
    Args:
        nominal_bandwidth: Bandwidth nominal em Mbps
        protocol_overhead: Porcentagem de overhead (0-100)
    """
    effective = nominal_bandwidth * (1 - protocol_overhead / 100)
    return effective

# Exemplo: 1 Gbps com 20% de overhead
effective = calculate_effective_bandwidth(1000, 20)
print(f"Bandwidth efetivo: {effective} Mbps")
```

### 4. Compartilhamento

- Bandwidth é compartilhado entre múltiplos usuários/processos
- Contenção reduz bandwidth disponível para cada um
- QoS (Quality of Service) pode priorizar tráfego

### 5. Congestionamento

- Tráfego excessivo causa congestionamento
- Pacotes podem ser descartados
- TCP reduz throughput em resposta

## Exemplos Práticos

### Streaming de Vídeo

```python
# Exemplo de requisitos de bandwidth para streaming
video_qualities = {
    "480p": {"bandwidth": "3 Mbps", "resolution": "854x480"},
    "720p": {"bandwidth": "5 Mbps", "resolution": "1280x720"},
    "1080p": {"bandwidth": "8 Mbps", "resolution": "1920x1080"},
    "4K": {"bandwidth": "25 Mbps", "resolution": "3840x2160"},
    "8K": {"bandwidth": "100 Mbps", "resolution": "7680x4320"}
}

def check_bandwidth_for_quality(available_bandwidth, quality):
    required = int(video_qualities[quality]["bandwidth"].split()[0])
    return available_bandwidth >= required

# Verificar se conexão de 50 Mbps suporta 4K
can_stream_4k = check_bandwidth_for_quality(50, "4K")
print(f"Pode fazer streaming 4K: {can_stream_4k}")
```

### Download de Arquivos

```python
# Exemplo de cálculo de tempo de download
def calculate_download_time(file_size_mb, bandwidth_mbps):
    """
    Calcula tempo de download
    
    Args:
        file_size_mb: Tamanho do arquivo em MB
        bandwidth_mbps: Bandwidth em Mbps
    """
    # Converter MB para Mb (megabits)
    file_size_mb = file_size_mb * 8
    
    # Calcular tempo em segundos
    time_seconds = file_size_mb / bandwidth_mbps
    
    # Converter para formato legível
    if time_seconds < 60:
        return f"{time_seconds:.1f} segundos"
    elif time_seconds < 3600:
        return f"{time_seconds / 60:.1f} minutos"
    else:
        return f"{time_seconds / 3600:.1f} horas"

# Exemplo: download de 10 GB com conexão de 100 Mbps
time = calculate_download_time(10240, 100)
print(f"Tempo estimado: {time}")
```

### API REST

```python
# Exemplo de bandwidth para API
import requests
import time

def measure_api_bandwidth(url, num_requests=100):
    """
    Mede bandwidth efetivo de uma API
    """
    total_bytes = 0
    start_time = time.time()
    
    for _ in range(num_requests):
        response = requests.get(url)
        total_bytes += len(response.content)
    
    end_time = time.time()
    elapsed = end_time - start_time
    
    # Calcular bandwidth em MB/s
    bandwidth_mbps = (total_bytes / elapsed) / (1024 * 1024)
    
    return bandwidth_mbps

bandwidth = measure_api_bandwidth("https://api.example.com/data")
print(f"Bandwidth da API: {bandwidth:.2f} MB/s")
```

## Otimização de Bandwidth

### 1. Compressão

```python
# Exemplo de compressão para economizar bandwidth
import gzip
import json

data = {"large": "data" * 10000}

# Sem compressão
json_data = json.dumps(data).encode('utf-8')
print(f"Tamanho sem compressão: {len(json_data)} bytes")

# Com compressão
compressed_data = gzip.compress(json_data)
print(f"Tamanho com compressão: {len(compressed_data)} bytes")
print(f"Redução: {(1 - len(compressed_data) / len(json_data)) * 100:.1f}%")
```

### 2. CDN (Content Delivery Network)

```yaml
# Exemplo de configuração de CDN
cdn_config:
  provider: cloudflare
  cache_rules:
    - pattern: "*.jpg"
      ttl: 86400  # 24 horas
    - pattern: "*.js"
      ttl: 3600   # 1 hora
    - pattern: "/api/*"
      ttl: 60     # 1 minuto
  
  compression:
    enabled: true
    types:
      - text/html
      - text/css
      - application/json
      - text/javascript
```

### 3. HTTP/2 e HTTP/3

- **HTTP/2**: Multiplexing, header compression, server push
- **HTTP/3 (QUIC)**: Melhor performance em redes com perda de pacotes

```python
# Exemplo de servidor HTTP/2 com Flask
from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1)

@app.route('/')
def hello():
    return "Hello, World! (HTTP/2)"

if __name__ == '__main__':
    # Necessário configurar certificado SSL para HTTP/2
    app.run(ssl_context='adhoc')
```

### 4. Lazy Loading

```javascript
// Exemplo de lazy loading de imagens
const images = document.querySelectorAll('img[data-src]');

const imageObserver = new IntersectionObserver((entries, observer) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      img.src = img.dataset.src;
      observer.unobserve(img);
    }
  });
});

images.forEach(img => imageObserver.observe(img));
```

### 5. Minificação e Bundling

```bash
# Exemplo de minificação com Webpack
# webpack.config.js
module.exports = {
  optimization: {
    minimize: true,
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        },
      },
    },
  },
};
```

## Monitoramento de Bandwidth

### Ferramentas

- **iftop**: Monitoramento de bandwidth de rede em tempo real
- **nload**: Monitoramento de tráfego de rede
- **speedtest-cli**: Teste de velocidade de conexão
- **Prometheus node_exporter**: Métricas de rede
- **CloudWatch/Azure Monitor**: Monitoramento de bandwidth em cloud

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de bandwidth com psutil
import psutil
import time

def monitor_network_bandwidth(interval=1):
    """
    Monitora bandwidth de rede em tempo real
    """
    while True:
        # Obter contadores de rede
        net_io = psutil.net_io_counters()
        
        # Calcular bandwidth
        bytes_sent = net_io.bytes_sent
        bytes_recv = net_io.bytes_recv
        
        time.sleep(interval)
        
        net_io_new = psutil.net_io_counters()
        
        # Calcular taxa
        sent_rate = (net_io_new.bytes_sent - bytes_sent) / interval
        recv_rate = (net_io_new.bytes_recv - bytes_recv) / interval
        
        print(f"Upload: {sent_rate / 1024 / 1024:.2f} MB/s")
        print(f"Download: {recv_rate / 1024 / 1024:.2f} MB/s")

# Executar monitoramento
monitor_network_bandwidth()
```

## Cálculo de Requisitos de Bandwidth

### Para Aplicações Web

```text
Requisitos de bandwidth = (Número de usuários simultâneos) × (Bandwidth por usuário)

Exemplo:
- 1.000 usuários simultâneos
- Cada usuário consome 2 Mbps (vídeo streaming)
- Requisito total: 1.000 × 2 Mbps = 2 Gbps
```

### Para Backup

```python
# Exemplo de cálculo de bandwidth para backup
def calculate_backup_bandwidth(data_size_gb, backup_window_hours):
    """
    Calcula bandwidth necessário para backup
    
    Args:
        data_size_gb: Tamanho dos dados em GB
        backup_window_hours: Janela de backup em horas
    """
    # Converter GB para Mb
    data_size_mb = data_size_gb * 8 * 1024
    
    # Converter horas para segundos
    window_seconds = backup_window_hours * 3600
    
    # Calcular bandwidth necessário em Mbps
    required_bandwidth = data_size_mb / window_seconds
    
    return required_bandwidth

# Exemplo: 10 TB em 8 horas
bandwidth = calculate_backup_bandwidth(10240, 8)
print(f"Bandwidth necessário: {bandwidth:.2f} Mbps")
```

### Para Video Conferencing

```python
# Exemplo de requisitos para video conferência
video_conference_requirements = {
    "audio_only": {"bandwidth": "64 Kbps", "quality": "básico"},
    "video_sd": {"bandwidth": "1 Mbps", "quality": "SD (480p)"},
    "video_hd": {"bandwidth": "2.5 Mbps", "quality": "HD (720p)"},
    "video_fhd": {"bandwidth": "4 Mbps", "quality": "Full HD (1080p)"},
    "video_4k": {"bandwidth": "25 Mbps", "quality": "4K"}
}

def calculate_conference_bandwidth(participants, quality):
    """
    Calcula bandwidth necessário para video conferência
    """
    required = int(video_conference_requirements[quality]["bandwidth"].split()[0])
    # Cada participante envia e recebe
    total = required * 2 * participants
    return total

# Exemplo: 10 participantes em HD
bandwidth = calculate_conference_bandwidth(10, "video_hd")
print(f"Bandwidth necessário: {bandwidth} Mbps")
```

## Limitações de Bandwidth

### 1. Lei de Shannon-Hartley

```text
C = B × log₂(1 + S/N)

Onde:
- C = Capacidade do canal (bandwidth máximo teórico)
- B = Largura de banda do canal (Hz)
- S = Potência do sinal
- N = Potência do ruído
```

Isso mostra que existe um limite teórico para a capacidade de qualquer canal de comunicação.

### 2. Overhead de Protocolo

- **TCP/IP**: ~20-40 bytes por pacote
- **Ethernet**: ~14 bytes por frame
- **HTTP headers**: ~500-1000 bytes por requisição
- **TLS/SSL**: Overhead adicional para criptografia

### 3. Jitter e Latência

Alto jitter e latência podem reduzir o throughput efetivo, mesmo com bandwidth disponível.

## Exemplo de SLA de Bandwidth

```text
Requisitos de negócio:
- Sistema de streaming para 10.000 usuários simultâneos
- Cada usuário consome 5 Mbps em média
- Pico de 20.000 usuários em horários de alta demanda

SLA de bandwidth:
- Bandwidth mínimo: 50 Gbps (baseline)
- Bandwidth de pico: 100 Gbps (horários de alta demanda)
- Bandwidth efetivo: ≥ 80% do bandwidth nominal

Monitoramento:
- Alerta se bandwidth efetivo < 40 Gbps por 5 minutos
- Alerta se bandwidth efetivo < 80 Gbps durante horários de pico
- Alerta se taxa de erro > 0.1%
```

## Trade-offs

### Bandwidth vs Custo

- Maior bandwidth geralmente aumenta custo
- Avaliar custo por Mbps
- Considerar bandwidth on-demand vs dedicado

### Bandwidth vs Latência

- Alta bandwidth não garante baixa latência
- Alguns aplicativos precisam mais de baixa latência que alta bandwidth
- Exemplo: VoIP precisa de baixa latência, streaming precisa de alta bandwidth

### Bandwidth vs Qualidade

- Compressão reduz bandwidth mas pode reduzir qualidade
- Encontrar balanceamento para experiência do usuário
- Adaptative bitrate ajusta qualidade baseado em bandwidth disponível

### _Links_

- <https://www.cloudflare.com/learning/network-layer/what-is-bandwidth/>
- <https://aws.amazon.com/blogs/networking-and-content-delivery/understanding-bandwidth-and-throughput-in-aws/>
- <https://www.sciencedirect.com/topics/engineering/bandwidth>
