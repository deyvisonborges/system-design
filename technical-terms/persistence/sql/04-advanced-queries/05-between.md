# BETWEEN

O operador `BETWEEN` é usado para selecionar valores dentro de um intervalo especificado. É uma alternativa mais legível ao usar múltiplos operadores de comparação com `AND`.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE column_name BETWEEN value1 AND value2;
```

## Como Funciona - Passo a Passo

### Passo 1: O operador BETWEEN avalia a condição

O operador `BETWEEN` verifica se o valor da coluna está dentro do intervalo especificado (incluindo os limites). Se estiver, a linha é retornada.

### Passo 2: Equivalência com AND e >=/<=

Internamente, `column_name BETWEEN value1 AND value2` é equivalente a:

```sql
column_name >= value1 AND column_name <= value2
```

Porém, `BETWEEN` é mais legível e expressa claramente a intenção de verificar um intervalo.

### Passo 3: Inclusão dos limites

O operador `BETWEEN` é inclusivo, ou seja, os valores dos limites (value1 e value2) são incluídos no resultado.

## Exemplos Práticos

### Exemplo 1: BETWEEN com números

```sql
-- Encontrar produtos com preço entre 100 e 500
SELECT id, nome, preco
FROM produtos
WHERE preco BETWEEN 100 AND 500;
```

**Explicação detalhada:**

1. O banco de dados verifica cada linha da tabela `produtos`
2. Para cada linha, verifica se o valor da coluna `preco` está entre 100 e 500 (incluindo 100 e 500)
3. Se estiver, a linha é incluída no resultado
4. Se não estiver, a linha é excluída

**Equivalência:**

```sql
-- BETWEEN
WHERE preco BETWEEN 100 AND 500

-- Equivalente a
WHERE preco >= 100 AND preco <= 500
```

### Exemplo 2: BETWEEN com datas

```sql
-- Encontrar pedidos feitos em janeiro de 2024
SELECT id, cliente_id, data_pedido
FROM pedidos
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-01-31';
```

**Explicação detalhada:**

1. O banco verifica se a data do pedido está entre 1º de janeiro e 31 de janeiro de 2024
2. Como `BETWEEN` é inclusivo, pedidos em 1º de janeiro e 31 de janeiro são incluídos
3. Pedidos fora desse intervalo são excluídos

**Nota:** Para datas, é importante garantir que o formato seja compatível com o banco de dados.

### Exemplo 3: BETWEEN com strings

```sql
-- Encontrar clientes com nome entre 'A' e 'F' (alfabeticamente)
SELECT id, nome
FROM clientes
WHERE nome BETWEEN 'A' AND 'F';
```

**Explicação detalhada:**

1. O banco verifica se o nome está entre 'A' e 'F' alfabeticamente
2. Isso inclui nomes que começam com 'A', 'B', 'C', 'D', 'E', e 'F'
3. Nomes que começam com 'G' ou depois são excluídos

### Exemplo 4: NOT BETWEEN

```sql
-- Encontrar produtos com preço NÃO entre 100 e 500
SELECT id, nome, preco
FROM produtos
WHERE preco NOT BETWEEN 100 AND 500;
```

**Explicação detalhada:**

1. O banco verifica se o preço NÃO está entre 100 e 500
2. Produtos com preço menor que 100 ou maior que 500 são incluídos
3. Produtos com preço entre 100 e 500 são excluídos

## Comportamento com NULL

### Cenário 1: Coluna contendo NULL

```sql
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 100 AND 500;
```

**Comportamento:**

- Se `preco` for NULL → retorna UNKNOWN (não TRUE nem FALSE)
- A linha não será retornada

**Resultado:** Linhas com NULL na coluna não são retornadas.

### Cenário 2: Limites sendo NULL

```sql
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 100 AND NULL;
```

**Comportamento:**

- A comparação `preco >= 100 AND preco <= NULL` sempre retorna UNKNOWN
- Portanto, nenhuma linha será retornada

**Resultado:** Se qualquer limite for NULL, `BETWEEN` não retornará nenhuma linha.

### Cenário 3: Tratando NULL explicitamente

```sql
-- Incluir produtos com preço entre 100 e 500 OU com preço NULL
SELECT nome, preco
FROM produtos
WHERE (preco BETWEEN 100 AND 500) OR preco IS NULL;
```

**Resultado:** Produtos com preço no intervalo OU com preço NULL são retornados.

## Pros e Contras

### Pros

1. **Legibilidade**: `BETWEEN` é muito mais legível que múltiplos operadores de comparação

```sql
-- Mais legível
WHERE preco BETWEEN 100 AND 500

