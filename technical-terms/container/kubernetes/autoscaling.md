# Autoscaling

Autoscaling é a técnica de automaticamente ajustar a quantidade de recursos baseado na carga, garantindo que a aplicação tenha recursos suficientes para lidar com o tráfego sem desperdício de recursos.

## Definição

Autoscaling é a capacidade de automaticamente ajustar o número de Pods ou recursos de um cluster baseado em métricas como CPU, memória, tráfego ou eventos externos, garantindo performance otimizada e custo eficiente.

```text
Autoscaling = Ajuste automático + Métricas + Eficiência
```

## Como Funciona

### 1. Tipos de Autoscaling

```text
- Horizontal Pod Autoscaler (HPA): Escala Pods horizontalmente
- Vertical Pod Autoscaler (VPA): Ajusta requests/limits verticalmente
- Cluster Autoscaler: Escala nós do cluster
- KEDA: Escala baseado em eventos externos
```

### 2. Métricas

```text
- CPU: Porcentagem de utilização
- Memória: Porcentagem de utilização
- Custom metrics: Métricas customizadas (Prometheus, etc.)
- External metrics: Métricas externas (SQS, Kafka, etc.)
```

### 3. Estratégias

```text
- Scale up: Aumenta recursos quando carga alta
- Scale down: Diminui recursos quando carga baixa
- Stabilization window: Período de estabilização
- Cool down: Tempo entre escalamentos
```

## Exemplo Prático

### HPA Simples

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### HPA com Múltiplas Métricas

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
```

### VPA

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: "*"
      minAllowed:
        cpu: "100m"
        memory: "100Mi"
      maxAllowed:
        cpu: "1"
        memory: "1Gi"
```

### KEDA com SQS

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
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-east-1.amazonaws.com/123456789012/my-queue
      awsRegion: us-east-1
      queueLength: "5"
```

## Comandos Úteis

### Gerenciar Autoscaling

```bash
# Criar HPA
kubectl apply -f hpa.yaml

# Listar HPAs
kubectl get hpa

# Ver detalhes do HPA
kubectl describe hpa myapp-hpa

# Ver métricas atuais
kubectl get hpa myapp-hpa --watch

# Criar VPA
kubectl apply -f vpa.yaml

# Ver recomendações do VPA
kubectl describe vpa myapp-vpa | grep -A 20 "Recommendation"

# Ver Cluster Autoscaler
kubectl logs -n kube-system deployment/cluster-autoscaler
```

## Vantagens

### 1. Eficiência

```text
- Recursos apenas quando necessário
- Reduz custos
- Melhora performance
```

### 2. Automático

```text
- Ajuste automático
- Sem intervenção manual
- Responde a carga em tempo real
```

### 3. Flexibilidade

```text
- Múltiplas métricas
- Estratégias personalizáveis
- Adaptação a diferentes cenários
```

## Limitações

### 1. Latência

```text
- Tempo de resposta
- Pode não responder instantaneamente
- Requer estabilização
```

### 2. Complexidade

```text
- Configuração pode ser complexa
- Requer monitoramento
- Troubleshooting desafiador
```

### 3. Recursos

```text
- Requer métricas
- Dependência de sistemas externos
- Pode impactar cluster
```

## Melhores Práticas

### 1. Configurar Requests Adequadamente

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### 2. Usar Múltiplas Métricas

```yaml
metrics:
- type: Resource
  resource:
    name: cpu
- type: Resource
  resource:
    name: memory
```

### 3. Configurar Min/Max Replicas

```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
```

### 4. Monitorar e Ajustar

```bash
# Monitorar métricas
kubectl get hpa myapp-hpa --watch

# Ajustar thresholds conforme necessário
kubectl edit hpa myapp-hpa
```

## Trade-offs

### HPA vs VPA

- **HPA**: Escala horizontal, mais Pods
- **VPA**: Escala vertical, mais recursos por Pod
- **Escolha**: HPA para escalabilidade, VPA para otimização

### CPU vs Memória vs Custom

- **CPU**: Métrica padrão, simples
- **Memória**: Para aplicações intensivas em memória
- **Custom**: Para casos específicos
- **Escolha**: CPU para geral, custom para específico

### Aggressivo vs Conservativo

- **Aggressivo**: Responde rápido, pode oscilar
- **Conservativo**: Estável, resposta lenta
- **Escolha**: Conservativo para produção, aggressivo para desenvolvimento

### _Links_

- <https://kubernetes.io/docs/concepts/cluster-administration/cluster-autoscaling/>
- <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>
- <https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler>
- <https://keda.sh/>
