# Performance de Subqueries

Subqueries são poderosas mas podem ser extremamente ineficientes se não usadas corretamente. Entender quando usar subqueries, CTEs, ou JOINs, e como otimizar subqueries correlatas é crucial para performance.

## Definição

Subqueries são consultas aninhadas dentro de outra consulta. A performance de subqueries depende do tipo (correlata vs não correlata), localização (WHERE, FROM, SELECT), e se índices podem ser usados. Subqueries correlatas são especialmente problemáticas pois executam uma vez por linha.

## Tipos de Subqueries e Performance

### Non-Correlated Subquery

Executa uma vez, independente da query principal. Geralmente eficiente.

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

**Performance:** Boa. Executa uma vez, resultado reutilizado.

### Correlated Subquery

Executa uma vez por linha da query principal. Pode ser muito lento.

```sql
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

**Performance:** Ruim em grandes conjuntos. Executa N vezes (N = número de linhas).

### Subquery em FROM (Table Subquery)

Cria tabela derivada. Pode ser eficiente se bem otimizada.

```sql
SELECT departamento, media_salario
FROM (SELECT departamento, AVG(salario) as media_salario FROM funcionarios GROUP BY departamento) t
WHERE media_salario > 5000;
```

**Performance:** Boa se subquery é eficiente. Pode usar índices.

## Exemplos Práticos

### Exemplo 1: Non-Correlated vs Correlated

```sql
-- Non-Correlated (eficiente)
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);

-- Correlated (ineficiente)
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

**Explicação detalhada:**

1. Non-correlated: subquery executa uma vez, resultado reutilizado
2. Correlated: subquery executa uma vez por linha, muito lento em grandes conjuntos
3. Converta correlated para JOIN ou CTE para melhor performance

### Exemplo 2: Subquery Correlata para JOIN

```sql
-- Correlated (lento)
SELECT f1.nome, f1.salario
FROM funcionarios f1
WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- JOIN (rápido)
SELECT f1.nome, f1.salario
FROM funcionarios f1
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f1.departamento = m.departamento
WHERE f1.salario > m.media;
```

**Explicação detalhada:**

1. Correlated: executa subquery para cada funcionário
2. JOIN: calcula médias uma vez, depois faz join
3. JOIN é geralmente muito mais eficiente

### Exemplo 3: IN vs EXISTS

```sql
-- IN (pode ser lento sem índice)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);

-- EXISTS (pode ser mais eficiente)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Explicação detalhada:**

1. IN: cria lista completa de valores, depois verifica
2. EXISTS: para ao encontrar primeira correspondência
3. EXISTS pode ser mais eficiente com índices apropriados

### Exemplo 4: Subquery em SELECT

```sql
-- Subquery em SELECT (executa uma vez por linha)
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) as media_geral
FROM funcionarios;

-- CTE (executa uma vez)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT f.nome, f.salario, m.media
FROM funcionarios f, media m;
```

**Explicação detalhada:**

1. Subquery em SELECT: executa uma vez por linha (se correlata) ou uma vez (se não correlata)
2. CTE: executa uma vez, resultado reutilizado
3. CTE é mais legível e pode ser mais eficiente

### Exemplo 5: Subquery em WHERE com Índice

```sql
-- Com índice
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);

SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

**Explicação detalhada:**

1. Índice em cliente_id acelera a subquery
2. Subquery retorna lista de cliente_ids rapidamente
3. IN verifica se id está na lista
4. Eficiente com índice apropriado

## Estratégias de Otimização

### Estratégia 1: Converta Correlated para JOIN

Subqueries correlatas são frequentemente a maior fonte de problemas de performance.

```sql
-- Correlated (lento)
SELECT f1.nome, f1.salario
FROM funcionarios f1
WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- JOIN (rápido)
SELECT f1.nome, f1.salario
FROM funcionarios f1
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f1.departamento = m.departamento
WHERE f1.salario > m.media;
```

### Estratégia 2: Use CTE em vez de Subquery Aninhada

CTEs são mais legíveis e podem ser otimizados melhor pelo banco.

