# NOT IN

O operador `NOT IN` é usado para verificar se um valor NÃO está presente em uma lista de valores especificados. É o oposto do operador `IN` e é uma alternativa mais legível ao usar múltiplos operadores `AND` com `!=` ou `<>`.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE column_name NOT IN (value1, value2, value3, ...);
```

## Como Funciona - Passo a Passo

### Passo 1: O operador NOT IN avalia a condição

O operador `NOT IN` verifica se o valor da coluna NÃO está presente na lista de valores fornecida. Se não estiver, a linha é retornada.

### Passo 2: Equivalência com AND

Internamente, `NOT IN (value1, value2, value3)` é equivalente a:

```sql
column_name != value1 AND column_name != value2 AND column_name != value3
```

Porém, `NOT IN` é mais legível e geralmente mais eficiente.

## Exemplos Práticos

### Exemplo 1: Lista de valores literais

```sql
-- Encontrar clientes que NÃO são de cidades específicas
SELECT id, nome, cidade
FROM clientes
WHERE cidade NOT IN ('São Paulo', 'Rio de Janeiro', 'Belo Horizonte');
```

**Explicação detalhada:**

1. O banco de dados verifica cada linha da tabela `clientes`
2. Para cada linha, verifica se o valor da coluna `cidade` NÃO está na lista
3. Se não estiver, a linha é incluída no resultado
4. Se estiver, a linha é excluída

### Exemplo 2: NOT IN com subquery

```sql
-- Encontrar produtos que NÃO foram vendidos
SELECT id, nome, preco
FROM produtos
WHERE id NOT IN (SELECT produto_id FROM vendas);
```

**Explicação detalhada:**

1. A subquery `(SELECT produto_id FROM vendas)` é executada primeiro
2. Ela retorna uma lista de todos os `produto_id` presentes na tabela `vendas`
3. O operador `NOT IN` verifica se cada `produto.id` NÃO está nessa lista
4. Se não estiver, o produto é incluído no resultado

### Exemplo 3: NOT IN com múltiplas colunas (alguns bancos)

```sql
-- PostgreSQL: NOT IN com múltiplas colunas
SELECT *
FROM produtos
WHERE (categoria_id, preco) NOT IN (
    SELECT categoria_id, AVG(preco)
    FROM produtos
    GROUP BY categoria_id
);
```

## Comportamento com NULL - O Problema Crítico

### Cenário 1: Lista contendo NULL

```sql
SELECT nome
FROM clientes
WHERE cidade NOT IN ('São Paulo', NULL, 'Rio de Janeiro');
```

**Comportamento:**

- Se `cidade` for 'São Paulo' → retorna FALSE
- Se `cidade` for 'Rio de Janeiro' → retorna FALSE
- Se `cidade` for NULL → retorna UNKNOWN (não TRUE)
- Se `cidade` for 'Curitiba' → retorna UNKNOWN (devido ao NULL na lista)

**Resultado:** Se a lista contém NULL, `NOT IN` sempre retorna UNKNOWN para qualquer valor que não esteja explicitamente na lista. Isso significa que NENHUMA linha será retornada!

**Por que isso acontece?**

A lógica do `NOT IN` é:

```sql
cidade NOT IN ('São Paulo', NULL, 'Rio de Janeiro')
```

É equivalente a:

```sql
cidade != 'São Paulo' AND cidade != NULL AND cidade != 'Rio de Janeiro'
```

Como qualquer comparação com NULL retorna UNKNOWN, e UNKNOWN AND qualquer coisa = UNKNOWN, o resultado é sempre UNKNOWN.

### Cenário 2: Subquery retornando NULL

```sql
-- Encontrar clientes que não fizeram pedidos
SELECT nome
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);
```

**Problema:** Se `cliente_id` na tabela `pedidos` puder ser NULL, e existir algum NULL, então `NOT IN` não retornará nenhuma linha!

**Solução:** Filtrar NULLs na subquery

```sql
SELECT nome
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL);
```

### Cenário 3: Coluna contendo NULL

```sql
SELECT nome
FROM clientes
WHERE cidade NOT IN ('São Paulo', 'Rio de Janeiro');
```

**Comportamento:**

- Se `cidade` for NULL → retorna UNKNOWN (não TRUE)
- A linha não será retornada

**Resultado:** Linhas com NULL na coluna não são retornadas.

## Pros e Contras

### Pros

1. **Legibilidade**: `NOT IN` é muito mais legível que múltiplos `AND` com `!=`

```sql
-- Mais legível
WHERE cidade NOT IN ('SP', 'RJ', 'MG')

