# ORDER BY

A cláusula `ORDER BY` é usada para ordenar o resultado de uma query em ordem ascendente ou descendente, baseada em uma ou mais colunas.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC];
```

## Como Funciona - Passo a Passo

### Passo 1: A query é executada

A query é executada normalmente, retornando todas as linhas que satisfazem as condições.

### Passo 2: As linhas são ordenadas

O banco de dados ordena as linhas baseadas nas colunas especificadas no `ORDER BY`.

### Passo 3: O resultado ordenado é retornado

O resultado é retornado na ordem especificada.

## Exemplos Práticos

### Exemplo 1: ORDER BY básico (ASC)

```sql
-- Listar clientes em ordem alfabética de nome
SELECT id, nome, email
FROM clientes
ORDER BY nome ASC;
```

**Explicação detalhada:**

1. O banco retorna todos os clientes
2. Ordena os clientes por nome em ordem ascendente (A-Z)
3. Retorna os clientes ordenados

### Exemplo 2: ORDER BY DESC

```sql
-- Listar produtos do mais caro para o mais barato
SELECT id, nome, preco
FROM produtos
ORDER BY preco DESC;
```

**Explicação detalhada:**

1. O banco retorna todos os produtos
2. Ordena os produtos por preço em ordem descendente (maior para menor)
3. Retorna os produtos ordenados

### Exemplo 3: ORDER BY com múltiplas colunas

```sql
-- Listar clientes ordenados por cidade e depois por nome
SELECT id, nome, cidade
FROM clientes
ORDER BY cidade ASC, nome ASC;
```

**Explicação detalhada:**

1. O banco retorna todos os clientes
2. Ordena os clientes por cidade em ordem ascendente
3. Para clientes na mesma cidade, ordena por nome em ordem ascendente
4. Retorna os clientes ordenados

### Exemplo 4: ORDER BY com expressão

```sql
-- Listar produtos ordenados pelo preço com desconto
SELECT id, nome, preco, desconto
FROM produtos
ORDER BY (preco * (1 - desconto)) DESC;
```

**Explicação detalhada:**

1. O banco retorna todos os produtos
2. Calcula o preço com desconto para cada produto
3. Ordena os produtos pelo preço com desconto em ordem descendente
4. Retorna os produtos ordenados

### Exemplo 5: ORDER BY com LIMIT

```sql
-- Listar os 10 clientes mais recentes
SELECT id, nome, data_cadastro
FROM clientes
ORDER BY data_cadastro DESC
LIMIT 10;
```

**Explicação detalhada:**

1. O banco retorna todos os clientes
2. Ordena os clientes por data de cadastro em ordem descendente (mais recente primeiro)
3. Retorna apenas os 10 primeiros

## Comportamento com NULL

### Cenário 1: ORDER BY com NULL (ASC)

```sql
SELECT nome, cidade
FROM clientes
ORDER BY cidade ASC;
```

**Comportamento:**

- Por padrão, NULL é considerado menor que qualquer valor não-NULL
- Em ordem ascendente, NULL aparece primeiro
- Em ordem descendente, NULL aparece por último

**Resultado:** Se houver clientes com cidade NULL e com cidade "São Paulo", em ORDER BY cidade ASC, NULL aparece primeiro.

### Cenário 2: ORDER BY com NULL (DESC)

```sql
SELECT nome, cidade
FROM clientes
ORDER BY cidade DESC;
```

**Comportamento:**

- Em ordem descendente, NULL aparece por último
- Isso pode variar entre bancos de dados

### Cenário 3: Tratando NULL explicitamente

```sql
-- Colocar NULL por último em ordem ascendente
SELECT nome, cidade
FROM clientes
ORDER BY CASE WHEN cidade IS NULL THEN 1 ELSE 0 END, cidade ASC;
```

**Resultado:** NULL é tratado como maior que qualquer valor não-NULL, aparecendo por último.

## Pros e Contras

### Pros

1. **Organização**: Permite organizar resultados de forma útil

```sql
-- Organizado
SELECT * FROM clientes ORDER BY nome;
```

1. **Flexibilidade**: Pode ordenar por múltiplas colunas e expressões

```sql
-- Flexível
SELECT * FROM clientes ORDER BY cidade, nome;
```

1. **Combinação com LIMIT**: Útil para top N queries

```sql
-- Top N
SELECT * FROM produtos ORDER BY preco DESC LIMIT 10;
```

### Contras

1. **Performance**: `ORDER BY` pode ser lento em tabelas grandes

```sql
-- Pode ser lento em tabelas grandes
SELECT * FROM tabela_grande ORDER BY coluna;
```

1. **Memória**: Requer memória adicional para ordenar

2. **Índice**: Sem índice, pode resultar em filesort (lento)

## Cenários a Considerar

### Cenário 1: Ordenação simples

**Recomendação:** Usar `ORDER BY` com coluna

```sql
SELECT * FROM clientes ORDER BY nome;
```

### Cenário 2: Ordenação múltipla

**Recomendação:** Usar `ORDER BY` com múltiplas colunas

```sql
SELECT * FROM clientes ORDER BY cidade, nome;
```

### Cenário 3: Ordenação com expressão

**Recomendação:** Usar `ORDER BY` com expressão

```sql
SELECT * FROM produtos ORDER BY (preco * (1 - desconto));
```

### Cenário 4: Top N

**Recomendação:** Usar `ORDER BY` com `LIMIT`

```sql
SELECT * FROM produtos ORDER BY preco DESC LIMIT 10;
```

### Cenário 5: Ordenação aleatória

**Recomendação:** Usar `ORDER BY RANDOM()`

```sql
-- PostgreSQL
SELECT * FROM clientes ORDER BY RANDOM() LIMIT 10;

