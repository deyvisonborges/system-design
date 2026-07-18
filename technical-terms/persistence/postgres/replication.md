# Replication

Replication (replicação) é o processo de copiar dados de um banco de dados PostgreSQL (primário) para um ou mais bancos de dados (réplicas), proporcionando alta disponibilidade, escalabilidade de leitura e backup em tempo real.

## Definição

Replication é a tecnologia que mantém múltiplas cópias de dados sincronizadas entre servidores PostgreSQL, permitindo failover, balanceamento de carga de leitura e redundância de dados.

```text
Replication = Primário + Réplicas + Sincronização
```

## Tipos de Replicação

### 1. Streaming Replication (Padrão)

```sql
-- Replicação em tempo real via WAL
-- Configuração no primário (postgresql.conf):
wal_level = replica
max_wal_senders = 5
wal_keep_size = 256

-- Configuração na réplica (recovery.conf):
standby_mode = on
primary_conninfo = 'host=primary port=5432 user=replicator password=secret'
restore_command = 'cp /var/lib/postgresql/archive/%f %p'

-- Vantagens:
-- - Baixa latência
-- - Sincronização em tempo real
-- - Fácil de configurar
```

### 2. Logical Replication

```sql
-- Replicação baseada em logical decoding
-- Configuração no primário:
wal_level = logical
max_replication_slots = 5

-- Criar publicação
CREATE PUBLICATION orders_pub FOR TABLE orders;

-- Configuração na réplica:
CREATE SUBSCRIPTION orders_sub
CONNECTION 'host=primary port=5432 user=replicator password=secret'
PUBLICATION orders_pub;

-- Vantagens:
-- - Replicação seletiva (tabelas específicas)
-- - Transformações de dados
-- - Cross-database replication
```

### 3. Cascading Replication

```sql
-- Réplica se replica de outra réplica
-- Útil para distribuir carga de replicação

-- Primário → Réplica 1 → Réplica 2

-- Configuração na Réplica 1:
-- Atua como réplica do primário E primário da réplica 2
hot_standby = on
max_wal_senders = 5

-- Configuração na Réplica 2:
-- Se replica da Réplica 1
primary_conninfo = 'host=replica1 port=5432 user=replicator password=secret'
```

## Modos de Replicação

### 1. Synchronous Replication

```sql
-- Primário espera confirmação da réplica antes de commit
-- Configuração no primário:
synchronous_commit = on
synchronous_standby_names = 'replica1'

-- Vantagens:
-- - Zero data loss
-- - Consistência forte

-- Desvantagens:
-- - Maior latência de escrita
-- - Menor throughput
```

### 2. Asynchronous Replication (Padrão)

```sql
-- Primário não espera confirmação da réplica
-- Configuração no primário:
synchronous_commit = off

-- Vantagens:
-- - Menor latência de escrita
-- - Maior throughput

-- Desvantagens:
-- - Possível data loss
-- - Consistência eventual
```

### 3. Semi-synchronous Replication

```sql
-- Primário espera confirmação de pelo menos uma réplica
-- Configuração no primário:
synchronous_commit = remote_apply
synchronous_standby_names = 'ANY 1 (replica1, replica2)'

-- Vantagens:
-- - Baixa latência
-- - Proteção contra data loss

-- Desvantagens:
-- - Complexidade de configuração
```

## Configuração

### 1. Configurar Primário

```bash
# /etc/postgresql/14/main/postgresql.conf
wal_level = replica
max_wal_senders = 5
wal_keep_size = 256
synchronous_commit = off

# Criar usuário de replicação
sudo -u postgres psql
CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'secret';

# Configurar pg_hba.conf para permitir replicação
host replication replicator 192.168.1.0/24 md5
```

### 2. Configurar Réplica

```bash
# Parar PostgreSQL na réplica
sudo systemctl stop postgresql

# Limpar diretório de dados
sudo rm -rf /var/lib/postgresql/14/main/*

# Usar pg_basebackup para copiar dados do primário
sudo -u postgres pg_basebackup -h primary -D /var/lib/postgresql/14/main -U replicator -P -v -R

# Criar recovery.conf
cat > /var/lib/postgresql/14/main/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=primary port=5432 user=replicator password=secret'
restore_command = 'cp /var/lib/postgresql/archive/%f %p'
EOF

# Iniciar PostgreSQL na réplica
sudo systemctl start postgresql
```

### 3. Verificar Status da Replicação

