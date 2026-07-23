# EXISTS

O operador `EXISTS` é usado para verificar se uma subquery retorna pelo menos uma linha. É uma alternativa eficiente ao `IN` para verificar a existência de registros, especialmente quando a subquery pode retornar muitos valores ou quando NULL é um problema.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE EXISTS (subquery);
```

## Como Funciona - Passo a Passo

### Passo 1: A subquery é executada

A subquery é executada para cada linha da tabela principal (correlated subquery) ou apenas uma vez (non-correlated subquery).

### Passo 2: Verificação de existência

O operador `EXISTS` verifica se a subquery retornou pelo menos uma linha. Se retornou, o resultado é TRUE. Se não retornou nenhuma linha, o resultado é FALSE.

### Passo 3: Short-circuit evaluation

Diferente do `IN`, o `EXISTS` para de processar assim que encontra a primeira linha que satisfaz a condição. Isso é chamado de short-circuit evaluation e pode melhorar significativamente a performance.

## Exemplos Práticos

### Exemplo 1: EXISTS básico

```sql
-- Encontrar clientes que fizeram pelo menos um pedido
SELECT id, nome, email
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Explicação detalhada:**

1. Para cada cliente na tabela `clientes`, o banco executa a subquery
2. A subquery verifica se existe pelo menos um pedido para esse cliente
3. Se existir, `EXISTS` retorna TRUE e o cliente é incluído no resultado
4. Se não existir, `EXISTS` retorna FALSE e o cliente é excluído

**Nota:** O valor retornado pela subquery não importa (pode ser 1, *, ou qualquer coluna). O importante é se existe pelo menos uma linha.

### Exemplo 2: EXISTS com condição adicional

```sql
-- Encontrar clientes que fizeram pedidos em 2024
SELECT id, nome, email
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2024
);
```

**Explicação detalhada:**

1. A subquery filtra pedidos pelo cliente E pelo ano de 2024
2. Se existir pelo menos um pedido em 2024 para o cliente, ele é retornado
3. Se não existir nenhum pedido em 2024, o cliente não é retornado

### Exemplo 3: EXISTS com JOIN

```sql
-- Encontrar produtos que foram vendidos em uma quantidade maior que 10
SELECT id, nome, preco
FROM produtos p
WHERE EXISTS (
    SELECT 1
    FROM itens_pedido ip
    JOIN pedidos ped ON ip.pedido_id = ped.id
    WHERE ip.produto_id = p.id
    AND ip.quantidade > 10
);
```

## Comportamento com NULL

### Cenário 1: Subquery retornando NULL

```sql
SELECT nome
FROM clientes c
WHERE EXISTS (
    SELECT NULL
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Comportamento:**

- Se a subquery retornar pelo menos uma linha (mesmo que seja NULL), `EXISTS` retorna TRUE
- Se a subquery não retornar nenhuma linha, `EXISTS` retorna FALSE

**Resultado:** `EXISTS` não é afetado por NULL na subquery. Ele apenas verifica se existe pelo menos uma linha.

### Cenário 2: Coluna na subquery sendo NULL

```sql
SELECT nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND p.status = NULL
);
```

**Comportamento:**

- A comparação `p.status = NULL` sempre retorna UNKNOWN
- Portanto, a subquery não retornará nenhuma linha
- `EXISTS` retornará FALSE

**Resultado:** Use `IS NULL` em vez de `= NULL`.

### Cenário 3: EXISTS vs NULL na tabela principal

```sql
SELECT nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Comportamento:**

- Se `c.id` for NULL, a comparação `p.cliente_id = c.id` será UNKNOWN
- A subquery não retornará linhas
- `EXISTS` retornará FALSE

**Resultado:** Linhas com NULL na coluna usada na correlação não serão retornadas.

## Pros e Contras

### Pros

1. **Performance**: `EXISTS` geralmente é mais eficiente que `IN` para subqueries que retornam muitos valores

```sql
-- EXISTS (geralmente mais rápido)
WHERE EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- IN (pode ser mais lento se subquery retorna muitos valores)
WHERE id IN (SELECT produto_id FROM vendas)
```

1. **Short-circuit**: Para de processar assim que encontra a primeira correspondência

2. **NULL-safe**: Não é afetado por NULL na subquery

```sql
-- EXISTS funciona corretamente mesmo se subquery retorna NULL
WHERE EXISTS (SELECT NULL FROM tabela WHERE condicao)
```

1. **Semântica clara**: Expressa claramente a intenção de verificar existência

### Contras

1. **Legibilidade**: Para iniciantes, `EXISTS` pode ser menos intuitivo que `IN`

2. **Correlated subquery**: Geralmente é uma correlated subquery, que pode ser menos eficiente em alguns casos

3. **Dificuldade de debug**: Mais difícil de debugar que `IN` com lista literal

## Cenários a Considerar

### Cenário 1: Subquery retornando poucos valores

**Recomendação:** `IN` pode ser mais legível

```sql
-- IN (mais legível)
WHERE id IN (1, 2, 3, 4, 5)

-- EXISTS (menos legível)
WHERE EXISTS (SELECT 1 FROM tabela WHERE tabela.id = produtos.id AND tabela.id IN (1, 2, 3, 4, 5))
```

### Cenário 2: Subquery retornando muitos valores

**Recomendação:** `EXISTS` é geralmente mais eficiente

