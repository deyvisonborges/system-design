# Locks em Nível de Banco de Dados

## 1. O problema que os locks resolvem

Em sistemas concorrentes, múltiplas transações podem tentar acessar e modificar os mesmos dados simultaneamente. Sem controle adequado, isso leva a problemas como:

- **Lost Update**: Duas transações leem o mesmo valor, modificam-no, e a última sobrescreve a primeira, perdendo a atualização intermediária
- **Dirty Read**: Uma transação lê dados não commitados de outra transação que pode ser revertida
- **Inconsistent Reads**: Dados lidos em um estado intermediário que viola invariantes do negócio

Locks são o mecanismo fundamental que os SGBDs usam para garantir que transações concorrentes não corrompam os dados, implementando a propriedade de **isolamento** do ACID.

## 2. Granularidade de Locks

Locks podem ser aplicados em diferentes níveis de granularidade, cada um com trade-offs distintos:

### 2.1 Table Locks (Locks de Tabela)

- Travam a tabela inteira para uma operação
- **Vantagem**: Simples, baixo overhead de gerenciamento
- **Desvantagem**: Baixa concorrência — uma operação bloqueia todas as outras na mesma tabela
- **Uso típico**: DDL (ALTER TABLE, DROP TABLE), bulk loads em tabelas pequenas
- **Exemplo**: `LOCK TABLE accounts IN EXCLUSIVE MODE;`

### 2.2 Page Locks (Locks de Página)

- Travam uma página de disco (tipicamente 8KB-16KB) contendo múltiplas linhas
- **Vantagem**: Melhor concorrência que table locks, menos overhead que row locks
- **Desvantagem**: Ainda pode bloquear linhas não relacionadas se estiverem na mesma página
- **Uso típico**: SQL Server (por padrão em alguns cenários)

### 2.3 Row Locks (Locks de Linha)

- Travam linhas individuais
- **Vantagem**: Máxima concorrência — operações em linhas diferentes não bloqueiam umas às outras
- **Desvantagem**: Maior overhead de gerenciamento, mais memória para rastrear locks
- **Uso típico**: OLTP com alta concorrência (sistemas de crédito, pagamentos)
- **Exemplo**: `SELECT * FROM accounts WHERE id = 123 FOR UPDATE;`

### 2.4 Predicate Locks (Locks de Predicado)

- Travam conjuntos de linhas baseados em condições (WHERE clauses)
- **Vantagem**: Previne phantom reads em níveis SERIALIZABLE
- **Desvantagem**: Complexo de implementar, overhead significativo
- **Uso típico**: SERIALIZABLE isolation level

## 3. Modos de Lock

### 3.1 Shared Lock (S Lock / Read Lock)

- Permite múltiplos leitores simultâneos
- Bloqueia escritores
- **Uso**: SELECT em transações que precisam garantir consistência
- **Compatibilidade**: S com S, não com X

### 3.2 Exclusive Lock (X Lock / Write Lock)

- Permite apenas um holder (escritor)
- Bloqueia tanto leitores quanto outros escritores
- **Uso**: UPDATE, DELETE, INSERT
- **Compatibilidade**: Não com S nem X

### 3.3 Intention Locks (IS, IX)

- Usados em hierarquias de locks (tabela → página → linha)
- **IS (Intention Shared)**: Transação pretende colocar S locks em itens descendentes
- **IX (Intention Exclusive)**: Transação pretende colocar X locks em itens descendentes
- **SIX (Shared Intention Exclusive)**: S lock no nível atual + IX locks em descendentes
- **Uso**: Otimização para evitar verificar cada linha individualmente

### 3.4 Outros Modos Específicos

- **Update Lock (U)**: Usado para prevenir deadlocks em UPDATEs que fazem SELECT antes de modificar
- **Schema Locks**: Para operações DDL
- **Bulk Update Locks**: Para operações de bulk load que permitem leituras mas bloqueiam outras modificações

## 4. Locks Explícitos vs Implícitos

### 4.1 Locks Implícitos

O SGBD adquire locks automaticamente baseado na operação:

```sql
-- Adquire shared lock implicitamente (dependendo do isolation level)
SELECT * FROM accounts WHERE id = 123;

-- Adquire exclusive lock implicitamente
UPDATE accounts SET balance = balance - 100 WHERE id = 123;
```

### 4.2 Locks Explícitos

Você controla explicitamente o comportamento:

```sql
-- PostgreSQL: FOR UPDATE (exclusive lock)
SELECT * FROM accounts WHERE id = 123 FOR UPDATE;

-- PostgreSQL: FOR SHARE (shared lock)
SELECT * FROM accounts WHERE id = 123 FOR SHARE;

-- MySQL: LOCK IN SHARE MODE
SELECT * FROM accounts WHERE id = 123 LOCK IN SHARE MODE;

-- SQL Server: WITH (XLOCK)
SELECT * FROM accounts WITH (XLOCK) WHERE id = 123;
```

## 5. Deadlocks

### 5.1 O que é um Deadlock

Situação onde duas ou mais transações estão esperando por locks que umas às outras seguram, criando um ciclo de espera infinito.

**Exemplo clássico**:

```text
Transação A: UPDATE accounts SET balance = ... WHERE id = 1;  -- lock na linha 1
Transação B: UPDATE accounts SET balance = ... WHERE id = 2;  -- lock na linha 2
Transação A: UPDATE accounts SET balance = ... WHERE id = 2;  -- espera B liberar linha 2
Transação B: UPDATE accounts SET balance = ... WHERE id = 1;  -- espera A liberar linha 1
```

### 5.2 Prevenção de Deadlocks

