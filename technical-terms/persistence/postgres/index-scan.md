# Index Scan

Index Scan é um método de acesso do PostgreSQL que usa índices para localizar linhas específicas, permitindo acesso direto aos dados sem ler toda a tabela, ideal para consultas que retornam poucas linhas.

## Definição

Index Scan é uma técnica de acesso que percorre um índice para encontrar TIDs (Tuple IDs) das linhas que correspondem ao predicado da consulta, e então acessa essas linhas diretamente na tabela.

```text
Index Scan = Índice + TIDs + Acesso Direto
```

## Como Funciona

### 1. Processo de Index Scan

```text
1. PostgreSQL percorre o índice (B-tree)
2. Encontra TIDs das linhas correspondentes
3. Acessa linhas diretamente na tabela usando TIDs
4. Retorna linhas que satisfazem o predicado
```

### 2. Tipos de Index Scan

```text
- Index Scan: Percorre índice em ordem
- Index Only Scan: Apenas índice, sem acesso à tabela
- Index Scan Backward: Percorre índice em ordem reversa
```

### 3. Estrutura do Índice

```text
- B-tree: Estrutura balanceada
- Chaves ordenadas: Permite busca eficiente
- TIDs: Ponteiros para linhas na tabela
```

## Quando o PostgreSQL Usa Index Scan

### 1. Predicados Seletivos

```sql
-- Query com predicado muito seletivo
SELECT * FROM orders 
WHERE order_id = 12345;

-- PostgreSQL usa index scan em order_id
-- Poucas linhas retornadas
```

### 2. ORDER BY com Índice

```sql
-- Query com ORDER BY em coluna indexada
SELECT * FROM orders 
WHERE customer_id = 123
ORDER BY created_at;

-- PostgreSQL pode usar index scan em created_at
-- Evita sort adicional
```

### 3. JOIN com Índice

```sql
-- Query com JOIN usando índice
SELECT o.*, c.name 
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed';

-- PostgreSQL pode usar index scan em customer_id
-- Eficiente para JOIN
```

## Tipos de Índices

### 1. B-tree Index

```sql
-- Índice padrão, mais comum
CREATE INDEX idx_orders_id ON orders(order_id);

-- Bom para:
-- - Igualdade (=)
-- - Range (>, <, BETWEEN)
-- - ORDER BY
```

### 2. Hash Index

```sql
-- Índice para igualdade apenas
CREATE INDEX idx_orders_status ON orders USING HASH (status);

-- Bom para:
-- - Igualdade (=)
-- - Não suporta range ou ORDER BY
```

### 3. GIN Index

```sql
-- Índice para arrays e JSONB
CREATE INDEX idx_orders_tags ON orders USING GIN (tags);

-- Bom para:
-- - Arrays
-- - JSONB
-- - Full-text search
```

### 4. GiST Index

```sql
-- Índice para dados espaciais
CREATE INDEX idx_locations_geo ON locations USING GIST (geo);

-- Bom para:
-- - Dados espaciais
-- - Range types
```

## Exemplo Prático

### Query com Index Scan

```sql
-- Criar índice
CREATE INDEX idx_orders_id ON orders(order_id);

-- Query
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE order_id = 12345;

-- Plano:
Index Scan using idx_orders_id on orders  (cost=...)
  Index Cond: (order_id = 12345)
```

### Index Only Scan

```sql
-- Criar índice covering
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- Query que usa apenas colunas do índice
EXPLAIN ANALYZE
SELECT customer_id, status 
FROM orders 
WHERE customer_id = 123;

-- Plano:
Index Only Scan using idx_orders_customer_status on orders  (cost=...)
  Index Cond: (customer_id = 123)
```

### Index Scan Backward

```sql
-- Query com ORDER BY DESC
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE customer_id = 123
ORDER BY created_at DESC;

-- Plano:
Index Scan Backward using idx_orders_created on orders  (cost=...)
  Index Cond: (customer_id = 123)
```

## Vantagens

### 1. Acesso Direto

```text
- Não lê toda a tabela
- Apenas linhas relevantes
- Menor I/O de disco
```

### 2. Ordenação Natural

```text
- Índices são ordenados
- Evita sort adicional
- Melhor performance para ORDER BY
```

### 3. Eficiente para Poucas Linhas

```text
- Ideal para predicados seletivos
- Menos overhead que bitmap scan
- Mais rápido que sequential scan
```

## Limitações

### 1. Acesso Aleatório

```text
- Acesso não sequencial ao disco
- Mais latência que acesso sequencial
- Menos eficiente para muitas linhas
```

### 2. Overhead de Índice

```text
- Índices ocupam espaço
- Custo de manutenção (INSERT/UPDATE/DELETE)
- Mais overhead que sequential scan
```

### 3. Não Funciona para Predicados Não Seletivos

```sql
-- Predicado não seletivo
SELECT * FROM orders 
WHERE status = 'pending';

-- Se status = 'pending' retorna muitas linhas
-- PostgreSQL pode preferir sequential scan
```

## Melhores Práticas

### 1. Criar Índices para Colunas Frequentemente Usadas

```sql
-- Criar índices para colunas em WHERE
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Criar índices para colunas em JOIN
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_customers_id ON customers(id);
```

### 2. Usar Índices Compostos para Padrões Comuns

```sql
-- Índice composto para padrões comuns
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- Eficiente para:
SELECT * FROM orders WHERE customer_id = 123 AND status = 'completed';
SELECT * FROM orders WHERE customer_id = 123 ORDER BY status;
```

### 3. Considerar Partial Indexes

```sql
-- Índice parcial para subset de dados
CREATE INDEX idx_orders_active ON orders(customer_id)
WHERE status = 'active';

-- Menor índice, mais eficiente para subset
```

### 4. Analisar Plano de Execução

```sql
-- Usar EXPLAIN ANALYZE para entender plano
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 123;

-- Verificar se index scan está sendo usado
-- Ajustar índices se necessário
```

## Trade-offs

### Index Scan vs Sequential Scan

- **Index Scan**: Menos I/O, mais overhead, aleatório
- **Seq Scan**: Mais I/O, menos overhead, sequencial
- **Escolha**: Index para <5% da tabela, seq para >5%

### Index Scan vs Bitmap Scan

- **Index Scan**: Poucas linhas, acesso aleatório, sem overhead de bitmap
- **Bitmap Scan**: Muitas linhas, acesso sequencial, overhead de bitmap
- **Escolha**: Index para <5% da tabela, bitmap para 5-50%

### B-tree vs Hash

- **B-tree**: Suporta range e ORDER BY, mais overhead
- **Hash**: Apenas igualdade, menos overhead
- **Escolha**: B-tree para geral, hash para igualdade apenas

### Single Column vs Composite Index

- **Single column**: Mais flexível, menos específico
- **Composite**: Mais específico, menos flexível
- **Escolha**: Single para queries variadas, composto para padrões fixos

### _Links_

- <https://www.postgresql.org/docs/current/indexes-types.html>
- <https://www.postgresql.org/docs/current/indexes.html>
- <https://www.postgresql.org/docs/current/using-explain.html>
