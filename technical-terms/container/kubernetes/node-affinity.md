# Node Affinity

Node Affinity é um conjunto de regras que influenciam onde os Pods são agendados, permitindo que você especifique preferências ou requisitos para quais nós um Pod pode ser executado.

## Definição

Node Affinity é um recurso do Kubernetes que permite especificar regras para agendamento de Pods baseado em labels dos nós, controlando quais nós são elegíveis para executar determinados Pods.

```text
Node Affinity = Regras de agendamento + Labels de nó + Preferências/requisitos
```

## Como Funciona

### 1. Tipos de Affinity

```text
- requiredDuringSchedulingIgnoredDuringExecution: Requisito rígido
- preferredDuringSchedulingIgnoredDuringExecution: Preferência suave
- requiredDuringSchedulingRequiredDuringExecution: Requisito dinâmico
```

### 2. Operadores

```text
- In: Valor está em uma lista
- NotIn: Valor não está em uma lista
- Exists: Label existe
- DoesNotExist: Label não existe
- Gt: Maior que (apenas números)
- Lt: Menor que (apenas números)
```

### 3. Comportamento

```text
- Hard: Pod só é agendado se nó satisfaz
- Soft: Scheduler tenta satisfazer, mas não garante
- Weight: Prioridade para preferências suaves
```

## Exemplo Prático

### Required Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-required-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - az1
            - az2
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

### Preferred Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-preferred-affinity
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - az1
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

### Node Affinity com Múltiplas Expressões

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-multi-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
          - key: zone
            operator: In
            values:
            - us-west-1
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

### Node Affinity com Operadores Numéricos

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-numeric-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: cpu
            operator: Gt
            values:
            - "4"
          - key: memory
            operator: Lt
            values:
            - "16"
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

## Comandos Úteis

### Gerenciar Node Affinity

```bash
# Ver labels de nós
kubectl get nodes --show-labels

# Adicionar label a um nó
kubectl label nodes node-1 disktype=ssd

# Remover label de um nó
kubectl label nodes node-1 disktype-

# Ver Pods com affinity
kubectl get pods -o wide

# Ver detalhes do Pod
kubectl describe pod with-required-affinity
```

## Vantagens

### 1. Controle

```text
- Controle preciso de agendamento
- Separação de workloads
- Isolamento de recursos
```

### 2. Flexibilidade

```text
- Requisitos rígidos ou preferências
- Múltiplas expressões
- Operadores poderosos
```

### 3. Otimização

```text
- Melhora performance
- Reduz latência
- Otimiza recursos específicos
```

## Limitações

### 1. Complexidade

```text
- Configuração pode ser complexa
- Requer planejamento
- Troubleshooting desafiador
```

### 2. Disponibilidade

```text
- Requisitos rígidos podem impedir agendamento
- Pode causar Pods pending
- Requer nós adequados
```

### 3. Manutenção

```text
- Labels precisam ser mantidos
- Mudanças podem impactar agendamento
- Requer monitoramento
```

## Melhores Práticas

### 1. Usar Required para Requisitos Críticos

```yaml
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: gpu
      operator: In
      values:
      - "true"
```

### 2. Usar Preferred para Otimização

```yaml
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100
  preference:
    matchExpressions:
    - key: disktype
      operator: In
      values:
      - ssd
```

### 3. Usar Labels Significativos

```bash
kubectl label nodes node-1 disktype=ssd zone=us-west-1
```

### 4. Combinar com Tolerations

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: dedicated
            operator: In
            values:
            - "true"
  tolerations:
  - key: dedicated
    operator: Equal
    value: "true"
```

## Trade-offs

### Required vs Preferred

- **Required**: Requisito rígido, pode impedir agendamento
- **Preferred**: Preferência suave, mais flexível
- **Escolha**: Required para crítico, preferred para otimização

### Node Affinity vs Node Selector

- **Node Affinity**: Mais expressivo, complexo
- **Node Selector**: Simples, limitado
- **Escolha**: Node Affinity para complexo, Node Selector para simples

### Node Affinity vs Taints/Tolerations

- **Affinity**: Onde Pod quer ir
- **Taints/Tolerations**: Onde Pod pode ir
- **Escolha**: Use ambos para controle completo

### _Links_

- <https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity>
