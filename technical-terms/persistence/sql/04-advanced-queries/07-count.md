# COUNT

A função `COUNT` é uma função de agregação que retorna o número de linhas que correspondem a um critério especificado. É usada para contar registros em uma tabela ou grupo de registros.

## Sintaxe Básica

```sql
SELECT COUNT(column_name)
FROM table_name
WHERE condition;
```

## Como Funciona - Passo a Passo

### Passo 1: A função COUNT é aplicada

A função `COUNT` é aplicada a cada linha ou grupo de linhas, dependendo do contexto.

### Passo 2: Contagem de linhas

A função conta o número de linhas que satisfazem o critério especificado.

### Passo 3: Retorno do resultado

O resultado é um único valor representando a contagem.

## Tipos de COUNT

### 1. COUNT(*)

Conta todas as linhas, incluindo linhas com NULL.

```sql
SELECT COUNT(*) FROM clientes;
```

**Comportamento:**

- Conta todas as linhas da tabela
- Inclui linhas com NULL em qualquer coluna
- Não ignora duplicatas

### 2. COUNT(column_name)

Conta linhas onde a coluna especificada não é NULL.

```sql
SELECT COUNT(nome) FROM clientes;
```

**Comportamento:**

- Conta apenas linhas onde a coluna não é NULL
- Ignora linhas onde a coluna é NULL
- Não ignora duplicatas

### 3. COUNT(DISTINCT column_name)

Conta valores distintos não-NULL da coluna especificada.

```sql
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

**Comportamento:**

- Conta apenas valores distintos não-NULL
- Ignora duplicatas
- Ignora NULL

## Exemplos Práticos

### Exemplo 1: COUNT(*) - Contar todas as linhas

```sql
-- Contar total de clientes
SELECT COUNT(*) as total_clientes
FROM clientes;
```

**Explicação detalhada:**

1. O banco conta todas as linhas da tabela `clientes`
2. Inclui linhas com NULL em qualquer coluna
3. Retorna o total de linhas

### Exemplo 2: COUNT(column_name) - Contar não-NULL

```sql
-- Contar clientes com email
SELECT COUNT(email) as clientes_com_email
FROM clientes;
```

**Explicação detalhada:**

1. O banco conta linhas onde `email` não é NULL
2. Ignora linhas onde `email` é NULL
3. Retorna o número de clientes com email

### Exemplo 3: COUNT(DISTINCT) - Contar valores distintos

```sql
-- Contar cidades distintas onde há clientes
SELECT COUNT(DISTINCT cidade) as cidades_distintas
FROM clientes;
```

**Explicação detalhada:**

1. O banco conta valores distintos de `cidade`
2. Ignora duplicatas (se 10 clientes são de São Paulo, conta apenas 1)
3. Ignora NULL
4. Retorna o número de cidades distintas

### Exemplo 4: COUNT com WHERE

```sql
-- Contar clientes de São Paulo
SELECT COUNT(*) as clientes_sp
FROM clientes
WHERE cidade = 'São Paulo';
```

**Explicação detalhada:**

1. O banco filtra clientes de São Paulo
2. Conta as linhas que satisfazem o filtro
3. Retorna o número de clientes de São Paulo

### Exemplo 5: COUNT com GROUP BY

```sql
-- Contar clientes por cidade
SELECT cidade, COUNT(*) as total_clientes
FROM clientes
GROUP BY cidade;
```

**Explicação detalhada:**

1. O banco agrupa clientes por cidade
2. Para cada grupo, conta o número de linhas
3. Retorna cada cidade com o total de clientes

## Comportamento com NULL

### Cenário 1: COUNT(*) com NULL

```sql
SELECT COUNT(*)
FROM clientes;
```

**Comportamento:**

- `COUNT(*)` conta todas as linhas, incluindo NULL
- Se houver 100 linhas, retorna 100, mesmo que algumas colunas sejam NULL

### Cenário 2: COUNT(column_name) com NULL

```sql
SELECT COUNT(email)
FROM clientes;
```

**Comportamento:**

- `COUNT(email)` conta apenas linhas onde `email` não é NULL
- Se houver 100 linhas e 20 com email NULL, retorna 80

### Cenário 3: COUNT(DISTINCT) com NULL

```sql
SELECT COUNT(DISTINCT cidade)
FROM clientes;
```

**Comportamento:**

- `COUNT(DISTINCT cidade)` conta valores distintos não-NULL
- NULL é ignorado
- Se houver 10 cidades distintas e algumas linhas com cidade NULL, retorna 10

## Pros e Contras

### Pros

1. **Simplicidade**: `COUNT` é simples de usar e entender

```sql
-- Simples
SELECT COUNT(*) FROM clientes;
```

1. **Flexibilidade**: Diferentes formas de contar permitem flexibilidade

```sql
-- Flexível
SELECT COUNT(*) FROM clientes;
SELECT COUNT(email) FROM clientes;
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

