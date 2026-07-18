# Row Lock

Row Lock (bloqueio de linha) é um mecanismo do PostgreSQL que bloqueia linhas específicas de uma tabela, permitindo que múltiplas transações acessem diferentes linhas da mesma tabela simultaneamente, prevenindo conflitos.

## Definição

Row Lock é um tipo de bloqueio granular que bloqueia linhas individuais em vez da tabela inteira, permitindo maior concorrência ao permitir que transações diferentes acessem linhas diferentes simultaneamente.

```text
Row Lock = Bloqueio granular por linha
```

## Tipos de Row Locks

### 1. FOR UPDATE

```sql
-- Bloqueia linhas para UPDATE
-- Outras transações podem ler mas não atualizar

BEGINSELECT * FROM orders WHERE id = 123 FOR UPDATE;
-- Linha 123 está bloqueada para UPDATE

-- Outra transação
BEGINSELECT * FROM orders WHERE id = 123;
-- Pode ler (SELECT sem FOR UPDATE)

-- Outra transação tentando UPDATE
UPDATE orders SET status = 'pending' WHERE id = 123;
-- Bloqueado até primeira transação commit/rollback
```

### 2. FOR NO KEY UPDATE

```sql
-- Bloqueia linhas mas não bloqueia chaves estrangeiras
-- Menos restritivo que FOR UPDATE

BEGINSELECT * FROM orders WHERE id = 123 FOR NO KEY UPDATE;
-- Linha 123 está bloqueada para UPDATE/DELETE
-- Mas não bloqueia chaves estrangeiras

-- Outra transação pode atualizar chaves estrangeiras
UPDATE customers SET id = 456 WHERE id = 123;
-- Permitido (não bloqueado)
```

### 3. FOR SHARE

```sql
-- Bloqueia linhas para leitura compartilhada
-- Múltiplas transações podem ter FOR SHARE
-- Mas nenhuma pode ter FOR UPDATE

BEGINSELECT * FROM orders WHERE id = 123 FOR SHARE;
-- Linha 123 está bloqueada para UPDATE
-- Mas outras transações podem ter FOR SHARE

-- Outra transação
SELECT * FROM orders WHERE id = 123 FOR SHARE;
-- Permitido (FOR SHARE compartilhado)

-- Outra transação tentando FOR UPDATE
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
-- Bloqueado até FOR SHARE commit/rollback
```

### 4. FOR KEY SHARE

```sql
-- Bloqueia linhas mas permite UPDATE em outras colunas
-- Menos restritivo que FOR SHARE

BEGINSELECT * FROM orders WHERE id = 123 FOR KEY SHARE;
-- Linha 123 está bloqueada para DELETE
-- Mas UPDATE em outras colunas é permitido

-- Outra transação pode atualizar colunas não-chave
UPDATE orders SET status = 'pending' WHERE id = 123;
-- Permitido (não bloqueado)
```

## Quando Row Locks São Usados

### 1. UPDATE e DELETE

```sql
-- PostgreSQL automaticamente bloqueia linhas em UPDATE/DELETE
BEGINUPDATE orders SET status = 'completed' WHERE id = 123;
-- Linha 123 automaticamente bloqueada (FOR UPDATE)

-- Outra transação
UPDATE orders SET amount = 200 WHERE id = 123;
-- Bloqueado até primeira transação commit/rollback
```

### 2. SELECT FOR UPDATE

```sql
-- Bloqueia linhas explicitamente para UPDATE futuro
BEGINSELECT * FROM orders WHERE id = 123 FOR UPDATE;
-- Linha 123 bloqueada

-- Verificar dados
-- Aplicar lógica de negócio
-- Atualizar se necessário
UPDATE orders SET status = 'completed' WHERE id = 123;
COMMIT;
```

### 3. SELECT FOR SHARE

```sql
-- Bloqueia linhas para leitura consistente
BEGINSELECT * FROM orders WHERE id = 123 FOR SHARE;
-- Linha 123 bloqueada para UPDATE

-- Verificar dados
-- Aplicar lógica de negócio
-- Não atualiza, apenas lê
COMMIT;
```

## Conflitos de Locks

### 1. FOR UPDATE vs FOR UPDATE

```sql
-- Duas transações com FOR UPDATE na mesma linha
-- Segunda transação espera
-- Deadlock se ambas esperam uma pela outra
```

### 2. FOR UPDATE vs FOR SHARE

```sql
-- FOR UPDATE espera por FOR SHARE
-- FOR SHARE espera por FOR UPDATE
-- FOR SHARE não espera por FOR SHARE
```

### 3. FOR NO KEY UPDATE vs FOR KEY SHARE

```sql
-- FOR NO KEY UPDATE não espera por FOR KEY SHARE
-- FOR KEY SHARE não espera por FOR NO KEY UPDATE
-- Menos conflitos que FOR UPDATE vs FOR SHARE
```

## Exemplo Prático

### Transferência de Saldo

```sql
-- Transação 1: Transferência
BEGIN;
SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;
-- Bloqueia conta 1

SELECT balance FROM accounts WHERE id = 2 FOR UPDATE;
-- Bloqueia conta 2

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;

-- Transação 2: Outra transferência
BEGIN;
SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;
-- Bloqueado até transação 1 commit
```

### Verificação de Disponibilidade

