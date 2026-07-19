# Tolerations

Tolerations são aplicados a Pods para permitir que eles sejam agendados em nós com taints correspondentes, funcionando como o oposto de taints e permitindo controle fino de agendamento.

## Definição

Toleration é um atributo aplicado a um Pod que permite que ele seja agendado em nós com taints correspondentes, ignorando os efeitos dos taints e permitindo agendamento em nós dedicados ou especiais.

```text
Toleration = Permite taints + Controle de agendamento + Flexibilidade
```

## Como Funciona

### 1. Operadores

```text
- Equal: Tolera taint com key e value específicos
- Exists: Tolera taint com key específico (ignora value)
```

### 2. Efeitos

```text
- NoSchedule: Pod pode ser agendado
- PreferNoSchedule: Pod pode ser agendado, scheduler tenta evitar
- NoExecute: Pod pode permanecer no nó
```

### 3. TolerationSeconds

```text
- Tempo que Pod pode permanecer em nó com NoExecute
- Após o tempo, Pod é evitado
- Útil para drain de nós
```

## Exemplo Prático

### Toleration Simples

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
  containers:
  - name: my-container
    image: my-image:1.0
```

### Toleration Exists

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "dedicated"
    operator: "Exists"
    effect: "NoSchedule"
  containers:
  - name: my-container
    image: my-image:1.0
```

### Toleration com TolerationSeconds

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoExecute"
    tolerationSeconds: 3600
  containers:
  - name: my-container
    image: my-image:1.0
```

### Múltiplas Tolerations

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "database"
    effect: "NoSchedule"
  - key: "special"
    operator: "Exists"
    effect: "NoExecute"
  containers:
  - name: my-container
    image: my-image:1.0
```

### Toleration para Master Nodes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: NoSchedule
  containers:
  - name: my-container
    image: my-image:1.0
```

## Comandos Úteis

### Gerenciar Tolerations

```bash
# Ver tolerations de um Pod
kubectl describe pod my-pod | grep -A 5 Tolerations

# Ver taints de nós
kubectl describe nodes | grep -A 5 Taints

# Adicionar taint a um nó
kubectl taint nodes node-1 key=value:NoSchedule

# Remover taint de um nó
kubectl taint nodes node-1 key:NoSchedule-
```

## Vantagens

### 1. Flexibilidade

```text
- Permite agendamento em nós especiais
- Controle fino de agendamento
- Combina com taints
```

### 2. Isolamento

```text
- Nós dedicados para workloads específicos
- Separação de ambientes
- Isolamento de recursos
```

### 3. Dinâmico

```text
- TolerationSeconds para drain
- Adaptação a mudanças
- Gerenciamento de nós
```

## Limitações

### 1. Complexidade

```text
- Configuração pode ser complexa
- Requer planejamento
- Troubleshooting desafiador
```

### 2. Dependência

```text
- Depende de taints
- Requer sincronização
- Manutenção necessária
```

### 3. Disponibilidade

```text
- Pode agendar em nós inadequados
- Requer monitoramento
- Pode impactar performance
```

## Melhores Práticas

### 1. Usar Tolerations Específicas

```yaml
tolerations:
- key: dedicated
  operator: Equal
  value: database
  effect: NoSchedule
```

### 2. Usar Exists para Geral

```yaml
tolerations:
- key: dedicated
  operator: Exists
  effect: NoSchedule
```

### 3. Usar TolerationSeconds para NoExecute

```yaml
tolerations:
- key: key
  operator: Equal
  value: value
  effect: NoExecute
  tolerationSeconds: 3600
```

### 4. Combinar com Node Affinity

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
            - database
  tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule
```

## Trade-offs

### Equal vs Exists

- **Equal**: Tolera key e value específicos
- **Exists**: Tolera key qualquer value
- **Escolha**: Equal para específico, Exists para geral

### Toleration vs Node Affinity

- **Toleration**: Onde Pod pode ir
- **Node Affinity**: Onde Pod quer ir
- **Escolha**: Use ambos para controle completo

### TolerationSeconds vs Sem TolerationSeconds

- **Com**: Pod permanece por tempo limitado
- **Sem**: Pod permanece indefinidamente
- **Escolha**: Com para drain, sem para permanente

### _Links_

- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#concepts>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#example-use-cases>