- **Ordem consistente de acesso**: Sempre acessar recursos na mesma ordem (ex: sempre por ID crescente)
- **Manter transações curtas**: Menor tempo segurando locks reduz chance de deadlock
- **Acessar recursos em um batch**: Adquirir todos os locks necessários de uma vez
- **Usar isolation level apropriado**: READ COMMITTED em vez de SERIALIZABLE quando possível

### 5.3 Detecção e Tratamento

A maioria dos SGBDs detecta deadlocks automaticamente e escolhe uma "vítima" para abortar:

```sql
-- PostgreSQL: erro típico de deadlock
ERROR: deadlock detected
DETAIL: Process 123 waits for ShareLock on transaction 456; blocked by process 789.
```

## 6. Locks em Diferentes SGBDs

### 6.1 PostgreSQL

- Usa MVCC como mecanismo principal, mas ainda tem locks
- **Row locks**: FOR UPDATE, FOR SHARE, FOR KEY SHARE
- **Advisory locks**: Locks de aplicação que não estão relacionados a dados (pg_advisory_lock)
- **Table locks**: ACCESS SHARE, ROW SHARE, ROW EXCLUSIVE, SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE
- Deadlock detection automática com timeout configurável

### 6.2 MySQL/InnoDB

- Locks em nível de linha por padrão
- **Next-Key Locks**: Combina record lock + gap lock para prevenir phantom reads
- **Gap Locks**: Travam o espaço entre registros para prevenir inserts
- **Record Locks**: Travam registros individuais
- **Auto-increment lock**: Lock especial para sequências auto-increment

### 6.3 SQL Server

- Usa lock escalation automaticamente (row → page → table) baseado em threshold
- **Lock modes**: mais granulares (S, X, IS, IX, SIX, U, etc.)
- **Lock hints**: WITH (NOLOCK), WITH (UPDLOCK), WITH (XLOCK), etc.
- **Snapshot isolation**: MVCC-like com row versioning

## 7. Lock Escalation

Lock escalation é o processo de converter muitos locks de granularidade fina em um lock de granularidade mais grossa para reduzir overhead de memória.

**Exemplo**: 1000 row locks → 1 table lock

- **Vantagem**: Reduz memória usada para gerenciar locks
- **Desvantagem**: Reduz concorrência drasticamente
- **Configuração**: Geralmente configurável (ex: SQL Server tem threshold de 5000 locks)

## 8. Boas Práticas para Locks em Sistemas de Alta Concorrência

### 8.1 Escolha o Isolation Level Adequado

- **READ COMMITTED**: Padrão, bom equilíbrio entre consistência e performance
- **REPEATABLE READ**: Quando precisa de leituras consistentes dentro da transação
- **SERIALIZABLE**: Máxima consistência, mas com alto custo de performance e retries

### 8.2 Minimize o Tempo de Lock

- Mantenha transações curtas
- Evite operações demoradas dentro de transações (chamadas de API externa, processamento pesado)
- Faça commits frequentes em batch operations

### 8.3 Use Locks Explícitos com Cautela

- Só use FOR UPDATE quando realmente necessário
- Considere optimistic locking (version columns) em vez de pessimistic locking quando apropriado
- Em sistemas de crédito, use FOR UPDATE para operações críticas (aprovacao, reserva de saldo)

### 8.4 Monitore Lock Contention

```sql
-- PostgreSQL: view locks ativos
SELECT * FROM pg_locks WHERE relation IS NOT NULL;

-- PostgreSQL: transações bloqueando outras
SELECT blocked_locks.pid AS blocked_pid,
       blocked_activity.usename AS blocked_user,
       blocking_locks.pid AS blocking_pid,
       blocking_activity.usename AS blocking_user
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.GRANTED;
```

### 8.5 Considere Alternativas a Locks

- **Optimistic Locking**: Use version columns e verifique conflitos no update
- **Queue-based processing**: Para operações que precisam serialização estrita
- **Partitioning**: Reduz contenção dividindo dados em partições
- **Read replicas**: Offload leituras para reduzir lock contention

## 9. Exemplo Prático: Sistema de Crédito

```sql
-- Cenário: Aprovação de crédito com verificação de limite agregado
-- Problema: Duas aprovações concorrentes podem exceder o limite total

-- Solução 1: Pessimistic locking com FOR UPDATE
BEGIN;
-- Trava as linhas relevantes para evitar que outras transações as modifiquem
SELECT SUM(approved_amount) as total 
FROM credit_approvals 
WHERE customer_id = 123 
AND status = 'approved'
FOR UPDATE;

-- Verifica se nova aprovação excede limite
-- Se passar, insere nova aprovação
INSERT INTO credit_approvals (customer_id, amount, status) 
VALUES (123, 5000, 'approved');
COMMIT;

-- Solução 2: Optimistic locking com version column
UPDATE credit_approvals 
SET approved_amount = approved_amount + 5000,
    version = version + 1
WHERE customer_id = 123 
AND version = 5; -- versão que você leu

-- Se rows_affected = 0, houve conflito — precisa retry
```

## 10. Lock Timeout e Retry

Configurar timeouts apropriados é crucial para evitar que transações fiquem esperando indefinidamente:

```sql
-- PostgreSQL: set lock timeout
SET lock_timeout = '5s'; -- aborta se não conseguir lock em 5 segundos

-- MySQL: set lock timeout
SET innodb_lock_wait_timeout = 5;

-- Na aplicação: implement retry com exponential backoff
for attempt in range(3):
    try:
        execute_transaction()
        break
    except DeadlockError:
        sleep(2 ** attempt)  # exponential backoff
        continue
```

### _Links_

- <https://www.postgresql.org/docs/current/explicit-locking.html>
- <https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html>
- <https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-lock-monitor>
- <https://blog.4linux.com.br/entendendo-os-locks-no-postgresql/>
