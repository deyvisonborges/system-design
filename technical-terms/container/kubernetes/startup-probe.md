# Startup Probe

Startup Probe é usado para determinar quando um container foi inicializado com sucesso, desabilitando liveness e readiness probes até que o container esteja pronto, sendo útil para aplicações com tempo de inicialização longo.

## Definição

Startup Probe é um diagnóstico executado periodicamente pelo kubelet para determinar se um container foi inicializado com sucesso, desabilitando outros probes até que o container esteja pronto, sendo ideal para aplicações com inicialização lenta.

```text
Startup Probe = Verificação de inicialização + Delay de outros probes + Aplicações lentas
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
- failureThreshold: Falhas necessárias para falhar
```

### 3. Comportamento

```text
- Success: Container inicializado, habilita outros probes
- Failure: Container não inicializado, reinicia container
- Unknown: Verificação em andamento
- Desabilita: Desabilita liveness e readiness até sucesso
```

## Exemplo Prático

### HTTP Startup Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-http
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 5
      timeoutSeconds: 3
      successThreshold: 1
      failureThreshold: 30
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 60
      periodSeconds: 10
```

### TCP Startup Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-tcp
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    startupProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 5
      failureThreshold: 30
```

### Command Startup Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-cmd
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    startupProbe:
      exec:
        command:
        - cat
        - /tmp/started
      initialDelaySeconds: 0
      periodSeconds: 5
      failureThreshold: 30
```

### gRPC Startup Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-grpc
spec:
  containers:
  - name: my-container
    image: my-image:1.0
    startupProbe:
      grpc:
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 5
      failureThreshold: 30
```

## Comandos Úteis

### Gerenciar Startup Probes

```bash
# Ver status do Pod
kubectl describe pod startup-http | grep -A 10 Startup

# Ver eventos do Pod
kubectl describe pod startup-http | grep -i startup

# Ver logs do Pod
kubectl logs startup-http

# Ver restarts do Pod
kubectl get pods
```

## Vantagens

### 1. Inicialização Lenta

```text
- Suporta aplicações com inicialização lenta
- Evita restarts prematuros
- Permite warm-up
```

### 2. Proteção

```text
- Desabilita outros probes até pronto
- Evita falsos negativos
- Melhora estabilidade
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
- Requer endpoints de startup
- Troubleshooting desafiador
```

### 2. Tempo

```text
- Aumenta tempo de inicialização
- Pode atrasar disponibilidade
- Requer tuning adequado
```

### 3. Dependência

```text
- Depende de implementação correta
- Requer monitoramento
- Pode falhar se endpoint não existir
```

## Melhores Práticas

### 1. Usar para Aplicações Lentas

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 5
```

### 2. Configurar failureThreshold Alto

```yaml
startupProbe:
  failureThreshold: 30  # 30 * 5s = 150s total
  periodSeconds: 5
```

### 3. Combinar com Liveness e Readiness

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 60
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 60
```

### 4. Implementar Endpoint Específico

```text
- /startup: Para startup probe
- /health: Para liveness probe
- /ready: Para readiness probe
- Verificações diferentes para cada
```

## Trade-offs

### Startup vs Sem Startup

- **Com Startup**: Protege aplicações lentas, mais complexo
- **Sem Startup**: Simples, pode causar restarts prematuros
- **Escolha**: Startup para aplicações lentas, sem startup para rápidas

### HTTP vs TCP vs Command

- **HTTP**: Mais expressivo, requer endpoint
- **TCP**: Simples, verifica apenas conexão
- **Command**: Flexível, mais complexo
- **Escolha**: HTTP para aplicações web, TCP para serviços, Command para específico

### failureThreshold Baixo vs Alto

- **Baixo**: Detecta falha rápido, pode reiniciar prematuramente
- **Alto**: Mais tolerante, pode deixar container travado
- **Escolha**: Alto para aplicações lentas, baixo para rápidas

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes>
