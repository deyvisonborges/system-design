# Backpressure

Backpressure (contrapressão) é um mecanismo de controle de fluxo que permite que um sistema downstream (consumidor) sinalize a um sistema upstream (produtor) que está sobrecarregado e precisa reduzir a taxa de envio de dados. Isso evita que o consumidor seja sobrecarregado e cause falhas em cascata.

## Definição

Backpressure é um padrão de controle de fluxo onde o consumidor controla a taxa de produção do produtor, garantindo que o sistema não seja sobrecarregado.

```text
Backpressure = Controle de fluxo do consumidor para o produtor
```

## Por que Backpressure é Importante

### 1. Prevenção de Sobrecarga

- **Evita OOM**: Previne out-of-memory errors
- **Evita crashes**: Previne falhas do sistema
- **Estabilidade**: Mantém o sistema estável sob carga

### 2. Controle de Recursos

- **Memória**: Controla uso de memória
- **CPU**: Controla uso de CPU
- **Rede**: Controla uso de rede
- **Disco**: Controla uso de disco

### 3. Qualidade de Serviço

- **Latência**: Mantém latência aceitável
- **Throughput**: Otimiza throughput
- **Priorização**: Permite priorizar requisições importantes

## Tipos de Backpressure

### 1. Reactive Pull-based

Consumidor solicita dados quando está pronto.

```python
# Exemplo de pull-based backpressure
import time
import queue

class PullBasedProducer:
    def __init__(self):
        self.data = [f"item_{i}" for i in range(1000)]
        self.index = 0
    
    def pull(self, batch_size=10):
        """Consumidor solicita dados"""
        if self.index >= len(self.data):
            return []
        
        batch = self.data[self.index:self.index + batch_size]
        self.index += batch_size
        return batch

class PullBasedConsumer:
    def __init__(self, producer):
        self.producer = producer
        self.processing_capacity = 5  # Pode processar 5 itens por vez
    
    def consume(self):
        """Consumidor controla a taxa"""
        while True:
            # Solicita apenas o que consegue processar
            batch = self.producer.pull(self.processing_capacity)
            
            if not batch:
                break
            
            # Processa o batch
            self.process(batch)
            
            # Pausa se necessário
            time.sleep(0.1)
    
    def process(self, batch):
        """Processa batch de dados"""
        for item in batch:
            print(f"Processing: {item}")
            time.sleep(0.01)

# Uso
producer = PullBasedProducer()
consumer = PullBasedConsumer(producer)
consumer.consume()
```

### 2. Push-based with Feedback

Produtor envia dados mas ajusta taxa baseado em feedback.

```python
# Exemplo de push-based com feedback
import time
import random

class PushBasedProducer:
    def __init__(self):
        self.data = [f"item_{i}" for i in range(1000)]
        self.index = 0
        self.send_rate = 10  # itens por segundo
    
    def push(self, consumer_feedback):
        """Produtor ajusta taxa baseado em feedback"""
        if consumer_feedback['queue_size'] > 50:
            # Reduz taxa se fila está cheia
            self.send_rate = max(1, self.send_rate // 2)
        elif consumer_feedback['queue_size'] < 10:
            # Aumenta taxa se fila está vazia
            self.send_rate = min(100, self.send_rate * 2)
        
        # Envia batch baseado na taxa
        batch_size = min(self.send_rate, len(self.data) - self.index)
        batch = self.data[self.index:self.index + batch_size]
        self.index += batch_size
        
        return batch

class PushBasedConsumer:
    def __init__(self):
        self.queue = queue.Queue(maxsize=100)
    
    def receive(self, batch):
        """Recebe dados do produtor"""
        for item in batch:
            try:
                self.queue.put_nowait(item)
            except queue.Full:
                print(f"Queue full, dropping: {item}")
    
    def process(self):
        """Processa dados da fila"""
        while not self.queue.empty():
            item = self.queue.get()
            print(f"Processing: {item}")
            time.sleep(0.01)
    
    def get_feedback(self):
        """Fornece feedback ao produtor"""
        return {
            'queue_size': self.queue.qsize(),
            'processing_rate': 10
        }

# Uso
producer = PushBasedProducer()
consumer = PushBasedConsumer()

for _ in range(100):
    feedback = consumer.get_feedback()
    batch = producer.push(feedback)
    consumer.receive(batch)
    consumer.process()
```

