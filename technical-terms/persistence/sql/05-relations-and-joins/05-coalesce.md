# COALESCE

A função `COALESCE` retorna o primeiro valor não-NULL de uma lista de expressões. É usada para substituir NULL por valores padrão ou para escolher o primeiro valor não-NULL de múltiplas colunas.

## Sintaxe Básica

```sql
COALESCE(expression1, expression2, expression3, ..., default_value)
```

## Como Funciona - Passo a Passo

### Passo 1: Avaliação das expressões

O banco avalia as expressões em ordem, da esquerda para a direita.

### Passo 2: Retorno do primeiro valor não-NULL

A primeira expressão que não for NULL é retornada.

### Passo 3: Retorno do valor padrão

Se todas as expressões forem NULL, o valor padrão é retornado.

## Exemplos Práticos

### Exemplo 1: COALESCE básico

```sql
-- Substituir NULL por 'Desconhecido'
SELECT nome, COALESCE(email, 'Sem email') as email_formatado
FROM clientes;
```

**Explicação detalhada:**

1. Para cada cliente, o banco verifica o valor de `email`
2. Se `email` não for NULL, retorna o valor de `email`
3. Se `email` for NULL, retorna 'Sem email'
4. Retorna o nome do cliente com o email formatado

### Exemplo 2: COALESCE com múltiplas expressões

```sql
-- Retornar o primeiro valor não-NULL
SELECT nome, COALESCE(telefone_celular, telefone_fixo, 'Sem telefone') as telefone
FROM clientes;
```

**Explicação detalhada:**

1. Para cada cliente, o banco verifica `telefone_celular`
2. Se `telefone_celular` não for NULL, retorna esse valor
3. Se `telefone_celular` for NULL, verifica `telefone_fixo`
4. Se `telefone_fixo` não for NULL, retorna esse valor
5. Se ambos forem NULL, retorna 'Sem telefone'

### Exemplo 3: COALESCE com LEFT JOIN

```sql
-- Substituir NULL por valor padrão em LEFT JOIN
SELECT c.nome, COALESCE(p.id, 0) as pedido_id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todos os clientes com seus pedidos (se houver)
2. Se um cliente não tiver pedidos, `p.id` será NULL
3. COALESCE substitui NULL por 0
4. Retorna todos os clientes com pedido_id (0 se não tiver pedidos)

### Exemplo 4: COALESCE com agregação

```sql
-- Substituir NULL por 0 em agregação
SELECT c.nome, COALESCE(SUM(p.valor_total), 0) as total_gasto
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

**Explicação detalhada:**

1. O banco retorna todos os clientes com o total gasto
2. Se um cliente não tiver pedidos, SUM retornará NULL
3. COALESCE substitui NULL por 0
4. Retorna todos os clientes com total_gasto (0 se não tiver pedidos)

### Exemplo 5: COALESCE em cálculos

```sql
-- Calcular valor com desconto (usando 0 se desconto for NULL)
SELECT nome, preco * COALESCE(desconto, 0) as valor_com_desconto
FROM produtos;
```

**Explicação detalhada:**

1. Para cada produto, o banco verifica o valor de `desconto`
2. Se `desconto` não for NULL, usa esse valor no cálculo
3. Se `desconto` for NULL, usa 0 no cálculo
4. Retorna o nome do produto com o valor calculado

## Comportamento com NULL

### Cenário 1: COALESCE com NULL

```sql
SELECT COALESCE(NULL, NULL, 'Valor padrão') as resultado;
```

**Comportamento:**

- O banco avalia as expressões em ordem
- As duas primeiras são NULL
- A terceira não é NULL, então é retornada

**Resultado:** 'Valor padrão'

### Cenário 2: COALESCE sem valor padrão

```sql
SELECT COALESCE(NULL, NULL, NULL) as resultado;
```

**Comportamento:**

- O banco avalia as expressões em ordem
- Todas são NULL
- Retorna NULL

**Resultado:** NULL

### Cenário 3: COALESCE com tipos diferentes

```sql
SELECT COALESCE(NULL, 123, 'Texto') as resultado;
```

**Comportamento:**

- O banco tenta converter os valores para um tipo compatível
- Se não for possível, pode ocorrer erro

## Pros e Contras

### Pros

1. **Simplicidade**: `COALESCE` é simples de usar e entender

```sql
-- Simples
COALESCE(coluna, valor_padrao)
```

1. **Flexibilidade**: Aceita múltiplas expressões

```sql
-- Flexível
COALESCE(col1, col2, col3, valor_padrao)
```

1. **Padrão SQL**: É uma função padrão SQL, suportada por todos os bancos

### Contras

1. **Conversão de tipos**: Pode ocorrer conversão implícita de tipos

```sql
-- Pode ocorrer conversão
COALESCE(NULL, 123, 'Texto')
```

1. **Performance**: Avaliação de múltiplas expressões pode ser lento

2. **Limitação**: Não pode ser usado em todos os contextos (por exemplo, em GROUP BY)

## Cenários a Considerar

### Cenário 1: Substituir NULL por valor padrão

**Recomendação:** Usar `COALESCE`

```sql
COALESCE(coluna, valor_padrao)
```

### Cenário 2: Escolher o primeiro valor não-NULL

**Recomendação:** Usar `COALESCE` com múltiplas expressões

```sql
COALESCE(col1, col2, col3, valor_padrao)
```

### Cenário 3: Substituir NULL em LEFT JOIN

**Recomendação:** Usar `COALESCE` com LEFT JOIN

```sql
FROM tabela1 t1
LEFT JOIN tabela2 t2 ON t1.id = t2.id
SELECT COALESCE(t2.coluna, valor_padrao)
```

