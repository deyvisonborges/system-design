# Taints

Taints são aplicados a nós para repelir Pods que não têm tolerações correspondentes, permitindo controlar quais Pods podem ser agendados em quais nós, sendo útil para nós dedicados ou com requisitos especiais.

## Definição

Taint é um atributo aplicado a um nó que repel Pods, impedindo que Pods sem tolerações correspondentes sejam agendados naquele nó, permitindo isolamento e controle de agendamento.

```text
Taint = Repel Pods + Isolamento de nó + Controle de agendamento
```

## Como Funciona

### 1. Efeitos de Taint

```text
- NoSchedule: Pod não é agendado se não tolerar
- PreferNoSchedule: Scheduler tenta evitar, mas não garante
- NoExecute: Pod é removido se já estiver no nó
```

### 2. Key-Value-Effect

```text
- Key: Identificador do taint
- Value: Valor do taint (opcional)
- Effect: Comportamento do taint
```

### 3. Compatibilidade

```text
- Taints: Aplicados a nós
- Tolerations: Aplicados a Pods
- Match: Pod só agendado se tolerar taints do nó
```

## Exemplo Prático

### Adicionar Taint a um Nó

```bash
kubectl taint nodes node-1 key=value:NoSchedule
```

### Taint NoSchedule

```bash
# Adicionar taint
kubectl taint nodes node-1 dedicated=database:NoSchedule

# Remover taint
kubectl taint nodes node-1 dedicated:NoSchedule-
```

### Taint PreferNoSchedule

```bash
# Adicionar taint
kubectl taint nodes node-1 dedicated=database:PreferNoSchedule
```

### Taint NoExecute

```bash
# Adicionar taint
kubectl taint nodes node-1 dedicated=database:NoExecute

# Adicionar taint com tolerationSeconds
kubectl taint nodes node-1 key=value:NoExecute
```

### Múltiplos Taints

```bash
# Adicionar múlttiplos taints
kubectl taint nodes node-1 dedicated=database:NoSchedule
kubectl taint nodes node-1 special=true:NoExecute
```

## Comandos Úteis

### Gerenciar Taints

```bash
# Adicionar taint
kubectl taint nodes node-1 key=value:NoSchedule

# Ver taints de um nó
kubectl describe node node-1 | grep Taint

# Remover taint
kubectl taint nodes node-1 key:NoSchedule-

# Ver todos os nós com taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## Vantagens

### 1. Isolamento

```text
- Nós dedicados para workloads específicos
- Separação de ambientes
- Isolamento de recursos
```

### 2. Controle

```text
- Controle preciso de agendamento
- Prevenção de Pods indesejados
- Gerenciamento de nós especiais
```

### 3. Flexibilidade

```text
- Múltiplos efeitos
- Combinado com tolerations
- Dinâmico
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
- Pode impedir agendamento
- Requer nós adequados
- Pods podem ficar pending
```

### 3. Manutenção

```text
- Taints precisam ser mantidos
- Mudanças impactam agendamento
- Requer monitoramento
```

## Melhores Práticas

### 1. Usar Nomes Significativos

```bash
kubectl taint nodes node-1 dedicated=database:NoSchedule
```

### 2. Combinar com Tolerations

```yaml
spec:
  tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule
```

### 3. Usar NoExecute para Crítico

```bash
kubectl taint nodes node-1 critical=true:NoExecute
```

### 4. Usar PreferNoSchedule para Preferência

```bash
kubectl taint nodes node-1 dedicated=database:PreferNoSchedule
```

## Trade-offs

### NoSchedule vs PreferNoSchedule vs NoExecute

- **NoSchedule**: Rígido, não agenda
- **PreferNoSchedule**: Suave, tenta evitar
- **NoExecute**: Remove Pods existentes
- **Escolha**: NoSchedule para dedicado, PreferNoSchedule para preferência, NoExecute para crítico

### Taints vs Node Affinity

- **Taints**: Onde Pod não pode ir
- **Node Affinity**: Onde Pod quer ir
- **Escolha**: Use ambos para controle completo

### Taints vs Node Selector

- **Taints**: Repel Pods
- **Node Selector**: Seleciona nós
- **Escolha**: Taints para isolamento, Node Selector para seleção

### _Links_

- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-nodes>
- <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-based-evictions>
