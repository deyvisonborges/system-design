# Query Planner

Query Planner (planejador de consultas) é o componente do PostgreSQL que determina o plano de execução mais eficiente para uma query SQL, analisando estatísticas, índices e custos para escolher o melhor método de acesso.

## Definição

Query Planner é o otimizador de queries do PostgreSQL que gera planos de execução baseados em custos estimados, escolhendo entre diferentes métodos de acesso (seq scan, index scan, bitmap scan) e ordens de join.

```text
Query Planner = Otimizador + Estatísticas + Custo
```

## Como Funciona

### 1. Processo de Planejamento

```text
1. Parser: Analisa a query SQL
2. Rewriter: Aplica regras de reescrita (views, rules)
3. Planner: Gera planos alternativos
4. Optimizer: Escolhe plano com menor custo
5. Executor: Executa o plano escolhido
```

### 2. Estimativa de Custo

```text
- Custo de I/O: Leitura de páginas do disco
- Custo de CPU: Processamento de linhas
- Custo de memória: Uso de work_mem
- Custo de rede: Para queries distribuídas
```

### 3. Estatísticas

```sql
-- Estatísticas são usadas para estimar seletividade
-- Coletadas por ANALYZE

-- Verificar estatísticas de uma tabela
SELECT * FROM pg_stats WHERE tablename = 'orders';

-- Atualizar estatísticas
ANALYZE orders;

-- Estatísticas incluem:
-- - Número de linhas
-- - Distribuição de valores
-- - Cardinalidade de colunas
```

## Tipos de Planos

### 1. Sequential Scan

```sql
-- Lê toda a tabela sequencialmente
EXPLAIN SELECT * FROM orders;

-- Plano:
Seq Scan on orders  (cost=0.00..1000.00 rows=100000 width=100)

-- Usado quando:
-- - Tabela pequena
-- - Sem índices relevantes
-- - Predicado não seletivo
```

### 2. Index Scan

```sql
-- Usa índice para encontrar linhas
EXPLAIN SELECT * FROM orders WHERE order_id = 12345;

-- Plano:
Index Scan using idx_orders_id on orders  (cost=0.29..8.31 rows=1 width=100)
  Index Cond: (order_id = 12345)

-- Usado quando:
-- - Predicado muito seletivo
-- - Índice disponível
-- - Poucas linhas retornadas
```

### 3. Bitmap Scan

```sql
-- Combina múltiplos índices
EXPLAIN SELECT * FROM orders 
WHERE customer_id = 123 AND status = 'completed';

-- Plano:
Bitmap Heap Scan on orders  (cost=...)
  Recheck Cond: ((customer_id = 123) AND (status = 'completed'))
  ->  BitmapAnd  (cost=...)
        ->  Bitmap Index Scan on idx_orders_customer
        ->  Bitmap Index Scan on idx_orders_status

-- Usado quando:
-- - Múltiplos predicados indexados
-- - Índices seletivos mas não muito
-- - OR conditions
```

## Join Strategies

### 1. Nested Loop Join

```sql
-- Para cada linha da tabela externa, busca correspondente na interna
EXPLAIN SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.order_id = 12345;

-- Plano:
Nested Loop  (cost=...)
  ->  Index Scan using idx_orders_id on orders o
  ->  Index Scan using idx_customers_id on customers c

-- Usado quando:
-- - Uma tabela pequena
-- - Índices disponíveis
-- - Poucas linhas
```

### 2. Hash Join

```sql
-- Cria hash da tabela menor e faz lookup
EXPLAIN SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- Plano:
Hash Join  (cost=...)
  Hash Cond: (o.customer_id = c.id)
  ->  Seq Scan on orders o
  ->  Hash
        ->  Seq Scan on customers c

-- Usado quando:
-- - Tabelas grandes
-- - Sem índices eficientes
-- - Equi-join
```

### 3. Merge Join

```sql
-- Ordena ambas tabelas e faz merge
EXPLAIN SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id
ORDER BY o.customer_id;

-- Plano:
Merge Join  (cost=...)
  Merge Cond: (o.customer_id = c.id)
  ->  Index Scan using idx_orders_customer on orders o
  ->  Sort
        ->  Seq Scan on customers c

-- Usado quando:
-- - Dados já ordenados
-- - Índices ordenados disponíveis
-- - Large datasets
```

## EXPLAIN e EXPLAIN ANALYZE

### 1. EXPLAIN

```sql
-- Mostra plano estimado (sem executar)
EXPLAIN SELECT * FROM orders WHERE customer_id = 123;

-- Saída:
Index Scan using idx_orders_customer on orders  (cost=0.29..8.31 rows=100 width=100)
  Index Cond: (customer_id = 123)
```

### 2. EXPLAIN ANALYZE

```sql
-- Executa e mostra plano real com tempos
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 123;

-- Saída:
Index Scan using idx_orders_customer on orders  (cost=0.29..8.31 rows=100 width=100) (actual time=0.015..0.045 rows=100 loops=1)
  Index Cond: (customer_id = 123)
Planning Time: 0.123 ms
Execution Time: 0.123 ms
```

