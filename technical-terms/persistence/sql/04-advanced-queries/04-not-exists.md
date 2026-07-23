# NOT EXISTS

O operador `NOT EXISTS` é usado para verificar se uma subquery NÃO retorna nenhuma linha. É o oposto do operador `EXISTS` e é uma alternativa segura ao `NOT IN` para verificar a não existência de registros, especialmente quando NULL é um problema.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE NOT EXISTS (subquery);
```

## Como Funciona - Passo a Passo

### Passo 1: A subquery é executada

A subquery é executada para cada linha da tabela principal (correlated subquery) ou apenas uma vez (non-correlated subquery).

### Passo 2: Verificação de não existência

O operador `NOT EXISTS` verifica se a subquery NÃO retornou nenhuma linha. Se não retornou nenhuma linha, o resultado é TRUE. Se retornou pelo menos uma linha, o resultado é FALSE.

### Passo 3: Short-circuit evaluation

Diferente do `NOT IN`, o `NOT EXISTS` para de processar assim que encontra a primeira linha que satisfaz a condição. Isso é chamado de short-circuit evaluation e pode melhorar significativamente a performance.

## Exemplos Práticos

### Exemplo 1: NOT EXISTS básico

```sql
-- Encontrar clientes que NÃO fizeram nenhum pedido
SELECT id, nome, email
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Explicação detalhada:**

1. Para cada cliente na tabela `clientes`, o banco executa a subquery
2. A subquery verifica se existe pelo menos um pedido para esse cliente
3. Se NÃO existir nenhum pedido, `NOT EXISTS` retorna TRUE e o cliente é incluído no resultado
4. Se existir pelo menos um pedido, `NOT EXISTS` retorna FALSE e o cliente é excluído

### Exemplo 2: NOT EXISTS com condição adicional

```sql
-- Encontrar clientes que NÃO fizeram pedidos em 2024
SELECT id, nome, email
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2024
);
```

**Explicação detalhada:**

1. A subquery filtra pedidos pelo cliente E pelo ano de 2024
2. Se NÃO existir nenhum pedido em 2024 para o cliente, ele é retornado
3. Se existir pelo menos um pedido em 2024, o cliente não é retornado

**Nota:** Este exemplo retorna clientes que podem ter pedidos em outros anos, mas não em 2024.

### Exemplo 3: NOT EXISTS com JOIN

```sql
-- Encontrar produtos que NÃO foram vendidos em uma quantidade maior que 10
SELECT id, nome, preco
FROM produtos p
WHERE NOT EXISTS (
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
WHERE NOT EXISTS (
    SELECT NULL
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Comportamento:**

- Se a subquery retornar pelo menos uma linha (mesmo que seja NULL), `NOT EXISTS` retorna FALSE
- Se a subquery não retornar nenhuma linha, `NOT EXISTS` retorna TRUE

**Resultado:** `NOT EXISTS` não é afetado por NULL na subquery. Ele apenas verifica se existe pelo menos uma linha.

### Cenário 2: Coluna na subquery sendo NULL

```sql
SELECT nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND p.status = NULL
);
```

**Comportamento:**

- A comparação `p.status = NULL` sempre retorna UNKNOWN
- Portanto, a subquery não retornará nenhuma linha
- `NOT EXISTS` retornará TRUE

**Resultado:** Use `IS NULL` em vez de `= NULL`.

### Cenário 3: NOT EXISTS vs NULL na tabela principal

```sql
SELECT nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
);
```

**Comportamento:**

- Se `c.id` for NULL, a comparação `p.cliente_id = c.id` será UNKNOWN
- A subquery não retornará linhas
- `NOT EXISTS` retornará TRUE

**Resultado:** Linhas com NULL na coluna usada na correlação serão retornadas (pois não existem pedidos para elas).

## Pros e Contras

### Pros

1. **NULL-safe**: Não é afetado por NULL na subquery, diferentemente do `NOT IN`

```sql
-- NOT EXISTS (funciona corretamente mesmo se subquery retorna NULL)
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE condicao)