-- MySQL
SELECT * FROM clientes ORDER BY RAND() LIMIT 10;
```

## ORDER BY vs Alternativas

### ORDER BY vs Window Functions

```sql
-- ORDER BY (ordena o resultado final)
SELECT nome, salario 
FROM funcionarios 
ORDER BY salario DESC;

-- ROW_NUMBER (mantém linhas originais, adiciona ranking)
SELECT nome, salario, 
       ROW_NUMBER() OVER (ORDER BY salario DESC) as ranking
FROM funcionarios;
```

**Escolha:** `ORDER BY` para ordenar resultado final, `WINDOW FUNCTIONS` para ranking sem alterar ordem.

### ORDER BY vs GROUP BY

```sql
-- ORDER BY (ordena linhas)
SELECT cidade, nome FROM clientes ORDER BY cidade, nome;

-- GROUP BY (agrupa linhas)
SELECT cidade, COUNT(*) FROM clientes GROUP BY cidade;
```

**Escolha:** `ORDER BY` para ordenar, `GROUP BY` para agregar.

### ORDER BY vs índice clusterizado

```sql
-- ORDER BY (pode usar índice)
SELECT * FROM clientes ORDER BY id;

-- Se a tabela tiver índice clusterizado em id, pode ser mais rápido
```

**Escolha:** Índice clusterizado pode acelerar ORDER BY na coluna do índice.

## Dicas de Performance

1. **Use índices**: Índices nas colunas usadas no `ORDER BY` podem melhorar performance

```sql
CREATE INDEX idx_clientes_nome ON clientes(nome);

-- Pode usar índice
SELECT * FROM clientes ORDER BY nome;
```

1. **Evite ORDER BY em colunas sem índice**: Pode resultar em filesort

```sql
-- Pode ser lento se preco não tiver índice
SELECT * FROM produtos ORDER BY preco;
```

1. **Use LIMIT com ORDER BY**: Reduz o número de linhas a ordenar

```sql
-- Mais eficiente com LIMIT
SELECT * FROM produtos ORDER BY preco DESC LIMIT 10;
```

1. **Evite ORDER BY em expressões complexas**: Expressões complexas impedem uso de índice

```sql
-- Pode ser lento
SELECT * FROM produtos ORDER BY (preco * (1 - desconto) + imposto);
```

## Exemplos Avançados

### Exemplo 1: ORDER BY com CASE

```sql
-- Ordenar por prioridade customizada
SELECT id, nome, status
FROM pedidos
ORDER BY CASE status
    WHEN 'urgente' THEN 1
    WHEN 'alta' THEN 2
    WHEN 'normal' THEN 3
    ELSE 4
