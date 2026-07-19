# VPA

VPA (Vertical Pod Autoscaler) é um recurso do Kubernetes que automaticamente ajusta os requests e limits de CPU e memória de Pods baseado no uso histórico, otimizando a alocação de recursos.

## Definição

VPA é um recurso do Kubernetes que automaticamente ajusta os requests e limits de recursos (CPU e memória) de Pods baseado no uso histórico, garantindo que os Pods tenham recursos adequados sem desperdício.

```text
VPA = Escalamento vertical + Requests/limits + Otimização de recursos
```

## Como Funciona

### 1. Modos de Atualização

```text
- Off: Apenas recomendações, não aplica
- Auto: Aplica automaticamente (requer recreação de Pods)
- Recreate: Recria Pods para aplicar mudanças
- Initial: Apenas para Pods novos
```

### 2. Recomendações

```text
- Baseado em uso histórico
- Calcula requests/limits ótimos
- Considera padrões de uso
- Ajusta periodicamente
```

### 3. Componentes

```text
- Recommender: Calcula recomendações
- Updater: Aplica mudanças
- Admission Controller: Injeta recomendações
```

## Exemplo Prático

### VPA Simples

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       myapp
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

### VPA com Modo Recreate

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       myapp
  updatePolicy:
    updateMode: "Recreate"
  resourcePolicy:
    containerPolicies:
    - containerName: "*"
      controlledResources: ["cpu", "memory"]
```

### VPA com Modo Off (Apenas Recomendações)

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       myapp
  updatePolicy:
    updateMode: "Off"
```

### VPA com Políticas de Container

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       myapp
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: myapp
      minAllowed:
        cpu: "100m"
        memory: "128Mi"
      maxAllowed:
        cpu: "500m"
        memory: "512Mi"
      controlledResources: ["cpu", "memory"]
    - containerName: sidecar
      mode: "Off"
```

## Comandos Úteis

### Gerenciar VPAs

```bash
# Criar VPA
kubectl apply -f vpa.yaml

# Listar VPAs
kubectl get vpa

# Ver detalhes
kubectl describe vpa myapp-vpa

# Ver recomendações
kubectl describe vpa myapp-vpa | grep -A 20 "Recommendation"

# Ver status
kubectl get vpa myapp-vpa -o yaml

# Deletar VPA
kubectl delete vpa myapp-vpa
```

## Vantagens

### 1. Otimização

```text
- Recursos adequados
- Reduz desperdício
- Melhora performance
```

### 2. Automático

```text
- Ajuste automático
- Sem intervenção manual
- Baseado em uso real
```

### 3. Flexibilidade

```text
- Múltiplos modos
- Políticas configuráveis
- Por container
```

## Limitações

### 1. Recreação

```text
- Requer recreação de Pods
- Downtime potencial
- Não compatível com HPA para CPU
```

### 2. Histórico

```text
- Requer histórico de uso
- Tempo para aprender
- Pode não ser preciso inicialmente
```

### 3. Complexidade

```text
- Configuração pode ser complexa
- Troubleshooting desafiador
- Requer monitoramento
```

## Melhores Práticas

### 1. Usar Modo Off Inicialmente

```yaml
updatePolicy:
  updateMode: "Off"  # Apenas recomendações
```

### 2. Configurar Min/Max Adequadamente

```yaml
resourcePolicy:
  containerPolicies:
  - minAllowed:
      cpu: "100m"
      memory: "100Mi"
    maxAllowed:
      cpu: "1"
      memory: "1Gi"
```

### 3. Não Usar com HPA para CPU

```text
- VPA e HPA para CPU não são compatíveis
- Use VPA para memória, HPA para CPU
- Ou use VPA sozinho
```

### 4. Monitorar Recomendações

```bash
kubectl describe vpa myapp-vpa | grep -A 20 "Recommendation"
```

## Trade-offs

### VPA vs HPA

- **VPA**: Escalamento vertical, otimiza recursos
- **HPA**: Escalamento horizontal, escala Pods
- **Escolha**: VPA para otimização, HPA para escalabilidade

### Auto vs Recreate vs Off

- **Auto**: Aplica automaticamente, recrea Pods
- **Recreate**: Recria Pods para aplicar
- **Off**: Apenas recomendações
- **Escolha**: Off inicialmente, Auto após validação

### VPA vs Manual

- **VPA**: Automático, baseado em uso
- **Manual**: Controle total, mais trabalho
- **Escolha**: VPA para produção, manual para desenvolvimento

### _Links_

- <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>
- <https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler>
- <https://kubernetes.io/docs/concepts/workloads/controllers/vertical-pod-autoscaler/>