-- NOT IN (pode não funcionar se houver NULL)
WHERE id NOT IN (SELECT id FROM tabela WHERE condicao)
```

1. **Performance**: `NOT EXISTS` geralmente é mais eficiente que `NOT IN` para subqueries que retornam muitos valores

2. **Short-circuit**: Para de processar assim que encontra a primeira correspondência

3. **Semântica clara**: Expressa claramente a intenção de verificar não existência

### Contras

1. **Legibilidade**: Para iniciantes, `NOT EXISTS` pode ser menos intuitivo que `NOT IN`

2. **Correlated subquery**: Geralmente é uma correlated subquery, que pode ser menos eficiente em alguns casos

3. **Dificuldade de debug**: Mais difícil de debugar que `NOT IN` com lista literal

## Cenários a Considerar

### Cenário 1: Lista pequena sem NULL

**Recomendação:** `NOT IN` pode ser mais legível

```sql
-- NOT IN (mais legível)
WHERE id NOT IN (1, 2, 3, 4, 5)

-- NOT EXISTS (menos legível)
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE tabela.id = produtos.id AND tabela.id IN (1, 2, 3, 4, 5))
```

### Cenário 2: Subquery que pode retornar NULL

**Recomendação:** `NOT EXISTS` é a melhor escolha

```sql
-- NOT EXISTS (funciona corretamente)
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE condicao)

-- NOT IN (pode não funcionar se houver NULL)
WHERE id NOT IN (SELECT id FROM tabela WHERE condicao)
```

### Cenário 3: Subquery retornando muitos valores

**Recomendação:** `NOT EXISTS` é geralmente mais eficiente

```sql
-- NOT EXISTS (recomendado)
WHERE NOT EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- NOT IN (pode ser lento)
WHERE id NOT IN (SELECT produto_id FROM vendas)
```

### Cenário 4: Verificação de não existência com condição complexa

**Recomendação:** `NOT EXISTS` é ideal

```sql
-- NOT EXISTS (ideal para condições complexas)
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    JOIN itens_pedido ip ON p.id = ip.pedido_id
    WHERE p.cliente_id = clientes.id
    AND ip.quantidade > 10
    AND p.data_pedido >= '2024-01-01'
)
```

## NOT EXISTS vs Alternativas

### NOT EXISTS vs NOT IN

```sql
-- NOT EXISTS (recomendado - NULL-safe)
WHERE NOT EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- NOT IN (perigoso se houver NULL)
WHERE id NOT IN (SELECT produto_id FROM vendas)
```

**Escolha:** `NOT EXISTS` é geralmente recomendado porque é NULL-safe.

### NOT EXISTS vs LEFT JOIN

```sql
-- NOT EXISTS (verifica não existência)
SELECT * FROM produtos p
WHERE NOT EXISTS (SELECT 1 FROM vendas v WHERE v.produto_id = p.id)

-- LEFT JOIN (retorna dados não relacionados)
SELECT p.*
FROM produtos p
LEFT JOIN vendas v ON p.id = v.produto_id
WHERE v.produto_id IS NULL
```

**Escolha:** `NOT EXISTS` para verificar não existência, `LEFT JOIN` quando precisa dos dados não relacionados.

### NOT EXISTS vs COUNT

```sql
-- NOT EXISTS (mais eficiente - para no primeiro resultado)
WHERE NOT EXISTS (SELECT 1 FROM vendas WHERE vendas.produto_id = produtos.id)

-- COUNT (menos eficiente - conta todas as linhas)
WHERE (SELECT COUNT(*) FROM vendas WHERE vendas.produto_id = produtos.id) = 0
```

**Escolha:** `NOT EXISTS` é sempre mais eficiente que `COUNT(*) = 0`.

## Dicas de Performance

1. **Índices**: Certifique-se de que as colunas usadas na correlação têm índices

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);
```

1. **Use SELECT 1**: Não importa o que a subquery retorna, use `SELECT 1` para clareza

```sql
-- Recomendado
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE condicao)

-- Funciona, mas menos claro
WHERE NOT EXISTS (SELECT * FROM tabela WHERE condicao)
```

1. **Evite SELECT ***: `SELECT *` na subquery é desnecessário e pode ser menos eficiente

```sql
-- Ruim
WHERE NOT EXISTS (SELECT * FROM tabela WHERE condicao)

-- Bom
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE condicao)
```

