# Partitioning

Partitioning (particionamento) é uma técnica do PostgreSQL que divide uma tabela grande em tabelas menores e mais gerenciáveis chamadas partições, mantendo a aparência de uma única tabela para a aplicação.

## Definição

Partitioning é o processo de dividir uma tabela lógica em múltiplas tabelas físicas menores baseadas em valores de uma coluna de chave de partição, melhorando performance e gerenciamento de dados.

```text
Partitioning = Tabela lógica → Múltiplas tabelas físicas
```

## Tipos de Partitioning

### 1. Range Partitioning

```sql
-- Particionamento por intervalo de valores
CREATE TABLE orders (
    id SERIAL,
    order_date DATE NOT NULL,
    customer_id INT,
    amount NUMERIC
) PARTITION BY RANGE (order_date);

-- Criar partições
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Bom para:
-- - Dados temporais
-- - Dados sequenciais
-- - Range queries
```

### 2. List Partitioning

```sql
-- Particionamento por lista de valores
CREATE TABLE orders (
    id SERIAL,
    region VARCHAR(50) NOT NULL,
    customer_id INT,
    amount NUMERIC
) PARTITION BY LIST (region);

-- Criar partições
CREATE TABLE orders_north PARTITION OF orders
    FOR VALUES IN ('north', 'northeast');

CREATE TABLE orders_south PARTITION OF orders
    FOR VALUES IN ('south', 'southeast');

-- Bom para:
-- - Categorias discretas
-- - Regiões geográficas
-- - Tipos de produtos
```

### 3. Hash Partitioning

```sql
-- Particionamento por hash
CREATE TABLE orders (
    id SERIAL,
    customer_id INT NOT NULL,
    order_date DATE,
    amount NUMERIC
) PARTITION BY HASH (customer_id);

-- Criar partições
CREATE TABLE orders_p0 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE orders_p1 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

-- Bom para:
-- - Distribuição uniforme
-- - Quando não há padrão óbvio
-- - Balanceamento de carga
```

## Vantagens

### 1. Performance

```text
- Queries acessam apenas partições relevantes
- Índices são menores por partição
- Menos I/O para queries filtradas
- Melhor cache hit rate
```

### 2. Gerenciamento

```text
- Facilita manutenção de dados antigos
- Pode dropar partições antigas rapidamente
- Backup e restore por partição
- Vacuum mais eficiente
```

### 3. Escalabilidade

```text
- Distribui dados em múltiplos tablespaces
- Pode colocar partições em discos diferentes
- Melhor uso de recursos
```

## Limitações

### 1. Chave Primária

```sql
-- Chave primária deve incluir chave de partição
-- Isso é obrigatório

-- Ruim:
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,  -- Não inclui order_date
    order_date DATE NOT NULL
) PARTITION BY RANGE (order_date);
-- Erro!

-- Bom:
CREATE TABLE orders (
    id SERIAL,
    order_date DATE NOT NULL,
    PRIMARY KEY (id, order_date)  -- Inclui order_date
) PARTITION BY RANGE (order_date);
```

### 2. Unique Constraints

```sql
-- Unique constraints devem incluir chave de partição
-- Limita flexibilidade de constraints

-- Ruim:
CREATE TABLE orders (
    id SERIAL,
    order_number VARCHAR(50) UNIQUE,  -- Não inclui chave de partição
    order_date DATE NOT NULL
) PARTITION BY RANGE (order_date);
-- Erro!

-- Bom:
CREATE TABLE orders (
    id SERIAL,
    order_number VARCHAR(50),
    order_date DATE NOT NULL,
    UNIQUE (order_number, order_date)  -- Inclui chave de partição
) PARTITION BY RANGE (order_date);
```

### 3. Foreign Keys

```sql
-- Foreign keys não podem referenciar tabelas particionadas
-- Limita relacionamentos

-- Ruim:
CREATE TABLE orders (
    id SERIAL,
    customer_id INT REFERENCES customers(id),
    order_date DATE NOT NULL
) PARTITION BY RANGE (order_date);
-- Erro!

-- Solução:
-- Não usar FK ou usar tabela não particionada
```

