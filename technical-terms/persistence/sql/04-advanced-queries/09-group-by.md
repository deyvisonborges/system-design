# GROUP BY

A cláusula `GROUP BY` é usada para agrupar linhas que têm os mesmos valores em colunas especificadas, geralmente usada com funções de agregação como COUNT, SUM, AVG, etc.

## Sintaxe Básica

```sql
SELECT column1, aggregate_function(column2)
FROM table_name
WHERE condition
GROUP BY column1;
```

## Como Funciona - Passo a Passo

### Passo 1: As linhas são agrupadas

O banco de dados agrupa as linhas baseadas nos valores das colunas especificadas no `GROUP BY`.

### Passo 2: Funções de agregação são aplicadas

Para cada grupo, as funções de agregação (COUNT, SUM, AVG, etc.) são aplicadas.

### Passo 3: Um resultado por grupo é retornado

O banco retorna uma linha por grupo com os resultados das agregações.

## Exemplos Práticos

### Exemplo 1: GROUP BY básico

```sql
-- Contar clientes por cidade
SELECT cidade, COUNT(*) as total_clientes
FROM clientes
GROUP BY cidade;
```

**Explicação detalhada:**

1. O banco agrupa clientes por cidade
2. Para cada cidade, conta o número de clientes
3. Retorna cada cidade com o total de clientes

### Exemplo 2: GROUP BY com múltiplas colunas

```sql
-- Contar clientes por cidade e estado
SELECT cidade, estado, COUNT(*) as total_clientes
FROM clientes
GROUP BY cidade, estado;
```

**Explicação detalhada:**

1. O banco agrupa clientes por cidade E estado
2. Para cada combinação de cidade e estado, conta o número de clientes
3. Retorna cada combinação com o total de clientes

### Exemplo 3: GROUP BY com SUM

```sql
-- Somar valor total de pedidos por cliente
SELECT cliente_id, SUM(valor_total) as total_gasto
FROM pedidos
GROUP BY cliente_id;
```

**Explicação detalhada:**

1. O banco agrupa pedidos por cliente
2. Para cada cliente, soma o valor total dos pedidos
3. Retorna cada cliente com o total gasto

### Exemplo 4: GROUP BY com AVG

```sql
-- Calcular preço médio por categoria
SELECT categoria_id, AVG(preco) as preco_medio
FROM produtos
GROUP BY categoria_id;
```

**Explicação detalhada:**

1. O banco agrupa produtos por categoria
2. Para cada categoria, calcula o preço médio
3. Retorna cada categoria com o preço médio

### Exemplo 5: GROUP BY com HAVING

```sql
-- Encontrar cidades com mais de 10 clientes
SELECT cidade, COUNT(*) as total_clientes
FROM clientes
GROUP BY cidade
HAVING COUNT(*) > 10;
```

**Explicação detalhada:**

1. O banco agrupa clientes por cidade
2. Para cada cidade, conta o número de clientes
3. `HAVING` filtra grupos com mais de 10 clientes
4. Retorna apenas cidades com mais de 10 clientes

## Regras Importantes

### Regra 1: Todas as colunas não agregadas devem estar no GROUP BY

```sql
-- Correto
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- Incorreto (em muitos bancos)
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY cidade;
```

### Regra 2: Ordem de execução

```sql
SELECT cidade, COUNT(*)  -- 4. SELECT é executado
FROM clientes            -- 1. FROM é executado
WHERE ativo = 1         -- 2. WHERE é executado
GROUP BY cidade         -- 3. GROUP BY é executado
HAVING COUNT(*) > 5     -- 5. HAVING é executado
ORDER BY cidade         -- 6. ORDER BY é executado
LIMIT 10;               -- 7. LIMIT é executado
```

### Regra 3: WHERE vs HAVING

- `WHERE`: Filtra linhas antes do agrupamento
- `HAVING`: Filtra grupos após o agrupamento

## Comportamento com NULL

### Cenário 1: GROUP BY com NULL

```sql
SELECT cidade, COUNT(*) as total
FROM clientes
GROUP BY cidade;
```

**Comportamento:**

- NULL é tratado como um valor de grupo
- Linhas com cidade NULL são agrupadas juntas
- Retorna um grupo para NULL

**Resultado:** Se houver 10 clientes com cidade NULL e 5 com cidade "São Paulo", retorna 2 grupos: NULL (10 clientes) e "São Paulo" (5 clientes).

### Cenário 2: Tratando NULL explicitamente