### 3. Hybrid Approach

Combinação de pull e push para melhor controle.

```python
# Exemplo de híbrido
import time
import queue

class HybridProducer:
    def __init__(self):
        self.data = [f"item_{i}" for i in range(1000)]
        self.index = 0
    
    def produce(self, request_size):
        """Produz baseado em solicitação"""
        batch_size = min(request_size, len(self.data) - self.index)
        batch = self.data[self.index:self.index + batch_size]
        self.index += batch_size
        return batch

class HybridConsumer:
    def __init__(self, producer):
        self.producer = producer
        self.queue = queue.Queue(maxsize=100)
    
    def consume(self):
        """Consumidor solicita dados quando necessário"""
        while True:
            # Verifica espaço disponível
            available_space = self.queue.maxsize - self.queue.qsize()
            
            if available_space > 0:
                # Solicita dados
                batch = self.producer.produce(available_space)
                
                if not batch:
                    break
                
                for item in batch:
                    self.queue.put_nowait(item)
            
            # Processa dados
            self.process()
            
            time.sleep(0.01)
    
    def process(self):
        """Processa dados da fila"""
        while not self.queue.empty():
            item = self.queue.get()
            print(f"Processing: {item}")
            time.sleep(0.01)

# Uso
producer = HybridProducer()
consumer = HybridConsumer(producer)
consumer.consume()
```

## Estratégias de Backpressure

### 1. Buffering

Usar buffers para absorver picos de carga.

```python
# Exemplo de buffering
import queue
import threading

class BufferedProducer:
    def __init__(self, buffer_size=100):
        self.buffer = queue.Queue(maxsize=buffer_size)
        self.running = False
    
    def start(self):
        """Inicia produção"""
        self.running = True
        thread = threading.Thread(target=self._produce)
        thread.start()
    
    def _produce(self):
        """Produz dados continuamente"""
        for i in range(1000):
            if not self.running:
                break
            
            try:
                self.buffer.put(f"item_{i}", timeout=1)
            except queue.Full:
                print("Buffer full, waiting...")
                time.sleep(0.1)
    
    def stop(self):
        """Para produção"""
        self.running = False

class BufferedConsumer:
    def __init__(self, producer):
        self.producer = producer
    
    def consume(self):
        """Consome dados do buffer"""
        while True:
            try:
                item = self.producer.buffer.get(timeout=1)
                print(f"Processing: {item}")
                time.sleep(0.01)
            except queue.Empty:
                print("Buffer empty, waiting...")
                time.sleep(0.1)

# Uso
producer = BufferedProducer(buffer_size=50)
producer.start()

consumer = BufferedConsumer(producer)
consumer.consume()
```

### 2. Rate Limiting

Limitar a taxa de produção.

```python
# Exemplo de rate limiting
import time
from collections import deque

class RateLimitedProducer:
    def __init__(self, rate_limit=10):
        self.rate_limit = rate_limit  # itens por segundo
        self.timestamps = deque()
    
    def produce(self, item):
        """Produz item respeitando rate limit"""
        now = time.time()
        
        # Remove timestamps antigos (mais de 1 segundo)
        while self.timestamps and now - self.timestamps[0] > 1:
            self.timestamps.popleft()
        
        # Verifica se pode produzir
        if len(self.timestamps) < self.rate_limit:
            self.timestamps.append(now)
            return item
        else:
            # Aguarda até poder produzir
            sleep_time = 1 - (now - self.timestamps[0])
            time.sleep(sleep_time)
            return self.produce(item)

# Uso
producer = RateLimitedProducer(rate_limit=5)

for i in range(20):
    item = producer.produce(f"item_{i}")
    print(f"Produced: {item} at {time.time():.2f}")
```