1. **Prefira NOT EXISTS ao NOT IN**: `NOT EXISTS` é mais seguro que `NOT IN` com NULL

```sql
-- Recomendado
WHERE NOT EXISTS (SELECT 1 FROM tabela WHERE tabela.id = produtos.id)

-- Perigoso se houver NULL
WHERE id NOT IN (SELECT id FROM tabela)
```

## Exemplos Avançados

### Exemplo 1: NOT EXISTS com agregação

```sql
-- Encontrar clientes cujo total de pedidos NÃO é maior que 1000
SELECT id, nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    GROUP BY p.cliente_id
    HAVING SUM(p.valor) > 1000
);
```

### Exemplo 2: NOT EXISTS múltiplos (aninhado)

```sql
-- Encontrar clientes que NÃO fizeram pedidos em 2023 e NÃO em 2024
SELECT id, nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2023
)
AND NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
    AND YEAR(p.data_pedido) = 2024
);
```

### Exemplo 3: NOT EXISTS com CASE

```sql
SELECT 
    id,
    nome,
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 
            FROM pedidos p 
            WHERE p.cliente_id = c.id 
            AND YEAR(p.data_pedido) = 2024
        ) THEN 'Cliente Inativo 2024'
        ELSE 'Cliente Ativo 2024'
    END as status_2024
FROM clientes c;
```

### Exemplo 4: NOT EXISTS com EXISTS

```sql
-- Encontrar clientes que fizeram pedidos em 2024 mas NÃO em 2023
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

## NOT EXISTS Correlated vs Non-Correlated

### Correlated NOT EXISTS

```sql
-- Correlated: subquery é executada para cada linha
SELECT * FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);
```

**Características:**

- Subquery referencia tabela externa
- Executada para cada linha da tabela principal
- Pode ser menos eficiente se a tabela principal for grande

### Non-Correlated NOT EXISTS

```sql
-- Non-correlated: subquery é executada apenas uma vez
SELECT * FROM clientes
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos WHERE valor > 1000
);
```

**Características:**

- Subquery não referencia tabela externa
- Executada apenas uma vez
- Geralmente mais eficiente

## O Problema do NOT IN vs NOT EXISTS

### Por que NOT EXISTS é mais seguro que NOT IN?

Vamos analisar passo a passo:

```sql
-- NOT IN (perigoso com NULL)
SELECT * FROM produtos
WHERE id NOT IN (SELECT produto_id FROM vendas);
```

Se `produto_id` na tabela `vendas` puder ser NULL, e existir algum NULL:

```sql
-- Isso é equivalente a:
SELECT * FROM produtos
WHERE id != 1 AND id != 2 AND id != NULL;
```

Para uma linha com `id = 3`:

- `3 != 1` → TRUE
- `3 != 2` → TRUE
- `3 != NULL` → UNKNOWN (qualquer comparação com NULL é UNKNOWN)
- `TRUE AND TRUE AND UNKNOWN` → UNKNOWN

Como UNKNOWN não é TRUE, a linha não é retornada!

### Solução com NOT EXISTS

```sql
-- NOT EXISTS (seguro com NULL)
SELECT * FROM produtos p
WHERE NOT EXISTS (SELECT 1 FROM vendas v WHERE v.produto_id = p.id);
```

`NOT EXISTS` não é afetado por NULL. Ele apenas verifica se existe pelo menos uma linha que satisfaz a condição.

## Resumo

- **Use NOT EXISTS quando**: Verificar não existência de registros, subquery pode retornar NULL, performance é crítica, segurança com NULL é importante
- **Evite NOT EXISTS quando**: Lista pequena de valores literais (use NOT IN), legibilidade é prioritária para iniciantes
- **Alternativas**: NOT IN para listas literais sem NULL, LEFT JOIN quando precisa dos dados não relacionados
- **NULL**: NOT EXISTS é NULL-safe, não é afetado por NULL na subquery
- **Performance**: NOT EXISTS geralmente é mais eficiente que NOT IN para subqueries, especialmente com short-circuit
- **Regra de ouro**: Para verificar não existência, especialmente quando NULL é um problema, NOT EXISTS é geralmente a melhor escolha