```sql
-- Substituir NULL por 'Desconhecida'
SELECT COALESCE(cidade, 'Desconhecida') as cidade, COUNT(*) as total
FROM clientes
GROUP BY COALESCE(cidade, 'Desconhecida');
```

**Resultado:** NULL é substituído por 'Desconhecida' antes do agrupamento.

## Pros e Contras

### Pros

1. **Agregação**: Permite agregações poderosas

```sql
-- Agregação
SELECT cidade, COUNT(*), SUM(valor) FROM clientes GROUP BY cidade;
```

1. **Análise de dados**: Facilita análise de dados por grupos

```sql
-- Análise
SELECT categoria, AVG(preco) FROM produtos GROUP BY categoria;
```

1. **Flexibilidade**: Combina com HAVING para filtrar grupos

```sql
-- Com HAVING
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade HAVING COUNT(*) > 10;
```

### Contras

1. **Performance**: `GROUP BY` pode ser lento em tabelas grandes

```sql
-- Pode ser lento em tabelas grandes
SELECT coluna, COUNT(*) FROM tabela_grande GROUP BY coluna;
```

1. **Complexidade**: A regra de que colunas não agregadas devem estar no GROUP BY pode ser confusa

2. **Memória**: Requer memória adicional para agrupar linhas

## Cenários a Considerar

### Cenário 1: Agregação simples

**Recomendação:** Usar `GROUP BY` com função de agregação

```sql
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;
```

### Cenário 2: Agregação com múltiplas colunas

**Recomendação:** Usar `GROUP BY` com múltiplas colunas

```sql
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY cidade, estado;
```

### Cenário 3: Filtrar grupos

**Recomendação:** Usar `HAVING`

```sql
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade HAVING COUNT(*) > 10;
```

### Cenário 4: Agregação com JOIN

**Recomendação:** Usar `GROUP BY` após JOIN

```sql
SELECT c.nome, COUNT(p.id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

### Cenário 5: Rollup (subtotal e total)

**Recomendação:** Usar `ROLLUP` ou `GROUPING SETS`

```sql
-- MySQL/PostgreSQL
SELECT cidade, estado, COUNT(*)
FROM clientes
GROUP BY ROLLUP(cidade, estado);
```

## GROUP BY vs Alternativas

### GROUP BY vs DISTINCT

```sql
-- GROUP BY (com agregação)
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- DISTINCT (sem agregação)
SELECT DISTINCT cidade FROM clientes;
```

**Escolha:** `GROUP BY` para agregações, `DISTINCT` para valores únicos.

### GROUP BY vs WINDOW FUNCTIONS

```sql
-- GROUP BY (uma linha por grupo)
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- WINDOW FUNCTION (mantém linhas originais)
SELECT nome, cidade, COUNT(*) OVER (PARTITION BY cidade) FROM clientes;
```

**Escolha:** `GROUP BY` para agregação, `WINDOW FUNCTIONS` para cálculos sem reduzir linhas.

### GROUP BY vs subqueries

```sql
-- GROUP BY
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- Subquery (mais complexo)
SELECT cidade, (SELECT COUNT(*) FROM clientes c2 WHERE c2.cidade = c1.cidade) FROM clientes c1 GROUP BY cidade;
```

**Escolha:** `GROUP BY` é geralmente mais simples e eficiente.

## Dicas de Performance

1. **Use índices**: Índices nas colunas usadas no `GROUP BY` podem melhorar performance

```sql
CREATE INDEX idx_clientes_cidade ON clientes(cidade);

-- Pode usar índice
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;
```

1. **Filtre antes de agrupar**: Use `WHERE` para reduzir o número de linhas antes do `GROUP BY`

```sql
-- Bom (filtra antes)
SELECT cidade, COUNT(*) FROM clientes WHERE ativo = 1 GROUP BY cidade;

-- Ruim (filtra depois)
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade HAVING COUNT(*) > 10;
```

1. **Evite GROUP BY com muitas colunas**: Mais colunas = mais lento

```sql
-- Pode ser lento com muitas colunas
SELECT col1, col2, col3, col4, col5, COUNT(*) FROM tabela GROUP BY col1, col2, col3, col4, col5;
```

1. **Considere materialized views**: Para queries GROUP BY frequentes

```sql
-- PostgreSQL
CREATE MATERIALIZED VIEW mv_clientes_por_cidade AS
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;
```

## Exemplos Avançados

### Exemplo 1: GROUP BY com múltiplas agregações

```sql
-- Estatísticas por categoria
SELECT 
    categoria_id,
    COUNT(*) as total_produtos,
    AVG(preco) as preco_medio,
    MIN(preco) as preco_minimo,
    MAX(preco) as preco_maximo,
    SUM(preco) as soma_precos