### 3. Rejection

Rejeitar requisições quando sobrecarregado.

```python
# Exemplo de rejection
import time
import random

class RejectingProducer:
    def __init__(self, max_queue_size=100):
        self.max_queue_size = max_queue_size
        self.queue_size = 0
    
    def produce(self, item):
        """Produz item ou rejeita se sobrecarregado"""
        if self.queue_size >= self.max_queue_size:
            raise Exception("System overloaded, request rejected")
        
        self.queue_size += 1
        return item
    
    def consume(self):
        """Consome item"""
        if self.queue_size > 0:
            self.queue_size -= 1

# Uso
producer = RejectingProducer(max_queue_size=10)

for i in range(20):
    try:
        item = producer.produce(f"item_{i}")
        print(f"Produced: {item}")
        producer.consume()
    except Exception as e:
        print(f"Rejected: {e}")
        time.sleep(0.1)
```

### 4. Load Shedding

Descartar carga não crítica.

```python
# Exemplo de load shedding
import time
import random

class LoadSheddingProducer:
    def __init__(self, shed_threshold=0.8):
        self.shed_threshold = shed_threshold
        self.load = 0.5
    
    def produce(self, item, priority='normal'):
        """Produz item com load shedding"""
        # Simula variação de carga
        self.load = min(1.0, self.load + random.uniform(-0.1, 0.1))
        
        # Se carga alta, descarta itens de baixa prioridade
        if self.load > self.shed_threshold and priority == 'low':
            print(f"Shedding low priority item: {item}")
            return None
        
        return item

# Uso
producer = LoadSheddingProducer(shed_threshold=0.7)

for i in range(20):
    priority = 'high' if i % 3 == 0 else 'low'
    item = producer.produce(f"item_{i}", priority)
    if item:
        print(f"Produced: {item}")
```

## Implementações Práticas

### 1. Reactive Streams (RxJava, Project Reactor)

```java
// Exemplo de backpressure com Project Reactor (Java)
import reactor.core.publisher.Flux;
import reactor.core.scheduler.Schedulers;

public class BackpressureExample {
    public static void main(String[] args) {
        Flux.range(1, 1000)
            .publishOn(Schedulers.boundedElastic())
            .onBackpressureBuffer(100)  // Buffer de 100 itens
            .map(item -> {
                System.out.println("Processing: " + item);
                Thread.sleep(10);  // Simula processamento
                return item * 2;
            })
            .subscribe(
                result -> System.out.println("Result: " + result),
                error -> System.err.println("Error: " + error)
            );
    }
}
```

### 2. Kafka Consumer

```python
# Exemplo de backpressure com Kafka
from kafka import KafkaConsumer
import time

consumer = KafkaConsumer(
    'events',
    bootstrap_servers=['localhost:9092'],
    group_id='consumer-group',
    max_poll_records=10,  # Limita registros por poll
    fetch_max_wait_ms=1000
)

for message in consumer:
    try:
        # Processa mensagem
        process_message(message.value)
        
        # Commit manual após processamento
        consumer.commit()
    except Exception as e:
        print(f"Error processing message: {e}")
        # Não commita, mensagem será reprocessada
        time.sleep(1)  # Backpressure: pausa antes de tentar novamente
```

### 3. HTTP Streaming

```python
# Exemplo de backpressure com HTTP streaming
import requests
import time

def stream_with_backpressure(url, chunk_size=1024):
    """Stream com backpressure"""
    response = requests.get(url, stream=True)
    
    for chunk in response.iter_content(chunk_size=chunk_size):
        # Processa chunk
        process_chunk(chunk)
        
        # Pausa se necessário
        if needs_pause():
            time.sleep(0.1)

def process_chunk(chunk):
    """Processa chunk"""
    print(f"Processing chunk of size: {len(chunk)}")

def needs_pause():
    """Verifica se precisa pausar"""
    return random.random() < 0.1
```

