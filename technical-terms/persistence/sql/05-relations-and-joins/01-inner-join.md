# INNER JOIN

O `INNER JOIN` é o tipo mais comum de JOIN em SQL. Ele retorna apenas as linhas onde há correspondência em ambas as tabelas, baseado em uma condição de junção.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

## Como Funciona - Passo a Passo

### Passo 1: Produto cartesiano

O banco cria um produto cartesiano das duas tabelas (todas as combinações possíveis).

### Passo 2: Aplicação da condição ON

A condição ON é aplicada para filtrar as combinações.

### Passo 3: Retorno das correspondências

Apenas as linhas que satisfazem a condição ON são retornadas.

## Exemplos Práticos

### Exemplo 1: INNER JOIN básico

```sql
-- Listar clientes com seus pedidos
SELECT c.nome, p.id as pedido_id, p.data_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco combina cada cliente com cada pedido (produto cartesiano)
2. Filtra para manter apenas combinações onde `c.id = p.cliente_id`
3. Retorna apenas clientes que têm pedidos e pedidos que têm clientes

### Exemplo 2: INNER JOIN com múltiplas colunas

```sql
-- Listar produtos com suas categorias
SELECT p.nome, c.nome as categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;
```

**Explicação detalhada:**

1. O banco combina cada produto com cada categoria
2. Filtra para manter apenas combinações onde `p.categoria_id = c.id`
3. Retorna apenas produtos que têm categorias e categorias que têm produtos

### Exemplo 3: INNER JOIN com WHERE

```sql
-- Listar pedidos de clientes de São Paulo
SELECT c.nome, p.id as pedido_id, p.valor_total
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE c.cidade = 'São Paulo';
```

**Explicação detalhada:**

1. O banco combina clientes com pedidos
2. Filtra para manter apenas combinações onde `c.id = p.cliente_id`
3. Filtra adicionalmente para manter apenas clientes de São Paulo
4. Retorna pedidos de clientes de São Paulo

### Exemplo 4: INNER JOIN com múltiplas tabelas

```sql
-- Listar itens de pedido com produtos e pedidos
SELECT ip.quantidade, p.nome as produto, ped.id as pedido_id
FROM itens_pedido ip
INNER JOIN produtos p ON ip.produto_id = p.id
INNER JOIN pedidos ped ON ip.pedido_id = ped.id;
```

**Explicação detalhada:**

1. O banco combina itens_pedido com produtos
2. Combina o resultado com pedidos
3. Retorna itens de pedido com informações do produto e do pedido

### Exemplo 5: INNER JOIN com alias

```sql
-- Listar funcionários com seus departamentos
SELECT f.nome, d.nome as departamento
FROM funcionarios f
INNER JOIN departamentos d ON f.departamento_id = d.id;
```

**Explicação detalhada:**

1. O banco usa alias `f` para funcionarios e `d` para departamentos
2. Combina funcionários com departamentos
3. Retorna funcionários com seus departamentos

## Comportamento com NULL

### Cenário 1: INNER JOIN com NULL na coluna de junção

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se `cliente_id` for NULL em pedidos, essas linhas não são retornadas
- Se `id` for NULL em clientes, essas linhas não são retornadas
- INNER JOIN não retorna linhas onde a coluna de junção é NULL

### Cenário 2: INNER JOIN com NULL em outras colunas

```sql
SELECT c.nome, c.email, p.id as pedido_id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- NULL em colunas não usadas na junção (como email) não afeta o JOIN
- Essas linhas são retornadas normalmente

## Pros e Contras

### Pros

1. **Eficiência**: INNER JOIN é geralmente o tipo de JOIN mais eficiente

```sql
-- Eficiente
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

1. **Semântica clara**: Expressa claramente a intenção de encontrar correspondências

2. **Índices**: Pode usar índices nas colunas de junção para melhorar performance

### Contras

1. **Perda de dados**: Linhas sem correspondência não são retornadas

```sql
-- Clientes sem pedidos não são retornados
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

1. **Filtro implícito**: Pode não ser óbvio que linhas sem correspondência são excluídas

2. **NULL na coluna de junção**: Linhas com NULL na coluna de junção são excluídas

## Cenários a Considerar

### Cenário 1: Correspondências obrigatórias

**Recomendação:** Usar `INNER JOIN`

```sql
-- Clientes que têm pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

### Cenário 2: Correspondências opcionais

**Recomendação:** Usar `LEFT JOIN`

```sql
-- Todos os clientes, com ou sem pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

### Cenário 3: Múltiplas tabelas

**Recomendação:** Usar múltiplos `INNER JOIN`

```sql
-- Itens de pedido com produtos e pedidos
FROM itens_pedido ip
INNER JOIN produtos p ON ip.produto_id = p.id
INNER JOIN pedidos ped ON ip.pedido_id = ped.id
```

