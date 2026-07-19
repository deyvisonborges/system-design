# Istio

Istio é um service mesh open-source que fornece uma camada de infraestrutura para gerenciar comunicações de serviço, incluindo roteamento, segurança, observabilidade e resiliência em microserviços.

## Definição

Istio é um service mesh para Kubernetes que gerencia comunicações entre microserviços, fornecendo recursos como roteamento inteligente, segurança com mTLS, observabilidade com métricas e tracing, e resiliência com retries e circuit breakers.

```text
Istio = Service mesh + Roteamento + Segurança + Observabilidade
```

## Como Funciona

### 1. Componentes

```text
- Control Plane: Istiod (Pilot, Citadel, Galley)
- Data Plane: Envoy Proxies (sidecars)
- Gateway: Ingress/Egress Gateway
- VirtualService: Regras de roteamento
- DestinationRule: Políticas de tráfego
```

### 2. Arquitetura

```text
- Envoy Sidecar: Intercepta tráfego de cada Pod
- Control Plane: Configura sidecars
- Service Discovery: Descobre serviços
- Load Balancing: Distribui tráfego
```

### 3. Funcionalidades

```text
- Roteamento: Traffic splitting, mirroring
- Segurança: mTLS, RBAC
- Observabilidade: Metrics, logs, tracing
- Resiliência: Retries, timeouts, circuit breakers
```

## Exemplo Prático

### VirtualService para Canary

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: v2
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
```

### DestinationRule

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### Gateway

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: myapp-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
```

### ServiceEntry para Serviço Externo

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: external-api
spec:
  hosts:
  - api.external.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

### PeerAuthentication para mTLS

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

## Comandos Úteis

### Gerenciar Istio

```bash
# Instalar Istio
istioctl install

# Ver status do Istio
istioctl status

# Ver configuração
istioctl proxy-config routes <pod-name>

# Ver logs do sidecar
istioctl proxy-config logs <pod-name>

# Ver clusters
istioctl proxy-config clusters <pod-name>

# Analisar configuração
istioctl analyze
```

### Debug

```bash
# Ver proxy config
istioctl proxy-config bootstrap <pod-name>

# Ver endpoints
istioctl proxy-config endpoints <pod-name>

# Ver listeners
istioctl proxy-config listeners <pod-name>

# Dump de config
istioctl proxy-config all <pod-name>
```

## Vantagens

### 1. Observabilidade

```text
- Métricas automáticas
- Distributed tracing
- Logs de tráfego
```

### 2. Segurança

```text
- mTLS automático
- RBAC granular
- Política de segurança
```

### 3. Resiliência

```text
- Retries automáticos
- Circuit breakers
- Timeouts
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado íngreme
- Configuração complexa
- Troubleshooting desafiador
```

### 2. Performance

```text
- Overhead de sidecar
- Latência adicional
- Recursos extras
```

### 3. Manutenção

```text
- Requer manutenção
- Atualizações frequentes
- Versão compatível
```

## Melhores Práticas

### 1. Usar Namespace Isolation

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

### 2. Configurar Retry e Timeout

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  http:
  - retries:
      attempts: 3
      perTryTimeout: 2s
    timeout: 10s
```

### 3. Usar Circuit Breakers

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
```

### 4. Monitorar com Kiali

```bash
# Acessar dashboard Kiali
istioctl dashboard kiali
```

## Trade-offs

### Istio vs Linkerd

- **Istio**: Mais recursos, mais complexo
- **Linkerd**: Mais leve, mais simples
- **Escolha**: Istio para recursos completos, Linkerd para leveza

### mTLS STRICT vs PERMISSIVE

- **STRICT**: Apenas mTLS, mais seguro
- **PERMISSIVE**: mTLS e plaintext, transição
- **Escolha**: STRICT para produção, PERMISSIVE para transição

### Sidecar vs Ambient Mesh

- **Sidecar**: Mais controle, mais overhead
- **Ambient**: Menos overhead, menos controle
- **Escolha**: Sidecar para controle, Ambient para performance

### _Links_

- <https://istio.io/latest/docs/concepts/what-is-istio/>
- <https://istio.io/latest/docs/concepts/traffic-management/>
- <https://istio.io/latest/docs/concepts/security/>
