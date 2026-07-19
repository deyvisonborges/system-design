# Rolling Update

Rolling Update é uma estratégia de atualização que gradualmente substitui Pods antigos por novos Pods, garantindo zero downtime e permitindo rollback em caso de problemas.

## Definição

Rolling Update é uma estratégia de atualização do Kubernetes que gradualmente substitui Pods antigos por novos Pods em um Deployment, garantindo disponibilidade contínua e permitindo rollback se necessário.

```text
Rolling Update = Atualização gradual + Zero downtime + Rollback
```

## Como Funciona

### 1. Estratégia

```text
- RollingUpdate: Substitui gradualmente Pods
- Recreate: Termina todos Pods antes de criar novos
- MaxUnavailable: Máximo de Pods indisponíveis
- MaxSurge: Máximo de Pods extras durante atualização
```

### 2. Processo

```text
- Cria novos Pods gradualmente
- Termina Pods antigos gradualmente
- Mantém disponibilidade
- Verifica readiness probes
```

### 3. Rollback

```text
- Guarda histórico de revisões
- Permite rollback instantâneo
- Reverte para versão anterior
- Sem downtime
```

## Exemplo Prático

### Rolling Update Padrão

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
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
```

### Rolling Update Conservativo

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
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
```

### Rolling Update Rápido

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 2
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
```

### Recreate Strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  strategy:
    type: Recreate
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
```

## Comandos Úteis

### Gerenciar Rolling Updates

```bash
# Atualizar imagem
kubectl set image deployment/my-app my-container=my-image:2.0

# Ver status da atualização
kubectl rollout status deployment/my-app

# Ver histórico de revisões
kubectl rollout history deployment/my-app

# Rollback para versão anterior
kubectl rollout undo deployment/my-app

# Rollback para versão específica
kubectl rollout undo deployment/my-app --to-revision=2

# Pausar atualização
kubectl rollout pause deployment/my-app

# Retomar atualização
kubectl rollout resume deployment/my-app
```

## Vantagens

### 1. Zero Downtime

```text
- Disponibilidade contínua
- Sem interrupção de serviço
- Experiência do usuário mantida
```

### 2. Segurança

```text
- Rollback instantâneo
- Histórico de revisões
- Recuperação rápida de problemas
```

### 3. Flexibilidade

```text
- Configuração granular
- Estratégias personalizáveis
- Adaptação a diferentes necessidades
```

## Limitações

### 1. Complexidade

```text
- Configuração pode ser complexa
- Requer readiness probes
- Troubleshooting desafiador
```

### 2. Tempo

```text
- Atualização pode ser lenta
- Depende de número de Pods
- Requer tuning adequado
```

### 3. Recursos

```text
- Requer recursos extras
- maxSurge aumenta uso temporário
- Pode impactar cluster
```

## Melhores Práticas

### 1. Usar Readiness Probes

```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

### 2. Configurar maxUnavailable e maxSurge

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

### 3. Testar em Ambiente de Staging

```bash
# Testar atualização em staging
kubectl set image deployment/my-app-staging my-container=my-image:2.0
kubectl rollout status deployment/my-app-staging
```

### 4. Monitorar Durante Atualização

```bash
# Monitorar status
kubectl rollout status deployment/my-app --watch

# Ver logs
kubectl logs -f deployment/my-app
```

## Trade-offs

### RollingUpdate vs Recreate

- **RollingUpdate**: Zero downtime, mais complexo
- **Recreate**: Downtime, simples
- **Escolha**: RollingUpdate para produção, Recreate para desenvolvimento

### maxUnavailable Baixo vs Alto

- **Baixo**: Mais Pods disponíveis, atualização mais lenta
- **Alto**: Atualização mais rápida, menos Pods disponíveis
- **Escolha**: Baixo para crítico, alto para não-crítico

### maxSurge Baixo vs Alto

- **Baixo**: Menos recursos extras, atualização mais lenta
- **Alto**: Atualização mais rápida, mais recursos extras
- **Escolha**: Baixo para recursos limitados, alto para recursos abundantes

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment>
- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment>
- <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rollback-a-deployment>
