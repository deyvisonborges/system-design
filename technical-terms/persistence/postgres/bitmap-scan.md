# Bitmap Scan

Bitmap Scan é um método de acesso do PostgreSQL que combina múltiplos índices para encontrar linhas, usando bitmaps para representar a presença de linhas em páginas de dados, permitindo acesso eficiente a disco.

## Definição

Bitmap Scan é uma técnica de acesso que usa bitmaps para representar quais linhas em páginas de dados correspondem a predicados de consulta, permitindo acesso sequencial otimizado ao disco.

```text
Bitmap Scan = Índices + Bitmaps + Acesso Sequencial
```

## Como Funciona

### 1. Processo de Bitmap Scan

```text
1. PostgreSQL usa índices para encontrar TIDs (Tuple IDs)
2. Cria bitmaps representando páginas de dados
3. Combina bitmaps com operações lógicas (AND, OR)
4. Acessa páginas de dados sequencialmente
5. Filtra linhas que não correspondem
```

### 2. Estrutura do Bitmap

```text
- Cada bit representa uma página de dados
- Bit = 1: página contém linhas correspondentes
- Bit = 0: página não contém linhas correspondentes
- Permite acesso sequencial ao disco
```

### 3. Combinação de Bitmaps

```text
- Bitmap AND: Interseção de predicados
- Bitmap OR: União de predicados
- Bitmap NOT: Exclusão de predicados
```

## Quando o PostgreSQL Usa Bitmap Scan

### 1. Múltiplos Índices

```sql
-- Query com múltiplos predicados indexados
SELECT * FROM orders 
WHERE customer_id = 123 
  AND status = 'completed'
  AND created_at > '2024-01-01';

-- PostgreSQL pode usar bitmap scan combinando:
-- - Índice em customer_id
-- - Índice em status
-- - Índice em created_at
```

### 2. Índices Seletivos

```sql
-- Quando índices são seletivos mas não muito
SELECT * FROM products 
WHERE category = 'electronics' 
  AND price > 1000;

-- Bitmap scan é mais eficiente que:
-- - Index scan individual (muito random I/O)
-- - Seq scan (muitas linhas para filtrar)
```

### 3. OR Conditions

```sql
-- Query com OR conditions
SELECT * FROM orders 
WHERE customer_id = 123 
   OR status = 'pending';

-- Bitmap scan combina:
-- - Bitmap de customer_id = 123
-- - Bitmap de status = 'pending'
-- - Operação OR entre bitmaps
```

## Comparação com Outros Scans

### 1. Bitmap Scan vs Index Scan

```sql
-- Index Scan
-- - Acesso aleatório a páginas
-- - Cada linha acessada individualmente
-- - Bom para poucas linhas

-- Bitmap Scan
-- - Acesso sequencial a páginas
-- - Páginas acessadas em ordem
-- - Bom para muitas linhas espalhadas
```

### 2. Bitmap Scan vs Sequential Scan

```sql
-- Sequential Scan
-- - Lê todas as páginas
-- - Sem uso de índices
-- - Bom para tabelas pequenas ou predicados não seletivos

-- Bitmap Scan
-- - Lê apenas páginas relevantes
-- - Usa índices para filtrar
-- - Bom para tabelas grandes com predicados seletivos
```

## Exemplo Prático

### Query com Bitmap Scan

```sql
-- Criar índices
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);

-- Query
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE customer_id = 123 
  AND status = 'completed'
  AND created_at > '2024-01-01';

-- Plano:
Bitmap Heap Scan on orders  (cost=...)
  Recheck Cond: ((customer_id = 123) AND (status = 'completed') AND (created_at > '2024-01-01'))
  ->  BitmapAnd  (cost=...)
        ->  Bitmap Index Scan on idx_orders_customer
        ->  Bitmap Index Scan on idx_orders_status
        ->  Bitmap Index Scan on idx_orders_created
```

### Configuração de Work_mem

```sql
-- Bitmap scan usa work_mem para armazenar bitmaps
-- Aumentar work_mem para tabelas grandes
SET work_mem = '256MB';

-- Ou configurar permanentemente
ALTER SYSTEM SET work_mem = '256MB';
```

## Vantagens

### 1. Acesso Sequencial

```text
- Menor latência de disco
- Melhor uso de cache
- Mais eficiente que acesso aleatório
```

### 2. Combinação de Índices

```text
- Pode usar múltiplos índices
- Combina predicados eficientemente
- Mais flexível que index scan único
```

### 3. Filtragem Eficiente

```text
- Filtra páginas antes de ler linhas
- Reduz I/O de disco
- Melhor performance para muitas linhas
```

## Limitações

### 1. Overhead de Bitmap

```text
- Criar bitmaps tem custo
- Usa memória (work_mem)
- Pode ser ineficiente para poucas linhas
```

### 2. Recheck Cond

```text
- Deve re-verificar condições
- Linhas podem não corresponder após leitura
- Overhead adicional
```

### 3. Não Funciona com ORDER BY

```sql
-- Bitmap scan não preserva ordem
-- Requer sort adicional para ORDER BY
SELECT * FROM orders 
WHERE customer_id = 123
ORDER BY created_at;

-- Pode usar index scan em created_at em vez de bitmap
```

## Melhores Práticas

### 1. Criar Índices Adequados

```sql
-- Criar índices para colunas usadas em WHERE
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Considerar índices compostos para padrões comuns
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
```

### 2. Ajustar work_mem

```sql
-- Aumentar work_mem para tabelas grandes
SET work_mem = '256MB';

-- Monitorar uso de memória
-- Ajustar conforme necessário
```

### 3. Analisar Plano de Execução

```sql
-- Usar EXPLAIN ANALYZE para entender plano
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 123;

-- Verificar se bitmap scan está sendo usado
-- Ajustar índices se necessário
```

## Trade-offs

### Bitmap Scan vs Index Scan

- **Bitmap Scan**: Melhor para muitas linhas, acesso sequencial
- **Index Scan**: Melhor para poucas linhas, acesso aleatório
- **Escolha**: Bitmap para >5% da tabela, index para <5%

### Bitmap Scan vs Seq Scan

- **Bitmap Scan**: Usa índices, mais overhead, menos I/O
- **Seq Scan**: Sem índices, menos overhead, mais I/O
- **Escolha**: Bitmap para predicados seletivos, seq para não seletivos

### Múltiplos Índices vs Índice Composto

- **Múltiplos índices**: Mais flexível, bitmap scan
- **Índice composto**: Mais específico, index scan
- **Escolha**: Múltiplos para queries variadas, composto para padrões fixos

### _Links_

- <https://www.postgresql.org/docs/current/indexes-bitmap-scans.html>
- <https://www.postgresql.org/docs/current/using-explain.html>
- <https://wiki.postgresql.org/wiki/Performance_Optimization>
