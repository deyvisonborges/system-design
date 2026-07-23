# RIGHT JOIN

O `RIGHT JOIN` (ou `RIGHT OUTER JOIN`) retorna todas as linhas da tabela à direita (segunda tabela) e as linhas correspondentes da tabela à esquerda (primeira tabela). Se não houver correspondência, retorna NULL para as colunas da tabela à esquerda.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table1
RIGHT JOIN table2 ON table1.column = table2.column;
```

## Como Funciona - Passo a Passo

### Passo 1: Produto cartesiano

O banco cria um produto cartesiano das duas tabelas (todas as combinações possíveis).

### Passo 2: Aplicação da condição ON

A condição ON é aplicada para filtrar as combinações.

### Passo 3: Retorno de todas as linhas da direita

Todas as linhas da tabela à direita são retornadas. Se não houver correspondência, NULL é usado para as colunas da tabela à esquerda.

## Exemplos Práticos

### Exemplo 1: RIGHT JOIN básico

```sql
-- Listar todos os pedidos com seus clientes (se houver)
SELECT c.nome, p.id as pedido_id, p.data_pedido
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `pedidos` (tabela à direita)
2. Para cada pedido, tenta encontrar o cliente correspondente
3. Se houver cliente, retorna os dados do cliente
4. Se não houver cliente, retorna NULL para as colunas de clientes

### Exemplo 2: RIGHT JOIN com WHERE

```sql
-- Listar pedidos sem cliente (dados inconsistentes)
SELECT p.id, p.data_pedido, p.cliente_id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `pedidos`
2. Para cada pedido, tenta encontrar o cliente correspondente
3. O WHERE filtra para manter apenas pedidos onde `c.id IS NULL`
4. Retorna apenas pedidos sem cliente (dados inconsistentes)

### Exemplo 3: RIGHT JOIN com múltiplas tabelas

```sql
-- Listar todas as categorias com seus produtos (se houver)
SELECT c.nome as categoria, p.nome as produto
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `categorias`
2. Para cada categoria, tenta encontrar produtos correspondentes
3. Se houver produtos, retorna os dados dos produtos
4. Se não houver produtos, retorna NULL para as colunas de produtos

### Exemplo 4: RIGHT JOIN com agregação

```sql
-- Contar produtos por categoria (incluindo categorias sem produtos)
SELECT c.nome as categoria, COUNT(p.id) as total_produtos
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nome;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `categorias`
2. Para cada categoria, conta os produtos correspondentes
3. Se não houver produtos, COUNT retorna 0 (não NULL)
4. Retorna todas as categorias com o total de produtos

### Exemplo 5: RIGHT JOIN com COALESCE

```sql
-- Listar departamentos com funcionário responsável (ou 'Sem responsável')
SELECT d.nome as departamento, COALESCE(f.nome, 'Sem responsável') as responsavel
FROM funcionarios f
RIGHT JOIN departamentos d ON f.departamento_id = d.id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `departamentos`
2. Para cada departamento, tenta encontrar o funcionário correspondente
3. Se houver funcionário, retorna o nome do funcionário
4. Se não houver funcionário (NULL), COALESCE substitui por 'Sem responsável'

## Comportamento com NULL

### Cenário 1: RIGHT JOIN com NULL na coluna de junção

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se `cliente_id` for NULL em pedidos, essas linhas são retornadas com NULL em clientes
- Se `id` for NULL em clientes, essas linhas não correspondem a nenhum pedido
- RIGHT JOIN retorna todas as linhas da direita, mesmo com NULL na coluna de junção

### Cenário 2: RIGHT JOIN com NULL no resultado

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se um pedido não tiver cliente, as colunas de clientes serão NULL
- Isso é normal e esperado em RIGHT JOIN
- Use COALESCE ou IS NULL para tratar esses casos

## Pros e Contras

### Pros

1. **Preserva dados**: Retorna todas as linhas da tabela à direita

```sql
-- Todos os pedidos, com ou sem cliente
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
```

1. **Flexibilidade**: Permite encontrar linhas sem correspondência

2. **Agregação completa**: COUNT com RIGHT JOIN inclui zeros para linhas sem correspondência

### Contras

1. **Performance**: Pode ser mais lento que INNER JOIN

```sql
-- Pode ser mais lento que INNER JOIN
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
```

1. **NULL handling**: Precisa tratar NULL no resultado

2. **Legibilidade**: RIGHT JOIN é menos comum e pode ser confuso

## Cenários a Considerar

### Cenário 1: Correspondências opcionais na direita

**Recomendação:** Usar `RIGHT JOIN` ou inverter as tabelas e usar `LEFT JOIN`

```sql
-- RIGHT JOIN
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- Equivalente com LEFT JOIN (mais legível)
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id
```

### Cenário 2: Encontrar linhas sem correspondência na direita

**Recomendação:** Usar `RIGHT JOIN` com `IS NULL` ou inverter as tabelas

```sql
-- RIGHT JOIN
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL;

-- Equivalente com LEFT JOIN
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id
WHERE c.id IS NULL
```

### Cenário 3: Agregação incluindo zeros

**Recomendação:** Usar `RIGHT JOIN` com `COUNT` ou inverter as tabelas

```sql
-- RIGHT JOIN
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nome;

-- Equivalente com LEFT JOIN
FROM categorias c
LEFT JOIN produtos p ON c.categoria_id = c.id
GROUP BY c.id, c.nome
```

### Cenário 4: Hierarquias opcionais

**Recomendação:** Usar `RIGHT JOIN` ou inverter as tabelas e usar `LEFT JOIN`

