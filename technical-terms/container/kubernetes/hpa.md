# HPA

HPA (Horizontal Pod Autoscaler) é um recurso do Kubernetes que automaticamente ajusta o número de Pods em um Deployment, ReplicaSet ou StatefulSet baseado em métricas observadas como CPU e memória.

## Definição

HPA é um recurso do Kubernetes que automaticamente escala horizontalmente o número de Pods baseado em métricas de utilização como CPU, memória e métricas customizadas, garantindo que a aplicação tenha recursos suficientes para lidar com a carga.

```text
HPA = Escalamento horizontal + Métricas + Autoscaling automático
```

## Como Funciona

### 1. Métricas

```text
- CPU: Porcentagem de utilização
- Memória: Porcentagem de utilização
- Custom metrics: Métricas customizadas (Prometheus, etc.)
- External metrics: Métricas externas (SQS, etc.)
```

### 2. Algoritmo

```text
- Calcula replicas desejadas
- Baseia-se em métricas atuais
- Considera min/max replicas
- Aplica mudanças gradualmente
```

### 3. Comportamento

```text
- Scale up: Aumenta replicas quando carga alta
- Scale down: Diminui replicas quando carga baixa
- Stabilization window: Período de estabilização
- Cool down: Tempo entre escalamentos
```

## Exemplo Prático

### HPA Baseado em CPU

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

### HPA Baseado em Memória

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
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
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

### HPA com Comportamento de Escalamento

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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

## Comandos Úteis

### Gerenciar HPAs

```bash
# Criar HPA
kubectl apply -f hpa.yaml

# Listar HPAs
kubectl get hpa

# Ver detalhes
kubectl describe hpa myapp-hpa

# Criar HPA via CLI
kubectl autoscale deployment myapp --cpu-percent=50 --min=2 --max=10

# Ver métricas atuais
kubectl get hpa myapp-hpa --watch

# Deletar HPA
kubectl delete hpa myapp-hpa
```

## Vantagens

### 1. Automático

```text
- Escalamento automático
- Sem intervenção manual
- Responde a carga em tempo real
```

### 2. Eficiência

```text
- Usa recursos apenas quando necessário
- Reduz custos
- Melhora performance
```

### 3. Flexibilidade

```text
- Múltiplas métricas
- Comportamento configurável
- Integração com métricas customizadas
```

## Limitações

### 1. Latência

```text
- Tempo de resposta
- Pode não responder instantaneamente
- Requer estabilização
```

### 2. Métricas

```text
- Requer metrics-server
- Métricas customizadas complexas
- Dependência de monitoramento
```

### 3. Complexidade

```text
- Configuração pode ser complexa
- Troubleshooting desafiador
- Requer tuning
```

## Melhores Práticas

### 1. Configurar Requests Adequadamente

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### 2. Usar Stabilization Window

```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300
```

### 3. Configurar Min/Max Replicas

```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
```

### 4. Usar Múltiplas Métricas

```yaml
metrics:
- type: Resource
  resource:
    name: cpu
- type: Resource
  resource:
    name: memory
```

## Trade-offs

### HPA vs Manual Scaling

- **HPA**: Automático, eficiente
- **Manual**: Controle total, mais trabalho
- **Escolha**: HPA para produção, manual para desenvolvimento

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

- <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>
- <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/>
- <https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/>