FROM produtos
GROUP BY categoria_id;
```

### Exemplo 2: GROUP BY com CASE

```sql
-- Classificar clientes por faixa de gasto
SELECT 
    CASE 
        WHEN total_gasto < 100 THEN 'Baixo'
        WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
        ELSE 'Alto'
    END as faixa_gasto,
    COUNT(*) as total_clientes
FROM (
    SELECT cliente_id, SUM(valor_total) as total_gasto
    FROM pedidos
    GROUP BY cliente_id
) t
GROUP BY 
    CASE 
        WHEN total_gasto < 100 THEN 'Baixo'
        WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
        ELSE 'Alto'
    END;
```

### Exemplo 3: GROUP BY com JOIN

```sql
-- Total de vendas por categoria
SELECT 
    c.nome as categoria,
    SUM(p.valor_total) as total_vendas
FROM categorias c
JOIN produtos p ON c.id = p.categoria_id
JOIN itens_pedido ip ON p.id = ip.produto_id
JOIN pedidos ped ON ip.pedido_id = ped.id
GROUP BY c.id, c.nome;
```

### Exemplo 4: GROUP BY com ROLLUP

```sql
-- Subtotal e total por cidade e estado
SELECT 
    cidade,
    estado,
    COUNT(*) as total_clientes
FROM clientes
GROUP BY ROLLUP(cidade, estado);
```

**Explicação:** `ROLLUP` cria subtotais e totais automaticamente.

### Exemplo 5: GROUP BY com CUBE

```sql
-- Todas as combinações possíveis
SELECT 
    cidade,
    estado,
    COUNT(*) as total_clientes
FROM clientes
GROUP BY CUBE(cidade, estado);
```

**Explicação:** `CUBE` cria todas as combinações possíveis de agrupamento.

## GROUP BY com HAVING - Detalhes Importantes

### WHERE vs HAVING

```sql
-- WHERE (filtra antes do GROUP BY)
SELECT cidade, COUNT(*) 
FROM clientes 
WHERE ativo = 1 
GROUP BY cidade;

-- HAVING (filtra após o GROUP BY)
SELECT cidade, COUNT(*) 
FROM clientes 
GROUP BY cidade 
HAVING COUNT(*) > 10;
```

**Escolha:** Use `WHERE` para filtrar linhas, `HAVING` para filtrar grupos.

### HAVING com agregações

```sql
-- Filtrar grupos baseado em agregação
SELECT cidade, COUNT(*) as total
FROM clientes
GROUP BY cidade
HAVING COUNT(*) > 10;
```

### HAVING sem agregação

```sql
-- Equivalente a WHERE
SELECT cidade, COUNT(*) as total
FROM clientes
GROUP BY cidade
HAVING cidade = 'São Paulo';

-- Melhor usar WHERE
SELECT cidade, COUNT(*) as total
FROM clientes
WHERE cidade = 'São Paulo'
GROUP BY cidade;
```

## GROUP BY em Diferentes Bancos

### MySQL

```sql
-- GROUP BY básico
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- GROUP BY com ROLLUP
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY ROLLUP(cidade, estado);
```

### PostgreSQL

```sql
-- GROUP BY básico
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- GROUP BY com ROLLUP
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY ROLLUP(cidade, estado);

-- GROUP BY com GROUPING SETS
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY GROUPING SETS ((cidade, estado), (cidade), ());
```

### SQL Server

```sql
-- GROUP BY básico
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- GROUP BY WITH ROLLUP (legado)
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY cidade, estado WITH ROLLUP;

-- GROUP BY WITH CUBE (legado)
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY cidade, estado WITH CUBE;
```

## Resumo

- **Use GROUP BY quando**: Precisa de agregações, análise por grupos, filtrar grupos
- **Evite GROUP BY quando**: Apenas valores únicos (use DISTINCT), performance é crítica
- **Alternativas**: DISTINCT para valores únicos, WINDOW FUNCTIONS para cálculos sem reduzir linhas
- **NULL**: NULL é tratado como um valor de grupo
- **Performance**: GROUP BY pode ser lento em tabelas grandes, use índices e WHERE para melhorar
- **HAVING**: HAVING filtra grupos após o agrupamento, WHERE filtra linhas antes
- **Regra de ouro**: GROUP BY para agregações, DISTINCT para valores únicos
