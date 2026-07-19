# Ingress

Ingress é um recurso do Kubernetes que gerencia o acesso externo aos Services no cluster, proporcionando roteamento HTTP/HTTPS, terminação SSL e balanceamento de carga baseado em regras.

## Definição

Ingress é uma coleção de regras que permitem rotear tráfego HTTP/HTTPS externo para Services dentro do cluster, funcionando como um entry point para aplicações.

```text
Ingress = Roteamento HTTP/HTTPS + SSL + Load balancing
```

## Como Funciona

### 1. Componentes

```text
- Ingress Resource: Define regras de roteamento
- Ingress Controller: Implementa as regras (nginx, traefik, etc.)
- Ingress Class: Define qual controller usar
```

### 2. Roteamento

```text
- Host-based routing: baseado em hostname
- Path-based routing: baseado em caminho
- TLS: terminação SSL
- Annotations: configurações específicas do controller
```

### 3. Controller

```text
- NGINX Ingress Controller: Mais popular
- Traefik: Moderno, auto-descoberta
- HAProxy: Balanceador de carga
- AWS ALB: Integrado com AWS
```

## Exemplo Prático

### Ingress Simples

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### Ingress com TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: my-tls-secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### Ingress com Múltiplos Services

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Ingress com Annotations (NGINX)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

## Tipos de Path

### 1. Prefix

```yaml
path: /api
pathType: Prefix
```

### 2. Exact

```yaml
path: /api/v1/users
pathType: Exact
```

### 3. ImplementationSpecific

```yaml
path: /api
pathType: ImplementationSpecific
```

## Comandos Úteis

### Gerenciar Ingress

```bash
# Criar ingress
kubectl apply -f ingress.yaml

# Listar ingress
kubectl get ingress

# Ver detalhes
kubectl describe ingress my-ingress

# Ver ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Ver certificados TLS
kubectl get secrets
```

## Vantagens

### 1. Roteamento

```text
- Roteamento baseado em host e path
- Balanceamento de carga
- Suporta múltiplos serviços
```

### 2. SSL

```text
- Terminação SSL
- Certificados automáticos (Let's Encrypt)
- Suporte a múltiplos certificados
```

### 3. Flexibilidade

```text
- Configurável via annotations
- Múltiplos controllers
- Integração com cloud providers
```

## Limitações

### 1. HTTP/HTTPS Apenas

```text
- Suporta apenas HTTP/HTTPS
- Requer controller para outros protocolos
- TCP/UDP requer Service tipo LoadBalancer
```

### 2. Complexidade

```text
- Requer Ingress Controller
- Configuração pode ser complexa
- Troubleshooting desafiador
```

### 3. Dependência

```text
- Requer controller externo
- Diferentes controllers, diferentes features
- Requer manutenção
```

## Melhores Práticas

### 1. Usar Ingress Class

```yaml
spec:
  ingressClassName: nginx
```

### 2. Configurar TLS Adequadamente

```yaml
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: my-tls-secret
```

### 3. Usar Path Types Adequadas

```yaml
paths:
  - path: /api
    pathType: Prefix  # Para prefixos
  - path: /health
    pathType: Exact   # Para caminhos exatos
```

### 4. Usar Annotations para Features Específicas

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
```

## Trade-offs

### Ingress vs LoadBalancer Service

- **Ingress**: Um IP, múltiplos serviços, HTTP/HTTPS
- **LoadBalancer**: Um IP por serviço, todos protocolos
- **Escolha**: Ingress para HTTP/HTTPS, LoadBalancer para outros

### NGINX vs Traefik vs HAProxy

- **NGINX**: Popular, estável, features ricas
- **Traefik**: Moderno, auto-descoberta, simples
- **HAProxy**: Performance, avançado
- **Escolha**: NGINX para geral, Traefik para modernidade

### Manual vs Cert-Manager

- **Manual**: Controle total, mais trabalho
- **Cert-Manager**: Automático, menos trabalho
- **Escolha**: Cert-Manager para produção, manual para desenvolvimento

### _Links_

- <https://kubernetes.io/docs/concepts/services-networking/ingress/>
- <https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-controllers>
- <https://kubernetes.io/docs/concepts/services-networking/ingress/#tls>
