# LEFT JOIN

O `LEFT JOIN` (ou `LEFT OUTER JOIN`) retorna todas as linhas da tabela à esquerda (primeira tabela) e as linhas correspondentes da tabela à direita (segunda tabela). Se não houver correspondência, retorna NULL para as colunas da tabela à direita.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table1
LEFT JOIN table2 ON table1.column = table2.column;
```

## Como Funciona - Passo a Passo

### Passo 1: Produto cartesiano

O banco cria um produto cartesiano das duas tabelas (todas as combinações possíveis).

### Passo 2: Aplicação da condição ON

A condição ON é aplicada para filtrar as combinações.

### Passo 3: Retorno de todas as linhas da esquerda

Todas as linhas da tabela à esquerda são retornadas. Se não houver correspondência, NULL é usado para as colunas da tabela à direita.

## Exemplos Práticos

### Exemplo 1: LEFT JOIN básico

```sql
-- Listar todos os clientes com seus pedidos (se houver)
SELECT c.nome, p.id as pedido_id, p.data_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `clientes` (tabela à esquerda)
2. Para cada cliente, tenta encontrar pedidos correspondentes
3. Se houver pedidos, retorna os dados do pedido
4. Se não houver pedidos, retorna NULL para as colunas de pedidos

### Exemplo 2: LEFT JOIN com WHERE

```sql
-- Listar clientes sem pedidos
SELECT c.nome, c.email
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `clientes`
2. Para cada cliente, tenta encontrar pedidos correspondentes
3. O WHERE filtra para manter apenas clientes onde `p.id IS NULL`
4. Retorna apenas clientes sem pedidos

### Exemplo 3: LEFT JOIN com múltiplas tabelas

```sql
-- Listar todos os produtos com suas categorias (se houver)
SELECT p.nome, c.nome as categoria
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `produtos`
2. Para cada produto, tenta encontrar a categoria correspondente
3. Se houver categoria, retorna o nome da categoria
4. Se não houver categoria, retorna NULL para o nome da categoria

### Exemplo 4: LEFT JOIN com agregação

```sql
-- Contar pedidos por cliente (incluindo clientes sem pedidos)
SELECT c.nome, COUNT(p.id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `clientes`
2. Para cada cliente, conta os pedidos correspondentes
3. Se não houver pedidos, COUNT retorna 0 (não NULL)
4. Retorna todos os clientes com o total de pedidos

### Exemplo 5: LEFT JOIN com COALESCE

```sql
-- Listar clientes com nome do departamento (ou 'Sem departamento')
SELECT f.nome, COALESCE(d.nome, 'Sem departamento') as departamento
FROM funcionarios f
LEFT JOIN departamentos d ON f.departamento_id = d.id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `funcionarios`
2. Para cada funcionário, tenta encontrar o departamento correspondente
3. Se houver departamento, retorna o nome do departamento
4. Se não houver departamento (NULL), COALESCE substitui por 'Sem departamento'

## Comportamento com NULL

### Cenário 1: LEFT JOIN com NULL na coluna de junção

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se `cliente_id` for NULL em pedidos, essas linhas não correspondem a nenhum cliente
- Se `id` for NULL em clientes, essas linhas são retornadas com NULL em pedidos
- LEFT JOIN retorna todas as linhas da esquerda, mesmo com NULL na coluna de junção

### Cenário 2: LEFT JOIN com NULL no resultado

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se um cliente não tiver pedidos, as colunas de pedidos serão NULL
- Isso é normal e esperado em LEFT JOIN
- Use COALESCE ou IS NULL para tratar esses casos

## Pros e Contras

### Pros

1. **Preserva dados**: Retorna todas as linhas da tabela à esquerda

```sql
-- Todos os clientes, com ou sem pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

1. **Flexibilidade**: Permite encontrar linhas sem correspondência

2. **Agregação completa**: COUNT com LEFT JOIN inclui zeros para linhas sem correspondência

### Contras

1. **Performance**: Pode ser mais lento que INNER JOIN

```sql
-- Pode ser mais lento que INNER JOIN
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

1. **NULL handling**: Precisa tratar NULL no resultado

2. **Tamanho do resultado**: Pode retornar mais linhas que INNER JOIN

## Cenários a Considerar

### Cenário 1: Correspondências opcionais

**Recomendação:** Usar `LEFT JOIN`

