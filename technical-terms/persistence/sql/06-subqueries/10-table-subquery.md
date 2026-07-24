# Table Subquery

Uma Table Subquery (Subquery de Tabela) é uma subquery que retorna múltiplas linhas e múltiplas colunas, funcionando como uma tabela temporária. Ela é usada na cláusula FROM para criar uma tabela derivada, permitindo manipular o resultado da subquery como se fosse uma tabela real.

## Sintaxe Básica

```sql
SELECT t.coluna1, t.coluna2
FROM (SELECT coluna1, coluna2, coluna3 FROM tabela WHERE condicao) as t
WHERE t.coluna1 > 100;
```

## Como Funciona - Passo a Passo

### Passo 1: Execução da subquery

A subquery é executada e retorna um conjunto de resultados (tabela derivada).

### Passo 2: Criação da tabela derivada

O resultado da subquery é tratado como uma tabela temporária.

### Passo 3: Aplicação da query principal

A query principal opera sobre a tabela derivada como se fosse uma tabela real.

### Passo 4: Retorno do resultado

O resultado final é retornado após todas as operações.

## Exemplos Práticos

### Exemplo 1: Table subquery básica

```sql
-- Calcular média salarial por departamento e filtrar
SELECT departamento, media_salario
FROM (
    SELECT departamento, AVG(salario) as media_salario
    FROM funcionarios
    GROUP BY departamento
) as dept_media
WHERE media_salario > 5000;
```

**Explicação detalhada:**

1. A subquery calcula a média salarial por departamento
2. O resultado é tratado como tabela derivada `dept_media`
3. A query principal filtra departamentos com média acima de 5000
4. Útil para filtrar resultados de agregações

### Exemplo 2: Table subquery com JOIN

```sql
-- Join com tabela derivada
SELECT f.nome, f.salario, dm.media_salario
FROM funcionarios f
JOIN (
    SELECT departamento, AVG(salario) as media_salario
    FROM funcionarios
    GROUP BY departamento
) as dm ON f.departamento = dm.departamento
WHERE f.salario > dm.media_salario;
```

**Explicação detalhada:**

1. A subquery cria tabela derivada com médias por departamento
2. JOIN conecta funcionários com suas médias departamentais
3. Filtra funcionários acima da média do departamento
4. Útil para comparações com agregações

### Exemplo 3: Table subquery com ordenação

```sql
-- Top 3 produtos mais caros de cada categoria
SELECT nome, preco, categoria
FROM (
    SELECT nome, preco, categoria,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY preco DESC) as rn
    FROM produtos
) as ranking
WHERE rn <= 3;
```

**Explicação detalhada:**

1. A subquery usa window function para ranking
2. Tabela derivada contém ranking por categoria
3. Query principal filtra top 3 de cada categoria
4. Útil para top N por grupo

### Exemplo 4: Table subquery com agregação múltipla

```sql
-- Estatísticas completas por departamento
SELECT departamento, num_func, media_salario, max_salario
FROM (
    SELECT 
        departamento,
        COUNT(*) as num_func,
        AVG(salario) as media_salario,
        MAX(salario) as max_salario
    FROM funcionarios
    GROUP BY departamento
) as dept_stats
ORDER BY media_salario DESC;
```

**Explicação detalhada:**

1. A subquery calcula múltiplas agregações
2. Tabela derivada contém estatísticas
3. Query principal ordena por média salarial
4. Útil para relatórios de estatísticas

### Exemplo 5: Table subquery com UNION

```sql
-- Combinar resultados de múltiplas tabelas
SELECT nome, tipo, valor
FROM (
    SELECT nome, 'Cliente' as tipo, limite_credito as valor
    FROM clientes
    UNION ALL
    SELECT nome, 'Fornecedor' as tipo, limite_compra as valor
    FROM fornecedores
) as entidades
WHERE valor > 10000;
```

**Explicação detalhada:**

1. A subquery combina clientes e fornecedores
2. Tabela derivada unifica os dados
3. Query principal filtra por valor
4. Útil para unificar dados de fontes diferentes

## Comportamento com NULL

### Cenário 1: Table subquery com NULL

```sql
SELECT nome, salario
FROM (
    SELECT nome, salario
    FROM funcionarios
    WHERE departamento IS NOT NULL
) as f
WHERE salario > 5000;
```

**Comportamento:**

- NULL é tratado normalmente na tabela derivada
- Filtragem funciona como esperado
- Use COALESCE se necessário para tratar NULLs

## Pros e Contras

### Pros

1. **Flexibilidade**: Permite manipular resultados complexos como tabelas

```sql
-- Flexível
SELECT * FROM (SELECT AVG(salario) as media FROM funcionarios) t WHERE media > 5000;
```

1. **Reutilização**: Pode usar o resultado da subquery múltiplas vezes

2. **Legibilidade**: Separa lógica complexa em passos

### Contras

1. **Performance**: Table subquery pode não usar índices da tabela original

```sql
-- Pode ser lento (não usa índices)
SELECT * FROM (SELECT * FROM tabela WHERE condicao) t WHERE outra_condicao;
```

1. **Complexidade**: Subqueries aninhadas podem ser difíceis de entender

2. **Limitações**: Algumas operações não são permitidas em tabelas derivadas

## Cenários a Considerar

### Cenário 1: Filtrar agregações

**Recomendação:** Usar table subquery ou HAVING

```sql
-- Table subquery
SELECT departamento, media FROM (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) t WHERE media > 5000;

-- HAVING (mais simples)
SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento HAVING AVG(salario) > 5000;
```

