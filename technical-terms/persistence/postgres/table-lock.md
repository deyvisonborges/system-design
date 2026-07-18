# Table Lock

Table Lock (bloqueio de tabela) é um mecanismo do PostgreSQL que bloqueia uma tabela inteira, impedindo que outras transações acessem a tabela de certas formas. É mais restritivo que row locks mas tem menos overhead.

## Definição

Table Lock é um tipo de bloqueio que bloqueia a tabela inteira em vez de linhas individuais, usado para operações que requerem acesso exclusivo à tabela ou para evitar contenção de muitos row locks.

```text
Table Lock = Bloqueio granular por tabela
```

## Tipos de Table Locks

### 1. ACCESS SHARE

```sql
-- Lock padrão para SELECT
-- Permite leitura concorrente
-- Bloqueia DROP TABLE, TRUNCATE

SELECT * FROM orders;
-- Implicitamente obtém ACCESS SHARE lock
```

### 2. ROW SHARE

```sql
-- Obtido por SELECT FOR UPDATE/FOR SHARE
-- Permite leitura concorrente
-- Bloqueia DROP TABLE, TRUNCATE, UPDATE/DELETE sem FOR

SELECT * FROM orders FOR UPDATE;
-- Obtém ROW SHARE lock
```

### 3. ROW EXCLUSIVE

```sql
-- Obtido por UPDATE, DELETE, INSERT
-- Bloqueia SELECT FOR UPDATE/FOR SHARE
-- Permite leitura concorrente

UPDATE orders SET status = 'completed' WHERE id = 123;
-- Implicitamente obtém ROW EXCLUSIVE lock
```

### 4. SHARE UPDATE EXCLUSIVE

```sql
-- Obtido por VACUUM (sem FULL), ANALYZE
-- Bloqueia UPDATE, DELETE, INSERT
-- Permite leitura concorrente

VACUUM orders;
-- Obtém SHARE UPDATE EXCLUSIVE lock
```

### 5. SHARE

```sql
-- Obtido por CREATE INDEX CONCURRENTLY
-- Bloqueia UPDATE, DELETE, INSERT
-- Permite leitura concorrente

CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status);
-- Obtém SHARE lock
```

### 6. SHARE ROW EXCLUSIVE

```sql
-- Obtido explicitamente com LOCK TABLE
-- Bloqueia UPDATE, DELETE, INSERT, SELECT FOR UPDATE
-- Permite leitura concorrente

LOCK TABLE orders IN SHARE ROW EXCLUSIVE MODE;
-- Obtém SHARE ROW EXCLUSIVE lock
```

### 7. EXCLUSIVE

```sql
-- Obtido explicitamente com LOCK TABLE
-- Bloqueia UPDATE, DELETE, INSERT, SELECT FOR UPDATE, SELECT FOR SHARE
-- Permite leitura concorrente (SELECT sem FOR)

LOCK TABLE orders IN EXCLUSIVE MODE;
-- Obtém EXCLUSIVE lock
```

### 8. ACCESS EXCLUSIVE

```sql
-- Lock mais restritivo
-- Obtido por DROP TABLE, TRUNCATE, REINDEX, VACUUM FULL
-- Bloqueia todas as operações na tabela

DROP TABLE orders;
-- Obtém ACCESS EXCLUSIVE lock
```

## Matriz de Compatibilidade

```text
Lock Mode              | ACCESS SHARE | ROW SHARE | ROW EXCL | SHARE UPDATE EXCL | SHARE | SHARE ROW EXCL | EXCLUSIVE | ACCESS EXCL
-----------------------|--------------|-----------|----------|-------------------|-------|----------------|-----------|----------------
ACCESS SHARE           |              | X         | X        | X                 | X     | X              | X         | X
ROW SHARE              | X            |           | X        | X                 | X     | X              | X         | X
ROW EXCLUSIVE          | X            | X         |          | X                 | X     | X              | X         | X
SHARE UPDATE EXCLUSIVE | X            | X         | X        |                   | X     | X              | X         | X
SHARE                  | X            | X         | X        | X                 |       | X              | X         | X
SHARE ROW EXCLUSIVE    | X            | X         | X        | X                 | X     |                | X         | X
EXCLUSIVE              | X            | X         | X        | X                 | X     | X              |           | X
ACCESS EXCLUSIVE       | X            | X         | X        | X                 | X     | X              | X         |

X = Conflito (locks não são compatíveis)
```

## Quando Table Locks São Usados

### 1. DDL Operations

```sql
-- DDL operations obtêm ACCESS EXCLUSIVE lock
DROP TABLE orders;
TRUNCATE orders;
ALTER TABLE orders ADD COLUMN new_column INT;
-- Bloqueia todas as operações na tabela
```

### 2. VACUUM FULL

```sql
-- VACUUM FULL reescreve a tabela
-- Obtém ACCESS EXCLUSIVE lock
VACUUM FULL orders;
-- Bloqueia todas as operações na tabela
```

### 3. CREATE INDEX CONCURRENTLY

```sql
-- CREATE INDEX CONCURRENTLY obtém SHARE lock
-- Permite leitura mas bloqueia escrita
CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status);
```

### 4. LOCK TABLE Explícito

```sql
-- Lock explícito para operações bulk
LOCK TABLE orders IN EXCLUSIVE MODE;
-- Bloqueia escrita, permite leitura

-- Realizar operações bulk
UPDATE orders SET status = 'processed' WHERE status = 'pending';
COMMIT;
```

