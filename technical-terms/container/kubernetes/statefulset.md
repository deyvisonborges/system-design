# StatefulSet

StatefulSet é um recurso do Kubernetes usado para gerenciar aplicações stateful, proporcionando identidades únicas e estáveis para Pods, armazenamento persistente e atualizações ordenadas.

## Definição

StatefulSet é um workload API usado para gerenciar aplicações stateful, garantindo que cada Pod tenha uma identidade única e estável, com armazenamento persistente e atualizações controladas.

```text
StatefulSet = Identidade estável + Persistência + Atualizações ordenadas
```

## Como Funciona

### 1. Identidade Estável

```text
- Identificadores únicos: web-0, web-1, web-2
- Hostnames estáveis: Não mudam ao recriar
- Endpoints estáveis: Mesmo IP/DNS após restart
```

### 2. Armazenamento Persistente

```text
- PVCs persistentes: Cada Pod tem seu PVC
- VolumeClaimTemplate: Template para PVCs
- Dados persistem: Mesmo após recriação
```

### 3. Atualizações Ordenadas

```text
- Rolling updates sequenciais: Um por vez
- Ordem reverso: Terminação em ordem reversa
- Garantia de consistência: Mantém estado durante atualização
```

## Exemplo Prático

### StatefulSet Simples

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
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
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

### StatefulSet com Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None  # Headless service
  selector:
    app: nginx
  ports:
  - port: 80
    name: web
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
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
          name: web
```

### StatefulSet com Update Strategy

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 3
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
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
```

## Comandos Úteis

### Gerenciar StatefulSets

```bash
# Criar StatefulSet
kubectl apply -f statefulset.yaml

# Listar StatefulSets
kubectl get statefulsets

# Ver detalhes
kubectl describe statefulset web

# Escalar StatefulSet
kubectl scale statefulset web --replicas=5

# Ver Pods
kubectl get pods -l app=nginx

# Ver PVCs
kubectl get pvc

# Deletar StatefulSet
kubectl delete statefulset web
```

## Vantagens

### 1. Identidade Única e Estável

```text
- Identificadores únicos e previsíveis
- Hostnames estáveis
- Endpoints consistentes
```

### 2. Persistência

```text
- PVCs persistentes
- Dados mantêm após recriação
- VolumeClaimTemplate automático
```

### 3. Ordem

```text
- Atualizações ordenadas
- Deploy sequencial
- Terminação ordenada
```

## Limitações

### 1. Complexidade

```text
- Mais complexo que Deployment
- Requer planejamento
- Troubleshooting desafiador
```

### 2. Escalabilidade

```text
- Escalabilidade limitada
- Requer mais recursos
- Não adequado para stateless
```

### 3. Dependência

```text
- Requer Headless Service
- Requer storage class
- Requer cluster estável
```

## Melhores Práticas

### 1. Usar Headless Service

```yaml
spec:
  clusterIP: None  # Headless
```

### 2. Usar VolumeClaimTemplate

```yaml
volumeClaimTemplates:
- metadata:
    name: data
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 10Gi
```

### 3. Configurar Update Strategy Adequadamente

```yaml
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    partition: 0  # Atualiza apenas Pods com índice >= partition
```

### 4. Usar Partitions para Canary

```yaml
# Atualiza apenas web-2 e web-3
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    partition: 2
```

## Trade-offs

### StatefulSet vs Deployment

- **StatefulSet**: Identidade estável, persistência, complexo
- **Deployment**: Stateless, simples, sem identidade
- **Escolha**: StatefulSet para stateful, Deployment para stateless

### RollingUpdate vs OnDelete

- **RollingUpdate**: Automático, ordenado
- **OnDelete**: Manual, controle total
- **Escolha**: RollingUpdate para geral, OnDelete para controle manual

### Partition 0 vs Partition Maior que 0

- **0**: Atualiza todos
- **> 0**: Atualiza parcial (canary)
- **Escolha**: 0 para geral, > 0 para canary

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/>
- <https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id>
- <https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#deployment-and-scaling-guarantees>
