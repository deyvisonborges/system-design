# Service

Service é um recurso do Kubernetes que define um conjunto de Pods e uma política para acessá-los, proporcionando descoberta de serviço e load balancing estável entre Pods.

## Definição

Service é uma abstração que define um conjunto lógico de Pods e uma política para acessá-los, permitindo comunicação estável entre Pods mesmo quando eles são recriados ou movidos.

```text
Service = Pods + Load balancing + Descoberta de serviço
```

## Como Funciona

### 1. Tipos de Service

```text
- ClusterIP: Acessível apenas dentro do cluster (padrão)
- NodePort: Acessível via porta em cada nó
- LoadBalancer: Exposto externamente via load balancer
- ExternalName: Mapeia para um DNS externo
- Headless: Sem IP de cluster, DNS direto para Pods
```

### 2. Service Discovery

```text
- DNS: kube-dns/CoreDNS fornece resolução DNS
- Environment Variables: Variáveis de ambiente injetadas
- Endpoints: Lista de IPs dos Pods selecionados
```

### 3. Load Balancing

```text
- Round-robin: Distribuição circular
- Session affinity: Sticky sessions
- ExternalTrafficPolicy: Local vs Cluster
```

## Exemplo Prático

### ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

### NodePort Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
    nodePort: 30007
```

### LoadBalancer Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

### Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  clusterIP: None
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

### Service com Session Affinity

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: myapp
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

## Tipos de Service

### 1. ClusterIP

```yaml
spec:
  type: ClusterIP  # Padrão
  clusterIP: None  # Headless
```

### 2. NodePort

```yaml
spec:
  type: NodePort
  ports:
  - nodePort: 30007  # 30000-32767
```

### 3. LoadBalancer

```yaml
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.100
```

### 4. ExternalName

```yaml
spec:
  type: ExternalName
  externalName: my.database.example.com
```

## Comandos Úteis

### Gerenciar Services

```bash
# Criar service
kubectl apply -f service.yaml

# Listar services
kubectl get services

# Ver detalhes
kubectl describe service my-service

# Ver endpoints
kubectl get endpoints my-service

# Expor deployment
kubectl expose deployment myapp --port=80 --target-port=9376

# Deletar service
kubectl delete service my-service
```

## Vantagens

### 1. Estabilidade

```text
- IP estável para Pods dinâmicos
- Load balancing automático
- Service discovery
```

### 2. Flexibilidade

```text
- Múltiplos tipos de service
- Configurável
- Suporta diferentes casos de uso
```

### 3. Integração

```text
- Integração com Ingress
- Suporta external traffic
- DNS automático
```

## Limitações

### 1. Portas

```text
- NodePort limitado a 30000-32767
- Requer planejamento
- Pode conflitar
```

### 2. Latência

```text
- LoadBalancer pode adicionar latência
- NodePort não é ideal para produção
- Requer proxy externo
```

### 3. Complexidade

```text
- Configuração pode ser complexa
- Requer entendimento de rede
- Troubleshooting desafiador
```

## Melhores Práticas

### 1. Usar Labels Adequadas

```yaml
metadata:
  name: my-service
  labels:
    app: myapp
    environment: production
spec:
  selector:
    app: myapp
```

### 2. Usar Nomes Significativos

```yaml
metadata:
  name: myapp-service  # Nome descritivo
```

### 3. Configurar Portas Adequadamente

```yaml
ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
```

### 4. Usar Session Affinity quando Necessário

```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

## Trade-offs

### ClusterIP vs NodePort vs LoadBalancer

- **ClusterIP**: Interno, simples
- **NodePort**: Exposto, limitado
- **LoadBalancer**: Exposto profissional, custo
- **Escolha**: ClusterIP para interno, LoadBalancer para externo

### Headless vs Regular Service

- **Headless**: DNS direto, sem load balancing
- **Regular**: Load balancing, IP estável
- **Escolha**: Headless para stateful, regular para stateless

### Session Affinity vs Sem Affinity

- **Com affinity**: Sticky sessions, menos balanceamento
- **Sem affinity**: Melhor balanceamento, sem sticky
- **Escolha**: Sem affinity para geral, com para stateful

### _Links_

- <https://kubernetes.io/docs/concepts/services-networking/service/>
- <https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types>
- <https://kubernetes.io/docs/concepts/services-networking/service/#connecting-to-a-service>
