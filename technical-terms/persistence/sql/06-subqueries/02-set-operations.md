# Set Operations

As operações de conjunto (Set Operations) combinam resultados de duas ou mais consultas em um único resultado. As principais operações são `UNION`, `UNION ALL`, `INTERSECT` e `EXCEPT` (ou `MINUS`).

## Sintaxe Básica

```sql
-- UNION (remove duplicatas)
SELECT coluna1, coluna2 FROM tabela1
UNION
SELECT coluna1, coluna2 FROM tabela2;

-- UNION ALL (mantém duplicatas)
SELECT coluna1, coluna2 FROM tabela1
UNION ALL
SELECT coluna1, coluna2 FROM tabela2;

-- INTERSECT (linhas em ambas)
SELECT coluna1, coluna2 FROM tabela1
INTERSECT
SELECT coluna1, coluna2 FROM tabela2;

-- EXCEPT (linhas na primeira não na segunda)
SELECT coluna1, coluna2 FROM tabela1
EXCEPT
SELECT coluna1, coluna2 FROM tabela2;
```

## Como Funciona - Passo a Passo

### Passo 1: Execução das consultas

Cada consulta é executada independentemente.

### Passo 2: Alinhamento das colunas

As colunas são alinhadas por posição (não por nome).

### Passo 3: Aplicação da operação

A operação de conjunto é aplicada aos resultados combinados.

### Passo 4: Remoção de duplicatas (exceto UNION ALL)

Para UNION, INTERSECT e EXCEPT, duplicatas são removidas.

## Exemplos Práticos

### Exemplo 1: UNION básico

```sql
-- Listar todos os clientes e fornecedores (sem duplicatas)
SELECT nome, email, 'cliente' as tipo
FROM clientes
UNION
SELECT nome, email, 'fornecedor' as tipo
FROM fornecedores;
```

**Explicação detalhada:**

1. A primeira consulta seleciona clientes com tipo 'cliente'
2. A segunda consulta seleciona fornecedores com tipo 'fornecedor'
3. UNION combina os resultados e remove duplicatas
4. Retorna lista única de pessoas com tipo

### Exemplo 2: UNION ALL

```sql
-- Listar todos os pedidos de diferentes tabelas (com duplicatas)
SELECT id, valor_total, 'online' as canal
FROM pedidos_online
UNION ALL
SELECT id, valor_total, 'loja' as canal
FROM pedidos_loja;
```

**Explicação detalhada:**

1. A primeira consulta seleciona pedidos online
2. A segunda consulta seleciona pedidos de loja
3. UNION ALL combina os resultados mantendo duplicatas
4. Retorna todos os pedidos com canal de origem

### Exemplo 3: INTERSECT

```sql
-- Encontrar clientes que compraram em ambos os anos
SELECT cliente_id
FROM pedidos
WHERE EXTRACT(YEAR FROM data_pedido) = 2023
INTERSECT
SELECT cliente_id
FROM pedidos
WHERE EXTRACT(YEAR FROM data_pedido) = 2024;
```

**Explicação detalhada:**

1. A primeira consulta retorna clientes que compraram em 2023
2. A segunda consulta retorna clientes que compraram em 2024
3. INTERSECT retorna clientes em ambos os resultados
4. Retorna clientes que compraram em ambos os anos

### Exemplo 4: EXCEPT

```sql
-- Encontrar clientes que compraram em 2023 mas não em 2024
SELECT cliente_id
FROM pedidos
WHERE EXTRACT(YEAR FROM data_pedido) = 2023
EXCEPT
SELECT cliente_id
FROM pedidos
WHERE EXTRACT(YEAR FROM data_pedido) = 2024;
```

**Explicação detalhada:**

1. A primeira consulta retorna clientes que compraram em 2023
2. A segunda consulta retorna clientes que compraram em 2024
3. EXCEPT retorna clientes na primeira não na segunda
4. Retorna clientes que compraram em 2023 mas não em 2024

### Exemplo 5: Múltiplas operações

```sql
-- Comparar produtos de duas categorias
SELECT produto_id, nome
FROM produtos
WHERE categoria_id = 1
UNION
SELECT produto_id, nome
FROM produtos
WHERE categoria_id = 2
ORDER BY nome;
```

**Explicação detalhada:**

1. A primeira consulta seleciona produtos da categoria 1
2. A segunda consulta seleciona produtos da categoria 2
3. UNION combina e remove duplicatas
4. ORDER BY ordena o resultado final

## Comportamento com NULL

### Cenário 1: NULL em UNION

```sql
SELECT nome, email FROM clientes
UNION
SELECT nome, email FROM fornecedores;
```

**Comportamento:**

- NULL é tratado como um valor normal
- Duas linhas com NULL nas mesmas colunas são consideradas duplicatas
- UNION remove duplicatas incluindo NULL

### Cenário 2: NULL em INTERSECT

