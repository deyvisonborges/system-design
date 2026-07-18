# WAL (Write-Ahead Log)

WAL (Write-Ahead Log) é um mecanismo do PostgreSQL que registra todas as modificações de dados em um log antes de serem aplicadas aos arquivos de dados, garantindo durabilidade e permitindo recuperação de falhas.

## Definição

WAL é o log de transações do PostgreSQL que registra todas as mudanças antes de serem escritas nos arquivos de dados, permitindo recuperação point-in-time e replicação.

```text
WAL = Log de transações + Durabilidade + Recuperação
```

## Como Funciona

### 1. Processo de WAL

```text
1. Transação modifica dados
2. Mudanças são escritas no WAL (buffer)
3. WAL buffer é flushado para disco (fsync)
4. Transação é considerada commitada
5. Mudanças são aplicadas aos arquivos de dados (lazy)
```

### 2. Estrutura do WAL

```text
- WAL segments: Arquivos de 16MB cada
- WAL records: Registros individuais de mudanças
- LSN (Log Sequence Number): Identificador único de cada registro
- Checkpoints: Pontos de recuperação
```

### 3. Flush do WAL

```text
- synchronous_commit = on: Flush síncrono (padrão)
- synchronous_commit = off: Flush assíncrono (mais rápido, menos seguro)
- synchronous_commit = remote_write: Flush para réplica
```

## Configuração do WAL

### 1. wal_level

```sql
-- Nível de informação no WAL
-- minimal: Apenas para crash recovery
-- replica: Inclui informações para replicação (padrão)
-- logical: Inclui informações para logical replication

SHOW wal_level;
-- Resultado: replica

ALTER SYSTEM SET wal_level = 'replica';
```

### 2. wal_buffers

```sql
-- Memória para buffer do WAL
-- Padrão: -1 (auto, 3% de shared_buffers, mínimo 32KB)
-- Recomendado: 16-64MB para produção

SHOW wal_buffers;
-- Resultado: -1

ALTER SYSTEM SET wal_buffers = '64MB';
```

### 3. wal_compression

```sql
-- Compressão do WAL
-- on: Comprime WAL (menos I/O, mais CPU)
-- off: Sem compressão (padrão)

SHOW wal_compression;
-- Resultado: off

ALTER SYSTEM SET wal_compression = on;
```

### 4. synchronous_commit

```sql
-- Quando flushar WAL
-- on: Flush antes de commit (padrão)
-- off: Flush assíncrono (mais rápido, menos seguro)
-- remote_write: Flush para réplica
-- remote_apply: Aplicar na réplica

SHOW synchronous_commit;
-- Resultado: on

SET synchronous_commit = off;  -- Para operações não críticas
```

## Checkpoints

### 1. Tipos de Checkpoints

```text
- Automatic checkpoint: Automático, baseado em tempo ou tamanho
- Fast checkpoint: Mais rápido, mais I/O
- Spread checkpoint: Mais lento, menos I/O
- Shutdown checkpoint: Ao desligar o servidor
```

### 2. Configuração de Checkpoints

```sql
-- checkpoint_timeout: Tempo entre checkpoints
SHOW checkpoint_timeout;
-- Resultado: 5min

ALTER SYSTEM SET checkpoint_timeout = '10min';

-- checkpoint_completion_target: Alvo de tempo de conclusão
SHOW checkpoint_completion_target;
-- Resultado: 0.5

ALTER SYSTEM SET checkpoint_completion_target = 0.9;

-- max_wal_size: Tamanho máximo do WAL
SHOW max_wal_size;
-- Resultado: 1GB

ALTER SYSTEM SET max_wal_size = '2GB';
```

### 3. Impacto do Checkpoint

```text
- Checkpoint frequente: Menos WAL para recovery, mais I/O
- Checkpoint infrequente: Mais WAL para recovery, menos I/O
- Spread checkpoint: I/O mais suave, recovery mais lento
```

## Archiving

### 1. Configurar WAL Archiving

```sql
-- Habilitar archiving
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'cp %p /var/lib/postgresql/archive/%f';

-- Reiniciar PostgreSQL
sudo systemctl restart postgresql
```

### 2. Archive Command

```bash
# Exemplo de archive command
archive_command = 'cp %p /var/lib/postgresql/archive/%f'

# Com compressão
archive_command = 'gzip < %p > /var/lib/postgresql/archive/%f.gz'

# Com backup remoto
archive_command = 'rsync -a %p backup-server:/archive/%f'
```

### 3. Verificar Archiving

```sql
-- Verificar status do archiving
SELECT * FROM pg_stat_archiver;

-- Saída:
-- - archived_count: Número de arquivos arquivados
-- - failed_count: Número de falhas
-- - last_archived_wal: Último WAL arquivado
-- - last_archived_time: Tempo do último archive
```

## Replicação com WAL

### 1. Streaming Replication