-- Menos legível
WHERE preco >= 100 AND preco <= 500
```

1. **Semântica clara**: Expressa claramente a intenção de verificar um intervalo

2. **Manutenção**: Fácil de entender e modificar

3. **Padrão SQL**: É um operador padrão SQL, suportado por todos os bancos

### Contras

1. **Inclusão dos limites**: `BETWEEN` é sempre inclusivo, o que pode não ser desejado em alguns casos

```sql
-- BETWEEN inclui os limites
WHERE preco BETWEEN 100 AND 500  -- Inclui 100 e 500

-- Se você quiser exclusivo, precisa usar
WHERE preco > 100 AND preco < 500  -- Exclui 100 e 500
```

1. **NULL handling**: Comportamento com NULL pode ser confuso

2. **Limitação a intervalos contínuos**: Não pode representar intervalos não contínuos

```sql
-- Não é possível com BETWEEN
WHERE preco IN (100, 200, 300, 400, 500)

-- BETWEEN representa intervalo contínuo
WHERE preco BETWEEN 100 AND 500
```

## Cenários a Considerar

### Cenário 1: Intervalo numérico simples

**Recomendação:** Usar `BETWEEN`

```sql
WHERE preco BETWEEN 100 AND 500
```

### Cenário 2: Intervalo de datas

**Recomendação:** Usar `BETWEEN` com cuidado com o formato de data

```sql
-- Certifique-se de incluir o dia final completo
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-01-31 23:59:59'
```

### Cenário 3: Intervalo exclusivo

**Recomendação:** Usar operadores de comparação

```sql
-- BETWEEN é inclusivo
WHERE preco BETWEEN 100 AND 500  -- Inclui 100 e 500

-- Para exclusivo, use
WHERE preco > 100 AND preco < 500  -- Exclui 100 e 500
```

### Cenário 4: Intervalo com NULL

**Recomendação:** Tratar NULL explicitamente

```sql
-- Incluir NULL no resultado
WHERE (preco BETWEEN 100 AND 500) OR preco IS NULL
```

### Cenário 5: Intervalo não contínuo

**Recomendação:** Usar `IN` em vez de `BETWEEN`

```sql
-- BETWEEN (intervalo contínuo)
WHERE preco BETWEEN 100 AND 500  -- 100, 101, 102, ..., 500

-- IN (valores específicos)
WHERE preco IN (100, 200, 300, 400, 500)  -- Apenas esses valores
```

## BETWEEN vs Alternativas

### BETWEEN vs AND com >=/<=

```sql
-- BETWEEN (recomendado)
WHERE preco BETWEEN 100 AND 500

-- AND com >=/<= (equivalente, mas menos legível)
WHERE preco >= 100 AND preco <= 500
```

**Escolha:** `BETWEEN` é preferível por legibilidade.

### BETWEEN vs IN

```sql
-- BETWEEN (intervalo contínuo)
WHERE preco BETWEEN 100 AND 500

-- IN (valores específicos)
WHERE preco IN (100, 200, 300, 400, 500)
```

**Escolha:** `BETWEEN` para intervalos contínuos, `IN` para valores específicos.

### BETWEEN vs < e >

```sql
-- BETWEEN (inclusivo)
WHERE preco BETWEEN 100 AND 500  -- Inclui 100 e 500

-- < e > (exclusivo)
WHERE preco > 100 AND preco < 500  -- Exclui 100 e 500
```

**Escolha:** `BETWEEN` para inclusivo, `<` e `>` para exclusivo.

## Dicas de Performance

1. **Índices**: Certifique-se de que a coluna usada no `BETWEEN` tem índice

```sql
CREATE INDEX idx_produtos_preco ON produtos(preco);
```

1. **Use índices compostos para BETWEEN em múltiplas colunas**

```sql
CREATE INDEX idx_pedidos_data_cliente ON pedidos(data_pedido, cliente_id);
```

1. **Evite BETWEEN em colunas sem índice**: Pode resultar em full table scan

```sql
-- Pode ser lento se preco não tiver índice
WHERE preco BETWEEN 100 AND 500
```

1. **Use BETWEEN com cuidado em datas**: Certifique-se de incluir o tempo completo se necessário

```sql
-- Pode não incluir pedidos do dia 31
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-01-31'