```sql
-- RIGHT JOIN
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Equivalente com LEFT JOIN
FROM categorias c
LEFT JOIN produtos p ON c.categoria_id = c.id
```

### Cenário 5: Substituir NULL por valor padrão

**Recomendação:** Usar `RIGHT JOIN` com `COALESCE` ou inverter as tabelas

```sql
-- RIGHT JOIN
FROM funcionarios f
RIGHT JOIN departamentos d ON f.departamento_id = d.id;

-- Equivalente com LEFT JOIN
FROM departamentos d
LEFT JOIN funcionarios f ON d.id = f.departamento_id
```

## RIGHT JOIN vs Alternativas

### RIGHT JOIN vs LEFT JOIN

```sql
-- RIGHT JOIN (todas as linhas da direita)
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT JOIN (todas as linhas da esquerda - equivalente invertendo)
SELECT c.nome, p.id
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id;
```

**Escolha:** `LEFT JOIN` é mais comum e legível. `RIGHT JOIN` pode ser substituído invertendo as tabelas.

### RIGHT JOIN vs INNER JOIN

```sql
-- RIGHT JOIN (todas as linhas da direita)
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- INNER JOIN (apenas correspondências)
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `RIGHT JOIN` para preservar linhas da direita, `INNER JOIN` para apenas correspondências.

### RIGHT JOIN vs FULL JOIN

```sql
-- RIGHT JOIN (todas as linhas da direita)
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- FULL JOIN (todas as linhas de ambas)
SELECT c.nome, p.id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `RIGHT JOIN` para preservar linhas da direita, `FULL JOIN` para preservar linhas de ambas.

## Dicas de Performance

1. **Use índices nas colunas de junção**: Índices podem melhorar performance significativamente

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);

-- Pode usar índice
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
```

1. **Prefira LEFT JOIN**: LEFT JOIN é mais legível e padrão

```sql
-- Prefira LEFT JOIN invertendo as tabelas
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id
```

1. **Filtre antes de JOIN**: Use WHERE para reduzir o número de linhas antes do JOIN

```sql
-- Bom (filtra antes)
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data_pedido > '2024-01-01'
```

1. **Evite RIGHT JOIN em colunas sem índice**: Pode resultar em full table scan

```sql
-- Pode ser lento se colunas não tiverem índice
FROM tabela1 t1
RIGHT JOIN tabela2 t2 ON t1.coluna_sem_indice = t2.coluna_sem_indice
```

## Exemplos Avançados

### Exemplo 1: RIGHT JOIN com subquery

```sql
-- Categorias com valor total de vendas (ou 0 se não tiver vendas)
SELECT c.nome, COALESCE(SUM(p.valor_total), 0) as total_vendas
FROM produtos prod
RIGHT JOIN categorias c ON prod.categoria_id = c.id
LEFT JOIN itens_pedido ip ON prod.id = ip.produto_id
LEFT JOIN pedidos p ON ip.pedido_id = p.id
GROUP BY c.id, c.nome;
```

### Exemplo 2: RIGHT JOIN com múltiplas tabelas

```sql
-- Departamentos com funcionários e projetos (se houver)
SELECT d.nome as departamento, f.nome as funcionario, proj.nome as projeto
FROM funcionarios f
RIGHT JOIN departamentos d ON f.departamento_id = d.id
LEFT JOIN projetos proj ON f.id = proj.gerente_id;
```

### Exemplo 3: RIGHT JOIN com HAVING

```sql
-- Categorias com menos de 3 produtos (incluindo zero)
SELECT c.nome, COUNT(p.id) as total_produtos
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nome
HAVING COUNT(p.id) < 3;
```

### Exemplo 4: RIGHT JOIN para encontrar órfãos

```sql
-- Pedidos sem cliente (dados inconsistentes)
SELECT p.id, p.data_pedido, p.cliente_id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL;
```

### Exemplo 5: RIGHT JOIN com CASE

```sql
-- Classificar categorias por número de produtos
SELECT c.nome,
    CASE 
        WHEN p.id IS NULL THEN 'Sem produtos'
        WHEN COUNT(p.id) < 5 THEN 'Poucos produtos'
        WHEN COUNT(p.id) BETWEEN 5 AND 20 THEN 'Média quantidade'
        ELSE 'Muitos produtos'
    END as nivel_produtos
FROM produtos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nome, p.id;
```

## RIGHT JOIN em Diferentes Bancos

### MySQL

```sql
-- RIGHT JOIN padrão
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- RIGHT OUTER JOIN (equivalente)
FROM clientes c
RIGHT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### PostgreSQL

```sql
-- RIGHT JOIN padrão
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- RIGHT OUTER JOIN (equivalente)
FROM clientes c
RIGHT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### SQL Server

```sql
-- RIGHT JOIN padrão
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- RIGHT OUTER JOIN (equivalente)
FROM clientes c
RIGHT OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

## Resumo

- **Use RIGHT JOIN quando**: Precisa preservar todas as linhas da tabela à direita
- **Evite RIGHT JOIN quando**: Pode inverter as tabelas e usar LEFT JOIN (mais legível)
- **Alternativas**: LEFT JOIN invertendo as tabelas (mais comum), INNER JOIN para apenas correspondências, FULL JOIN para preservar ambas
- **NULL**: RIGHT JOIN retorna NULL para colunas da esquerda quando não há correspondência
- **Performance**: Use índices nas colunas de junção, prefira LEFT JOIN invertendo as tabelas
- **Filtragem**: Use IS NULL para encontrar linhas sem correspondência
- **Regra de ouro**: Prefira LEFT JOIN invertendo as tabelas em vez de RIGHT JOIN