```sql
-- Configuração no primário
wal_level = replica
max_wal_senders = 5
wal_keep_size = 256

-- Réplica se conecta e consome WAL
-- Replicação em tempo real
```

### 2. Logical Replication

```sql
-- Configuração no primário
wal_level = logical
max_replication_slots = 5

-- Criar publicação
CREATE PUBLICATION orders_pub FOR TABLE orders;

-- Réplica se inscreve
CREATE SUBSCRIPTION orders_sub CONNECTION '...' PUBLICATION orders_pub;
```

### 3. Slots de Replicação

```sql
-- Verificar slots de replicação
SELECT * FROM pg_replication_slots;

-- Criar slot físico
SELECT * FROM pg_create_physical_replication_slot('slot_name');

-- Dropar slot
SELECT pg_drop_replication_slot('slot_name');
```

## Recovery

### 1. Point-in-Time Recovery (PITR)

```bash
# Configurar recovery.conf
restore_command = 'cp /var/lib/postgresql/archive/%f %p'
recovery_target_time = '2024-01-15 10:00:00'
recovery_target_name = 'before-drop'
```

### 2. Recovery Targets

```sql
-- Recuperar até timestamp
recovery_target_time = '2024-01-15 10:00:00'

-- Recuperar até nome
recovery_target_name = 'before-drop'

-- Recuperar até XID
recovery_target_xid = '12345'

-- Recuperar até LSN
recovery_target_lsn = '0/16B37D8'
```

### 3. Timeline

```text
- Timeline: Versão do banco após recovery
- Cada recovery cria nova timeline
- Permite branching de histórico
```

## Monitoramento

### 1. Verificar Tamanho do WAL

```sql
-- Verificar tamanho do WAL
SELECT 
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')) AS wal_size;
```

### 2. Verificar Atividade do WAL

```sql
-- Verificar estatísticas do WAL
SELECT * FROM pg_stat_wal;

-- Saída:
-- - wal_records: Número de registros
-- - wal_bytes: Bytes escritos
-- - wal_buffers_full: Buffer cheio
-- - wal_write_time: Tempo de escrita
```

### 3. Verificar Checkpoints

```sql
-- Verificar estatísticas de checkpoints
SELECT * FROM pg_stat_bgwriter;

-- Saída:
-- - checkpoints_timed: Checkpoints por tempo
-- - checkpoints_req: Checkpoints requisitados
-- - checkpoint_write_time: Tempo de escrita
```

## Melhores Práticas

### 1. Ajustar wal_buffers

```sql
-- Para produção, aumentar wal_buffers
ALTER SYSTEM SET wal_buffers = '64MB';

-- Para desenvolvimento, padrão é suficiente
ALTER SYSTEM SET wal_buffers = '-1';
```

### 2. Configurar Archiving

```sql
-- Sempre configurar archiving para produção
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'cp %p /archive/%f';
```

### 3. Monitorar Tamanho do WAL

```sql
-- Monitorar crescimento do WAL
-- Alertar se > 2GB
-- Configurar max_wal_size adequadamente

ALTER SYSTEM SET max_wal_size = '2GB';
```

### 4. Usar synchronous_commit Adequadamente

```sql
-- Para dados críticos
SET synchronous_commit = on;

-- Para dados não críticos
SET synchronous_commit = off;

-- Para replicação síncrona
SET synchronous_commit = remote_apply;
```

## Vantagens

### 1. Durabilidade

```text
- Garante que transações commitadas não são perdidas
- Recuperação de falhas
- Proteção contra corrupção
```

### 2. Replicação

```text
- Base para replicação
- Alta disponibilidade
- Backup em tempo real
```

### 3. Point-in-Time Recovery

```text
- Recuperação até ponto específico
- Undo de erros
- Análise de histórico
```

## Limitações

### 1. Overhead de I/O

```text
- Cada transação escreve no WAL
- Mais I/O de disco
- Pode impactar performance
```

### 2. Espaço em Disco

```text
- WAL ocupa espaço em disco
- Requer gerenciamento
- Pode crescer indefinidamente sem archiving
```

### 3. Latência

```text
- synchronous_commit = on adiciona latência
- Flush síncrono é lento
- Pode impactar throughput
```

## Trade-offs

### synchronous_commit on vs off

- **on**: Durabilidade garantida, mais latência
- **off**: Menor latência, possível data loss
- **Escolha**: on para crítico, off para não crítico

### wal_compression on vs off

- **on**: Menos I/O, mais CPU
- **off**: Mais I/O, menos CPU
- **Escolha**: on para I/O bound, off para CPU bound

### Frequent vs Infrequent Checkpoints

- **Frequente**: Menos WAL, mais I/O
- **Infrequente**: Mais WAL, menos I/O
- **Escolha**: Frequent para recovery rápido, infrequente para performance

### _Links_

- <https://www.postgresql.org/docs/current/wal.html>
- <https://www.postgresql.org/docs/current/runtime-config-wal.html>
- <https://www.postgresql.org/docs/current/continuous-archiving.html>