### Cenário 4: Filtragem após JOIN

**Recomendação:** Usar `WHERE` após JOIN

```sql
-- Pedidos de clientes de São Paulo
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE c.cidade = 'São Paulo'
```

### Cenário 5: JOIN com agregação

**Recomendação:** Usar `INNER JOIN` com `GROUP BY`

```sql
-- Total de pedidos por cliente
SELECT c.nome, COUNT(p.id) as total_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
```

## INNER JOIN vs Alternativas

### INNER JOIN vs WHERE

```sql
-- INNER JOIN
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;

-- WHERE (equivalente)
SELECT c.nome, p.id
FROM clientes c, pedidos p
WHERE c.id = p.cliente_id;
```

**Escolha:** `INNER JOIN` é mais legível e padrão.

### INNER JOIN vs LEFT JOIN

```sql
-- INNER JOIN (apenas correspondências)
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT JOIN (todas as linhas da esquerda)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `INNER JOIN` para correspondências obrigatórias, `LEFT JOIN` para opcionais.

### INNER JOIN vs CROSS JOIN

```sql
-- INNER JOIN (com condição)
SELECT c.nome, p.nome
FROM clientes c
INNER JOIN produtos p ON c.id = p.cliente_id;

-- CROSS JOIN (produto cartesiano)
SELECT c.nome, p.nome
FROM clientes c
CROSS JOIN produtos p;
```

**Escolha:** `INNER JOIN` para correspondências, `CROSS JOIN` para produto cartesiano.

## Dicas de Performance

1. **Use índices nas colunas de junção**: Índices podem melhorar performance significativamente

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);

-- Pode usar índice
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

1. **Filtre antes de JOIN**: Use WHERE para reduzir o número de linhas antes do JOIN

```sql
-- Bom (filtra antes)
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE c.cidade = 'São Paulo'
```

1. **Evite JOIN em colunas sem índice**: Pode resultar em full table scan

```sql
-- Pode ser lento se colunas não tiverem índice
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.coluna_sem_indice = t2.coluna_sem_indice
```

1. **Selecione apenas colunas necessárias**: Reduz a quantidade de dados transferidos

```sql
-- Bom (apenas colunas necessárias)
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

## Exemplos Avançados

### Exemplo 1: INNER JOIN com subquery

```sql
-- Clientes que fizeram pedidos em 2024
SELECT c.nome
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE YEAR(p.data_pedido) = 2024
GROUP BY c.id, c.nome;
```

### Exemplo 2: INNER JOIN com agregação

```sql
-- Total gasto por cliente
SELECT c.nome, SUM(p.valor_total) as total_gasto
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

### Exemplo 3: INNER JOIN com HAVING

```sql
-- Clientes com mais de 5 pedidos
SELECT c.nome, COUNT(p.id) as total_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
HAVING COUNT(p.id) > 5;
```

### Exemplo 4: INNER JOIN com múltiplas condições

```sql
-- Pedidos de produtos específicos em período específico
SELECT c.nome, p.nome as produto, ped.data_pedido
FROM clientes c
INNER JOIN pedidos ped ON c.id = ped.cliente_id
INNER JOIN itens_pedido ip ON ped.id = ip.pedido_id
INNER JOIN produtos p ON ip.produto_id = p.id
WHERE p.categoria_id = 1
AND ped.data_pedido BETWEEN '2024-01-01' AND '2024-12-31';
```

### Exemplo 5: INNER JOIN com ORDER BY

```sql
-- Top 10 clientes por valor gasto
SELECT c.nome, SUM(p.valor_total) as total_gasto
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
ORDER BY total_gasto DESC
LIMIT 10;
```

## INNER JOIN em Diferentes Bancos

### MySQL

```sql
-- INNER JOIN padrão
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;

-- JOIN (equivalente a INNER JOIN)
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

### PostgreSQL

```sql
-- INNER JOIN padrão
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;

-- JOIN (equivalente a INNER JOIN)
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

### SQL Server

```sql
-- INNER JOIN padrão
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;

-- JOIN (equivalente a INNER JOIN)
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

## Resumo

- **Use INNER JOIN quando**: Precisa de correspondências obrigatórias entre tabelas
- **Evite INNER JOIN quando**: Precisa de todas as linhas de uma tabela (use LEFT JOIN)
- **Alternativas**: LEFT JOIN para correspondências opcionais, CROSS JOIN para produto cartesiano
- **NULL**: Linhas com NULL na coluna de junção não são retornadas
- **Performance**: Use índices nas colunas de junção para melhorar performance
- **Filtragem**: Filtre antes de JOIN com WHERE para reduzir o número de linhas
- **Regra de ouro**: INNER JOIN para correspondências obrigatórias, LEFT JOIN para opcionais
