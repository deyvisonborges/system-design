# CTE (Common Table Expression)

A CTE (Common Table Expression) é uma expressão de tabela temporária que pode ser referenciada dentro de uma instrução SELECT, INSERT, UPDATE ou DELETE. É definida usando a cláusula `WITH` e melhora a legibilidade e manutenção de consultas complexas.

## Sintaxe Básica

```sql
WITH nome_cte AS (
    -- Consulta que define a CTE
    SELECT coluna1, coluna2
    FROM tabela
    WHERE condicao
)
-- Consulta principal que usa a CTE
SELECT *
FROM nome_cte;
```

## Como Funciona - Passo a Passo

### Passo 1: Definição da CTE

A CTE é definida com a cláusula `WITH` e um nome. A consulta dentro da CTE é executada primeiro.

### Passo 2: Execução da CTE

A consulta da CTE é executada e o resultado é armazenado temporariamente como uma tabela virtual.

### Passo 3: Uso da CTE

A consulta principal pode referenciar a CTE como se fosse uma tabela normal.

### Passo 4: Múltiplas CTEs

É possível definir múltiplas CTEs separadas por vírgulas.

## Exemplos Práticos

### Exemplo 1: CTE básico

```sql
-- Calcular total de pedidos por cliente
WITH total_pedidos AS (
    SELECT cliente_id, SUM(valor_total) as total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT c.nome, tp.total
FROM clientes c
JOIN total_pedidos tp ON c.id = tp.cliente_id;
```

**Explicação detalhada:**

1. A CTE `total_pedidos` é definida e calcula o total de pedidos por cliente
2. A CTE é executada primeiro, agrupando pedidos por cliente_id
3. A consulta principal junta clientes com o resultado da CTE
4. Retorna o nome do cliente com o total gasto

### Exemplo 2: CTE com múltiplas definições

```sql
-- Comparar vendas de dois meses
WITH vendas_janeiro AS (
    SELECT produto_id, SUM(quantidade) as qtd_jan
    FROM vendas
    WHERE data BETWEEN '2024-01-01' AND '2024-01-31'
    GROUP BY produto_id
),
vendas_fevereiro AS (
    SELECT produto_id, SUM(quantidade) as qtd_fev
    FROM vendas
    WHERE data BETWEEN '2024-02-01' AND '2024-02-29'
    GROUP BY produto_id
)
SELECT p.nome, vj.qtd_jan, vf.qtd_fev
FROM produtos p
LEFT JOIN vendas_janeiro vj ON p.id = vj.produto_id
LEFT JOIN vendas_fevereiro vf ON p.id = vf.produto_id;
```

**Explicação detalhada:**

1. A primeira CTE `vendas_janeiro` calcula vendas de janeiro
2. A segunda CTE `vendas_fevereiro` calcula vendas de fevereiro
3. A consulta principal junta produtos com ambas as CTEs
4. Retorna nome do produto com quantidades de ambos os meses

### Exemplo 3: CTE recursiva

```sql
-- Calcular hierarquia de funcionários
WITH RECURSIVE hierarquia AS (
    -- Caso base: funcionários sem gerente
    SELECT id, nome, gerente_id, 1 as nivel
    FROM funcionarios
    WHERE gerente_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo: funcionários com gerente
    SELECT f.id, f.nome, f.gerente_id, h.nivel + 1
    FROM funcionarios f
    JOIN hierarquia h ON f.gerente_id = h.id
)
SELECT * FROM hierarquia ORDER BY nivel, nome;
```

**Explicação detalhada:**

1. A CTE recursiva começa com o caso base (funcionários sem gerente)
2. A parte recursiva junta funcionários com seus gerentes da CTE
3. A recursão continua até não haver mais correspondências
4. Retorna a hierarquia completa com níveis

### Exemplo 4: CTE para reutilização

```sql
-- Calcular estatísticas em múltiplas agregações
WITH vendas_por_cliente AS (
    SELECT cliente_id, COUNT(*) as num_pedidos, SUM(valor_total) as total_gasto
    FROM pedidos
    GROUP BY cliente_id
)
SELECT 
    AVG(num_pedidos) as media_pedidos,
    AVG(total_gasto) as media_gasto,
    MAX(num_pedidos) as max_pedidos
FROM vendas_por_cliente;
```

**Explicação detalhada:**

1. A CTE calcula vendas por cliente
2. A consulta principal usa a CTE para calcular estatísticas agregadas
3. Evita repetir a lógica de agrupamento
4. Retorna médias e máximos

### Exemplo 5: CTE com filtragem

```sql
-- Encontrar clientes acima da média
WITH media_gasto AS (
    SELECT AVG(valor_total) as media
    FROM pedidos
),
total_cliente AS (
    SELECT cliente_id, SUM(valor_total) as total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT c.nome, tc.total
FROM clientes c
JOIN total_cliente tc ON c.id = tc.cliente_id
CROSS JOIN media_gasto mg
WHERE tc.total > mg.media;
```

