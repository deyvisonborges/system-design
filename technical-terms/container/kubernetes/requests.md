# Requests

Requests são a quantidade mínima de recursos (CPU e memória) garantidos para um Pod, usados pelo scheduler para decidir em qual nó agendar o Pod e para garantir que o Pod tenha recursos suficientes.

## Definição

Resource requests especificam a quantidade mínima de recursos (CPU e memória) que um Pod precisa, garantindo que o scheduler agende o Pod em um nó com recursos suficientes e que o Pod tenha acesso a esses recursos.

```text
Requests = Recursos mínimos + Garantia + Agendamento
```

## Como Funciona

### 1. CPU Requests

```text
- Garantia de CPU: Mínimo de CPU disponível
- Unidades: millicores (m) ou cores
- Throttling: Pod pode usar mais se disponível
- Scheduling: Considerado pelo scheduler
```

### 2. Memory Requests

```text
- Garantia de memória: Mínimo de memória disponível
- Unidades: Mi, Gi, etc.
- OOM: Pod pode ser terminado se exceder
- Scheduling: Considerado pelo scheduler
```

### 3. Comportamento

```text
- Garantido: Pod sempre tem acesso aos recursos
- Não limitado: Pod pode usar mais se disponível
- QoS: Influencia classe de qualidade de serviço
```

## Exemplo Prático

### Requests Simples

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
```

### Requests com Limits

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

### Requests para Deployment

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
          requests:
            cpu: "100m"
            memory: "128Mi"
```

### Requests para Múltiplos Containers

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
      requests:
        cpu: "100m"
        memory: "128Mi"
  - name: sidecar
    image: my-sidecar:1.0
    resources:
      requests:
        cpu: "50m"
        memory: "64Mi"
```

## Comandos Úteis

### Gerenciar Requests

```bash
# Ver requests de um Pod
kubectl describe pod my-pod | grep -A 5 Requests

# Ver requests de todos os Pods
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[*].resources.requests.cpu,MEMORY:.spec.containers[*].resources.requests.memory

# Ver uso de recursos
kubectl top nodes
kubectl top pods

# Ver capacidade de nós
kubectl describe nodes | grep -A 5 Capacity
```

## Vantagens

### 1. Garantia

```text
- Recursos garantidos
- Performance previsível
- Estabilidade
```

### 2. Scheduling

```text
- Scheduler usa requests
- Agendamento inteligente
- Evita sobrecarga
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

### 2. Recursos

```text
- Pode desperdiçar recursos
- Overprovisioning
- Custo aumentado
```

### 3. Manutenção

```text
- Requer monitoramento
- Ajustes necessários
- Evolução da aplicação
```

## Melhores Práticas

### 1. Definir Requests Sempre

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### 2. Usar Valores Realistas

```yaml
# Baseado em monitoramento
resources:
  requests:
    cpu: "100m"  # Média de uso
    memory: "128Mi"  # Pico de uso
```

### 3. Usar VPA para Otimização

```yaml
# VPA recomenda requests ótimos
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

### 4. Combinar com Limits

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

### Requests vs Sem Requests

- **Com Requests**: Garantia, scheduling inteligente
- **Sem Requests**: Sem garantia, pode ser evitado
- **Escolha**: Sempre usar requests em produção

### Requests Baixos vs Altos

- **Baixos**: Economiza recursos, risco de performance
- **Altos**: Garantia, desperdício de recursos
- **Escolha**: Basear em monitoramento real

### Requests vs Limits

- **Requests**: Mínimo garantido
- **Limits**: Máximo permitido
- **Escolha**: Usar ambos para controle completo

### _Links_

- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/>
- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container>
- <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#how-pods-with-resource-limits-are-run>