### Cenário 2: Top N por grupo

**Recomendação:** Usar table subquery com window function

```sql
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY valor DESC) as rn
    FROM tabela
) t WHERE rn <= 3;
```

### Cenário 3: Performance crítica

**Recomendação:** Usar CTE ou VIEW

```sql
-- CTE
WITH ranking AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY valor DESC) as rn
    FROM tabela
)
SELECT * FROM ranking WHERE rn <= 3;
```

## Table Subquery vs Alternativas

### Table Subquery vs CTE

```sql
-- Table Subquery
SELECT * FROM (SELECT AVG(salario) as media FROM funcionarios) t WHERE media > 5000;

-- CTE (mais legível)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT * FROM media WHERE media > 5000;
```

**Escolha:** CTE para legibilidade e reuso, table subquery para uso único.

### Table Subquery vs VIEW

```sql
-- Table Subquery (temporário)
SELECT * FROM (SELECT AVG(salario) as media FROM funcionarios) t WHERE media > 5000;

-- VIEW (persistente)
CREATE VIEW media_salario AS SELECT AVG(salario) as media FROM funcionarios;
SELECT * FROM media_salario WHERE media > 5000;
```

**Escolha:** Table subquery para uso temporário, VIEW para reuso frequente.

### Table Subquery vs Temp Table

```sql
-- Table Subquery
SELECT * FROM (SELECT * FROM tabela WHERE condicao) t WHERE outra_condicao;

-- Temp Table (pode usar índices)
CREATE TEMP TABLE temp_tabela AS SELECT * FROM tabela WHERE condicao;
CREATE INDEX idx_temp ON temp_tabela(coluna);
SELECT * FROM temp_tabela WHERE outra_condicao;
```

**Escolha:** Temp table para performance crítica com grandes conjuntos.

## Dicas de Performance

1. **Use CTE em vez de table subquery**: CTE pode ser otimizado melhor pelo banco

```sql
-- CTE (melhor otimização)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT * FROM media WHERE media > 5000;
```

1. **Filtre na subquery**: Reduza o conjunto de dados na subquery

```sql
-- Bom para performance
SELECT * FROM (SELECT * FROM tabela WHERE condicao1) t WHERE condicao2;
```

1. **Evite subqueries aninhadas**: Use CTE para múltiplas operações

```sql
-- CTE (mais legível)
WITH passo1 AS (SELECT ...),
     passo2 AS (SELECT ... FROM passo1)
SELECT * FROM passo2;
```

## Exemplos Avançados

### Exemplo 1: Múltiplas table subqueries

```sql
-- Comparar agregações de diferentes períodos
SELECT 
    p1.ano,
    p1.media as media_ano1,
    p2.media as media_ano2,
    p1.media - p2.media as diferenca
FROM (
    SELECT YEAR(data) as ano, AVG(valor) as media
    FROM vendas
    WHERE YEAR(data) = 2023
    GROUP BY YEAR(data)
) p1
JOIN (
    SELECT YEAR(data) as ano, AVG(valor) as media
    FROM vendas
    WHERE YEAR(data) = 2022
    GROUP BY YEAR(data)
) p2 ON p1.ano = p2.ano + 1;
```

### Exemplo 2: Table subquery com window functions

```sql
-- Soma cumulativa com ranking
SELECT nome, valor, soma_cumulativa, ranking
FROM (
    SELECT 
        nome,
        valor,
        SUM(valor) OVER (ORDER BY data) as soma_cumulativa,
        ROW_NUMBER() OVER (ORDER BY valor DESC) as ranking
    FROM vendas
) t
WHERE ranking <= 10;
```

### Exemplo 3: Table subquery em UPDATE

```sql
-- Atualizar baseado em cálculo complexo
UPDATE funcionarios f
SET salario = t.novo_salario
FROM (
    SELECT id, salario * 1.1 as novo_salario
    FROM funcionarios
    WHERE departamento = 'Vendas'
) t
WHERE f.id = t.id;
```

### Exemplo 4: Table subquery em DELETE

```sql
-- Deletar duplicatas
DELETE FROM funcionarios
WHERE id NOT IN (
    SELECT MIN(id)
    FROM (
        SELECT id, nome, departamento
        FROM funcionarios
    ) t
    GROUP BY nome, departamento
);
```

### Exemplo 5: Table subquery com CASE

```sql
-- Classificação baseada em múltiplas condições
SELECT nome, classificacao
FROM (
    SELECT 
        nome,
        CASE 
            WHEN valor > 10000 THEN 'Alto'
            WHEN valor > 5000 THEN 'Médio'
            ELSE 'Baixo'
        END as classificacao
    FROM vendas
) t
WHERE classificacao IN ('Alto', 'Médio');
```

## Table Subquery em Diferentes Bancos

### PostgreSQL, MySQL, SQL Server, Oracle

Todas suportam table subqueries na cláusula FROM da mesma forma.

## Resumo

- **Use table subquery quando**: Precisa filtrar agregações, top N por grupo, manipular resultados complexos
- **Use CTE quando**: Precisa reuso, legibilidade, múltiplas operações
- **Use VIEW quando**: Precisa reuso frequente, persistência
- **Use temp table quando**: Performance crítica, grandes conjuntos, precisa de índices
- **Performance**: Filtre na subquery, use CTE para melhor otimização, evite aninhamento
- **Compatibilidade**: Suportado em PostgreSQL, MySQL, SQL Server, Oracle
- **Regra de ouro**: CTE para legibilidade, table subquery para uso único, temp table para performance