### Cenário 4: Substituir NULL em agregação

**Recomendação:** Usar `COALESCE` com agregação

```sql
COALESCE(SUM(coluna), 0)
```

### Cenário 5: COALESCE em cálculos

**Recomendação:** Usar `COALESCE` para evitar NULL em cálculos

```sql
coluna1 * COALESCE(coluna2, 0)
```

## COALESCE vs Alternativas

### COALESCE vs ISNULL (SQL Server)

```sql
-- COALESCE (padrão SQL)
COALESCE(coluna, valor_padrao)

-- ISNULL (SQL Server específico)
ISNULL(coluna, valor_padrao)
```

**Escolha:** `COALESCE` é padrão SQL, `ISNULL` é específico do SQL Server.

### COALESCE vs IFNULL (MySQL)

```sql
-- COALESCE (padrão SQL)
COALESCE(coluna, valor_padrao)

-- IFNULL (MySQL específico)
IFNULL(coluna, valor_padrao)
```

**Escolha:** `COALESCE` é padrão SQL, `IFNULL` é específico do MySQL.

### COALESCE vs NVL (Oracle)

```sql
-- COALESCE (padrão SQL)
COALESCE(coluna, valor_padrao)

-- NVL (Oracle específico)
NVL(coluna, valor_padrao)
```

**Escolha:** `COALESCE` é padrão SQL, `NVL` é específico do Oracle.

### COALESCE vs CASE

```sql
-- COALESCE (mais simples)
COALESCE(col1, col2, valor_padrao)

-- CASE (mais flexível)
CASE 
    WHEN col1 IS NOT NULL THEN col1
    WHEN col2 IS NOT NULL THEN col2
    ELSE valor_padrao
END
```

**Escolha:** `COALESCE` para substituição simples, `CASE` para lógica complexa.

## Dicas de Performance

1. **Ordem das expressões**: Coloque expressões mais prováveis de não ser NULL primeiro

```sql
-- Mais eficiente se col1 raramente é NULL
COALESCE(col1, col2, valor_padrao)
```

1. **Evite muitas expressões**: Muitas expressões podem ser lentas

```sql
-- Pode ser lento com muitas expressões
COALESCE(col1, col2, col3, col4, col5, valor_padrao)
```

1. **Use índices**: Se COALESCE for usado em WHERE, considere índices funcionais

```sql
-- Índice funcional (PostgreSQL)
CREATE INDEX idx_clientes_email_coalesce ON clientes(COALESCE(email, ''));
```

## Exemplos Avançados

### Exemplo 1: COALESCE com subquery

```sql
-- Retornar valor ou subquery se NULL
SELECT nome, COALESCE(telefone, (SELECT telefone FROM contatos WHERE cliente_id = clientes.id LIMIT 1), 'Sem telefone') as telefone
FROM clientes;
```

### Exemplo 2: COALESCE com múltiplas tabelas

```sql
-- Retornar o primeiro endereço não-NULL
SELECT nome, COALESCE(endereco_residencial, endereco_comercial, endereco_entrega) as endereco
FROM clientes;
```

### Exemplo 3: COALESCE com CASE

```sql
-- Classificar baseado em primeiro valor não-NULL
SELECT nome,
    CASE 
        WHEN COALESCE(telefone_celular, telefone_fixo) IS NOT NULL THEN 'Com telefone'
        ELSE 'Sem telefone'
    END as status_telefone
FROM clientes;
```

### Exemplo 4: COALESCE em UPDATE

```sql
-- Atualizar NULL com valor padrão
UPDATE clientes
SET email = COALESCE(email, 'sem@email.com')
WHERE email IS NULL;
```

### Exemplo 5: COALESCE em ORDER BY

```sql
-- Ordenar por primeiro valor não-NULL
SELECT nome, telefone_celular, telefone_fixo
FROM clientes
ORDER BY COALESCE(telefone_celular, telefone_fixo);
```

## COALESCE em Diferentes Bancos

### MySQL

```sql
-- COALESCE padrão
COALESCE(coluna, valor_padrao)

-- IFNULL (MySQL específico)
IFNULL(coluna, valor_padrao)
```

### PostgreSQL

```sql
-- COALESCE padrão
COALESCE(coluna, valor_padrao)
```

### SQL Server

```sql
-- COALESCE padrão
COALESCE(coluna, valor_padrao)

-- ISNULL (SQL Server específico)
ISNULL(coluna, valor_padrao)
```

### Oracle

```sql
-- COALESCE padrão
COALESCE(coluna, valor_padrao)

-- NVL (Oracle específico)
NVL(coluna, valor_padrao)
```

## COALESCE vs NULLIF

### COALESCE

```sql
-- Substituir NULL por valor padrão
COALESCE(coluna, valor_padrao)
```

### NULLIF

```sql
-- Retornar NULL se valores forem iguais
NULLIF(coluna1, coluna2)
```

**Escolha:** `COALESCE` para substituir NULL, `NULLIF` para criar NULL.

## Resumo

- **Use COALESCE quando**: Substituir NULL por valor padrão, escolher primeiro valor não-NULL
- **Evite COALESCE quando**: Precisa de lógica complexa (use CASE), performance é crítica com muitas expressões
- **Alternativas**: CASE para lógica complexa, ISNULL/IFNULL/NVL (específicos de banco)
- **NULL**: COALESCE retorna o primeiro valor não-NULL, ou NULL se todos forem NULL
- **Performance**: Coloque expressões mais prováveis primeiro, evite muitas expressões
- **Compatibilidade**: COALESCE é padrão SQL, suportado por todos os bancos
- **Regra de ouro**: COALESCE para substituição simples de NULL, CASE para lógica complexa