## Exemplo Prático

### Tabela de Pedidos Particionada por Data

```sql
-- Criar tabela particionada
CREATE TABLE orders (
    id SERIAL,
    order_date DATE NOT NULL,
    customer_id INT,
    amount NUMERIC,
    status VARCHAR(20),
    PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (order_date);

-- Criar partições trimestrais
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE orders_2024_q3 PARTITION OF orders
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

CREATE TABLE orders_2024_q4 PARTITION OF orders
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Criar índices por partição
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Inserir dados (vai para partição correta automaticamente)
INSERT INTO orders (order_date, customer_id, amount, status)
VALUES ('2024-02-15', 123, 100.00, 'completed');

-- Query usa apenas partição relevante
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-02-01' AND '2024-02-28';

-- Plano mostra apenas partição orders_2024_q1
```

### Particionamento com Subparticionamento

```sql
-- Particionamento por data e região
CREATE TABLE orders (
    id SERIAL,
    order_date DATE NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_id INT,
    amount NUMERIC,
    PRIMARY KEY (id, order_date, region)
) PARTITION BY RANGE (order_date);

-- Criar partições por data
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01')
    PARTITION BY LIST (region);

-- Subpartições por região
CREATE TABLE orders_2024_q1_north PARTITION OF orders_2024_q1
    FOR VALUES IN ('north', 'northeast');

CREATE TABLE orders_2024_q1_south PARTITION OF orders_2024_q1
    FOR VALUES IN ('south', 'southeast');
```

## Gerenciamento de Partições

### 1. Criar Nova Partição

```sql
-- Adicionar partição para novo trimestre
CREATE TABLE orders_2025_q1 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
```

### 2. Remover Partição Antiga

```sql
-- Dropar partição antiga (rápido)
DROP TABLE orders_2023_q4;

-- Ou detach para backup
ALTER TABLE orders DETACH PARTITION orders_2023_q4;
```

### 3. Mover Dados Entre Partições

```sql
-- Mover dados para nova partição
ALTER TABLE orders DETACH PARTITION orders_2024_q1;
-- Modificar dados
ALTER TABLE orders ATTACH PARTITION orders_2024_q1
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
```

## Melhores Práticas

### 1. Escolher Chave de Partição Adequada

```sql
-- Escolher coluna usada frequentemente em WHERE
-- Bom: order_date para queries temporais
-- Bom: region para queries geográficas
-- Ruim: id (não usado em WHERE)
```

### 2. Planejar Partições Antecipadamente

```sql
-- Criar partições futuras antecipadamente
-- Evita erro ao inserir dados fora do range
CREATE TABLE orders_2025_q1 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
```

### 3. Usar Partition Pruning

```sql
-- Queries devem filtrar pela chave de partição
-- Bom:
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Ruim (não usa partition pruning):
SELECT * FROM orders WHERE customer_id = 123;
```

### 4. Monitorar Tamanho das Partições

```sql
-- Verificar tamanho das partições
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE tablename LIKE 'orders_%';
```

## Trade-offs

### Partitioning vs Single Table

- **Partitioning**: Melhor performance para queries filtradas, mais complexo
- **Single table**: Mais simples, pior performance para tabelas grandes
- **Escolha**: Partitioning para >10GB, single para <10GB

### Range vs List vs Hash

- **Range**: Queries temporais, distribuição desigual
- **List**: Categorias discretas, distribuição controlada
- **Hash**: Distribuição uniforme, sem queries otimizadas
- **Escolha**: Range para temporal, list para categorias, hash para balanceamento

### Partitioning vs Sharding

- **Partitioning**: Mesmo servidor, transparência para app
- **Sharding**: Múltiplos servidores, mais complexo
- **Escolha**: Partitioning para single server, sharding para distribuído

### _Links_

- <https://www.postgresql.org/docs/current/ddl-partitioning.html>
- <https://www.postgresql.org/docs/current/sql-createpartitionedtable.html>
- <https://www.postgresql.org/docs/current/sql-altertable.html>