**Explicação detalhada:**

1. A primeira CTE calcula a média de gastos
2. A segunda CTE calcula total por cliente
3. A consulta principal junta clientes com total e média
4. Filtra clientes acima da média

## Comportamento com NULL

### Cenário 1: CTE com NULL

```sql
WITH dados AS (
    SELECT nome, email
    FROM clientes
    WHERE email IS NULL
)
SELECT * FROM dados;
```

**Comportamento:**

- A CTE pode retornar linhas com NULL
- NULL é tratado normalmente na CTE e na consulta principal

### Cenário 2: CTE recursiva com NULL

```sql
WITH RECURSIVE hierarquia AS (
    SELECT id, nome, gerente_id
    FROM funcionarios
    WHERE gerente_id IS NULL
    
    UNION ALL
    
    SELECT f.id, f.nome, f.gerente_id
    FROM funcionarios f
    JOIN hierarquia h ON f.gerente_id = h.id
)
SELECT * FROM hierarquia;
```

**Comportamento:**

- NULL em gerente_id é tratado como condição de parada
- A recursão funciona corretamente com NULL

## Pros e Contras

### Pros

1. **Legibilidade**: CTEs tornam consultas complexas mais legíveis

```sql
-- Mais legível com CTE
WITH total_pedidos AS (
    SELECT cliente_id, SUM(valor_total) as total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT c.nome, tp.total
FROM clientes c
JOIN total_pedidos tp ON c.id = tp.cliente_id;
```

1. **Reutilização**: CTEs podem ser reutilizadas múltiplas vezes na mesma consulta

```sql
-- Reutilização da CTE
WITH vendas AS (
    SELECT cliente_id, SUM(valor_total) as total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT * FROM vendas WHERE total > 1000
UNION ALL
SELECT * FROM vendas WHERE total < 100;
```

1. **Manutenção**: CTEs facilitam manutenção de consultas complexas

### Contras

1. **Performance**: CTEs podem não ser materializadas (depende do banco)

```sql
-- Pode não ser materializado
WITH dados AS (
    SELECT * FROM tabela_larga
)
SELECT * FROM dados WHERE condicao;
```

1. **Escopo**: CTEs só existem dentro da consulta onde são definidas

2. **Complexidade**: CTEs recursivas podem ser difíceis de entender

## Cenários a Considerar

### Cenário 1: Consultas complexas com múltiplas etapas

**Recomendação:** Usar CTE

```sql
WITH etapa1 AS (SELECT ...),
     etapa2 AS (SELECT ...),
     etapa3 AS (SELECT ...)
SELECT * FROM etapa3;
```

### Cenário 2: Reutilização de subquery

**Recomendação:** Usar CTE

```sql
WITH dados AS (SELECT ...)
SELECT * FROM dados WHERE cond1
UNION ALL
SELECT * FROM dados WHERE cond2;
```

### Cenário 3: Hierarquias e grafos

**Recomendação:** Usar CTE recursiva

```sql
WITH RECURSIVE hierarquia AS (...)
SELECT * FROM hierarquia;
```

### Cenário 4: Performance crítica

**Recomendação:** Considerar subquery ou tabela temporária

```sql
-- Subquery pode ser mais eficiente
SELECT * FROM (SELECT ...) WHERE condicao;
```

## CTE vs Alternativas

### CTE vs Subquery

```sql
-- CTE (mais legível)
WITH dados AS (SELECT cliente_id, SUM(valor) as total FROM pedidos GROUP BY cliente_id)
SELECT * FROM dados WHERE total > 1000;

-- Subquery (mais compacta)
SELECT * FROM (SELECT cliente_id, SUM(valor) as total FROM pedidos GROUP BY cliente_id) dados WHERE total > 1000;
```

**Escolha:** CTE para legibilidade e reutilização, subquery para consultas simples.

### CTE vs Tabela Temporária

```sql
-- CTE (escopo limitado)
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- Tabela temporária (persiste na sessão)
CREATE TEMP TABLE dados AS SELECT ...;
SELECT * FROM dados;
DROP TABLE dados;
```

**Escolha:** CTE para uso único na consulta, tabela temporária para múltiplas consultas.

### CTE vs View

```sql
-- CTE (temporário)
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- View (persistente)
CREATE VIEW dados AS SELECT ...;
SELECT * FROM dados;
```

**Escolha:** CTE para consulta específica, view para reutilização entre sessões.

## Dicas de Performance

1. **Índices**: CTEs podem usar índices das tabelas originais

```sql
-- Pode usar índice em cliente_id
WITH dados AS (
    SELECT cliente_id, SUM(valor) as total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT * FROM dados;
```

1. **Materialização**: Alguns bancos materializam CTEs, outros não

```sql
-- PostgreSQL: pode usar MATERIALIZED
WITH dados AS MATERIALIZED (SELECT ...)
SELECT * FROM dados;
```

