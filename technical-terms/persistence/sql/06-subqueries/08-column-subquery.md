# Column Subquery

Uma Column Subquery (Subquery de Coluna) é uma subquery que retorna múltiplas linhas de uma única coluna. Ela é usada com operadores como IN, NOT IN, ANY, ALL, ou EXISTS para filtrar dados baseados em uma lista de valores.

## Sintaxe Básica

```sql
SELECT coluna1, coluna2
FROM tabela1
WHERE coluna3 IN (SELECT coluna4 FROM tabela2 WHERE condicao);
```

## Como Funciona - Passo a Passo

### Passo 1: Execução da subquery

A subquery é executada e retorna uma lista de valores de uma única coluna.

### Passo 2: Comparação

Cada linha da query principal é comparada com os valores retornados pela subquery.

### Passo 3: Filtragem

Linhas que satisfazem a condição (IN, NOT IN, ANY, ALL) são mantidas.

### Passo 4: Retorno

O resultado filtrado é retornado.

## Exemplos Práticos

### Exemplo 1: IN com column subquery

```sql
-- Clientes que fizeram pedidos
SELECT nome, email
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```

**Explicação detalhada:**

1. A subquery retorna todos os cliente_id da tabela pedidos
2. IN verifica se o id do cliente está na lista retornada
3. Retorna apenas clientes que fizeram pedidos
4. Útil para filtrar baseado em relacionamentos

### Exemplo 2: NOT IN com column subquery

```sql
-- Clientes que NÃO fizeram pedidos
SELECT nome, email
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);
```

**Explicação detalhada:**

1. A subquery retorna todos os cliente_id da tabela pedidos
2. NOT IN verifica se o id do cliente NÃO está na lista
3. Retorna apenas clientes sem pedidos
4. Cuidado: NOT IN com NULL retorna nenhuma linha

### Exemplo 3: ANY com column subquery

```sql
-- Produtos com preço maior que algum produto da categoria A
SELECT nome, preco
FROM produtos
WHERE preco > ANY (SELECT preco FROM produtos WHERE categoria = 'A');
```

**Explicação detalhada:**

1. A subquery retorna preços da categoria A
2. ANY verifica se o preço é maior que pelo menos um valor
3. Equivalente a > MIN(preco) da subquery
4. Útil para comparações flexíveis

### Exemplo 4: ALL com column subquery

```sql
-- Produtos com preço maior que todos os produtos da categoria A
SELECT nome, preco
FROM produtos
WHERE preco > ALL (SELECT preco FROM produtos WHERE categoria = 'A');
```

**Explicação detalhada:**

1. A subquery retorna preços da categoria A
2. ALL verifica se o preço é maior que todos os valores
3. Equivalente a > MAX(preco) da subquery
4. Útil para encontrar extremos

### Exemplo 5: Column subquery correlata

```sql
-- Funcionários com salário acima da média do departamento
SELECT nome, salario, departamento
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);
```

**Explicação detalhada:**

1. A subquery é correlata (usa f.departamento da query principal)
2. Para cada funcionário, calcula a média do departamento
3. Compara o salário individual com a média do departamento
4. Útil para comparações dentro de grupos

## Comportamento com NULL

### Cenário 1: IN com NULL

```sql
SELECT nome FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL);
```

**Comportamento:**

- IN ignora NULL na lista
- Funciona corretamente mesmo com NULLs
- Retorna linhas que correspondem a valores não-NULL

### Cenário 2: NOT IN com NULL

```sql
SELECT nome FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);
```

**Comportamento:**

- NOT IN com NULL retorna nenhuma linha
- A comparação id NOT IN (1, 2, NULL) resulta em UNKNOWN para todos
- Use NOT EXISTS ou filtre NULLs na subquery

### Cenário 3: Solução para NOT IN com NULL

```sql
-- Opção 1: Filtrar NULLs
SELECT nome FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL);

-- Opção 2: Usar NOT EXISTS
SELECT nome FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

## Operadores com Column Subquery

### IN

Verifica se o valor está na lista retornada pela subquery.

```sql
WHERE coluna IN (subquery)
```

### NOT IN

Verifica se o valor NÃO está na lista retornada pela subquery.

```sql
WHERE coluna NOT IN (subquery)
```

### ANY

Compara com qualquer valor da lista.

```sql
WHERE coluna > ANY (subquery)
```

### ALL

Compara com todos os valores da lista.

```sql
WHERE coluna > ALL (subquery)
```

## Pros e Contras

### Pros

1. **Flexibilidade**: Permite filtrar baseado em conjuntos de valores

```sql
-- Flexível
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

1. **Legibilidade**: Expressa claramente a intenção de filtrar por lista

2. **Correlação**: Pode ser correlata para comparações contextuais

### Contras

1. **Performance**: Subquery correlata pode ser lenta

```sql
-- Pode ser lento (executa uma vez por linha)
SELECT nome, salario
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);
```

1. **NULL**: NOT IN com NULL retorna nenhuma linha

2. **Complexidade**: ANY e ALL podem ser confusos

## Cenários a Considerar

### Cenário 1: Filtrar por lista de valores

