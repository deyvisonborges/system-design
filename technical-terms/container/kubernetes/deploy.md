# Deploy

Deploy (Deployment) é um recurso do Kubernetes que gerencia a implantação e o ciclo de vida de Pods stateless, proporcionando atualizações declarativas, rollback e escalabilidade.

## Definição

Deployment é um recurso do Kubernetes que declara o estado desejado de Pods e ReplicaSets, gerenciando automaticamente a criação, atualização e escalabilidade de aplicações stateless.

```text
Deploy = Pods + ReplicaSets + Atualizações declarativas
```

## Como Funciona

### 1. Estrutura do Deployment

```text
- Deployment: Define o estado desejado
- ReplicaSet: Mantém o número de Pods
- Pods: Executa os containers
- Controller: Garante o estado desejado
```

### 2. Processo de Atualização

```text
1. Nova versão do Deployment é aplicada
2. Novo ReplicaSet é criado
3. Pods novos são criados gradualmente
4. Pods antigos são terminados gradualmente
5. Atualização é completada
```

### 3. Rolling Update

```text
- Atualização gradual sem downtime
- Configurável (maxSurge, maxUnavailable)
- Permite rollback instantâneo
- Mantém disponibilidade durante atualização
```

## Exemplo Prático

### Deployment Simples

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### Deployment com Strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### Deployment com Resources

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

## Estratégias de Atualização

### 1. RollingUpdate (Padrão)

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 25%
```

### 2. Recreate

```yaml
strategy:
  type: Recreate
```

## Comandos Úteis

### Gerenciar Deployments

```bash
# Criar deployment
kubectl apply -f deployment.yaml

# Listar deployments
kubectl get deployments

# Ver detalhes
kubectl describe deployment nginx-deployment

# Escalar deployment
kubectl scale deployment nginx-deployment --replicas=5

# Atualizar imagem
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Ver histórico de revisões
kubectl rollout history deployment/nginx-deployment

# Rollback
kubectl rollout undo deployment/nginx-deployment

# Rollback para revisão específica
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

## Vantagens

### 1. Declarativo

```text
- Define estado desejado
- Kubernetes gerencia implementação
- Self-healing automático
```

### 2. Atualizações

```text
- Rolling updates sem downtime
- Rollback instantâneo
- Histórico de revisões
```

### 3. Escalabilidade

```text
- Escalabilidade horizontal
- Auto-scaling com HPA
- Fácil de gerenciar
```

## Limitações

### 1. Stateful

```text
- Não adequado para aplicações stateful
- Pods são efêmeros
- Requer StatefulSet para stateful
```

### 2. Persistência

```text
- Pods não mantêm dados
- Requer PVCs para persistência
- Dados perdidos ao recriar
```

### 3. Complexidade

```text
- Configuração pode ser complexa
- Requer entendimento do Kubernetes
- Troubleshooting desafiador
```

## Melhores Práticas

### 1. Usar Labels Adequadamente

```yaml
metadata:
  labels:
    app: myapp
    version: v1
    environment: production
```

### 2. Configurar Resources

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

### 3. Usar Probes

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 4. Configurar Strategy Adequadamente

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

## Trade-offs

### RollingUpdate vs Recreate

- **RollingUpdate**: Sem downtime, mais complexo
- **Recreate**: Downtime, simples
- **Escolha**: RollingUpdate para produção, Recreate para desenvolvimento

### Replicas Fixas vs Auto-scaling

- **Fixas**: Previsível, menos flexível
- **Auto-scaling**: Flexível, menos previsível
- **Escolha**: Auto-scaling para produção, fixas para desenvolvimento

### Single Container vs Multi-container

- **Single**: Simples, menos overhead
- **Multi-container**: Mais flexível, mais complexo
- **Escolha**: Single para geral, multi-container quando necessário

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment>
- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment>
