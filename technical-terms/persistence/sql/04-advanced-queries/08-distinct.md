# DISTINCT

A cláusula `DISTINCT` é usada para remover duplicatas do resultado de uma query, retornando apenas valores únicos. É usada para eliminar linhas duplicadas baseadas em uma ou mais colunas.

## Sintaxe Básica

```sql
SELECT DISTINCT column1, column2, ...
FROM table_name
WHERE condition;
```

## Como Funciona - Passo a Passo

### Passo 1: A query é executada

A query é executada normalmente, retornando todas as linhas que satisfazem as condições.

### Passo 2: Remoção de duplicatas

O banco de dados remove linhas duplicatas baseadas nas colunas especificadas no `DISTINCT`.

### Passo 3: Retorno do resultado

O resultado é retornado com apenas linhas únicas.

## Exemplos Práticos

### Exemplo 1: DISTINCT em uma coluna

```sql
-- Encontrar cidades distintas onde há clientes
SELECT DISTINCT cidade
FROM clientes;
```

**Explicação detalhada:**

1. O banco retorna todas as cidades da tabela `clientes`
2. Remove duplicatas (se 10 clientes são de São Paulo, retorna apenas uma vez)
3. Retorna a lista de cidades distintas

### Exemplo 2: DISTINCT em múltiplas colunas

```sql
-- Encontrar combinações distintas de cidade e estado
SELECT DISTINCT cidade, estado
FROM clientes;
```

**Explicação detalhada:**

1. O banco retorna todas as combinações de cidade e estado
2. Remove duplicatas baseadas na combinação de cidade E estado
3. Retorna combinações únicas de cidade e estado

### Exemplo 3: DISTINCT com COUNT

```sql
-- Contar cidades distintas
SELECT COUNT(DISTINCT cidade) as total_cidades
FROM clientes;
```

**Explicação detalhada:**

1. O banco conta valores distintos de `cidade`
2. Ignora duplicatas
3. Retorna o número de cidades distintas

### Exemplo 4: DISTINCT com ORDER BY

```sql
-- Listar cidades distintas em ordem alfabética
SELECT DISTINCT cidade
FROM clientes
ORDER BY cidade;
```

**Explicação detalhada:**

1. O banco retorna cidades distintas
2. Ordena as cidades alfabeticamente
3. Retorna cidades distintas ordenadas

## Comportamento com NULL

### Cenário 1: DISTINCT com NULL

```sql
SELECT DISTINCT cidade
FROM clientes;
```

**Comportamento:**

- `DISTINCT` trata NULL como um valor único
- Se houver múltiplas linhas com cidade NULL, retorna apenas uma linha com NULL
- NULL é considerado um valor distinto

**Resultado:** Se houver 10 clientes com cidade NULL e 5 com cidade "São Paulo", retorna 2 linhas: NULL e "São Paulo".

### Cenário 2: DISTINCT com múltiplas colunas e NULL

```sql
SELECT DISTINCT cidade, estado
FROM clientes;
```

**Comportamento:**

- A combinação de (cidade=NULL, estado="SP") é considerada distinta de (cidade="São Paulo", estado="SP")
- Cada combinação única é retornada

## Pros e Contras

### Pros

1. **Eliminação de duplicatas**: Remove facilmente duplicatas do resultado

```sql
-- Remove duplicatas
SELECT DISTINCT cidade FROM clientes;
```

1. **Flexibilidade**: Pode ser usado com múltiplas colunas

```sql
-- Múltiplas colunas
SELECT DISTINCT cidade, estado FROM clientes;
```

1. **Combinação com agregações**: Funciona bem com COUNT e outras agregações

```sql
-- Com COUNT
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

### Contras

1. **Performance**: `DISTINCT` pode ser lento em tabelas grandes

```sql
-- Pode ser lento em tabelas grandes
SELECT DISTINCT coluna FROM tabela_grande;
```

1. **Ordenação implícita**: Alguns bancos ordenam implicitamente para remover duplicatas

2. **Memória**: Requer memória adicional para identificar duplicatas

## Cenários a Considerar

### Cenário 1: Lista de valores únicos

**Recomendação:** Usar `DISTINCT`

```sql
SELECT DISTINCT cidade FROM clientes;
```

### Cenário 2: Contagem de valores únicos

**Recomendação:** Usar `COUNT(DISTINCT)`

```sql
SELECT COUNT(DISTINCT cidade) FROM clientes;
```

### Cenário 3: Combinação única de múltiplas colunas

**Recomendação:** Usar `DISTINCT` com múltiplas colunas

```sql
SELECT DISTINCT cidade, estado FROM clientes;
```

### Cenário 4: DISTINCT com JOIN

**Recomendação:** Usar `DISTINCT` para remover duplicatas de JOIN

```sql
SELECT DISTINCT c.nome
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

### Cenário 5: DISTINCT com GROUP BY

**Recomendação:** `GROUP BY` pode ser mais eficiente em alguns casos

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- GROUP BY (equivalente, pode ser mais eficiente)
SELECT cidade FROM clientes GROUP BY cidade;
```

## DISTINCT vs Alternativas

### DISTINCT vs GROUP BY

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- GROUP BY (equivalente)
SELECT cidade FROM clientes GROUP BY cidade;
```

**Escolha:** `DISTINCT` é mais legível para valores únicos, `GROUP BY` para agregações.

