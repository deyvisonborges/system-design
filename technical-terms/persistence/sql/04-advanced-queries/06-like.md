# LIKE

O operador `LIKE` é usado para buscar padrões em colunas de texto. É usado com caracteres curinga (wildcards) para correspondência de padrões, permitindo buscas flexíveis em strings.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table_name
WHERE column_name LIKE pattern;
```

## Caracteres Curinga (Wildcards)

### 1. Percentual (%)

- Representa zero, um ou múltiplos caracteres
- Pode ser usado em qualquer posição do padrão

### 2. Underscore (_)

- Representa exatamente um caractere
- Pode ser usado em qualquer posição do padrão

### 3. Colchetes ([])

- Representa qualquer caractere dentro do intervalo especificado
- Exemplo: `[a-z]` representa qualquer letra de 'a' a 'z'
- Exemplo: `[0-9]` representa qualquer dígito

### 4. Circunflexo dentro de colchetes ([^])

- Representa qualquer caractere EXCETO os especificados
- Exemplo: `[^a-z]` representa qualquer caractere que não seja uma letra de 'a' a 'z'

## Como Funciona - Passo a Passo

### Passo 1: O operador LIKE avalia o padrão

O operador `LIKE` compara cada valor da coluna com o padrão especificado, usando os caracteres curinga.

### Passo 2: Correspondência de padrão

Se o valor da coluna corresponder ao padrão, a linha é retornada. Caso contrário, é excluída.

### Passo 3: Case sensitivity

Por padrão, `LIKE` é case-sensitive em muitos bancos de dados. Para case-insensitive, use `UPPER` ou `LOWER`, ou `ILIKE` em PostgreSQL.

## Exemplos Práticos

### Exemplo 1: LIKE com % no início

```sql
-- Encontrar clientes cujo nome termina com 'silva'
SELECT id, nome
FROM clientes
WHERE nome LIKE '%silva';
```

**Explicação detalhada:**

1. O padrão `%silva` significa "qualquer coisa seguido de 'silva'"
2. O banco verifica cada nome na tabela
3. Nomes como "João Silva", "Maria Silva", "Carlos Silva" são retornados
4. Nomes como "Silva João" não são retornados (não termina com 'silva')

### Exemplo 2: LIKE com % no final

```sql
-- Encontrar clientes cujo nome começa com 'João'
SELECT id, nome
FROM clientes
WHERE nome LIKE 'João%';
```

**Explicação detalhada:**

1. O padrão `João%` significa "'João' seguido de qualquer coisa"
2. Nomes como "João Silva", "João Santos", "João" são retornados
3. Nomes como "Maria João" não são retornados (não começa com 'João')

### Exemplo 3: LIKE com % em ambos os lados

```sql
-- Encontrar clientes cujo nome contém 'maria'
SELECT id, nome
FROM clientes
WHERE nome LIKE '%maria%';
```

**Explicação detalhada:**

1. O padrão `%maria%` significa "qualquer coisa, 'maria', qualquer coisa"
2. Nomes como "Maria Silva", "Ana Maria", "Maria", "Santos Maria" são retornados
3. Nomes como "Mari" não são retornados (não contém 'maria' completo)

### Exemplo 4: LIKE com underscore (_)

```sql
-- Encontrar clientes cujo nome tem exatamente 5 caracteres
SELECT id, nome
FROM clientes
WHERE nome LIKE '_____';
```

**Explicação detalhada:**

1. O padrão `_____` (5 underscores) significa "exatamente 5 caracteres"
2. Nomes como "João", "Maria", "Pedro" são retornados
3. Nomes como "Carlos" (6 caracteres) ou "Ana" (3 caracteres) não são retornados

### Exemplo 5: LIKE combinando % e _

```sql
-- Encontrar clientes cujo nome começa com 'J' e tem exatamente 5 caracteres
SELECT id, nome
FROM clientes
WHERE nome LIKE 'J____';
```

**Explicação detalhada:**

1. O padrão `J____` significa "começa com 'J' seguido de exatamente 4 caracteres"
2. Nomes como "João", "Júlia", "José" são retornados
3. Nomes como "Juan" (4 caracteres) ou "Jacqueline" (10 caracteres) não são retornados

### Exemplo 6: NOT LIKE

```sql
-- Encontrar clientes cujo nome NÃO contém 'silva'
SELECT id, nome
FROM clientes
WHERE nome NOT LIKE '%silva%';
```

**Explicação detalhada:**

1. O operador `NOT LIKE` inverte a lógica
2. Nomes que NÃO contêm 'silva' são retornados
3. Nomes que contêm 'silva' são excluídos

## Comportamento com NULL

### Cenário 1: Coluna contendo NULL

```sql
SELECT nome
FROM clientes
WHERE nome LIKE '%silva%';
```

**Comportamento:**

- Se `nome` for NULL → retorna UNKNOWN (não TRUE nem FALSE)
- A linha não será retornada

**Resultado:** Linhas com NULL na coluna não são retornadas.

### Cenário 2: Tratando NULL explicitamente

```sql
-- Incluir clientes com nome contendo 'silva' OU com nome NULL
SELECT nome
FROM clientes
WHERE nome LIKE '%silva%' OR nome IS NULL;
```

**Resultado:** Clientes com nome contendo 'silva' OU com nome NULL são retornados.

## Pros e Contras

### Pros

1. **Flexibilidade**: Permite buscas flexíveis com padrões

```sql
-- Busca flexível
WHERE nome LIKE '%maria%'
```

1. **Padrões complexos**: Combinação de curinga permite padrões complexos

```sql
-- Padrão complexo
WHERE email LIKE '%@gmail.com'
```

1. **Busca parcial**: Permite busca parcial de strings

```sql
-- Busca parcial
WHERE descricao LIKE '%laptop%'
```

### Contras

1. **Performance**: `LIKE` com curinga no início (`%padrão`) pode ser lento

```sql
-- Pode ser lento (full table scan)
WHERE nome LIKE '%silva'