```sql
-- Todos os clientes, com ou sem pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

### Cenário 2: Encontrar linhas sem correspondência

**Recomendação:** Usar `LEFT JOIN` com `IS NULL`

```sql
-- Clientes sem pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL
```

### Cenário 3: Agregação incluindo zeros

**Recomendação:** Usar `LEFT JOIN` com `COUNT`

```sql
-- Total de pedidos por cliente (incluindo zeros)
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
```

### Cenário 4: Hierarquias opcionais

**Recomendação:** Usar `LEFT JOIN` para tabelas opcionais

```sql
-- Produtos com categorias opcionais
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
```

### Cenário 5: Substituir NULL por valor padrão

**Recomendação:** Usar `LEFT JOIN` com `COALESCE`

```sql
-- Funcionários com departamento (ou 'Sem departamento')
FROM funcionarios f
LEFT JOIN departamentos d ON f.departamento_id = d.id
```

## LEFT JOIN vs Alternativas

### LEFT JOIN vs INNER JOIN

```sql
-- LEFT JOIN (todas as linhas da esquerda)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- INNER JOIN (apenas correspondências)
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `LEFT JOIN` para preservar todas as linhas da esquerda, `INNER JOIN` para apenas correspondências.

### LEFT JOIN vs RIGHT JOIN

```sql
-- LEFT JOIN (todas as linhas da esquerda)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- RIGHT JOIN (todas as linhas da direita)
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `LEFT JOIN` é mais comum e legível. `RIGHT JOIN` pode ser substituído invertendo as tabelas.

### LEFT JOIN vs FULL JOIN

```sql
-- LEFT JOIN (todas as linhas da esquerda)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- FULL JOIN (todas as linhas de ambas)
SELECT c.nome, p.id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `LEFT JOIN` para preservar linhas da esquerda, `FULL JOIN` para preservar linhas de ambas.

## Dicas de Performance

1. **Use índices nas colunas de junção**: Índices podem melhorar performance significativamente

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);

-- Pode usar índice
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

1. **Filtre antes de JOIN**: Use WHERE para reduzir o número de linhas antes do JOIN

```sql
-- Bom (filtra antes)
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.cidade = 'São Paulo'
```

1. **Use LEFT JOIN apenas quando necessário**: Se todas as linhas têm correspondência, INNER JOIN é mais eficiente

```sql
-- Se todos os clientes têm pedidos, INNER JOIN é mais eficiente
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
```

1. **Evite LEFT JOIN em colunas sem índice**: Pode resultar em full table scan

```sql
-- Pode ser lento se colunas não tiverem índice
FROM tabela1 t1
LEFT JOIN tabela2 t2 ON t1.coluna_sem_indice = t2.coluna_sem_indice
```

## Exemplos Avançados

### Exemplo 1: LEFT JOIN com subquery

```sql
-- Clientes com total gasto (ou 0 se não tiver pedidos)
SELECT c.nome, COALESCE(SUM(p.valor_total), 0) as total_gasto
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

### Exemplo 2: LEFT JOIN com múltiplas tabelas

```sql
-- Produtos com categoria e fornecedor (se houver)
SELECT p.nome, c.nome as categoria, f.nome as fornecedor
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN fornecedores f ON p.fornecedor_id = f.id;
```

### Exemplo 3: LEFT JOIN com HAVING

```sql
-- Clientes com menos de 3 pedidos (incluindo zero)
SELECT c.nome, COUNT(p.id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
HAVING COUNT(p.id) < 3;
```

### Exemplo 4: LEFT JOIN para encontrar órfãos

```sql
-- Pedidos sem cliente (dados inconsistentes)
SELECT p.id, p.data_pedido, p.cliente_id
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id
WHERE c.id IS NULL;
```

### Exemplo 5: LEFT JOIN com CASE

```sql
-- Classificar clientes por atividade
SELECT c.nome,
    CASE 
        WHEN p.id IS NULL THEN 'Sem pedidos'
        WHEN COUNT(p.id) < 5 THEN 'Baixa atividade'
        WHEN COUNT(p.id) BETWEEN 5 AND 20 THEN 'Média atividade'
        ELSE 'Alta atividade'
    END as nivel_atividade
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome, p.id;
```

## LEFT JOIN em Diferentes Bancos

### MySQL

```sql
-- LEFT JOIN padrão
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT OUTER JOIN (equivalente)
FROM clientes c
LEFT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### PostgreSQL

```sql
-- LEFT JOIN padrão
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT OUTER JOIN (equivalente)
FROM clientes c
LEFT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### SQL Server

```sql
-- LEFT JOIN padrão
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT OUTER JOIN (equivalente)
FROM clientes c
LEFT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

## Resumo

- **Use LEFT JOIN quando**: Precisa preservar todas as linhas da tabela à esquerda, encontrar linhas sem correspondência
- **Evite LEFT JOIN quando**: Todas as linhas têm correspondência (use INNER JOIN)
- **Alternativas**: INNER JOIN para apenas correspondências, RIGHT JOIN para preservar direita, FULL JOIN para preservar ambas
- **NULL**: LEFT JOIN retorna NULL para colunas da direita quando não há correspondência
- **Performance**: Use índices nas colunas de junção, LEFT JOIN pode ser mais lento que INNER JOIN
- **Filtragem**: Use IS NULL para encontrar linhas sem correspondência
- **Regra de ouro**: LEFT JOIN para preservar linhas da esquerda, INNER JOIN para apenas correspondências
