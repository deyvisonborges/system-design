# Fundamentos de Subqueries

## Definição

Uma subquery (ou subconsulta) é uma consulta SQL aninhada dentro de outra consulta. Ela permite usar o resultado de uma consulta como parte de outra consulta, possibilitando operações complexas que seriam difíceis ou impossíveis com uma única consulta.

## Estrutura Básica

```sql
SELECT coluna1, coluna2
FROM tabela1
WHERE coluna3 = (SELECT coluna4 FROM tabela2 WHERE condicao);
```

A subquery é executada primeiro, e seu resultado é usado pela consulta principal.

## Classificação por Resultado

### Scalar Subquery

Retorna exatamente uma coluna e uma linha (um único valor).

Ver [07-scalar-subquery.md](./07-scalar-subquery.md)

### Column Subquery

Retorna múltiplas linhas de uma única coluna.

Ver [08-column-subquery.md](./08-column-subquery.md)

### Row Subquery

Retorna exatamente uma linha com múltiplas colunas.

Ver [09-row-subquery.md](./09-row-subquery.md)

### Table Subquery

Retorna múltiplas linhas e múltiplas colunas (tabela derivada).

Ver [10-table-subquery.md](./10-table-subquery.md)

## Classificação por Dependência

### Non-Correlated Subquery

Subquery independente que não referencia a query principal. Executa uma vez e o resultado é reutilizado.

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

Ver mais em [11-correlated-vs-noncorrelated.md](./11-correlated-vs-noncorrelated.md)

### Correlated Subquery

Subquery que referencia colunas da query principal. Executa uma vez para cada linha da query principal.

```sql
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

Ver mais em [11-correlated-vs-noncorrelated.md](./11-correlated-vs-noncorrelated.md)

## Onde Usar Subqueries

### SELECT

Adicionar colunas calculadas baseadas em subqueries.

```sql
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) as media_empresa
FROM funcionarios;
```

### FROM

Criar tabelas derivadas para manipulação complexa.

```sql
SELECT departamento, media_salario
FROM (SELECT departamento, AVG(salario) as media_salario FROM funcionarios GROUP BY departamento) t
WHERE media_salario > 5000;
```

### WHERE

Filtrar linhas baseadas em condições complexas.

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

### HAVING

Filtrar grupos baseados em condições complexas.

```sql
SELECT departamento, AVG(salario) as media
FROM funcionarios
GROUP BY departamento
HAVING AVG(salario) > (SELECT AVG(salario) FROM funcionarios);
```

### JOIN

Usar subqueries como tabelas em joins.

```sql
SELECT f.nome, f.salario, m.media
FROM funcionarios f
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f.departamento = m.departamento;
```

## Operadores com Subqueries

### IN / NOT IN

Verificar se valor está (ou não está) em uma lista retornada pela subquery.

```sql
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

### EXISTS / NOT EXISTS

Verificar se a subquery retorna alguma linha.

```sql
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### ANY / ALL

Comparar com qualquer ou todos os valores retornados pela subquery.

```sql
SELECT nome FROM produtos WHERE preco > ANY (SELECT preco FROM produtos WHERE categoria = 'A');
```

### =

Comparar com um único valor (scalar subquery).

```sql
SELECT nome FROM funcionarios WHERE salario = (SELECT MAX(salario) FROM funcionarios);
```

## Considerações de Performance

### Non-Correlated vs Correlated

- **Non-Correlated**: Executa uma vez, geralmente mais eficiente
- **Correlated**: Executa uma vez por linha, pode ser lento em grandes conjuntos

### Alternativas Eficientes

- **JOIN**: Geralmente mais eficiente que subqueries correlatas
- **CTE**: Pode ser mais legível e otimizado pelo banco
- **Window Functions**: Mais eficiente para cálculos sobre conjuntos relacionados

### Índices

Índices nas colunas usadas em subqueries, especialmente em joins e where clauses, melhoram significativamente a performance.

## Tópicos Relacionados

- **CTE (Common Table Expression)**: Ver [01-cte.md](./01-cte.md)
- **Set Operations**: Ver [02-set-operations.md](./02-set-operations.md)
- **DISTINCT**: Ver [03-distinct-expect.md](./03-distinct-expect.md)
- **Window Functions**: Ver [04-window-function.md](./04-window-function.md)
- **Ranking Functions**: Ver [05-row-number-rank-dense.md](./05-row-number-rank-dense.md)
- **Shift Functions**: Ver [06-shift-functions.md](./06-shift-functions.md)