### 3. EXPLAIN (BUFFERS, ANALYZE)

```sql
-- Inclui estatísticas de buffers
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE customer_id = 123;

-- Saída inclui:
-- - shared hit: cache hit
-- - shared read: disco read
-- - shared dirtied: páginas modificadas
```

## Configuração do Planner

### 1. cost_estimator

```sql
-- Configurar custos de operações
SET seq_page_cost = 1.0;        -- Custo de seq scan
SET random_page_cost = 4.0;     -- Custo de acesso aleatório
SET cpu_tuple_cost = 0.01;      -- Custo de processamento de linha
SET cpu_index_tuple_cost = 0.005; -- Custo de processamento de índice
```

### 2. work_mem

```sql
-- Memória para operações de sort e hash
SET work_mem = '256MB';

-- Aumentar para:
-- - Sorts grandes
-- - Hash joins grandes
-- - Bitmap scans grandes
```

### 3. enable_* settings

```sql
-- Habilitar/desabilitar planos específicos
SET enable_seqscan = off;       -- Desabilita seq scan
SET enable_indexscan = off;     -- Desabilita index scan
SET enable_bitmapscan = off;    -- Desabilita bitmap scan
SET enable_nestloop = off;      -- Desabilita nested loop join
SET enable_hashjoin = off;      -- Desabilita hash join
SET enable_mergejoin = off;     -- Desabilita merge join
```

## Problemas Comuns

### 1. Estatísticas Desatualizadas

```sql
-- Problema: Planner usa estatísticas antigas
-- Solução: Atualizar estatísticas
ANALYZE orders;

-- Ou configurar autovacuum
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;
```

### 2. Custo de Random Page

```sql
-- Problema: SSD vs HDD
-- SSD: random_page_cost deve ser menor
SET random_page_cost = 1.1;  -- Para SSD

-- HDD: random_page_cost deve ser maior
SET random_page_cost = 4.0;  -- Para HDD
```

### 3. work_mem Insuficiente

```sql
-- Problema: Spill to disk (lento)
-- Solução: Aumentar work_mem
SET work_mem = '512MB';

-- Ou configurar por transação
SET LOCAL work_mem = '1GB';
```

## Melhores Práticas

### 1. Manter Estatísticas Atualizadas

```sql
-- Configurar autovacuum automático
ALTER SYSTEM SET autovacuum = on;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;

-- Executar ANALYZE após grandes mudanças
ANALYZE orders;
```

### 2. Criar Índices Adequados

```sql
-- Criar índices para colunas usadas em WHERE
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Criar índices compostos para padrões comuns
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
```

### 3. Analisar Planos de Execução

```sql
-- Usar EXPLAIN ANALYZE regularmente
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE customer_id = 123;

-- Procurar por:
-- - Seq scans inesperados
-- - Nested loops em tabelas grandes
-- - Spill to disk
```

### 4. Ajustar Custo do Planner

```sql
-- Ajustar random_page_cost para SSD
SET random_page_cost = 1.1;

-- Ajustar work_mem para evitar spill
SET work_mem = '256MB';

-- Ajustar effective_cache_size
SET effective_cache_size = '8GB';
```

## Exemplo Prático

### Otimização de Query

```sql
-- Query lenta
EXPLAIN ANALYZE
SELECT o.*, c.name 
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed'
  AND o.created_at > '2024-01-01';

-- Plano inicial (lento):
Seq Scan on orders o  (cost=0.00..50000.00 rows=50000 width=100)
  Filter: (status = 'completed' AND created_at > '2024-01-01')
  ->  Hash Join
        ->  Seq Scan on customers c

-- Criar índices
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Plano otimizado (rápido):
Bitmap Heap Scan on orders o  (cost=...)
  Recheck Cond: ((status = 'completed') AND (created_at > '2024-01-01'))
  ->  BitmapAnd  (cost=...)
        ->  Bitmap Index Scan on idx_orders_status
        ->  Bitmap Index Scan on idx_orders_created
  ->  Index Scan using idx_customers_id on customers c
```

## Trade-offs

### Seq Scan vs Index Scan

- **Seq Scan**: Simples, overhead baixo, lento para tabelas grandes
- **Index Scan**: Overhead alto, rápido para predicados seletivos
- **Escolha**: Seq para <5% da tabela, index para >5%

### Nested Loop vs Hash Join

- **Nested Loop**: Bom para tabelas pequenas, usa índices
- **Hash Join**: Bom para tabelas grandes, usa memória
- **Escolha**: Nested loop para pequeno, hash para grande

### Merge Join vs Hash Join

- **Merge Join**: Requer ordenação, bom para dados ordenados
- **Hash Join**: Requer memória, bom para dados não ordenados
- **Escolha**: Merge para ordenado, hash para não ordenado

### _Links_

- <https://www.postgresql.org/docs/current/sql-explain.html>
- <https://www.postgresql.org/docs/current/runtime-config-query.html>
- <https://www.postgresql.org/docs/current/routine-vacuuming.html>