-- Menos legível
WHERE cidade != 'SP' AND cidade != 'RJ' AND cidade != 'MG'
```

1. **Manutenção**: Adicionar ou remover valores é mais fácil

```sql
-- Fácil adicionar mais valores
WHERE cidade NOT IN ('SP', 'RJ', 'MG', 'RS', 'PR')
```

1. **Subqueries**: Permite usar resultados de subqueries diretamente

```sql
WHERE id NOT IN (SELECT produto_id FROM vendas)
```

### Contras

1. **NULL handling**: Comportamento com NULL é perigoso e contra-intuitivo

```sql
-- Se a subquery retornar NULL, NENHUMA linha será retornada
WHERE id NOT IN (SELECT id FROM tabela WHERE condicao)
```

1. **Performance**: Pode ser lento com listas grandes ou subqueries que retornam muitos valores

```sql
-- Pode ser lento se a lista tiver milhares de valores
WHERE id NOT IN (1, 2, 3, ..., 10000)
```

1. **Limitações de tamanho**: Alguns bancos têm limites no tamanho da lista

## Cenários a Considerar

### Cenário 1: Lista pequena sem NULL

**Recomendação:** Usar `NOT IN` com lista literal

```sql
WHERE id NOT IN (1, 2, 3, 4, 5)
```

### Cenário 2: Lista grande (100+ valores)

**Recomendação:** Usar `NOT EXISTS` ou `LEFT JOIN`

```sql
-- Opção 1: NOT EXISTS (recomendado)
WHERE NOT EXISTS (SELECT 1 FROM tabela_temporaria WHERE tabela_temporaria.id = tabela.id)

-- Opção 2: LEFT JOIN
SELECT t1.*
FROM tabela1 t1
LEFT JOIN tabela_temporaria t2 ON t1.id = t2.id
WHERE t2.id IS NULL
```

### Cenário 3: Subquery que pode retornar NULL

**Recomendação:** Filtrar NULLs na subquery ou usar NOT EXISTS

```sql
-- Opção 1: Filtrar NULLs
WHERE id NOT IN (SELECT id FROM tabela WHERE id IS NOT NULL)

-- Opção 2: NOT EXISTS (recomendado)
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE tabela.id = produtos.id)
```

### Cenário 4: Subquery retornando muitos valores

**Recomendação:** Usar `NOT EXISTS` (geralmente mais eficiente)

```sql
-- NOT IN (pode ser lento)
WHERE id NOT IN (SELECT produto_id FROM vendas)

-- NOT EXISTS (geralmente mais eficiente)
WHERE NOT EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)
```

## NOT IN vs Alternativas

### NOT IN vs AND com !=

```sql
-- NOT IN (recomendado)
WHERE cidade NOT IN ('SP', 'RJ', 'MG')

-- AND com != (menos legível)
WHERE cidade != 'SP' AND cidade != 'RJ' AND cidade != 'MG'
```

**Escolha:** `NOT IN` é preferível por legibilidade.

### NOT IN vs LEFT JOIN

```sql
-- NOT IN
SELECT * FROM produtos
WHERE id NOT IN (SELECT produto_id FROM vendas)

-- LEFT JOIN (geralmente mais eficiente para grandes volumes)
SELECT p.*
FROM produtos p
LEFT JOIN vendas v ON p.id = v.produto_id
WHERE v.produto_id IS NULL
```

**Escolha:** `LEFT JOIN` para grandes volumes, `NOT IN` para pequenos volumes ou quando legibilidade é prioritária.

### NOT IN vs NOT EXISTS

```sql
-- NOT IN (cuidado com NULL!)
SELECT * FROM produtos
WHERE id NOT IN (SELECT produto_id FROM vendas)