```sql
SELECT cliente_id FROM clientes WHERE email IS NULL
INTERSECT
SELECT cliente_id FROM fornecedores WHERE email IS NULL;
```

**Comportamento:**

- NULL é tratado como valor para comparação
- INTERSECT funciona corretamente com NULL

## Pros e Contras

### Pros

1. **Simplicidade**: Operações de conjunto são simples de usar

```sql
-- Simples
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;
```

1. **Legibilidade**: Expressa claramente a intenção de combinar conjuntos

```sql
-- Legível
SELECT ... FROM tabela1
INTERSECT
SELECT ... FROM tabela2;
```

1. **Performance**: UNION ALL é geralmente mais rápido que JOIN para grandes conjuntos

### Contras

1. **Tipos de dados**: Colunas devem ter tipos compatíveis

```sql
-- Erro se tipos não forem compatíveis
SELECT nome, idade FROM tabela1
UNION
SELECT nome, salario FROM tabela2; -- idade e salario podem ter tipos diferentes
```

1. **Ordem das colunas**: Colunas são combinadas por posição, não por nome

```sql
-- Perigoso se ordem for diferente
SELECT nome, email FROM clientes
UNION
SELECT email, nome FROM fornecedores; -- colunas trocadas
```

1. **LIMITações**: Não pode usar ORDER BY em cada consulta individual

```sql
-- Erro
SELECT ... FROM tabela1 ORDER BY nome
UNION
SELECT ... FROM tabela2;
```

## Cenários a Considerar

### Cenário 1: Combinar tabelas similares

**Recomendação:** Usar `UNION` ou `UNION ALL`

```sql
SELECT ... FROM tabela1
UNION ALL
SELECT ... FROM tabela2;
```

### Cenário 2: Encontrar interseção

**Recomendação:** Usar `INTERSECT`

```sql
SELECT ... FROM tabela1
INTERSECT
SELECT ... FROM tabela2;
```

### Cenário 3: Encontrar diferença

**Recomendação:** Usar `EXCEPT`

```sql
SELECT ... FROM tabela1
EXCEPT
SELECT ... FROM tabela2;
```

### Cenário 4: Performance crítica

**Recomendação:** Usar `UNION ALL` se duplicatas não forem problema

```sql
-- Mais rápido
SELECT ... FROM tabela1
UNION ALL
SELECT ... FROM tabela2;
```

### Cenário 5: MySQL (não suporta INTERSECT/EXCEPT)

**Recomendação:** Usar JOIN ou subqueries

```sql
-- INTERSECT em MySQL
SELECT DISTINCT t1.coluna
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.coluna = t2.coluna;

-- EXCEPT em MySQL
SELECT DISTINCT t1.coluna
FROM tabela1 t1
LEFT JOIN tabela2 t2 ON t1.coluna = t2.coluna
WHERE t2.coluna IS NULL;
```

## Set Operations vs Alternativas

### UNION vs JOIN

```sql
-- UNION (combina linhas verticalmente)
SELECT nome FROM clientes
UNION
SELECT nome FROM fornecedores;

-- JOIN (combina linhas horizontalmente)
SELECT c.nome, f.nome
FROM clientes c
FULL JOIN fornecedores f ON c.nome = f.nome;
```

**Escolha:** UNION para combinar conjuntos, JOIN para relacionar dados.

### UNION ALL vs UNION

```sql
-- UNION ALL (mais rápido, mantém duplicatas)
SELECT ... FROM tabela1
UNION ALL
SELECT ... FROM tabela2;

-- UNION (mais lento, remove duplicatas)
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;
```

**Escolha:** UNION ALL para performance se duplicatas não importam, UNION para remover duplicatas.

### INTERSECT vs INNER JOIN

```sql
-- INTERSECT (mais legível)
SELECT cliente_id FROM pedidos_2023
INTERSECT
SELECT cliente_id FROM pedidos_2024;

-- INNER JOIN (mais flexível)
SELECT DISTINCT p2023.cliente_id
FROM pedidos_2023 p2023
INNER JOIN pedidos_2024 p2024 ON p2023.cliente_id = p2024.cliente_id;
```

**Escolha:** INTERSECT para simplicidade, INNER JOIN para flexibilidade.

### EXCEPT vs LEFT JOIN

```sql
-- EXCEPT (mais legível)
SELECT cliente_id FROM pedidos_2023
EXCEPT
SELECT cliente_id FROM pedidos_2024;

-- LEFT JOIN (mais flexível)
SELECT DISTINCT p2023.cliente_id
FROM pedidos_2023 p2023
LEFT JOIN pedidos_2024 p2024 ON p2023.cliente_id = p2024.cliente_id
WHERE p2024.cliente_id IS NULL;
```

**Escolha:** EXCEPT para simplicidade, LEFT JOIN para flexibilidade.

## Dicas de Performance

