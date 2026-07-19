# Readiness Probe

Readiness Probe é usado para determinar quando um Pod está pronto para receber tráfego, garantindo que apenas Pods saudáveis e funcionais recebam requisições dos Services.

## Definição

Readiness Probe é um diagnóstico executado periodicamente pelo kubelet para determinar se um Pod está pronto para receber tráfego, sendo usado para controlar quando um Pod é adicionado aos Services e Load Balancers.

```text
Readiness Probe = Verificação de prontidão + Tráfego + Services
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
- failureThreshold: Falhas necessárias para falha
```

### 3. Comportamento

```text
- Success: Pod está pronto, recebe tráfego
- Failure: Pod não está pronto, não recebe tráfego
- Unknown: Verificação em andamento
- Restart: Não reinicia Pod (diferente de liveness)
```

## Exemplo Prático

### HTTP Readiness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-http
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    readinessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 3
```

### TCP Readiness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-tcp
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
```

### Command Readiness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-cmd
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 10
```

### gRPC Readiness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-grpc
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    readinessProbe:
      grpc:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
```

## Comandos Úteis

### Gerenciar Readiness Probes

```bash
# Ver status do Pod
kubectl describe pod readiness-http | grep -A 10 Readiness

# Ver eventos do Pod
kubectl describe pod readiness-http | grep -i readiness

# Ver logs do Pod
kubectl logs readiness-http

# Ver status de todos os Pods
kubectl get pods
```

## Vantagens

### 1. Disponibilidade

```text
- Apenas Pods prontos recebem tráfego
- Evita requisições para Pods não prontos
- Melhora experiência do usuário
```

### 2. Gradual Rollout

```text
- Pods são adicionados gradualmente
- Permite warm-up
- Reduz impacto de atualizações
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

### 2. Latência

```text
- Tempo para detectar prontidão
- Pode atrasar tráfego
- Requer tuning
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
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
```

### 2. Configurar Parâmetros Adequadamente

```yaml
readinessProbe:
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### 3. Usar Com Liveness Probe

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
- /health/live: Para liveness
- /health/ready: Para readiness
- Verificações diferentes para cada
```

## Trade-offs

### HTTP vs TCP vs Command

- **HTTP**: Mais expressivo, requer endpoint
- **TCP**: Simples, verifica apenas conexão
- **Command**: Flexível, mais complexo
- **Escolha**: HTTP para aplicações web, TCP para serviços, Command para específico

### Readiness vs Liveness

- **Readiness**: Controla tráfego, não reinicia
- **Liveness**: Reinicia Pod se falhar
- **Escolha**: Usar ambos para controle completo

### FailureThreshold Baixo vs Alto

- **Baixo**: Remove tráfego rápido, pode ser instável
- **Alto**: Mais tolerante, pode enviar tráfego para Pod não pronto
- **Escolha**: Balancear entre rapidez e estabilidade

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes>