END;
```

### Exemplo 2: ORDER BY com subquery

```sql
-- Ordenar por total de pedidos
SELECT c.id, c.nome
FROM clientes c
ORDER BY (
    SELECT COUNT(*) 
    FROM pedidos p 
    WHERE p.cliente_id = c.id
) DESC;
```

### Exemplo 3: ORDER BY com agregação

```sql
-- Ordenar categorias por preço médio
SELECT categoria_id, AVG(preco) as preco_medio
FROM produtos
GROUP BY categoria_id
ORDER BY AVG(preco) DESC;
```

### Exemplo 4: ORDER BY com NULLS FIRST/LAST

```sql
-- PostgreSQL específico
SELECT nome, cidade
FROM clientes
ORDER BY cidade NULLS LAST;
```

### Exemplo 5: ORDER BY com múltiplas direções

```sql
-- Ordenar por cidade ASC e nome DESC
SELECT nome, cidade
FROM clientes
ORDER BY cidade ASC, nome DESC;
```

## ORDER BY em Diferentes Bancos

### MySQL

```sql
-- ORDER BY básico
SELECT * FROM clientes ORDER BY nome;

-- ORDER BY com RAND()
SELECT * FROM clientes ORDER BY RAND() LIMIT 10;
```

### PostgreSQL

```sql
-- ORDER BY básico
SELECT * FROM clientes ORDER BY nome;

-- ORDER BY com RANDOM()
SELECT * FROM clientes ORDER BY RANDOM() LIMIT 10;

-- ORDER BY com NULLS FIRST/LAST
SELECT * FROM clientes ORDER BY cidade NULLS LAST;
```

### SQL Server

```sql
-- ORDER BY básico
SELECT * FROM clientes ORDER BY nome;

-- ORDER BY com NEWID()
SELECT TOP 10 * FROM clientes ORDER BY NEWID();
```

## ORDER BY com NULL Handling

### NULLS FIRST (PostgreSQL)

```sql
-- Colocar NULL primeiro
SELECT nome, cidade
FROM clientes
ORDER BY cidade NULLS FIRST;
```

### NULLS LAST (PostgreSQL)

```sql
-- Colocar NULL por último
SELECT nome, cidade
FROM clientes
ORDER BY cidade NULLS LAST;
```

### NULL handling manual (outros bancos)

```sql
-- Colocar NULL por último
SELECT nome, cidade
FROM clientes
ORDER BY CASE WHEN cidade IS NULL THEN 1 ELSE 0 END, cidade;
```

## ORDER BY com LIMIT/OFFSET

### LIMIT

```sql
-- Top 10
SELECT * FROM clientes ORDER BY nome LIMIT 10;
```

### OFFSET

```sql
-- Paginação (página 2, 10 por página)
SELECT * FROM clientes ORDER BY nome LIMIT 10 OFFSET 10;
```

### FETCH (SQL Server)

```sql
-- Top 10
SELECT * FROM clientes ORDER BY nome OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
```

## Resumo

- **Use ORDER BY quando**: Precisa ordenar resultados, top N queries, organização de dados
- **Evite ORDER BY quando**: Não precisa de ordem específica, performance é crítica
- **Alternativas**: Window Functions para ranking sem alterar ordem, índice clusterizado para ordenação implícita
- **NULL**: Por padrão, NULL é menor que qualquer valor não-NULL em ORDER BY ASC
- **Performance**: ORDER BY pode ser lento em tabelas grandes, use índices nas colunas usadas
- **LIMIT**: Use LIMIT com ORDER BY para reduzir o número de linhas a ordenar
- **Regra de ouro**: ORDER BY para ordenar resultados, use índices para melhorar performance
