# Liveness Probe

Liveness Probe é usado para determinar se um Pod está funcionando corretamente, reiniciando o Pod automaticamente se a verificação falhar, garantindo que Pods com problemas sejam recuperados automaticamente.

## Definição

Liveness Probe é um diagnóstico executado periodicamente pelo kubelet para determinar se um container está funcionando corretamente, reiniciando o container se a verificação falhar, garantindo auto-recuperação de Pods com problemas.

```text
Liveness Probe = Verificação de saúde + Auto-restart + Recuperação
```

## Como Funciona

### 1. Tipos de Probes

```text
- HTTP: Verifica endpoint HTTP
- TCP: Verifica conexão TCP
- Command: Executa comando no container
- gRPC: Verifica serviço gRPC
```

### 2. Parâmetros

```text
- initialDelaySeconds: Delay antes de iniciar
- periodSeconds: Intervalo entre verificações
- timeoutSeconds: Tempo limite para resposta
- successThreshold: Sucessos necessários para sucesso
- failureThreshold: Falhas necessárias para reiniciar
```

### 3. Comportamento

```text
- Success: Pod está saudável, continua rodando
- Failure: Pod não está saudável, reinicia container
- Unknown: Verificação em andamento
- Restart: Reinicia container se falhar
```

## Exemplo Prático

### HTTP Liveness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-http
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 3
```

### TCP Liveness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-tcp
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

### Command Liveness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-cmd
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

### gRPC Liveness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-grpc
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    livenessProbe:
      grpc:
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
```

## Comandos Úteis

### Gerenciar Liveness Probes

```bash
# Ver status do Pod
kubectl describe pod liveness-http | grep -A 10 Liveness

# Ver eventos do Pod
kubectl describe pod liveness-http | grep -i liveness

# Ver logs do Pod
kubectl logs liveness-http

# Ver restarts do Pod
kubectl get pods
```

## Vantagens

### 1. Auto-recuperação

```text
- Reinicia automaticamente Pods com problemas
- Reduz tempo de downtime
- Melhora disponibilidade
```

### 2. Detecção

```text
- Detecta problemas automaticamente
- Sem intervenção manual
- Monitoramento contínuo
```

### 3. Flexibilidade

```text
- Múltiplos tipos de probes
- Configuração granular
- Adaptação a diferentes aplicações
```

## Limitações

### 1. Complexidade

```text
- Configuração pode ser complexa
- Requer endpoints de health
- Troubleshooting desafiador
```

### 2. Restart Loop

```text
- Pode causar loop de restart
- Requer tuning adequado
- Pode impactar estabilidade
```

### 3. Dependência

```text
- Depende de implementação correta
- Requer monitoramento
- Pode falhar se endpoint não existir
```

## Melhores Práticas

### 1. Usar Endpoints Leves

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
```

### 2. Configurar Parâmetros Adequadamente

```yaml
livenessProbe:
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### 3. Usar Com Readiness Probe

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
```

### 4. Implementar Endpoints Diferentes

```text
- /health/live: Para liveness (verifica se está vivo)
- /health/ready: Para readiness (verifica se está pronto)
- Verificações diferentes para cada
```

## Trade-offs

### HTTP vs TCP vs Command

- **HTTP**: Mais expressivo, requer endpoint
- **TCP**: Simples, verifica apenas conexão
- **Command**: Flexível, mais complexo
- **Escolha**: HTTP para aplicações web, TCP para serviços, Command para específico

### Liveness vs Readiness

- **Liveness**: Reinicia Pod se falhar
- **Readiness**: Controla tráfego, não reinicia
- **Escolha**: Usar ambos para controle completo

### FailureThreshold Baixo vs Alto

- **Baixo**: Reinicia rápido, pode ser instável
- **Alto**: Mais tolerante, pode deixar Pod com problema rodando
- **Escolha**: Balancear entre rapidez e estabilidade

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command>