1. **Use UNION ALL quando possível**: UNION ALL é mais rápido que UNION

```sql
-- Mais rápido
SELECT ... FROM tabela1
UNION ALL
SELECT ... FROM tabela2;
```

1. **Use índices**: As consultas individuais podem usar índices

```sql
-- Pode usar índice em cliente_id
SELECT cliente_id FROM pedidos WHERE cliente_id = 1
UNION
SELECT cliente_id FROM pedidos WHERE cliente_id = 2;
```

1. **Limite o resultado**: Use LIMIT para reduzir o tamanho do resultado

```sql
-- Bom para performance
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2
LIMIT 100;
```

1. **Evite ORDER BY em cada consulta**: Use ORDER BY apenas no final

```sql
-- Errado
SELECT ... FROM tabela1 ORDER BY nome
UNION
SELECT ... FROM tabela2;

-- Correto
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2
ORDER BY nome;
```

## Exemplos Avançados

### Exemplo 1: UNION com agregação

```sql
-- Comparar totais de diferentes fontes
SELECT 'clientes' as fonte, COUNT(*) as total
FROM clientes
UNION
SELECT 'fornecedores' as fonte, COUNT(*) as total
FROM fornecedores
UNION
SELECT 'produtos' as fonte, COUNT(*) as total
FROM produtos;
```

### Exemplo 2: UNION com WHERE

```sql
-- Combinar resultados com filtros diferentes
SELECT nome, email FROM clientes WHERE cidade = 'São Paulo'
UNION
SELECT nome, email FROM clientes WHERE cidade = 'Rio de Janeiro'
ORDER BY nome;
```

### Exemplo 3: INTERSECT com múltiplas colunas

```sql
-- Encontrar produtos iguais em duas lojas
SELECT produto_id, preco
FROM produtos_loja1
INTERSECT
SELECT produto_id, preco
FROM produtos_loja2;
```

### Exemplo 4: EXCEPT com subquery

```sql
-- Encontrar produtos sem vendas
SELECT produto_id FROM produtos
EXCEPT
SELECT DISTINCT produto_id FROM itens_pedido;
```

### Exemplo 5: Múltiplas operações

```sql
-- Análise complexa com múltiplas operações
WITH clientes_2023 AS (SELECT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM data_pedido) = 2023),
     clientes_2024 AS (SELECT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM data_pedido) = 2024)
SELECT 'apenas_2023' as tipo, COUNT(*) as total
FROM clientes_2023
EXCEPT
SELECT cliente_id FROM clientes_2024
UNION ALL
SELECT 'apenas_2024' as tipo, COUNT(*) as total
FROM clientes_2024
EXCEPT
SELECT cliente_id FROM clientes_2023
UNION ALL
SELECT 'ambos' as tipo, COUNT(*) as total
FROM clientes_2023
INTERSECT
SELECT cliente_id FROM clientes_2024;
```

## Set Operations em Diferentes Bancos

### PostgreSQL

```sql
-- Todas as operações suportadas
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
INTERSECT
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
EXCEPT
SELECT ... FROM tabela2;
```

### MySQL

```sql
-- UNION e UNION ALL suportados
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;

-- INTERSECT não suportado (use JOIN)
SELECT DISTINCT t1.coluna
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.coluna = t2.coluna;

-- EXCEPT não suportado (use LEFT JOIN)
SELECT DISTINCT t1.coluna
FROM tabela1 t1
LEFT JOIN tabela2 t2 ON t1.coluna = t2.coluna
WHERE t2.coluna IS NULL;
```

### SQL Server

```sql
-- Todas as operações suportadas
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
INTERSECT
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
EXCEPT
SELECT ... FROM tabela2;
```

### Oracle

```sql
-- Todas as operações suportadas (EXCEPT é MINUS)
SELECT ... FROM tabela1
UNION
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
INTERSECT
SELECT ... FROM tabela2;

SELECT ... FROM tabela1
MINUS
SELECT ... FROM tabela2;
```

## Resumo

- **Use UNION quando**: Combinar conjuntos removendo duplicatas
- **Use UNION ALL quando**: Combinar conjuntos mantendo duplicatas, performance é crítica
- **Use INTERSECT quando**: Encontrar interseção entre conjuntos
- **Use EXCEPT quando**: Encontrar diferença entre conjuntos
- **Evite set operations quando**: Precisa relacionar dados (use JOIN), tipos de dados incompatíveis
- **Alternativas**: JOIN para relacionar dados, subqueries para INTERSECT/EXCEPT em MySQL
- **NULL**: NULL é tratado como valor normal em set operations
- **Performance**: UNION ALL é mais rápido que UNION, use índices nas consultas individuais
- **Compatibilidade**: MySQL não suporta INTERSECT/EXCEPT, Oracle usa MINUS ao invés de EXCEPT
- **Regra de ouro**: UNION ALL para performance, UNION para unicidade, JOIN para relacionamento