### DISTINCT vs EXISTS

```sql
-- DISTINCT com JOIN
SELECT DISTINCT c.nome
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;

-- EXISTS (geralmente mais eficiente)
SELECT c.nome
FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Escolha:** `EXISTS` é geralmente mais eficiente para verificar existência.

### DISTINCT vs WINDOW FUNCTIONS

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- ROW_NUMBER (mais controle)
SELECT cidade
FROM (
    SELECT cidade, ROW_NUMBER() OVER (PARTITION BY cidade ORDER BY id) as rn
    FROM clientes
) t
WHERE rn = 1;
```

**Escolha:** `DISTINCT` para simples, `ROW_NUMBER` para casos complexos.

## Dicas de Performance

1. **Use índices**: Índices nas colunas usadas no `DISTINCT` podem melhorar performance

```sql
CREATE INDEX idx_clientes_cidade ON clientes(cidade);

-- Pode usar índice
SELECT DISTINCT cidade FROM clientes;
```

1. **Considere GROUP BY**: Em alguns casos, `GROUP BY` pode ser mais eficiente

```sql
-- GROUP BY pode ser mais eficiente
SELECT cidade FROM clientes GROUP BY cidade;
```

1. **Evite DISTINCT com muitas colunas**: Mais colunas = mais lento

```sql
-- Pode ser lento com muitas colunas
SELECT DISTINCT col1, col2, col3, col4, col5 FROM tabela;
```

1. **Use EXISTS para verificar existência**: `EXISTS` é geralmente mais eficiente

```sql
-- EXISTS (mais eficiente)
SELECT c.nome
FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

## Exemplos Avançados

### Exemplo 1: DISTINCT com JOIN

```sql
-- Encontrar clientes que fizeram pedidos (sem duplicatas)
SELECT DISTINCT c.nome, c.email
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

### Exemplo 2: DISTINCT com subquery

```sql
-- Encontrar produtos que foram vendidos
SELECT DISTINCT nome
FROM produtos
WHERE id IN (SELECT produto_id FROM itens_pedido);
```

### Exemplo 3: DISTINCT com agregação

```sql
-- Contar clientes distintos que fizeram pedidos em 2024
SELECT COUNT(DISTINCT cliente_id) as clientes_distintos
FROM pedidos
WHERE YEAR(data_pedido) = 2024;
```

### Exemplo 4: DISTINCT com ORDER BY

```sql
-- Listar cidades distintas ordenadas por número de clientes
SELECT DISTINCT cidade
FROM clientes
ORDER BY cidade;
```

### Exemplo 5: DISTINCT com CASE

```sql
-- Classificar clientes por faixa de preço (distinto)
SELECT DISTINCT
    CASE 
        WHEN valor_total < 100 THEN 'Baixo'
        WHEN valor_total BETWEEN 100 AND 500 THEN 'Médio'
        ELSE 'Alto'
    END as faixa_preco
FROM pedidos;
```

## DISTINCT vs GROUP BY - Quando Usar Cada Um

### Use DISTINCT quando

- Quer apenas valores únicos
- Não precisa de agregações
- Legibilidade é importante

### Use GROUP BY quando

- Precisa de agregações (COUNT, SUM, AVG, etc.)
- Precisa de filtrar grupos (HAVING)
- Performance é crítica

## DISTINCT em Diferentes Bancos

### MySQL

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- DISTINCT com múltiplas colunas
SELECT DISTINCT cidade, estado FROM clientes;
```

### PostgreSQL

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- DISTINCT ON (PostgreSQL específico)
SELECT DISTINCT ON (cidade) id, nome, cidade
FROM clientes
ORDER BY cidade, id;
```

**Nota:** `DISTINCT ON` é específico do PostgreSQL e permite manter a primeira linha de cada grupo.

### SQL Server

```sql
-- DISTINCT
SELECT DISTINCT cidade FROM clientes;

-- DISTINCT com múltiplas colunas
SELECT DISTINCT cidade, estado FROM clientes;
```

## DISTINCT ON (PostgreSQL)

### Sintaxe

```sql
SELECT DISTINCT ON (column1, column2, ...) column1, column2, ...
FROM table_name
ORDER BY column1, column2, ...;
```

### Exemplo

```sql
-- Retornar o cliente mais recente de cada cidade
SELECT DISTINCT ON (cidade) 
    id, 
    nome, 
    cidade, 
    data_cadastro
FROM clientes
ORDER BY cidade, data_cadastro DESC;
```

**Explicação detalhada:**

1. Para cada cidade, retorna apenas uma linha
2. A linha retornada é a mais recente (devido ao ORDER BY)
3. Útil para encontrar "o mais recente" por grupo

## Resumo

- **Use DISTINCT quando**: Quer valores únicos, eliminar duplicatas, legibilidade é importante
- **Evite DISTINCT quando**: Precisa de agregações (use GROUP BY), performance é crítica (use EXISTS)
- **Alternativas**: GROUP BY para agregações, EXISTS para verificar existência, ROW_NUMBER para casos complexos
- **NULL**: DISTINCT trata NULL como um valor único
- **Performance**: DISTINCT pode ser lento em tabelas grandes, use índices nas colunas usadas
- **GROUP BY**: GROUP BY pode ser mais eficiente em alguns casos e permite agregações
- **Regra de ouro**: DISTINCT para valores únicos simples, GROUP BY para agregações
