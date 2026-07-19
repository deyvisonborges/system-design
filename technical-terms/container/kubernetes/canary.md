# Canary

Canary é uma estratégia de implantação que direciona uma pequena porcentagem de tráfego para uma nova versão da aplicação, permitindo testes em produção com risco minimizado antes de uma implantação completa.

## Definição

Canary é uma estratégia de implantação que direciona uma pequena porcentagem de tráfego para uma nova versão da aplicação, permitindo validação em produção com risco minimizado antes de uma implantação completa.

```text
Canary = Tráfego parcial + Testes em produção + Risco minimizado
```

## Como Funciona

### 1. Estratégias

```text
- Pod-based: Múltiplos Deployments com diferentes versões
- Service-based: Service com seleção de Pods
- Ingress-based: Ingress com split de tráfego
- Istio-based: VirtualService com split de tráfego
```

### 2. Processo

```text
- Implanta nova versão com poucas réplicas
- Direciona pequena porcentagem de tráfego
- Monitora métricas e logs
- Aumenta tráfego gradualmente se estável
- Rollback rápido se problemas
```

### 3. Métricas

```text
- Taxa de erro
- Latência
- Throughput
- Satisfação do usuário
```

## Exemplo Prático

### Canary com Múltiplos Deployments

```yaml
# Deployment versão estável
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-stable
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
      version: stable
  template:
    metadata:
      labels:
        app: my-app
        version: stable
    spec:
      containers:
      - name: my-container
        image: my-image:1.0

---
# Deployment versão canary
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
      version: canary
  template:
    metadata:
      labels:
        app: my-app
        version: canary
    spec:
      containers:
      - name: my-container
        image: my-image:2.0
```

### Service para Canary

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

### Canary com Istio

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: my-app
spec:
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: my-app
        subset: canary
  - route:
    - destination:
        host: my-app
        subset: stable
      weight: 90
    - destination:
        host: my-app
        subset: canary
      weight: 10
```

### Canary com Argo Rollouts

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-app
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 10m}
      - setWeight: 25
      - pause: {duration: 10m}
      - setWeight: 50
      - pause: {duration: 10m}
      - setWeight: 100
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
        image: my-image:2.0
```

## Comandos Úteis

### Gerenciar Canary

```bash
# Ver Deployments
kubectl get deployments

# Ver Pods
kubectl get pods -l app=my-app

# Ver tráfego (com Istio)
kubectl get virtualservices

# Escalar canary
kubectl scale deployment my-app-canary --replicas=2

# Promover canary
kubectl set image deployment/my-app-stable my-container=my-image:2.0
kubectl scale deployment/my-app-canary --replicas=0
```

## Vantagens

### 1. Risco Minimizado

```text
- Testes em produção com risco baixo
- Impacto limitado a pequena porcentagem
- Rollback rápido
```

### 2. Validação Real

```text
- Testes com tráfego real
- Validação de performance
- Feedback de usuários reais
```

### 3. Flexibilidade

```text
- Controle granular de tráfego
- Ajuste dinâmico
- Adaptação a diferentes cenários
```

## Limitações

### 1. Complexidade

```text
- Configuração complexa
- Requer ferramentas adicionais
- Troubleshooting desafiador
```

### 2. Tempo

```text
- Processo mais lento
- Requer monitoramento contínuo
- Decisões manuais
```

### 3. Recursos

```text
- Requer recursos extras
- Múltiplos Deployments
- Aumenta custo temporariamente
```

## Melhores Práticas

### 1. Começar com Porcentagem Baixa

```text
- Iniciar com 5-10% de tráfego
- Aumentar gradualmente
- Monitorar métricas
```

### 2. Monitorar Métricas Chave

```text
- Taxa de erro
- Latência
- Throughput
- Satisfação do usuário
```

### 3. Definir Critérios de Sucesso

```text
- Taxa de erro < 0.1%
- Latência < 100ms
- Sem regressões
```

### 4. Automatizar Rollback

```text
- Rollback automático se critérios não atendidos
- Integração com sistemas de alerta
- Processo manual como fallback
```

## Trade-offs

### Canary vs Blue-Green

- **Canary**: Tráfego gradual, mais complexo
- **Blue-Green**: Troca instantânea, mais simples
- **Escolha**: Canary para validação gradual, Blue-Green para troca rápida

### Canary vs Rolling Update

- **Canary**: Tráfego controlado, validação em produção
- **Rolling Update**: Atualização automática, sem controle de tráfego
- **Escolha**: Canary para crítico, Rolling Update para padrão

### Istio vs Argo Rollouts vs Manual

- **Istio**: Poderoso, complexo, requer service mesh
- **Argo Rollouts**: Especializado, mais simples
- **Manual**: Flexível, mais trabalho
- **Escolha**: Istio se já usa, Argo Rollouts para especializado, Manual para simples

### _Links_

- <https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#canary-deployments>
- <https://istio.io/latest/docs/concepts/traffic-management/#canary-deployments>
- <https://argoproj.github.io/argo-rollouts/>