-- Inclui todo o dia 31
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-01-31 23:59:59'
```

## Exemplos Avançados

### Exemplo 1: BETWEEN com agregação

```sql
-- Encontrar categorias com preço médio entre 100 e 500
SELECT 
    categoria_id,
    AVG(preco) as preco_medio
FROM produtos
GROUP BY categoria_id
HAVING AVG(preco) BETWEEN 100 AND 500;
```

### Exemplo 2: BETWEEN com JOIN

```sql
-- Encontrar clientes que fizeram pedidos entre datas específicas
SELECT DISTINCT c.id, c.nome
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data_pedido BETWEEN '2024-01-01' AND '2024-01-31';
```

### Exemplo 3: BETWEEN com CASE

```sql
SELECT 
    id,
    nome,
    preco,
    CASE 
        WHEN preco BETWEEN 0 AND 100 THEN 'Barato'
        WHEN preco BETWEEN 101 AND 500 THEN 'Médio'
        WHEN preco BETWEEN 501 AND 1000 THEN 'Caro'
        ELSE 'Muito Caro'
    END as faixa_preco
FROM produtos;
```

### Exemplo 4: BETWEEN múltiplos

```sql
-- Encontrar produtos com preço entre 100 e 500 E data de cadastro entre datas específicas
SELECT id, nome, preco, data_cadastro
FROM produtos
WHERE preco BETWEEN 100 AND 500
AND data_cadastro BETWEEN '2024-01-01' AND '2024-12-31';
```

### Exemplo 5: BETWEEN com subquery

```sql
-- Encontrar produtos com preço entre o mínimo e máximo da categoria
SELECT p1.id, p1.nome, p1.preco
FROM produtos p1
WHERE p1.preco BETWEEN (
    SELECT MIN(preco) 
    FROM produtos p2 
    WHERE p2.categoria_id = p1.categoria_id
) AND (
    SELECT MAX(preco) 
    FROM produtos p2 
    WHERE p2.categoria_id = p1.categoria_id
);
```

## BETWEEN com Datas - Detalhes Importantes

### Problema com datas sem tempo

```sql
-- Pode não incluir pedidos do dia 31 após as 00:00:00
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-01-31'
```

**Solução 1: Incluir o tempo completo**

```sql
WHERE data_pedido BETWEEN '2024-01-01 00:00:00' AND '2024-01-31 23:59:59'
```

**Solução 2: Usar < no dia seguinte**

```sql
WHERE data_pedido >= '2024-01-01' AND data_pedido < '2024-02-01'
```

**Solução 3: Converter para DATE (se aplicável)**

```sql
WHERE CAST(data_pedido AS DATE) BETWEEN '2024-01-01' AND '2024-01-31'
```

### BETWEEN com funções de data

```sql
-- Encontrar pedidos nos últimos 30 dias
WHERE data_pedido BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) AND CURRENT_DATE

-- PostgreSQL
WHERE data_pedido BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
```

## BETWEEN com Strings - Detalhes Importantes

### Ordenação alfabética

```sql
-- Encontrar clientes com nome entre 'A' e 'F'
WHERE nome BETWEEN 'A' AND 'F'
```

**Comportamento:**

- Inclui nomes que começam com 'A', 'B', 'C', 'D', 'E', 'F'
- A ordenação depende do collation do banco
- Case sensitivity depende do collation

### Case sensitivity

```sql
-- Pode não funcionar como esperado se case-sensitive
WHERE nome BETWEEN 'a' AND 'f'

-- Use UPPER ou LOWER para case-insensitive
WHERE UPPER(nome) BETWEEN 'A' AND 'F'
```

## Resumo

- **Use BETWEEN quando**: Verificar intervalo contínuo, inclusão dos limites é desejada, legibilidade é importante
- **Evite BETWEEN quando**: Intervalo exclusivo (use < e >), valores não contínuos (use IN), NULL é um problema
- **Alternativas**: AND com >=/<= (equivalente), IN para valores específicos, < e > para exclusivo
- **NULL**: BETWEEN com NULL na coluna ou nos limites não retorna linhas
- **Datas**: Cuidado com datas sem tempo - use tempo completo ou < no dia seguinte
- **Strings**: Depende do collation do banco - use UPPER/LOWER para case-insensitive
- **Performance**: Use índices na coluna usada no BETWEEN para melhor performance
- **Regra de ouro**: BETWEEN é ideal para intervalos contínuos inclusivos, mas cuidado com NULL e datas