```sql
-- Subquery aninhada (menos legível)
SELECT * FROM (
    SELECT * FROM (
        SELECT * FROM tabela WHERE condicao1
    ) t1 WHERE condicao2
) t2 WHERE condicao3;

-- CTE (mais legível e eficiente)
WITH passo1 AS (SELECT * FROM tabela WHERE condicao1),
     passo2 AS (SELECT * FROM passo1 WHERE condicao2)
SELECT * FROM passo2 WHERE condicao3;
```

### Estratégia 3: Use EXISTS em vez de IN

EXISTS pode parar ao encontrar primeira correspondência.

```sql
-- IN (cria lista completa)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);

-- EXISTS (para cedo)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### Estratégia 4: Use Índices em Subqueries

Índices nas colunas usadas em subqueries melhoram performance.

```sql
-- Índice para subquery
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);

SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

### Estratégia 5: Limite o Resultado da Subquery

Use LIMIT ou WHERE para reduzir o conjunto da subquery.

```sql
-- Subquery com limite
SELECT nome FROM clientes WHERE id IN (
    SELECT cliente_id FROM pedidos WHERE data > '2024-01-01' LIMIT 1000
);
```

## Padrões Problemáticos

### Padrão 1: Subquery Correlata em Loop

```sql
-- Problema (executa N vezes)
SELECT nome, salario
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- Solução (JOIN)
SELECT f1.nome, f1.salario
FROM funcionarios f1
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f1.departamento = m.departamento
WHERE f1.salario > m.media;
```

### Padrão 2: Subquery em SELECT Correlata

```sql
-- Problema (executa N vezes)
SELECT nome, salario, (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id) as num_pedidos
FROM clientes c;

-- Solução (JOIN)
SELECT c.nome, c.salario, COUNT(p.id) as num_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome, c.salario;
```

### Padrão 3: NOT IN com NULL

```sql
-- Problema (retorna nenhuma linha se NULL presente)
SELECT nome FROM clientes WHERE id NOT IN (SELECT cliente_id FROM pedidos);

-- Solução (NOT EXISTS ou filtre NULL)
SELECT nome FROM clientes c WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### Padrão 4: Subquery Aninhada Profunda

```sql
-- Problema (difícil de ler e otimizar)
SELECT * FROM (SELECT * FROM (SELECT * FROM tabela WHERE condicao1) t1 WHERE condicao2) t2 WHERE condicao3;

-- Solução (CTE)
WITH passo1 AS (SELECT * FROM tabela WHERE condicao1),
     passo2 AS (SELECT * FROM passo1 WHERE condicao2)
SELECT * FROM passo2 WHERE condicao3;
```

### Padrão 5: Subquery Sem Índice

```sql
-- Problema (subquery lenta sem índice)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos WHERE data > '2024-01-01');

-- Solução (adicione índice)
CREATE INDEX idx_pedidos_cliente_data ON pedidos(cliente_id, data);
```

## Pros e Contras

### Non-Correlated Subquery

**Pros:**

- Executa uma vez
- Geralmente eficiente
- Legível

**Contras:**

- Limitada a valores independentes
- Não pode usar valores da query principal

### Correlated Subquery

**Pros:**

- Flexível (usa valores da query principal)
- Poderosa para comparações contextuais

**Contras:**

- Executa uma vez por linha
- Muito lento em grandes conjuntos
- Difícil de otimizar

### CTE

**Pros:**

- Legível
- Pode ser reutilizado
- Otimizador pode otimizar melhor

**Contras:**

- Nem todos os bancos materializam CTEs
- Pode ser ineficiente se não materializado

### JOIN

**Pros:**

- Geralmente mais eficiente que correlated subquery
- Otimizador tem mais opções

**Contras:**

- Pode ser mais verboso
- Nem sempre intuitivo

## Cenários a Considerar

### Cenário 1: Comparação com Agregação

**Recomendação:** Use JOIN em vez de correlated subquery

```sql
-- Correlated (lento)
SELECT f1.nome FROM funcionarios f1 WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- JOIN (rápido)
SELECT f1.nome FROM funcionarios f1 JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m ON f1.departamento = m.departamento WHERE f1.salario > m.media;
```

### Cenário 2: Verificação de Existência

**Recomendação:** Use EXISTS em vez de IN

```sql
-- EXISTS (mais eficiente)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### Cenário 3: Múltiplas Subqueries

