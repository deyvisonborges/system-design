# CronJobs

CronJob é um recurso do Kubernetes usado para executar Jobs em um cronograma recorrente, sendo ideal para tarefas agendadas como backups, relatórios e manutenção.

## Definição

CronJob é um workload API que cria Jobs em um cronograma recorrente baseado em expressões cron, permitindo automação de tarefas periódicas como backups, limpeza e processamento batch.

```text
CronJob = Cronograma recorrente + Jobs automáticos + Expressões cron
```

## Como Funciona

### 1. Cron Schedule

```text
- Expressão cron: Minuto Hora Dia Mês DiaSemana
- Timezone: Configurável
- Concurrency: Controla execuções simultâneas
```

### 2. Concurrency Policy

```text
- Allow: Permite execuções simultâneas (padrão)
- Forbid: Não permite execuções simultâneas
- Replace: Cancela execução anterior e inicia nova
```

### 3. Histórico

```text
- SuccessfulJobsHistoryLimit: Mantém histórico de Jobs bem-sucedidos
- FailedJobsHistoryLimit: Mantém histórico de Jobs falhados
- Limpeza automática baseada em limites
```

## Exemplo Prático

### CronJob Simples

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"  # Executa a cada minuto
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from Kubernetes
          restartPolicy: OnFailure
```

### CronJob com Concurrency Policy

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 2 * * *"  # Executa às 2h da manhã
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:1.0
            command: ["/bin/sh", "-c", "backup.sh"]
          restartPolicy: OnFailure
```

### CronJob com TTL e Histórico

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup
spec:
  schedule: "0 3 * * *"  # Executa às 3h da manhã
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 3600
      template:
        spec:
          containers:
          - name: cleanup
            image: cleanup-tool:1.0
            command: ["/bin/sh", "-c", "cleanup.sh"]
          restartPolicy: OnFailure
```

### CronJob com Suspend

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report
spec:
  schedule: "0 6 * * 1"  # Executa às 6h de segunda-feira
  suspend: true  # Suspende o CronJob
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report
            image: report-tool:1.0
            command: ["/bin/sh", "-c", "generate-report.sh"]
          restartPolicy: OnFailure
```

## Comandos Úteis

### Gerenciar CronJobs

```bash
# Criar CronJob
kubectl apply -f cronjob.yaml

# Listar CronJobs
kubectl get cronjobs

# Ver detalhes
kubectl describe cronjob hello

# Ver Jobs criados pelo CronJob
kubectl get jobs --field-selector metadata.ownerReferences.name=hello

# Suspender CronJob
kubectl patch cronjob hello -p '{"spec":{"suspend":true}}'

# Ativar CronJob
kubectl patch cronjob hello -p '{"spec":{"suspend":false}}'

# Deletar CronJob
kubectl delete cronjob hello
```

## Vantagens

### 1. Automação

```text
- Execução automática
- Cronograma flexível
- Sem intervenção manual
```

### 2. Confiabilidade

```text
- Gerenciado pelo Kubernetes
- Retries automáticos
- Monitoramento de status
```

### 3. Flexibilidade

```text
- Expressões cron poderosas
- Concurrency policies
- Timezone configurável
```

## Limitações

### 1. Precisão

```text
- Não garante execução exata
- Pode haver atrasos
- Requer cluster estável
```

### 2. Recursos

```text
- Consome recursos regularmente
- Pode impactar cluster
- Requer planejamento
```

### 3. Complexidade

```text
- Expressões cron podem ser complexas
- Troubleshooting desafiador
- Logs distribuídos
```

## Melhores Práticas

### 1. Usar Concurrency Policy Adequadamente

```yaml
spec:
  concurrencyPolicy: Forbid  # Para tarefas que não devem sobrepor
```

### 2. Configurar Histórico

```yaml
spec:
  successfulJobsHistoryLimit: 3  # Mantém 3 Jobs bem-sucedidos
  failedJobsHistoryLimit: 1      # Mantém 1 Job falhado
```

### 3. Usar TTL para Limpeza

```yaml
jobTemplate:
  spec:
    ttlSecondsAfterFinished: 3600  # Remove após 1 hora
```

### 4. Configurar Deadline

```yaml
spec:
  startingDeadlineSeconds: 300  # 5 minutos de tolerância
```

## Trade-offs

### Allow vs Forbid vs Replace

- **Allow**: Permite sobreposição
- **Forbid**: Não permite sobreposição
- **Replace**: Cancela anterior, inicia nova
- **Escolha**: Forbid para crítico, Allow para geral

### CronJob vs External Cron

- **CronJob**: Gerenciado pelo Kubernetes
- **External**: Gerenciado externamente
- **Escolha**: CronJob para cluster, external para fora

### Suspend vs Delete

- **Suspend**: Pausa temporariamente
- **Delete**: Remove permanentemente
- **Escolha**: Suspend para pausa, delete para remoção

### _Links_

- <https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/>
- <https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax>
- <https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#concurrency-policy>