-- Mais rápido (pode usar índice)
WHERE nome LIKE 'silva%'
```

1. **Case sensitivity**: Pode ser case-sensitive dependendo do banco

```sql
-- Pode não funcionar se case-sensitive
WHERE nome LIKE 'MARIA%'

-- Use UPPER ou LOWER para case-insensitive
WHERE UPPER(nome) LIKE 'MARIA%'
```

1. **Complexidade**: Padrões complexos podem ser difíceis de entender

## Cenários a Considerar

### Cenário 1: Busca por prefixo

**Recomendação:** Usar `LIKE` com curinga no final

```sql
-- Eficiente (pode usar índice)
WHERE nome LIKE 'João%'
```

### Cenário 2: Busca por sufixo

**Recomendação:** Usar `LIKE` com curinga no início (pode ser lento)

```sql
-- Pode ser lento (full table scan)
WHERE nome LIKE '%silva'

-- Considere índice reverso ou full-text search
```

### Cenário 3: Busca por substring

**Recomendação:** Usar `LIKE` com curinga em ambos os lados (pode ser lento)

```sql
-- Pode ser lento (full table scan)
WHERE nome LIKE '%maria%'

-- Considere full-text search para grandes volumes
```

### Cenário 4: Busca case-insensitive

**Recomendação:** Usar `UPPER` ou `LOWER`, ou `ILIKE` no PostgreSQL

```sql
-- Case-insensitive (funciona na maioria dos bancos)
WHERE UPPER(nome) LIKE 'MARIA%'

-- PostgreSQL específico
WHERE nome ILIKE 'maria%'
```

### Cenário 5: Busca exata com tamanho específico

**Recomendação:** Usar `LIKE` com underscores

```sql
-- Exatamente 5 caracteres
WHERE nome LIKE '_____'
```

## LIKE vs Alternativas

### LIKE vs =

```sql
-- LIKE (busca de padrão)
WHERE nome LIKE 'João%'

-- = (igualdade exata)
WHERE nome = 'João'
```

**Escolha:** `LIKE` para padrões, `=` para igualdade exata.

### LIKE vs Full-Text Search

```sql
-- LIKE (busca simples)
WHERE descricao LIKE '%laptop%'

-- Full-Text Search (mais eficiente para grandes volumes)
-- MySQL
WHERE MATCH(descricao) AGAINST('laptop')

-- PostgreSQL
WHERE to_tsvector('portuguese', descricao) @@ to_tsquery('laptop')
```

**Escolha:** `LIKE` para buscas simples em pequenos volumes, Full-Text Search para grandes volumes.

### LIKE vs REGEXP/REGEX

```sql
-- LIKE (padrões simples)
WHERE email LIKE '%@gmail.com'

-- REGEXP (padrões complexos)
-- MySQL
WHERE email REGEXP '^[a-zA-Z0-9._%+-]+@gmail\\.com$'

-- PostgreSQL
WHERE email ~ '^[a-zA-Z0-9._%+-]+@gmail\\.com$'
```

**Escolha:** `LIKE` para padrões simples, REGEXP para padrões complexos.

## Dicas de Performance

1. **Evite curinga no início**: Curinga no início (`%padrão`) impede o uso de índice

```sql
-- Ruim (full table scan)
WHERE nome LIKE '%silva'

-- Bom (pode usar índice)
WHERE nome LIKE 'silva%'
```

1. **Use índices para prefixos**: Índices funcionam bem com curinga no final

```sql
CREATE INDEX idx_clientes_nome ON clientes(nome);

-- Pode usar índice
WHERE nome LIKE 'João%'
```

1. **Considere índices funcionais**: Para curinga no início, considere índice funcional

```sql
-- PostgreSQL
CREATE INDEX idx_clientes_nome_reverso ON clientes(REVERSE(nome));