```sql
-- Transação 1: Reserva estoque
BEGIN;
SELECT quantity FROM products WHERE id = 123 FOR UPDATE;
-- Bloqueia produto 123

IF quantity >= 10 THEN
    UPDATE products SET quantity = quantity - 10 WHERE id = 123;
    INSERT INTO orders (product_id, quantity) VALUES (123, 10);
END IF;
COMMIT;

-- Transação 2: Outra reserva
BEGIN;
SELECT quantity FROM products WHERE id = 123 FOR UPDATE;
-- Bloqueado até transação 1 commit
-- Garante que não haja overselling
```

## Monitoramento

### 1. Verificar Locks Ativos

```sql
-- Verificar locks de linha ativos
SELECT 
    pid,
    relation::regclass,
    mode,
    granted
FROM pg_locks
WHERE locktype = 'tuple'
ORDER BY pid;
```

### 2. Verificar Transações Bloqueadas

```sql
-- Verificar transações esperando por locks
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
WHERE NOT blocked_locks.granted;
```

### 3. Verificar Deadlocks

```sql
-- Verificar deadlocks no log
-- Deadlocks são registrados no log do PostgreSQL
-- Configurar log_deadlock_errors

SHOW log_deadlock_errors;
-- Resultado: on
```

## Melhores Práticas

### 1. Manter Transações Curtas

```sql
-- Ruim: Transação longa
BEGIN;
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
-- Processamento longo (segundos/minutos)
UPDATE orders SET status = 'completed' WHERE id = 123;
COMMIT;

-- Bom: Transação curta
BEGIN;
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
UPDATE orders SET status = 'completed' WHERE id = 123;
COMMIT;
-- Processamento fora da transação
```

### 2. Usar Lock Adequado

```sql
-- Use FOR UPDATE quando vai atualizar
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
UPDATE orders SET status = 'completed' WHERE id = 123;

-- Use FOR SHARE quando apenas vai ler
SELECT * FROM orders WHERE id = 123 FOR SHARE;
-- Apenas leitura, sem atualização

-- Use FOR NO KEY UPDATE quando não afeta chaves
SELECT * FROM orders WHERE id = 123 FOR NO KEY UPDATE;
UPDATE orders SET status = 'completed' WHERE id = 123;
```

### 3. Evitar Deadlocks

```sql
-- Sempre acessar tabelas na mesma ordem
-- Bom:
BEGIN;
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
SELECT * FROM customers WHERE id = 456 FOR UPDATE;
COMMIT;

-- Ruim (ordem inconsistente):
-- Transação 1:
BEGIN;
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
SELECT * FROM customers WHERE id = 456 FOR UPDATE;
COMMIT;

-- Transação 2:
BEGIN;
SELECT * FROM customers WHERE id = 456 FOR UPDATE;
SELECT * FROM orders WHERE id = 123 FOR UPDATE;
COMMIT;
-- Pode causar deadlock
```

### 4. Tratar Timeouts

```python
# Exemplo: Tratar lock timeout
import psycopg2
from psycopg2 import OperationalError

def execute_with_retry():
    max_retries = 3
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(...)
            cursor = conn.cursor()
            
            cursor.execute("SELECT * FROM orders WHERE id = 123 FOR UPDATE")
            cursor.execute("UPDATE orders SET status = 'completed' WHERE id = 123")
            
            conn.commit()
            return
        except OperationalError as e:
            if 'could not obtain lock' in str(e):
                conn.rollback()
                continue
            raise
        finally:
            conn.close()
```

## Vantagens

### 1. Alta Concorrência

```text
- Múltiplas transações podem acessar diferentes linhas
- Maior throughput que table locks
- Melhor uso de recursos
```

### 2. Granularidade Fina

```text
- Bloqueia apenas linhas necessárias
- Menos bloqueios desnecessários
- Maior paralelismo
```

### 3. Prevenção de Conflitos

```text
- Previne atualizações simultâneas
- Garante consistência de dados
- Evita race conditions
```

## Limitações

### 1. Overhead de Lock

```text
- Manter locks tem custo
- Mais locks = mais overhead
- Pode impactar performance
```

### 2. Deadlocks

```text
- Pode ocorrer deadlocks
- Requer detecção e tratamento
- Complexidade adicional
```

### 3. Escalabilidade

```text
- Muitos locks podem causar contenção
- Limite de locks por transação
- Pode não escalar para cargas muito altas
```

## Trade-offs

### Row Lock vs Table Lock

- **Row Lock**: Maior concorrência, mais overhead
- **Table Lock**: Menor concorrência, menos overhead
- **Escolha**: Row lock para geral, table lock para bulk operations

### FOR UPDATE vs FOR SHARE

- **FOR UPDATE**: Exclusivo, bloqueia updates
- **FOR SHARE**: Compartilhado, permite leitura
- **Escolha**: FOR UPDATE para atualização, FOR SHARE para verificação

### Explicit Lock vs Implicit Lock

- **Explicit**: Controle total, mais complexo
- **Implicit**: Automático, simples
- **Escolha**: Implicit para geral, explicit para casos específicos

### _Links_

- <https://www.postgresql.org/docs/current/explicit-locking.html>
- <https://www.postgresql.org/docs/current/sql-select.html#SQL-FOR-UPDATE-SHARE>
- <https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS>