## Monitoramento de Backpressure

### Métricas Importantes

- **Queue Size**: Tamanho da fila
- **Processing Rate**: Taxa de processamento
- **Production Rate**: Taxa de produção
- **Rejection Rate**: Taxa de rejeição
- **Latency**: Latência de processamento

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento de backpressure
from collections import deque
import time

class BackpressureMonitor:
    def __init__(self):
        self.queue_sizes = deque(maxlen=100)
        self.production_rates = deque(maxlen=100)
        self.processing_rates = deque(maxlen=100)
        self.rejections = 0
    
    def record_queue_size(self, size):
        """Registra tamanho da fila"""
        self.queue_sizes.append(size)
    
    def record_production_rate(self, rate):
        """Registra taxa de produção"""
        self.production_rates.append(rate)
    
    def record_processing_rate(self, rate):
        """Registra taxa de processamento"""
        self.processing_rates.append(rate)
    
    def record_rejection(self):
        """Registra rejeição"""
        self.rejections += 1
    
    def get_summary(self):
        """Retorna resumo de métricas"""
        return {
            'avg_queue_size': sum(self.queue_sizes) / len(self.queue_sizes) if self.queue_sizes else 0,
            'avg_production_rate': sum(self.production_rates) / len(self.production_rates) if self.production_rates else 0,
            'avg_processing_rate': sum(self.processing_rates) / len(self.processing_rates) if self.processing_rates else 0,
            'total_rejections': self.rejections
        }

# Uso
monitor = BackpressureMonitor()

for i in range(100):
    monitor.record_queue_size(random.randint(0, 100))
    monitor.record_production_rate(random.randint(50, 150))
    monitor.record_processing_rate(random.randint(40, 120))
    
    if random.random() < 0.1:
        monitor.record_rejection()

summary = monitor.get_summary()
print(f"Backpressure summary: {summary}")
```

## Exemplo de SLA de Backpressure

```text
Requisitos de negócio:
- Sistema de processamento de eventos
- Não pode perder eventos críticos
- Deve lidar com picos de carga

SLA de backpressure:
- Tamanho máximo de buffer: 10.000 itens
- Taxa de rejeição: < 0.1% para eventos de alta prioridade
- Latência de processamento: < 100ms (P95)
- Tempo de recuperação: < 5 minutos após pico de carga

Monitoramento:
- Alerta se tamanho de buffer > 8.000 itens
- Alerta se taxa de rejeição > 0.05%
- Alerta se latência P95 > 150ms
- Alerta se taxa de produção > taxa de processamento por 5 minutos

Estratégias:
- Buffering para absorver picos
- Rejection para eventos de baixa prioridade
- Rate limiting para controlar carga
- Auto-scaling para aumentar capacidade
```

## Trade-offs

### Backpressure vs Latency

- Backpressure pode aumentar latência
- Produtor precisa esperar pelo consumidor
- Encontrar balanceamento adequado

### Backpressure vs Throughput

- Backpressure pode reduzir throughput
- Sistema opera abaixo da capacidade máxima
- Priorizar estabilidade sobre throughput

### Backpressure vs Complexity

- Implementações de backpressure são mais complexas
- Requer monitoramento e ajuste
- Manter simplicidade quando possível

### Buffer vs Rejection

- **Buffer**: Absorve picos mas usa memória
- **Rejection**: Economiza recursos mas pode perder dados
- Escolha baseada nos requisitos do negócio

### _Links_

- <https://reactivex.io/documentation/flow-control.html>
- <https://kafka.apache.org/documentation/#consumerconfigs>
- <https://aws.amazon.com/blogs/architecture/backpressure-patterns/>