-- Pode usar índice
WHERE nome LIKE '%silva'
-- Equivalente a
WHERE REVERSE(nome) LIKE REVERSE('%silva')
```

1. **Use Full-Text Search para grandes volumes**: Para busca de texto em grandes volumes

```sql
-- MySQL
CREATE FULLTEXT INDEX idx_descricao ON produtos(descricao);
WHERE MATCH(descricao) AGAINST('laptop');
```

## Exemplos Avançados

### Exemplo 1: LIKE com colchetes

```sql
-- Encontrar clientes cujo nome começa com uma letra de 'A' a 'F'
SELECT id, nome
FROM clientes
WHERE nome LIKE '[A-F]%';
```

**Nota:** Sintaxe varia entre bancos. PostgreSQL usa `SIMILAR TO` ou regex.

### Exemplo 2: LIKE com múltiplos curingas

```sql
-- Encontrar emails que terminam com .com ou .br
SELECT id, email
FROM clientes
WHERE email LIKE '%.com' OR email LIKE '%.br';
```

### Exemplo 3: LIKE com CASE

```sql
SELECT 
    id,
    nome,
    CASE 
        WHEN nome LIKE '%silva%' THEN 'Sobrenome Silva'
        WHEN nome LIKE '%santos%' THEN 'Sobrenome Santos'
        ELSE 'Outro Sobrenome'
    END as tipo_sobrenome
FROM clientes;
```

### Exemplo 4: LIKE com agregação

```sql
-- Contar clientes por padrão de nome
SELECT 
    CASE 
        WHEN nome LIKE 'A%' THEN 'A'
        WHEN nome LIKE 'B%' THEN 'B'
        WHEN nome LIKE 'C%' THEN 'C'
        ELSE 'Outros'
    END as letra_inicial,
    COUNT(*) as total
FROM clientes
GROUP BY 
    CASE 
        WHEN nome LIKE 'A%' THEN 'A'
        WHEN nome LIKE 'B%' THEN 'B'
        WHEN nome LIKE 'C%' THEN 'C'
        ELSE 'Outros'
    END;
```

### Exemplo 5: LIKE com subquery

```sql
-- Encontrar produtos cuja descrição contém palavras de uma lista
SELECT id, nome, descricao
FROM produtos
WHERE EXISTS (
    SELECT 1 
    FROM palavras_chave 
    WHERE produtos.descricao LIKE '%' || palavra || '%'
);
```

## LIKE com Diferentes Bancos

### MySQL

```sql
-- LIKE case-sensitive (depende do collation)
WHERE nome LIKE 'João%'

-- Case-insensitive (depende do collation)
WHERE nome LIKE 'João%' COLLATE utf8_general_ci
```

### PostgreSQL

```sql
-- LIKE case-sensitive
WHERE nome LIKE 'João%'

-- ILIKE case-insensitive
WHERE nome ILIKE 'joão%'
```

### SQL Server

```sql
-- LIKE case-insensitive (depende do collation)
WHERE nome LIKE 'João%'

-- Case-sensitive
WHERE nome LIKE 'João%' COLLATE SQL_Latin1_General_CP1_CS_AS
```

## Escape de Caracteres Especiais

### Problema: Caracteres curinga no texto

```sql
-- Se você quer buscar literalmente '%', precisa escapar
WHERE descricao LIKE '50\% off' ESCAPE '\'
```

### Sintaxe de escape

```sql
-- ESCAPE define o caractere de escape
WHERE descricao LIKE '50\% off' ESCAPE '\'

-- Outro caractere de escape
WHERE descricao LIKE '50|% off' ESCAPE '|'
```

## LIKE vs REGEXP - Quando Usar Cada Um

### Use LIKE quando

- Padrões simples com % e _
- Busca de prefixo ou sufixo
- Performance é importante
- Índices podem ser usados

### Use REGEXP quando

- Padrões complexos
- Múltiplas condições
- Expressões regulares são necessárias
- Performance não é crítica

## Resumo

- **Use LIKE quando**: Busca de padrão simples, prefixo/suffixo, performance é importante
- **Evite LIKE quando**: Padrões muito complexos (use REGEXP), grandes volumes com curinga no início (use Full-Text Search)
- **Alternativas**: = para igualdade exata, REGEXP para padrões complexos, Full-Text Search para grandes volumes
- **NULL**: LIKE com NULL na coluna não retorna linhas
- **Performance**: Curinga no início impede uso de índice, curinga no final permite uso de índice
- **Case sensitivity**: Depende do banco e collation - use UPPER/LOWER ou ILIKE para case-insensitive
- **Regra de ouro**: LIKE é ideal para buscas simples, mas cuidado com curinga no início em grandes volumes