## Exemplo Prático

### Bulk Update com Table Lock

```sql
-- Ruim: Muitos row locks
BEGIN;
UPDATE orders SET status = 'processed' WHERE status = 'pending';
-- Obtém row lock para cada linha
-- Muito overhead se muitas linhas
COMMIT;

-- Bom: Table lock
BEGIN;
LOCK TABLE orders IN EXCLUSIVE MODE;
-- Um único lock para toda a tabela
UPDATE orders SET status = 'processed' WHERE status = 'pending';
COMMIT;
```

### Schema Migration

```sql
-- Migration que requer ACCESS EXCLUSIVE
BEGIN;
LOCK TABLE orders IN ACCESS EXCLUSIVE MODE;
-- Bloqueia todas as operações

-- Realizar migration
ALTER TABLE orders ADD COLUMN new_column INT;
ALTER TABLE orders ALTER COLUMN new_column SET DEFAULT 0;

COMMIT;
```

### Backup Consistente

```sql
-- Backup com table lock
BEGIN;
LOCK TABLE orders IN SHARE MODE;
-- Permite leitura, bloqueia escrita

-- Realizar backup
SELECT * FROM orders;

COMMIT;
```

## Monitoramento

### 1. Verificar Locks de Tabela

```sql
-- Verificar locks de tabela ativos
SELECT 
    pid,
    relation::regclass,
    mode,
    granted
FROM pg_locks
WHERE locktype = 'relation'
ORDER BY pid;
```

### 2. Verificar Transações Bloqueadas

```sql
-- Verificar transações esperando por table locks
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement
FROM pg_catalog.pg_locks blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted
  AND blocked_locks.locktype = 'relation';
```

### 3. Verificar Lock Timeout

```sql
-- Verificar configuração de lock timeout
SHOW lock_timeout;
-- Resultado: 0 (sem timeout)

-- Configurar lock timeout
SET lock_timeout = '5s';
```

## Melhores Práticas

### 1. Usar Table Lock para Operações Bulk

```sql
-- Para operações que afetam muitas linhas
-- Usar table lock em vez de muitos row locks

BEGIN;
LOCK TABLE orders IN EXCLUSIVE MODE;
UPDATE orders SET status = 'processed' WHERE status = 'pending';
COMMIT;
```

### 2. Manter DDL em Maintenance Windows

```sql
-- DDL operations obtêm ACCESS EXCLUSIVE lock
-- Executar em maintenance windows

-- Exemplo:
BEGIN;
LOCK TABLE orders IN ACCESS EXCLUSIVE MODE NOWAIT;
-- Falha imediatamente se lock não disponível

-- Realizar DDL
ALTER TABLE orders ADD COLUMN new_column INT;
COMMIT;
```

### 3. Usar CREATE INDEX CONCURRENTLY

```sql
-- Evitar bloquear tabela ao criar índice
-- Usar CREATE INDEX CONCURRENTLY

-- Ruim:
CREATE INDEX idx_orders_status ON orders(status);
-- Bloqueia escrita na tabela

-- Bom:
CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status);
-- Permite leitura, bloqueia escrita apenas
```

### 4. Configurar Lock Timeout

```sql
-- Configurar lock timeout para evitar espera infinita
SET lock_timeout = '5s';

-- Ou configurar permanentemente
ALTER SYSTEM SET lock_timeout = '5s';
```

## Vantagens

### 1. Menos Overhead

```text
- Um único lock em vez de muitos
- Menor overhead de gerenciamento
- Mais eficiente para operações bulk
```

### 2. Simplicidade

```text
- Fácil de entender e usar
- Menos complexo que row locks
- Menor chance de deadlocks
```

### 3. Prevenção de Contenção

```text
- Evita contenção de muitos row locks
- Melhor para operações que afetam toda a tabela
- Mais previsível
```

## Limitações

### 1. Menor Concorrência

```text
- Bloqueia toda a tabela
- Menor throughput que row locks
- Pode causar contenção
```

### 2. Bloqueio de Operações

```text
- Bloqueia todas as operações na tabela
- Pode impactar outras transações
- Não ideal para tabelas acessadas frequentemente
```

### 3. Não Adequado para OLTP

```text
- Não ideal para transações OLTP
- Melhor para operações batch
- Pode impactar performance de aplicação
```

## Trade-offs

### Table Lock vs Row Lock

- **Table Lock**: Menos overhead, menor concorrência
- **Row Lock**: Maior overhead, maior concorrência
- **Escolha**: Table lock para bulk, row lock para OLTP

### Explicit vs Implicit Lock

- **Explicit**: Controle total, mais complexo
- **Implicit**: Automático, simples
- **Escolha**: Implicit para geral, explicit para bulk operations

### ACCESS EXCLUSIVE vs Outros Locks

- **ACCESS EXCLUSIVE**: Mais restritivo, bloqueia tudo
- **Outros**: Menos restritivos, permitem algumas operações
- **Escolha**: ACCESS EXCLUSIVE para DDL, outros para operações de dados

### _Links_

- <https://www.postgresql.org/docs/current/explicit-locking.html>
- <https://www.postgresql.org/docs/current/sql-lock.html>
- <https://www.postgresql.org/docs/current/ddl-locks.html>