-- NOT EXISTS (recomendado - não afetado por NULL)
SELECT * FROM produtos p
WHERE NOT EXISTS (SELECT 1 FROM vendas v WHERE v.produto_id = p.id)
```

**Escolha:** `NOT EXISTS` é geralmente recomendado porque não é afetado por NULL.

## Dicas de Performance

1. **Índices**: Certifique-se de que a coluna usada no `NOT IN` tem índice

```sql
CREATE INDEX idx_clientes_cidade ON clientes(cidade);
```

1. **Evite NOT IN com NULL**: Sempre filtre NULLs na subquery

```sql
-- Ruim (se houver NULL, não retorna nada)
WHERE id NOT IN (SELECT id FROM tabela)

-- Bom (filtra NULLs)
WHERE id NOT IN (SELECT id FROM tabela WHERE id IS NOT NULL)
```

1. **Prefira NOT EXISTS**: `NOT EXISTS` é geralmente mais eficiente e não tem problemas com NULL

```sql
-- Recomendado
WHERE NOT EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)
```

1. **Use LEFT JOIN para grandes volumes**: Para grandes volumes, LEFT JOIN pode ser mais eficiente

```sql
SELECT p.*
FROM produtos p
LEFT JOIN vendas v ON p.id = v.produto_id
WHERE v.produto_id IS NULL
```

## Exemplos Avançados

### Exemplo 1: NOT IN com CASE

```sql
SELECT 
    nome,
    CASE 
        WHEN regiao NOT IN ('Norte', 'Nordeste') THEN 'Outros'
        ELSE 'Norte/Nordeste'
    END as regiao_grupo
FROM estados;
```

### Exemplo 2: NOT IN com agregação

```sql
SELECT 
    categoria_id,
    COUNT(*) as total
FROM produtos
WHERE id NOT IN (SELECT produto_id FROM vendas WHERE data_venda >= '2024-01-01')
GROUP BY categoria_id;
```

### Exemplo 3: NOT IN múltiplos (aninhado)

```sql
SELECT *
FROM clientes
WHERE cidade NOT IN (
    SELECT cidade 
    FROM filiais 
    WHERE regiao NOT IN ('Sudeste', 'Sul')
);
```

## O Problema do NULL em Detalhe

### Por que NOT IN é perigoso com NULL?

Vamos analisar passo a passo:

```sql
SELECT * FROM produtos
WHERE id NOT IN (1, 2, NULL);
```

Isso é equivalente a:

```sql
SELECT * FROM produtos
WHERE id != 1 AND id != 2 AND id != NULL;
```

Para uma linha com `id = 3`:

- `3 != 1` → TRUE
- `3 != 2` → TRUE
- `3 != NULL` → UNKNOWN (qualquer comparação com NULL é UNKNOWN)
- `TRUE AND TRUE AND UNKNOWN` → UNKNOWN

Como UNKNOWN não é TRUE, a linha não é retornada!

### Como resolver?

#### **Solução 1: Filtrar NULLs na lista**

```sql
SELECT * FROM produtos
WHERE id NOT IN (SELECT id FROM tabela WHERE id IS NOT NULL);
```

#### **Solução 2: Usar NOT EXISTS**

```sql
SELECT * FROM produtos p
WHERE NOT EXISTS (SELECT 1 FROM tabela t WHERE t.id = p.id);
```

#### **Solução 3: Usar LEFT JOIN**

```sql
SELECT p.*
FROM produtos p
LEFT JOIN tabela t ON p.id = t.id
WHERE t.id IS NULL;
```

## Resumo

- **Use NOT IN quando**: Lista pequena, sem NULL, legibilidade é importante
- **Evite NOT IN quando**: Lista muito grande, subquery pode retornar NULL, performance é crítica
- **Alternativas**: NOT EXISTS (recomendado), LEFT JOIN para grandes volumes
- **NULL**: CUIDADO! NOT IN com NULL na lista ou subquery pode não retornar nenhuma linha
- **Regra de ouro**: Se a subquery pode ter NULL, use NOT EXISTS ou LEFT JOIN em vez de NOT IN