1. **Agregação**: Funciona bem com GROUP BY para agregações

```sql
-- Com GROUP BY
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;
```

### Contras

1. **Performance**: `COUNT(*)` em tabelas grandes pode ser lento

```sql
-- Pode ser lento em tabelas grandes
SELECT COUNT(*) FROM tabela_grande;
```

1. **NULL handling**: Comportamento com NULL pode ser confuso

```sql
-- COUNT(*) inclui NULL
-- COUNT(column) exclui NULL
```

1. **COUNT(DISTINCT)**: Pode ser lento em tabelas grandes com muitos valores distintos

```sql
-- Pode ser lento
SELECT COUNT(DISTINCT coluna) FROM tabela_grande;
```

## Cenários a Considerar

### Cenário 1: Contar total de linhas

**Recomendação:** Usar `COUNT(*)`

```sql
SELECT COUNT(*) FROM clientes;
```

### Cenário 2: Contar linhas com valor não-NULL

**Recomendação:** Usar `COUNT(column_name)`

```sql
SELECT COUNT(email) FROM clientes;
```

### Cenário 3: Contar valores distintos

**Recomendação:** Usar `COUNT(DISTINCT column_name)`

```sql
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

### Cenário 4: Contar com condição

**Recomendação:** Usar `COUNT` com `WHERE` ou `COUNT` com `CASE`

```sql
-- Opção 1: WHERE
SELECT COUNT(*) FROM clientes WHERE cidade = 'São Paulo';

-- Opção 2: CASE
SELECT SUM(CASE WHEN cidade = 'São Paulo' THEN 1 ELSE 0 END) FROM clientes;
```

### Cenário 5: Contar múltiplas condições

**Recomendação:** Usar `COUNT` com `CASE`

```sql
SELECT 
    SUM(CASE WHEN cidade = 'São Paulo' THEN 1 ELSE 0 END) as sp,
    SUM(CASE WHEN cidade = 'Rio de Janeiro' THEN 1 ELSE 0 END) as rj
FROM clientes;
```

## COUNT vs Alternativas

### COUNT(*) vs COUNT(1)

```sql
-- COUNT(*)
SELECT COUNT(*) FROM clientes;

-- COUNT(1)
SELECT COUNT(1) FROM clientes;
```

**Escolha:** São equivalentes na maioria dos bancos. `COUNT(*)` é mais legível.

### COUNT(*) vs COUNT(column_name)

```sql
-- COUNT(*) - conta todas as linhas
SELECT COUNT(*) FROM clientes;

-- COUNT(column_name) - conta não-NULL
SELECT COUNT(email) FROM clientes;
```

**Escolha:** `COUNT(*)` para total de linhas, `COUNT(column_name)` para não-NULL.

### COUNT vs SUM com CASE

```sql
-- COUNT com WHERE
SELECT COUNT(*) FROM clientes WHERE cidade = 'São Paulo';

-- SUM com CASE (útil para múltiplas contagens)
SELECT SUM(CASE WHEN cidade = 'São Paulo' THEN 1 ELSE 0 END) FROM clientes;
```

**Escolha:** `COUNT` com WHERE para única condição, `SUM` com CASE para múltiplas.

## Dicas de Performance

1. **Use COUNT(*) para total de linhas**: É geralmente otimizado pelos bancos

```sql
-- Otimizado
SELECT COUNT(*) FROM clientes;
```

1. **Evite COUNT(DISTINCT) em tabelas grandes**: Pode ser lento

```sql
-- Pode ser lento
SELECT COUNT(DISTINCT coluna) FROM tabela_grande;
```

1. **Use índices para COUNT(column_name)**: Índices podem melhorar performance

```sql
CREATE INDEX idx_clientes_email ON clientes(email);

