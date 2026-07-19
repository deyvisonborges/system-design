# Jobs

Job é um recurso do Kubernetes usado para executar tarefas finitas, garantindo que um número específico de Pods seja executado com sucesso até a conclusão da tarefa.

## Definição

Job é um workload API que cria um ou mais Pods e garante que um número especificado deles seja executado com sucesso até a conclusão, sendo ideal para tarefas batch e processamento finito.

```text
Job = Tarefas finitas + Garantia de conclusão + Pods efêmeros
```

## Como Funciona

### 1. Tipos de Jobs

```text
- Non-parallel: Executa um Pod até completar
- Parallel com completions fixas: Múltiplos Pods até completar
- Parallel com work queue: Múltiplos Pods processando itens de fila
```

### 2. Conclusão

```text
- Completions: Número de Pods que devem completar
- Parallelism: Número de Pods executando em paralelo
- BackoffLimit: Número de retries antes de falhar
```

### 3. Limpeza

```text
- TTLSecondsAfterFinished: Remove Job após conclusão
- CleanPodPolicy: Política de limpeza de Pods
- Automatic: Limpeza automática
```

## Exemplo Prático

### Job Simples

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

### Job Paralelo

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  completions: 5
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item; sleep 5"]
      restartPolicy: OnFailure
```

### Job com TTL

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: job-with-ttl
spec:
  ttlSecondsAfterFinished: 3600
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Hello Kubernetes"]
      restartPolicy: OnFailure
```

### Job com Work Queue

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: work-queue-job
spec:
  parallelism: 3
  completions: 30
  template:
    spec:
      containers:
      - name: worker
        image: my-worker:1.0
        env:
        - name: WORK_QUEUE
          value: "redis://redis-service:6379"
      restartPolicy: OnFailure
```

## Comandos Úteis

### Gerenciar Jobs

```bash
# Criar Job
kubectl apply -f job.yaml

# Listar Jobs
kubectl get jobs

# Ver detalhes
kubectl describe job pi

# Ver Pods do Job
kubectl get pods -l job-name=pi

# Ver logs
kubectl logs -l job-name=pi

# Deletar Job
kubectl delete job pi

# Limpar Jobs completos
kubectl delete jobs --field-selector status.successful=1
```

## Vantagens

### 1. Garantia de Conclusão

```text
- Tenta até completar
- Retries automáticos
- Monitoramento de status
```

### 2. Paralelismo

```text
- Execução paralela
- Work queue
- Escalabilidade
```

### 3. Limpeza Automática

```text
- Limpeza automática
- TTL configurável
- Gerenciamento de recursos
```

## Limitações

### 1. Finito

```text
- Não para tarefas contínuas
- Requer CronJob para recorrente
- Não mantém estado
```

### 2. Recursos

```text
- Consome recursos durante execução
- Pode impactar cluster
- Requer planejamento
```

### 3. Monitoramento

```text
- Requer monitoramento
- Logs podem ser perdidos
- Troubleshooting desafiador
```

## Melhores Práticas

### 1. Configurar Restart Policy Adequadamente

```yaml
spec:
  template:
    spec:
      restartPolicy: OnFailure  # ou Never
```

### 2. Usar TTL para Limpeza

```yaml
spec:
  ttlSecondsAfterFinished: 3600  # Remove após 1 hora
```

### 3. Configurar Backoff Limit

```yaml
spec:
  backoffLimit: 4  # Tenta 4 vezes antes de falhar
```

### 4. Usar Active Deadline Seconds

```yaml
spec:
  activeDeadlineSeconds: 3600  # Timeout de 1 hora
```

## Trade-offs

### Job vs CronJob

- **Job**: Executa uma vez
- **CronJob**: Executa recorrentemente
- **Escolha**: Job para único, CronJob para recorrente

### Parallelism 1 vs N

- **1**: Sequencial, mais lento
- **N**: Paralelo, mais rápido
- **Escolha**: 1 para simples, N para work queue

### OnFailure vs Never

- **OnFailure**: Retry em falha
- **Never**: Não retry
- **Escolha**: OnFailure para geral, Never para crítico

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/job/>
- <https://kubernetes.io/docs/concepts/workloads/controllers/job/#running-an-example-job>
- <https://kubernetes.io/docs/concepts/workloads/controllers/job/#clean-up-jobs/>