```sql
-- EXISTS (recomendado)
WHERE EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- IN (pode ser lento)
WHERE id IN (SELECT produto_id FROM vendas)
```

### Cenário 3: Subquery pode retornar NULL

**Recomendação:** `EXISTS` é a melhor escolha

```sql
-- EXISTS (funciona corretamente)
WHERE EXISTS (SELECT 1 FROM tabela WHERE condicao)

-- IN (pode não funcionar se houver NULL)
WHERE id IN (SELECT id FROM tabela WHERE condicao)
```

### Cenário 4: Verificação de existência com condição complexa

**Recomendação:** `EXISTS` é ideal

```sql
-- EXISTS (ideal para condições complexas)
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    JOIN itens_pedido ip ON p.id = ip.pedido_id
    WHERE p.cliente_id = clientes.id
    AND ip.quantidade > 10
    AND p.data_pedido >= '2024-01-01'
)
```

## EXISTS vs Alternativas

### EXISTS vs IN

```sql
-- EXISTS (recomendado para subqueries)
WHERE EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- IN (recomendado para listas literais)
WHERE id IN (1, 2, 3, 4, 5)
```

**Escolha:** `EXISTS` para subqueries, `IN` para listas literais.

### EXISTS vs JOIN

```sql
-- EXISTS (verifica existência)
SELECT * FROM produtos p
WHERE EXISTS (SELECT 1 FROM vendas v WHERE v.produto_id = p.id)

-- JOIN (retorna dados relacionados)
SELECT DISTINCT p.*
FROM produtos p
JOIN vendas v ON p.id = v.produto_id
```

**Escolha:** `EXISTS` para verificar existência, `JOIN` quando precisa dos dados relacionados.

### EXISTS vs COUNT

```sql
-- EXISTS (mais eficiente - para no primeiro resultado)
WHERE EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- COUNT (menos eficiente - conta todas as linhas)
WHERE (SELECT COUNT(*) FROM vendas WHERE vendas.produto_id = produtos.id) > 0
```

**Escolha:** `EXISTS` é sempre mais eficiente que `COUNT(*) > 0`.

## Dicas de Performance

1. **Índices**: Certifique-se de que as colunas usadas na correlação têm índices

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);
```

1. **Use SELECT 1**: Não importa o que a subquery retorna, use `SELECT 1` para clareza

```sql
-- Recomendado
WHERE EXISTS (SELECT 1 FROM tabela WHERE condicao)

-- Funciona, mas menos claro
WHERE EXISTS (SELECT * FROM tabela WHERE condicao)
```

1. **Evite SELECT ***: `SELECT *` na subquery é desnecessário e pode ser menos eficiente

```sql
-- Ruim
WHERE EXISTS (SELECT * FROM tabela WHERE condicao)

-- Bom
WHERE EXISTS (SELECT 1 FROM tabela WHERE condicao)
```

1. **Use EXISTS para NOT IN**: `NOT EXISTS` é mais seguro que `NOT IN` com NULL

```sql
-- Recomendado
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE tabela.id = produtos.id)

-- Perigoso se houver NULL
WHERE id NOT IN (SELECT id FROM tabela)
```

## Exemplos Avançados

### Exemplo 1: EXISTS com agregação

```sql
-- Encontrar clientes cujo total de pedidos é maior que 1000
SELECT id, nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    GROUP BY p.cliente_id
    HAVING SUM(p.valor) > 1000
);
```

### Exemplo 2: EXISTS múltiplos (aninhado)

```sql
-- Encontrar clientes que fizeramente pedidos em 2023 e 2024
SELECT id, nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2023
)
AND EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2024
);
```

### Exemplo 3: EXISTS com CASE

```sql
SELECT 
    id,
    nome,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pedidos p 
            WHERE p.cliente_id = c.id 
            AND YEAR(p.data_pedido) = 2024
        ) THEN 'Cliente Ativo 2024'
        ELSE 'Cliente Inativo 2024'
    END as status_2024
FROM clientes c;
```

### Exemplo 4: EXISTS com NOT EXISTS

```sql
-- Encontrar clientes que fizeram pedidos em 2024 mas não em 2023
SELECT id, nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2024
)
AND NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2023
);
```

## EXISTS Correlated vs Non-Correlated

### Correlated EXISTS

```sql
-- Correlated: subquery é executada para cada linha
SELECT * FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);
```

**Características:**

- Subquery referencia tabela externa
- Executada para cada linha da tabela principal
- Pode ser menos eficiente se a tabela principal for grande

### Non-Correlated EXISTS

```sql
-- Non-correlated: subquery é executada apenas uma vez
SELECT * FROM clientes
WHERE EXISTS (
    SELECT 1 FROM pedidos WHERE valor > 1000
);
```

**Características:**

- Subquery não referencia tabela externa
- Executada apenas uma vez
- Geralmente mais eficiente

## Resumo

- **Use EXISTS quando**: Verificar existência de registros, subquery retorna muitos valores, NULL é um problema, performance é crítica
- **Evite EXISTS quando**: Lista pequena de valores literais (use IN), legibilidade é prioritária para iniciantes
- **Alternativas**: IN para listas literais, JOIN quando precisa dos dados relacionados
- **NULL**: EXISTS é NULL-safe, não é afetado por NULL na subquery
- **Performance**: EXISTS geralmente é mais eficiente que IN para subqueries, especialmente com short-circuit
- **Regra de ouro**: Para verificar existência, EXISTS é geralmente a melhor escolha
