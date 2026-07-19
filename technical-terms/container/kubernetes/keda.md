# KEDA

KEDA (Kubernetes Event-driven Autoscaling) é um componente de escalonamento baseado em eventos que permite escalar Kubernetes Pods automaticamente baseado em eventos externos como filas de mensagens, bancos de dados ou outras fontes.

## Definição

KEDA é um escalonador baseado em eventos para Kubernetes que permite escalar horizontalmente Pods baseado em eventos externos, integrando-se com o Horizontal Pod Autoscaler (HPA) para fornecer escalonamento inteligente e eficiente.

```text
KEDA = Event-driven autoscaling + Scalers externos + HPA
```

## Como Funciona

### 1. Componentes

```text
- Scaler: Conecta a fonte de eventos
- ScaledObject: Define regras de escalonamento
- ScaledJob: Escala Jobs baseado em eventos
- Metrics Server: Expor métricas para HPA
```

### 2. Fluxo

```text
- Scaler monitora fonte de eventos
- Calcula número de Pods necessários
- Expor métricas para HPA
- HPA escala Pods
- Pods processam eventos
```

### 3. Scalers

```text
- AWS SQS, Kafka, RabbitMQ
- Azure Storage, Service Bus
- GCP Pub/Sub
- Prometheus, Redis
- Custom scalers
```

## Exemplo Prático

### ScaledObject com SQS

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-sqs-scaler
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 2
  maxReplicaCount: 10
  cooldownPeriod: 30
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-east-1.amazonaws.com/123456789012/my-queue
      awsRegion: us-east-1
      queueLength: "5"
```

### ScaledObject com Kafka

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-kafka-scaler
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 2
  maxReplicaCount: 10
  cooldownPeriod: 30
  triggers:
  - type: kafka
    metadata:
      bootstrapServers: my-kafka-server:9092
      consumerGroup: my-group
      topic: my-topic
      lagThreshold: "100"
```

### ScaledObject com Prometheus

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-prometheus-scaler
spec:
  scaleTargetRef:
    name: myapp
  minReplicaCount: 2
  maxReplicaCount: 10
  cooldownPeriod: 30
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-server:9090
      metricName: http_requests_total
      threshold: "100"
      query: rate(http_requests_total[1m])
```

### ScaledJob para Processamento Batch

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: myapp-scaled-job
spec:
  jobTargetRef:
    parallelism: 1
    completions: 1
    backoffLimit: 6
  pollingInterval: 30
  maxReplicaCount: 10
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-east-1.amazonaws.com/123456789012/my-queue
      awsRegion: us-east-1
```

## Comandos Úteis

### Gerenciar KEDA

```bash
# Instalar KEDA
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.10.0/keda-2.10.0.yaml

# Ver ScaledObjects
kubectl get scaledobjects

# Ver detalhes do ScaledObject
kubectl describe scaledobject myapp-sqs-scaler

# Ver ScaledJobs
kubectl get scaledjobs

# Ver métricas do KEDA
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1 | jq
```

### Debug

```bash
# Ver logs do KEDA
kubectl logs -n keda deployment/keda-operator -f

# Ver métricas expostas
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1/namespaces/default/sqs-queue-length

# Ver status do HPA
kubectl get hpa
```

## Vantagens

### 1. Event-driven

```text
- Escala baseado em eventos reais
- Responde a carga de trabalho
- Eficiente em recursos
```

### 2. Flexibilidade

```text
- Múltiplos scalers
- Integração com HPA
- Custom scalers
```

### 3. Eficiência

```text
- Escala para zero quando não há eventos
- Reduz custos
- Otimiza recursos
```

## Limitações

### 1. Complexidade

```text
- Configuração pode ser complexa
- Requer entendimento de fontes de eventos
- Troubleshooting desafiador
```

### 2. Latência

```text
- Tempo de escalonamento
- Pode não responder instantaneamente
- Requer tuning
```

### 3. Dependência

```text
- Dependência de sistemas externos
- Requer acesso a métricas
- Ponto único de falha
```

## Melhores Práticas

### 1. Configurar min/max Replicas

```yaml
spec:
  minReplicaCount: 2
  maxReplicaCount: 10
```

### 2. Usar Cooldown Adequado

```yaml
spec:
  cooldownPeriod: 30
```

### 3. Usar ScaledJob para Batch

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
```

### 4. Monitorar Métricas

```bash
# Ver métricas expostas
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1
```

## Trade-offs

### KEDA vs HPA

- **KEDA**: Event-driven, escalonamento inteligente
- **HPA**: Baseado em CPU/memória, simples
- **Escolha**: KEDA para eventos, HPA para recursos

### Scale to Zero vs Min Replicas

- **Scale to zero**: Economiza recursos, latência de cold start
- **Min replicas**: Sempre pronto, mais custo
- **Escolha**: Scale to zero para não-crítico, min replicas para crítico

### Single Scaler vs Multiple Scalers

- **Single**: Simples, limitado
- **Multiple**: Flexível, mais complexo
- **Escolha**: Single para simples, multiple para complexo

### _Links_

- <https://keda.sh/docs/>
- <https://keda.sh/docs/concepts/>
- <https://keda.sh/docs/2.10/scalers/>