```sql
-- No primário, verificar status das réplicas
SELECT * FROM pg_stat_replication;

-- Saída:
-- - pid: Process ID da conexão
-- - usesysid: ID do usuário
-- - usename: Nome do usuário
-- - application_name: Nome da aplicação
-- - client_addr: Endereço IP da réplica
-- - state: Estado (streaming, catchup)
-- - sync_state: Estado de sincronização (sync, async, potential)
-- - replay_lag: Lag de replicação
```

## Failover

### 1. Failover Manual

```bash
# Promover réplica a primário
sudo -u postgres pg_ctl promote -D /var/lib/postgresql/14/main

# Ou via SQL na réplica
SELECT pg_promote();
```

### 2. Failover Automático com Patroni

```yaml
# patroni.yml
scope: postgres-cluster
name: postgres-1

restapi:
  listen: 0.0.0.0:8008

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576

postgresql:
  listen: 0.0.0.0:5432
  data_dir: /var/lib/postgresql/14/main
  authentication:
    replication:
      username: replicator
      password: secret
```

### 3. Switchover Planejado

```bash
# Com Patroni
patronictl switchover

# Ou manual:
# 1. Parar escritas no primário
# 2. Promover réplica
# 3. Reconfigurar aplicação
# 4. Configurar antigo primário como réplica
```

## Monitoramento

### 1. Lag de Replicação

```sql
-- Verificar lag de replicação
SELECT 
    client_addr,
    state,
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lag_lsn) AS lag_bytes
FROM pg_stat_replication;

-- Ou em segundos
SELECT 
    client_addr,
    state,
    sync_state,
    EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp())) AS lag_seconds
FROM pg_stat_replication;
```

### 2. Status da Réplica

```sql
-- Verificar se réplica está em recovery
SELECT pg_is_in_recovery();

-- Verificar último replay
SELECT pg_last_xact_replay_timestamp();
```

### 3. Slots de Replicação

```sql
-- Verificar slots de replicação
SELECT * FROM pg_replication_slots;

-- Limpar slots não utilizados
SELECT pg_drop_replication_slot('slot_name');
```

## Melhores Práticas

### 1. Usar Synchronous Replication para Dados Críticos

```sql
-- Para dados críticos, usar replicação síncrona
synchronous_commit = on
synchronous_standby_names = 'replica1'

-- Para dados não críticos, usar assíncrona
synchronous_commit = off
```

### 2. Monitorar Lag de Replicação

```sql
-- Configurar alertas para lag alto
-- Lag > 5 segundos: warning
-- Lag > 30 segundos: critical

-- Usar pg_stat_replication para monitorar
```

### 3. Usar Multiple Replicas

```sql
-- Múltiplas réplicas para:
-- - Alta disponibilidade
-- - Balanceamento de carga de leitura
-- - Backup em tempo real

-- Configurar múltiplas réplicas
max_wal_senders = 10
```

### 4. Testar Failover Regularmente

```bash
-- Testar failover manual regularmente
-- Verificar se aplicação se reconecta
-- Verificar se dados são consistentes

-- Usar ferramentas como Patroni para automação
```

## Vantagens

### 1. Alta Disponibilidade

```text
- Failover automático em caso de falha
- Tempo de inatividade mínimo
- Recuperação rápida
```

### 2. Escalabilidade de Leitura

```text
- Distribuir leituras entre réplicas
- Reduzir carga no primário
- Melhor performance de leitura
```

### 3. Backup em Tempo Real

```text
- Réplicas servem como backup
- Recuperação point-in-time
- Proteção contra corrupção de dados
```

## Limitações

### 1. Escrita Apenas no Primário

```text
- Réplicas são read-only
- Não podem aceitar escritas
- Limita escalabilidade de escrita
```

### 2. Latência de Replicação

```text
- Lag entre primário e réplica
- Dados podem não estar sincronizados
- Consistência eventual
```

### 3. Complexidade de Configuração

```text
- Configuração complexa
- Requer monitoramento
- Troubleshooting difícil
```

## Trade-offs

### Synchronous vs Asynchronous

- **Synchronous**: Zero data loss, maior latência
- **Asynchronous**: Possível data loss, menor latência
- **Escolha**: Synchronous para crítico, asynchronous para geral

### Streaming vs Logical

- **Streaming**: Tabela inteira, mais simples
- **Logical**: Seletivo, mais flexível
- **Escolha**: Streaming para geral, logical para específico

### Single vs Multiple Replicas

- **Single**: Menor custo, menor HA
- **Multiple**: Maior custo, maior HA
- **Escolha**: Single para dev, multiple para prod

### _Links_

- <https://www.postgresql.org/docs/current/high-availability.html>
- <https://www.postgresql.org/docs/current/warm-standby.html>
- <https://www.postgresql.org/docs/current/logical-replication.html>