**Recomendação:** Usar IN

```sql
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

### Cenário 2: Filtrar por ausência na lista

**Recomendação:** Usar NOT EXISTS (evita NOT IN com NULL)

```sql
SELECT nome FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### Cenário 3: Comparação com extremos

**Recomendação:** Usar ALL ou agregações

```sql
-- ALL
SELECT nome FROM produtos WHERE preco > ALL (SELECT preco FROM produtos WHERE categoria = 'A');

-- Agregação (mais legível)
SELECT nome FROM produtos WHERE preco > (SELECT MAX(preco) FROM produtos WHERE categoria = 'A');
```

### Cenário 4: Performance crítica

**Recomendação:** Usar JOIN ou EXISTS

```sql
-- JOIN
SELECT DISTINCT c.nome FROM clientes c JOIN pedidos p ON c.id = p.cliente_id;

-- EXISTS
SELECT c.nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

## Column Subquery vs Alternativas

### Column Subquery vs JOIN

```sql
-- Column Subquery (mais simples)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);

-- JOIN (mais eficiente em alguns casos)
SELECT DISTINCT c.nome FROM clientes c JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** Column subquery para simplicidade, JOIN para performance.

### Column Subquery vs EXISTS

```sql
-- Column Subquery (IN)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);

-- EXISTS (mais eficiente com índices)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Escolha:** EXISTS para performance, IN para legibilidade.

### Column Subquery vs ANY/ALL vs Agregações

```sql
-- ANY
SELECT nome FROM produtos WHERE preco > ANY (SELECT preco FROM produtos WHERE categoria = 'A');

-- Agregação (mais legível)
SELECT nome FROM produtos WHERE preco > (SELECT MIN(preco) FROM produtos WHERE categoria = 'A');

-- ALL
SELECT nome FROM produtos WHERE preco > ALL (SELECT preco FROM produtos WHERE categoria = 'A');

-- Agregação (mais legível)
SELECT nome FROM produtos WHERE preco > (SELECT MAX(preco) FROM produtos WHERE categoria = 'A');
```

**Escolha:** Agregações para legibilidade, ANY/ALL para flexibilidade.

## Dicas de Performance

1. **Use EXISTS em vez de IN**: EXISTS pode parar ao encontrar primeira correspondência

```sql
-- EXISTS (mais eficiente)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

1. **Use índices**: Índices nas colunas de junção melhoram performance

```sql
-- Índice em cliente_id ajuda
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

1. **Evite subqueries correlatas**: Use JOIN quando possível

```sql
-- Evite
SELECT nome, salario
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);

-- Prefira JOIN
SELECT f.nome, f.salario
FROM funcionarios f
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f.departamento = m.departamento
WHERE f.salario > m.media;
```

## Exemplos Avançados

### Exemplo 1: Múltiplas column subqueries

```sql
-- Produtos mais caros que a média de cada categoria
SELECT nome, preco, categoria
FROM produtos p
WHERE preco > (SELECT AVG(preco) FROM produtos p2 WHERE p2.categoria = p.categoria);
```

### Exemplo 2: Column subquery em HAVING

```sql
-- Categorias com mais produtos que a média
SELECT categoria, COUNT(*) as num_produtos
FROM produtos
GROUP BY categoria
HAVING COUNT(*) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) as cnt FROM produtos GROUP BY categoria) t);
```

### Exemplo 3: ANY com múltiplas condições

```sql
-- Funcionários com salário maior que algum gerente
SELECT nome, salario
FROM funcionarios
WHERE salario > ANY (SELECT salario FROM funcionarios WHERE cargo = 'Gerente');
```

### Exemplo 4: ALL com subquery complexa

```sql
-- Vendedores com vendas maiores que todos os vendedores de outra região
SELECT nome, total_vendas
FROM vendedores
WHERE total_vendas > ALL (
    SELECT total_vendas 
    FROM vendedores 
    WHERE regiao <> 'Sul'
);
```

### Exemplo 5: Column subquery em UPDATE

```sql
-- Atualizar produtos acima da média
UPDATE produtos
SET status = 'Premium'
WHERE preco > (SELECT AVG(preco) FROM produtos);
```

## Column Subquery em Diferentes Bancos

### PostgreSQL, MySQL, SQL Server, Oracle

Todas suportam column subqueries com IN, NOT IN, ANY, ALL da mesma forma.

## Resumo

- **Use column subquery quando**: Filtrar por lista de valores, comparações com conjuntos
- **Use IN quando**: Verificar presença em lista, legibilidade é prioridade
- **Use NOT EXISTS quando**: Verificar ausência (evita NOT IN com NULL)
- **Use ANY quando**: Comparar com qualquer valor da lista
- **Use ALL quando**: Comparar com todos os valores da lista
- **NULL**: NOT IN com NULL retorna nenhuma linha, use NOT EXISTS ou filtre NULLs
- **Performance**: Use EXISTS em vez de IN, use índices, evite subqueries correlatas
- **Compatibilidade**: Suportado em PostgreSQL, MySQL, SQL Server, Oracle
- **Regra de ouro**: EXISTS para performance, IN para legibilidade, agregações para clareza
