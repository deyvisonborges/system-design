# DaemonSet

DaemonSet é um recurso do Kubernetes que garante que um Pod específico seja executado em todos (ou em um subconjunto) de nós do cluster, sendo ideal para tarefas de manutenção, monitoramento e agentes de sistema.

## Definição

DaemonSet é um workload API que garante que uma cópia de um Pod seja executada em cada nó do cluster, sendo usado para tarefas de sistema como monitoramento, logging e agentes de rede.

```text
DaemonSet = Um Pod por nó + Tarefas de sistema + Agentes
```

## Como Funciona

### 1. Escalonamento

```text
- Um Pod por nó: Garantido em cada nó elegível
- Novos nós: DaemonSet adiciona Pods automaticamente
- Nós removidos: Pods são terminados
- Tolerations: Controla quais nós executam
```

### 2. Seleção de Nós

```text
- Node selector: Seleciona nós baseado em labels
- Node affinity: Regras mais complexas de seleção
- Tolerations: Permite execução em nós com taints
```

### 3. Atualizações

```text
- RollingUpdate: Atualização gradual
- OnDelete: Atualização manual
- MaxUnavailable: Controla Pods indisponíveis durante atualização
```

## Exemplo Prático

### DaemonSet Simples

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

### DaemonSet com Node Selector

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: "true"
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.3.1
        ports:
        - containerPort: 9100
          hostPort: 9100
```

### DaemonSet com Tolerations

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: kube-proxy
        image: k8s.gcr.io/kube-proxy:v1.21.0
```

### DaemonSet com Update Strategy

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
```

## Comandos Úteis

### Gerenciar DaemonSets

```bash
# Criar DaemonSet
kubectl apply -f daemonset.yaml

# Listar DaemonSets
kubectl get daemonsets

# Ver detalhes
kubectl describe daemonset fluentd

# Ver Pods do DaemonSet
kubectl get pods -l name=fluentd

# Atualizar imagem
kubectl set image daemonset/fluentd fluentd=fluentd:v1.15

# Ver status de atualização
kubectl rollout status daemonset/fluentd

# Deletar DaemonSet
kubectl delete daemonset fluentd
```

## Vantagens

### 1. Cobertura

```text
- Executa em todos os nós
- Automático para novos nós
- Cobertura garantida
```

### 2. Tarefas de Sistema

```text
- Ideal para agentes de sistema
- Monitoramento distribuído
- Logging centralizado
```

### 3. Simplicidade

```text
- Configuração simples
- Gerenciamento automático
- Self-healing
```

## Limitações

### 1. Recursos

```text
- Consome recursos em todos os nós
- Pode impactar performance
- Requer planejamento
```

### 2. Escalabilidade

```text
- Não escala horizontalmente
- Um Pod por nó
- Limitado ao número de nós
```

### 3. Complexidade

```text
- Troubleshooting desafiador
- Múltiplos Pods para monitorar
- Logs distribuídos
```

## Melhores Práticas

### 1. Usar Node Selector Adequadamente

```yaml
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: "true"
```

### 2. Configurar Resources

```yaml
resources:
  limits:
    memory: 200Mi
  requests:
    cpu: 100m
    memory: 200Mi
```

### 3. Usar Tolerations para Master Nodes

```yaml
tolerations:
- key: node-role.kubernetes.io/master
  effect: NoSchedule
```

### 4. Configurar Update Strategy

```yaml
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
```

## Trade-offs

### DaemonSet vs Deployment

- **DaemonSet**: Um Pod por nó, tarefas de sistema
- **Deployment**: Múltiplos Pods, aplicações
- **Escolha**: DaemonSet para agentes, Deployment para aplicações

### RollingUpdate vs OnDelete

- **RollingUpdate**: Automático, gradual
- **OnDelete**: Manual, controle total
- **Escolha**: RollingUpdate para geral, OnDelete para controle manual

### HostPath vs HostNetwork

- **HostPath**: Acesso a arquivos do host
- **HostNetwork**: Acesso à rede do host
- **Escolha**: HostPath para arquivos, HostNetwork para rede

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/>
- <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#how-daemonset-pods-are-scheduled>
- <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#updating-a-daemonset>
