# Limits

Limits são a quantidade máxima de recursos (CPU e memória) que um Pod pode usar, prevenindo que um Pod consuma todos os recursos de um nó e afete outros Pods no mesmo nó.

## Definição

Resource limits especificam a quantidade máxima de recursos (CPU e memória) que um Pod pode usar, prevenindo que um Pod consuma recursos excessivos e afete a estabilidade do nó e outros Pods.

```text
Limits = Recursos máximos + Prevenção de excesso + Controle
```

## Como Funciona

### 1. CPU Limits

```text
- Limite de CPU: Máximo de CPU que Pod pode usar
- Throttling: CPU é limitada ao exceder
- Unidades: millicores (m) ou cores
- Não afeta scheduling: Scheduler não considera limits
```

### 2. Memory Limits

```text
- Limite de memória: Máximo de memória que Pod pode usar
- OOM Kill: Pod é terminado se exceder
- Unidades: Mi, Gi, etc.
- Hard limit: Não pode exceder
```

### 3. Comportamento

```text
- CPU: Throttling se exceder
- Memória: OOM Kill se exceder
- QoS: Influencia classe de qualidade de serviço
- Proteção: Protege outros Pods
```

## Exemplo Prático

### Limits Simples

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    resources:
      limits:
        cpu: "500m"
        memory: "512Mi"
```

### Limits com Requests

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

### Limits para Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: my-image:1.0
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
```

### Limits para Múltiplos Containers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: my-app:1.0
    resources:
      limits:
        cpu: "500m"
        memory: "512Mi"
  - name: sidecar
    image: my-sidecar:1.0
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
```

## Comandos Úteis

### Gerenciar Limits

```bash
# Ver limits de um Pod
kubectl describe pod my-pod | grep -A 5 Limits

# Ver limits de todos os Pods
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[*].resources.limits.cpu,MEMORY:.spec.containers[*].resources.limits.memory

# Ver uso de recursos
kubectl top nodes
kubectl top pods

# Ver eventos de OOM
kubectl describe pod my-pod | grep -i oom
```

## Vantagens

### 1. Proteção

```text
- Protege outros Pods
- Previne runaway processes
- Estabilidade do nó
```

### 2. Controle

```text
- Controla uso de recursos
- Prevenção de excesso
- Isolamento
```

### 3. QoS

```text
- Define classe de QoS
- Prioridade em situações críticas
- Melhora estabilidade
```

## Limitações

### 1. Complexidade

```text
- Requer tuning
- Difícil de estimar
- Pode ser subestimado
```

### 2. Performance

```text
- CPU throttling pode afetar performance
- OOM Kill pode causar downtime
- Requer monitoramento
```

### 3. Manutenção

```text
- Requer monitoramento
- Ajustes necessários
- Evolução da aplicação
```

## Melhores Práticas

### 1. Definir Limits Sempre

```yaml
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

### 2. Usar Valores Realistas

```yaml
# Baseado em monitoramento
resources:
  limits:
    cpu: "500m"  # Pico de uso + buffer
    memory: "512Mi"  # Pico de uso + buffer
```

### 3. Usar VPA para Otimização

```yaml
# VPA recomenda limits ótimos
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
```

### 4. Combinar com Requests

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

## Trade-offs

### Limits vs Sem Limits

- **Com Limits**: Proteção, controle
- **Sem Limits**: Sem proteção, pode afetar outros
- **Escolha**: Sempre usar limits em produção

### Limits Baixos vs Altos

- **Baixos**: Economiza recursos, risco de OOM/throttling
- **Altos**: Proteção, desperdício de recursos
- **Escolha**: Basear em monitoramento real

### CPU vs Memory Limits

- **CPU**: Throttling, não mata Pod
- **Memory**: OOM Kill, mata Pod
- **Escolha**: CPU mais flexível, memory mais crítico

### _Links_

- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/>
- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container>
- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#how-pods-with-resource-limits-are-run>