-- Pode usar índice
SELECT COUNT(email) FROM clientes;
```

1. **Considere estimativas para tabelas muito grandes**: Alguns bancos têm funções de estimativa

```sql
-- PostgreSQL (estimativa)
SELECT reltuples FROM pg_class WHERE relname = 'clientes';

-- MySQL (estimativa)
SELECT TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_NAME = 'clientes';
```

## Exemplos Avançados

### Exemplo 1: COUNT com JOIN

```sql
-- Contar pedidos por cliente
SELECT 
    c.nome,
    COUNT(p.id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

### Exemplo 2: COUNT com HAVING

```sql
-- Encontrar cidades com mais de 10 clientes
SELECT cidade, COUNT(*) as total_clientes
FROM clientes
GROUP BY cidade
HAVING COUNT(*) > 10;
```

### Exemplo 3: COUNT com CASE

```sql
-- Contar clientes por status em uma única query
SELECT 
    SUM(CASE WHEN email IS NOT NULL THEN 1 ELSE 0 END) as com_email,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) as sem_email
FROM clientes;
```

### Exemplo 4: COUNT com subquery

```sql
-- Contar clientes que fizeram pedidos
SELECT COUNT(*) 
FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

### Exemplo 5: COUNT múltiplos

```sql
-- Contar clientes, pedidos e produtos em uma única query
SELECT 
    (SELECT COUNT(*) FROM clientes) as total_clientes,
    (SELECT COUNT(*) FROM pedidos) as total_pedidos,
    (SELECT COUNT(*) FROM produtos) as total_produtos;
```

## COUNT com GROUP BY - Detalhes Importantes

### Regra: Todas as colunas não agregadas devem estar no GROUP BY

```sql
-- Correto
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;

-- Incorreto (em muitos bancos)
SELECT cidade, estado, COUNT(*) FROM clientes GROUP BY cidade;
```

### COUNT com múltiplas colunas no GROUP BY

```sql
-- Contar clientes por cidade e estado
SELECT cidade, estado, COUNT(*) as total
FROM clientes
GROUP BY cidade, estado;
```

## COUNT com Window Functions

### COUNT OVER

```sql
-- Contar total de linhas em cada partição
SELECT 
    nome,
    cidade,
    COUNT(*) OVER (PARTITION BY cidade) as total_por_cidade
FROM clientes;
```

### COUNT OVER com ORDER BY

```sql
-- Contar running total
SELECT 
    nome,
    COUNT(*) OVER (ORDER BY id) as running_total
FROM clientes;
```

## COUNT em Diferentes Bancos

### MySQL

```sql
-- COUNT(*)
SELECT COUNT(*) FROM clientes;

-- COUNT(DISTINCT)
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

### PostgreSQL

```sql
-- COUNT(*)
SELECT COUNT(*) FROM clientes;

-- COUNT(DISTINCT)
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

### SQL Server

```sql
-- COUNT(*)
SELECT COUNT(*) FROM clientes;

-- COUNT(DISTINCT)
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

## Resumo

- **Use COUNT(*) quando**: Contar total de linhas, performance é importante
- **Use COUNT(column_name) quando**: Contar não-NULL, verificar preenchimento de coluna
- **Use COUNT(DISTINCT) quando**: Contar valores distintos, eliminar duplicatas
- **Alternativas**: SUM com CASE para múltiplas contagens, estimativas para tabelas muito grandes
- **NULL**: COUNT(*) inclui NULL, COUNT(column) exclui NULL, COUNT(DISTINCT) exclui NULL
- **Performance**: COUNT(*) é geralmente otimizado, COUNT(DISTINCT) pode ser lento em tabelas grandes
- **GROUP BY**: Todas as colunas não agregadas devem estar no GROUP BY
- **Regra de ouro**: COUNT(*) para total, COUNT(column) para não-NULL, COUNT(DISTINCT) para distintos
