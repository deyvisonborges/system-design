# Isolation Levels

Isolation Levels (níveis de isolamento) são configurações que determinam como as transações interagem entre si, controlando quais anomalias de concorrência são permitidas. PostgreSQL suporta 4 níveis de isolamento padrão SQL.

## Definição

Isolation Level define o grau de isolamento entre transações concorrentes, especificando quais fenômenos (dirty reads, non-repeatable reads, phantom reads) são permitidos.

```text
Isolation Level = Grau de isolamento entre transações
```

## Níveis de Isolamento

### 1. Read Uncommitted

```sql
-- Nível mais baixo de isolamento
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Permite:
-- - Dirty reads (ler dados não commitados)
-- - Non-repeatable reads
-- - Phantom reads

-- PostgreSQL não suporta READ UNCOMMITTED
-- É tratado como READ COMMITTED
```

### 2. Read Committed (Padrão)

```sql
-- Nível padrão do PostgreSQL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Permite:
-- - Non-repeatable reads
-- - Phantom reads

-- Previne:
-- - Dirty reads
```

### 3. Repeatable Read

```sql
-- Nível mais alto padrão do PostgreSQL
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Permite:
-- - Serialization anomalies (raro)

-- Previne:
-- - Dirty reads
-- - Non-repeatable reads
-- - Phantom reads

-- PostgreSQL implementa MVCC para Repeatable Read
```

### 4. Serializable

```sql
-- Nível mais alto de isolamento
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Previne:
-- - Dirty reads
-- - Non-repeatable reads
-- - Phantom reads
-- - Serialization anomalies

-- Garante serialização completa
-- Pode causar mais conflitos e rollbacks
```

## Anomalias de Concorrência

### 1. Dirty Read

```sql
-- Transação 1
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- Não commit ainda

-- Transação 2
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT balance FROM accounts WHERE id = 1;
-- Lê valor não commitado (dirty read)

-- Transação 1
ROLLBACK;
-- Valor volta ao original
```

### 2. Non-repeatable Read

```sql
-- Transação 1
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 1000

-- Transação 2
BEGIN;
UPDATE accounts SET balance = 900 WHERE id = 1;
COMMIT;

-- Transação 1
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 900 (non-repeatable read)
```

### 3. Phantom Read

```sql
-- Transação 1
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM accounts WHERE balance > 1000;
-- Retorna 5 linhas

-- Transação 2
BEGIN;
INSERT INTO accounts (id, balance) VALUES (6, 2000);
COMMIT;

-- Transação 1
SELECT * FROM accounts WHERE balance > 1000;
-- Retorna 6 linhas (phantom read)
```

## MVCC no PostgreSQL

### 1. Como MVCC Funciona

```text
- Cada transação vê um snapshot dos dados
- Versões antigas de linhas são mantidas
- Não há bloqueio de leitura
- Escritas não bloqueiam leituras
```

### 2. Snapshot Isolation

```sql
-- Repeatable Read usa snapshot isolation
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Todas as leituras veem o mesmo snapshot
-- Mesmo se outras transações modificarem dados
```

### 3. VACUUM

```sql
-- Remove versões antigas de linhas
-- Necessário para limpar MVCC
VACUUM accounts;

-- VACUUM FULL reescreve a tabela
VACUUM FULL accounts;
```

## Exemplo Prático

### Comparação: Read Committed vs Repeatable Read

```sql
-- Transação 1 (Read Committed)
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 1000

-- Transação 2
BEGIN;
UPDATE accounts SET balance = 900 WHERE id = 1;
COMMIT;

-- Transação 1
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 900 (non-repeatable read)
COMMIT;

-- Transação 3 (Repeatable Read)
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 900

-- Transação 4
BEGIN;
UPDATE accounts SET balance = 800 WHERE id = 1;
COMMIT;

-- Transação 3
SELECT balance FROM accounts WHERE id = 1;
-- Retorna 900 (repeatable read)
COMMIT;
```

### Serializable e Conflitos

```sql
-- Transação 1
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM accounts WHERE balance > 1000;
-- Retorna 5 linhas

-- Transação 2
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO accounts (id, balance) VALUES (6, 2000);
COMMIT;

-- Transação 1
SELECT * FROM accounts WHERE balance > 1000;
-- Retorna 5 linhas (sem phantom)
-- Mas pode causar conflito ao commit
COMMIT;
-- Pode falhar com serialization error
```

## Configuração

### 1. Nível Padrão

```sql
-- Ver nível padrão
SHOW default_transaction_isolation;
-- Resultado: read committed

-- Alterar nível padrão
ALTER DATABASE mydb SET default_transaction_isolation = 'repeatable read';
```

### 2. Nível por Transação

```sql
-- Definir nível para transação atual
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Definir nível para sessão
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

### 3. Nível por Função

```sql
-- Definir nível em função
CREATE FUNCTION get_account_balance(p_id INT)
RETURNS NUMERIC AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SELECT balance FROM accounts WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
```

## Melhores Práticas

### 1. Escolher Nível Adequado

```sql
-- Use Read Committed para:
-- - Maioria das aplicações
-- - Quando non-repeatable reads são aceitáveis
-- - Menor overhead

-- Use Repeatable Read para:
-- - Relatórios consistentes
-- - Quando non-repeatable reads não são aceitáveis
-- - Mais overhead

-- Use Serializable para:
-- - Críticas financeiras
-- - Quando serialização completa é necessária
-- - Maior overhead, mais conflitos
```

### 2. Monitorar Conflitos

```sql
-- Verificar conflitos de serialização
SELECT * FROM pg_stat_database_conflicts;

-- Verificar deadlocks
SELECT * FROM pg_stat_activity 
WHERE wait_event_type = 'Lock';
```

### 3. Tratar Erros de Serialização

```python
# Exemplo: Retirar em caso de serialization error
import psycopg2
from psycopg2 import OperationalError

def execute_transaction():
    max_retries = 3
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(...)
            conn.set_session(isolation_level='SERIALIZABLE')
            cursor = conn.cursor()
            
            cursor.execute("SELECT ...")
            cursor.execute("UPDATE ...")
            
            conn.commit()
            return
        except OperationalError as e:
            if 'could not serialize' in str(e):
                conn.rollback()
                continue
            raise
        finally:
            conn.close()
```

## Trade-offs

### Read Committed vs Repeatable Read

- **Read Committed**: Menor overhead, non-repeatable reads
- **Repeatable Read**: Maior overhead, repeatable reads
- **Escolha**: Read committed para geral, repeatable para consistência

### Repeatable Read vs Serializable

- **Repeatable Read**: Menos conflitos, serialização parcial
- **Serializable**: Mais conflitos, serialização completa
- **Escolha**: Repeatable para maioria, serializable para crítico

### MVCC vs Locking

- **MVCC**: Sem bloqueio de leitura, mais overhead
- **Locking**: Bloqueio de leitura, menos overhead
- **Escolha**: MVCC para concorrência alta, locking para baixa

### _Links_

- <https://www.postgresql.org/docs/current/transaction-iso.html>
- <https://www.postgresql.org/docs/current/mvcc.html>
- <https://www.postgresql.org/docs/current/routine-vacuuming.html>