**Recomendação:** Use CTE para legibilidade e performance

```sql
-- CTE (mais legível)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios),
     maximo AS (SELECT MAX(salario) as maximo FROM funcionarios)
SELECT nome, salario FROM funcionarios f, media m, maximo mx WHERE f.salario > m.media AND f.salario < mx.maximo;
```

### Cenário 4: Subquery em SELECT

**Recomendação:** Use CTE ou JOIN

```sql
-- JOIN (mais eficiente)
SELECT c.nome, COUNT(p.id) as num_pedidos FROM clientes c LEFT JOIN pedidos p ON c.id = p.cliente_id GROUP BY c.id, c.nome;
```

## Dicas de Performance

1. **Sempre converta correlated subqueries para JOIN quando possível**

```sql
-- JOIN é geralmente mais eficiente
SELECT f1.nome FROM funcionarios f1 JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m ON f1.departamento = m.departamento WHERE f1.salario > m.media;
```

1. **Use EXISTS em vez de IN para verificação de existência**

```sql
-- EXISTS pode parar cedo
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

1. **Use CTE para subqueries complexas ou aninhadas**

```sql
-- CTE é mais legível e pode ser mais eficiente
WITH passo1 AS (SELECT * FROM tabela WHERE condicao1)
SELECT * FROM passo1 WHERE condicao2;
```

1. **Crie índices nas colunas usadas em subqueries**

```sql
-- Índice acelera subquery
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
```

1. **Use EXPLAIN para analisar performance de subqueries**

```sql
EXPLAIN SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

## Subqueries em Diferentes Bancos

### PostgreSQL

- Otimizador agressivo para subqueries
- CTEs podem ser materializadas (MATERIALIZED) ou inline
- LATERAL joins para subqueries correlatas

```sql
-- CTE materializada
WITH media AS MATERIALIZED (SELECT AVG(salario) as media FROM funcionarios)
SELECT * FROM funcionarios f, media m WHERE f.salario > m.media;

-- LATERAL join
SELECT f.nome, m.media
FROM funcionarios f,
LATERAL (SELECT AVG(salario) as media FROM funcionarios f2 WHERE f2.departamento = f.departamento) m;
```

### MySQL

- Otimizador menos agressivo para subqueries
- Subqueries em FROM são otimizadas
- CTEs (MySQL 8.0+) podem ser eficientes

```sql
-- CTE (MySQL 8.0+)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT * FROM funcionarios f, media m WHERE f.salario > m.media;
```

### SQL Server

- Otimizador bom para subqueries
- CTEs são inline (não materializadas)
- APPLY para subqueries correlatas

```sql
-- CROSS APPLY
SELECT f.nome, m.media
FROM funcionarios f
CROSS APPLY (SELECT AVG(salario) as media FROM funcionarios f2 WHERE f2.departamento = f.departamento) m;
```

### Oracle

- Otimizador muito bom para subqueries
- CTEs (WITH clause) podem ser materializadas
- Hints para forçar comportamento

```sql
-- CTE com hint
WITH /*+ MATERIALIZE */ media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT * FROM funcionarios f, media m WHERE f.salario > m.media;
```

## Resumo

- **Non-Correlated**: Executa uma vez, geralmente eficiente
- **Correlated**: Executa uma vez por linha, muito lento em grandes conjuntos
- **JOIN**: Geralmente mais eficiente que correlated subquery
- **CTE**: Mais legível, pode ser mais eficiente se materializado
- **EXISTS vs IN**: EXISTS pode parar cedo, geralmente mais eficiente
- **Índices**: Crie índices nas colunas usadas em subqueries
- **NOT IN**: Cuidado com NULL, use NOT EXISTS
- **Aninhadas**: Use CTE em vez de subqueries aninhadas
- **EXPLAIN**: Use EXPLAIN para analisar performance
- **Compatibilidade**: Cada banco tem otimizações específicas
- **Regra de ouro**: Converta correlated para JOIN, use CTE para complexidade, EXISTS para existência