1. **Evite CTEs desnecessárias**: Para consultas simples, subquery pode ser mais eficiente

```sql
-- CTE desnecessário
WITH dados AS (SELECT * FROM tabela)
SELECT * FROM dados WHERE id = 1;

-- Mais eficiente
SELECT * FROM tabela WHERE id = 1;
```

1. **CTE recursiva**: Limite a profundidade para evitar loops infinitos

```sql
-- PostgreSQL: limite de profundidade
WITH RECURSIVE hierarquia AS (...)
SELECT * FROM hierarquia;
```

## Exemplos Avançados

### Exemplo 1: CTE com window function

```sql
-- Calcular ranking com CTE
WITH vendas_por_cliente AS (
    SELECT cliente_id, SUM(valor_total) as total
    FROM pedidos
    GROUP BY cliente_id
),
ranking AS (
    SELECT cliente_id, total,
           RANK() OVER (ORDER BY total DESC) as posicao
    FROM vendas_por_cliente
)
SELECT c.nome, r.total, r.posicao
FROM clientes c
JOIN ranking r ON c.id = r.cliente_id
ORDER BY r.posicao;
```

### Exemplo 2: CTE para data manipulation

```sql
-- Atualizar dados usando CTE
WITH clientes_inativos AS (
    SELECT id
    FROM clientes
    WHERE id NOT IN (SELECT DISTINCT cliente_id FROM pedidos WHERE data_pedido > CURRENT_DATE - INTERVAL '1 year')
)
UPDATE clientes
SET status = 'inativo'
WHERE id IN (SELECT id FROM clientes_inativos);
```

### Exemplo 3: CTE com DELETE

```sql
-- Deletar duplicados usando CTE
WITH duplicados AS (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn
    FROM clientes
)
DELETE FROM clientes
WHERE id IN (SELECT id FROM duplicados WHERE rn > 1);
```

### Exemplo 4: CTE múltipla com JOIN

```sql
-- Análise complexa com múltiplas CTEs
WITH vendas_mensais AS (
    SELECT DATE_TRUNC('month', data_pedido) as mes, SUM(valor_total) as total
    FROM pedidos
    GROUP BY DATE_TRUNC('month', data_pedido)
),
media_mensal AS (
    SELECT AVG(total) as media
    FROM vendas_mensais
)
SELECT vm.mes, vm.total, mm.media,
       CASE WHEN vm.total > mm.media THEN 'Acima' ELSE 'Abaixo' END as status
FROM vendas_mensais vm
CROSS JOIN media_mensal mm;
```

### Exemplo 5: CTE recursiva para caminho

```sql
-- Calcular caminho completo em hierarquia
WITH RECURSIVE caminho AS (
    SELECT id, nome, gerente_id, nome as caminho_completo
    FROM funcionarios
    WHERE gerente_id IS NULL
    
    UNION ALL
    
    SELECT f.id, f.nome, f.gerente_id, CONCAT(h.caminho_completo, ' > ', f.nome)
    FROM funcionarios f
    JOIN caminho h ON f.gerente_id = h.id
)
SELECT * FROM caminho ORDER BY caminho_completo;
```

## CTE em Diferentes Bancos

### PostgreSQL

```sql
-- CTE padrão
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- CTE materializada (PostgreSQL 12+)
WITH dados AS MATERIALIZED (SELECT ...)
SELECT * FROM dados;

-- CTE não materializada
WITH dados AS NOT MATERIALIZED (SELECT ...)
SELECT * FROM dados;

-- CTE recursiva
WITH RECURSIVE dados AS (...)
SELECT * FROM dados;
```

### MySQL

```sql
-- CTE padrão (MySQL 8.0+)
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- CTE recursiva (MySQL 8.0+)
WITH RECURSIVE dados AS (...)
SELECT * FROM dados;
```

### SQL Server

```sql
-- CTE padrão
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- CTE recursiva
WITH dados AS (...)
SELECT * FROM dados;
```

### Oracle

```sql
-- CTE padrão
WITH dados AS (SELECT ...)
SELECT * FROM dados;

-- CTE recursiva
WITH dados AS (...)
SELECT * FROM dados;
```

## Resumo

- **Use CTE quando**: Consultas complexas, reutilização de subquery, hierarquias, melhoria de legibilidade
- **Evite CTE quando**: Consultas simples (use subquery direta), performance crítica (considere tabela temporária)
- **Alternativas**: Subquery para consultas simples, tabela temporária para múltiplas consultas, view para persistência
- **Performance**: CTEs podem não ser materializadas, use índices das tabelas originais
- **Compatibilidade**: CTE suportado em PostgreSQL, MySQL 8.0+, SQL Server, Oracle
- **Recursão**: Use CTE recursiva para hierarquias e grafos
- **Regra de ouro**: CTE para legibilidade e manutenção, subquery para simplicidade
