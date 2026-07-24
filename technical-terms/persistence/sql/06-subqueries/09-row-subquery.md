# Row Subquery

Uma Row Subquery (Subquery de Linha) é uma subquery que retorna exatamente uma linha com múltiplas colunas. Ela é usada com operadores de comparação de linha para comparar múltiplas colunas simultaneamente.

## Sintaxe Básica

```sql
SELECT coluna1, coluna2
FROM tabela1
WHERE (coluna3, coluna4) = (SELECT coluna5, coluna6 FROM tabela2 WHERE condicao LIMIT 1);
```

## Como Funciona - Passo a Passo

### Passo 1: Execução da subquery

A subquery é executada e retorna uma linha com múltiplas colunas.

### Passo 2: Validação do resultado

O banco verifica se a subquery retornou exatamente uma linha.

### Passo 3: Comparação de linha

A tupla (coluna3, coluna4) é comparada com a tupla retornada pela subquery.

### Passo 4: Filtragem

Linhas que satisfazem a comparação são mantidas.

## Exemplos Práticos

### Exemplo 1: Row subquery com =

```sql
-- Encontrar funcionário com mesmo nome e departamento de outro
SELECT nome, departamento, salario
FROM funcionarios
WHERE (nome, departamento) = (
    SELECT nome, departamento 
    FROM funcionarios 
    WHERE id = 5
);
```

**Explicação detalhada:**

1. A subquery retorna nome e departamento do funcionário com id 5
2. A query principal compara nome e departamento de cada funcionário
3. Retorna funcionários com mesma combinação de nome e departamento
4. Útil para encontrar duplicatas ou correspondências exatas

### Exemplo 2: Row subquery com IN

```sql
-- Funcionários cuja combinação nome-departamento está em uma lista
SELECT nome, departamento, salario
FROM funcionarios
WHERE (nome, departamento) IN (
    SELECT nome, departamento 
    FROM funcionarios 
    WHERE salario > 5000
);
```

**Explicação detalhada:**

1. A subquery retorna combinações de nome e departamento de funcionários bem pagos
2. IN verifica se a combinação está na lista retornada
3. Retorna funcionários com mesma combinação que funcionários bem pagos
4. Útil para filtrar por múltiplas colunas

### Exemplo 3: Row subquery com comparações

```sql
-- Produtos com mesmo preço e categoria que o produto mais caro
SELECT nome, preco, categoria
FROM produtos
WHERE (preco, categoria) = (
    SELECT preco, categoria 
    FROM produtos 
    ORDER BY preco DESC 
    LIMIT 1
);
```

**Explicação detalhada:**

1. A subquery retorna preço e categoria do produto mais caro
2. A query principal compara preço e categoria
3. Retorna produtos com mesma combinação
4. Útil para encontrar produtos com características específicas

### Exemplo 4: Row subquery com UPDATE

```sql
-- Atualizar funcionário com base em outra linha
UPDATE funcionarios
SET salario = 5000
WHERE (nome, departamento) = (
    SELECT nome, departamento 
    FROM funcionarios 
    WHERE id = 10
);
```

**Explicação detalhada:**

1. A subquery identifica um funcionário específico
2. UPDATE modifica funcionários com mesma combinação nome-departamento
3. Útil para atualizações baseadas em identificadores compostos

### Exemplo 5: Row subquery com DELETE

```sql
-- Deletar duplicatas mantendo a primeira
DELETE FROM funcionarios
WHERE id NOT IN (
    SELECT MIN(id)
    FROM funcionarios
    GROUP BY nome, departamento
);
```

**Explicação detalhada:**

1. A subquery encontra o menor id para cada combinação nome-departamento
2. DELETE remove linhas que não são a primeira ocorrência
3. Remove duplicatas mantendo a primeira
4. Útil para limpeza de dados

## Comportamento com NULL

### Cenário 1: Row subquery com NULL

```sql
SELECT nome, departamento
FROM funcionarios
WHERE (nome, departamento) = (SELECT nome, departamento FROM funcionarios WHERE id = 1);
```

**Comportamento:**

- Se qualquer coluna na tupla for NULL, a comparação resulta em UNKNOWN
- A linha não é retornada
- Use COALESCE para tratar NULLs

### Cenário 2: Row subquery com COALESCE

```sql
SELECT nome, departamento
FROM funcionarios
WHERE (COALESCE(nome, ''), COALESCE(departamento, '')) = (
    SELECT COALESCE(nome, ''), COALESCE(departamento, '') 
    FROM funcionarios 
    WHERE id = 1
);
```

**Comportamento:**

- COALESCE substitui NULL por valor default
- A comparação funciona mesmo com NULLs
- Útil para garantir comparações

## Erros Comuns

### Erro 1: Subquery retorna múltiplas linhas

```sql
-- ERRO: retorna múltiplas linhas
SELECT nome, departamento
FROM funcionarios
WHERE (nome, departamento) = (SELECT nome, departamento FROM funcionarios);
```

**Solução:** Use IN, adicione WHERE, ou use LIMIT 1.

### Erro 2: Número de colunas não corresponde

```sql
-- ERRO: número de colunas diferente
SELECT nome, departamento, salario
FROM funcionarios
WHERE (nome, departamento) = (SELECT nome FROM funcionarios WHERE id = 1);
```

**Solução:** Garanta que ambas as tuplas tenham o mesmo número de colunas.

## Pros e Contras

### Pros

1. **Comparação múltipla**: Permite comparar múltiplas colunas simultaneamente

```sql
-- Compara duas colunas de uma vez
WHERE (nome, departamento) = (SELECT nome, departamento FROM ...)
```

1. **Legibilidade**: Expressa claramente a intenção de comparar tuplas

2. **Identificadores compostos**: Útil para chaves compostas

### Contras

1. **Compatibilidade**: Nem todos os bancos suportam row subqueries

```sql
-- MySQL não suporta row subqueries com =
-- Use JOIN ou múltiplas condições
```

1. **Complexidade**: Sintaxe pode ser confusa

2. **NULL**: NULL em qualquer coluna quebra a comparação

## Cenários a Considerar

### Cenário 1: Comparar múltiplas colunas

**Recomendação:** Usar row subquery se suportado, senão múltiplas condições

```sql
-- Row subquery (PostgreSQL)
WHERE (nome, departamento) = (SELECT nome, departamento FROM ...)

-- Múltiplas condições (MySQL)
WHERE nome = (SELECT nome FROM ...) AND departamento = (SELECT departamento FROM ...)
```

### Cenário 2: Identificadores compostos

**Recomendação:** Usar row subquery ou concatenar valores

```sql
-- Row subquery
WHERE (col1, col2) = (SELECT col1, col2 FROM ...)

-- Concatenação
WHERE CONCAT(col1, '|', col2) = (SELECT CONCAT(col1, '|', col2) FROM ...)
```

### Cenário 3: Performance crítica

**Recomendação:** Usar JOIN

```sql
-- JOIN
SELECT f1.nome, f1.departamento
FROM funcionarios f1
JOIN funcionarios f2 ON f1.nome = f2.nome AND f1.departamento = f2.departamento
WHERE f2.id = 5;
```

## Row Subquery vs Alternativas

### Row Subquery vs Múltiplas Condições

```sql
-- Row Subquery (mais legível)
WHERE (nome, departamento) = (SELECT nome, departamento FROM funcionarios WHERE id = 5);

-- Múltiplas Condições (mais compatível)
WHERE nome = (SELECT nome FROM funcionarios WHERE id = 5)
  AND departamento = (SELECT departamento FROM funcionarios WHERE id = 5);
```

**Escolha:** Row subquery para legibilidade, múltiplas condições para compatibilidade.

### Row Subquery vs JOIN

```sql
-- Row Subquery
SELECT nome, departamento, salario
FROM funcionarios
WHERE (nome, departamento) = (SELECT nome, departamento FROM funcionarios WHERE id = 5);

-- JOIN (mais eficiente)
SELECT f1.nome, f1.departamento, f1.salario
FROM funcionarios f1
JOIN funcionarios f2 ON f1.nome = f2.nome AND f1.departamento = f2.departamento
WHERE f2.id = 5;
```

**Escolha:** JOIN para performance, row subquery para simplicidade.

## Dicas de Performance

1. **Use JOIN**: JOIN é geralmente mais eficiente que row subquery

```sql
-- Mais eficiente
SELECT f1.nome FROM funcionarios f1 JOIN funcionarios f2 ON f1.nome = f2.nome WHERE f2.id = 5;
```

1. **Use índices**: Índices nas colunas comparadas melhoram performance

```sql
-- Índices em nome e departamento ajudam
WHERE (nome, departamento) = (SELECT nome, departamento FROM ...)
```

1. **Limite a uma linha**: Use LIMIT 1 para garantir uma linha

```sql
-- Garante uma linha
WHERE (nome, departamento) = (SELECT nome, departamento FROM ... LIMIT 1);
```

## Exemplos Avançados

### Exemplo 1: Row subquery com IN

```sql
-- Encontrar produtos com mesma combinação de atributos
SELECT nome, preco, categoria
FROM produtos
WHERE (preco, categoria) IN (
    SELECT preco, categoria 
    FROM produtos 
    WHERE nome LIKE '%Premium%'
);
```

### Exemplo 2: Row subquery com comparações

```sql
-- Funcionários com salário e departamento maiores que outro
SELECT nome, salario, departamento
FROM funcionarios
WHERE (salario, departamento) > (
    SELECT salario, departamento 
    FROM funcionarios 
    WHERE nome = 'João'
);
```

### Exemplo 3: Row subquery em INSERT

```sql
-- Inserir baseado em outra linha
INSERT INTO historico (nome, departamento, salario)
SELECT nome, departamento, salario
FROM funcionarios
WHERE (nome, departamento) = (
    SELECT nome, departamento 
    FROM funcionarios 
    WHERE id = 10
);
```

### Exemplo 4: Row subquery com agregação

```sql
-- Encontrar funcionário com salário médio e departamento mais comum
SELECT nome, salario, departamento
FROM funcionarios
WHERE (salario, departamento) = (
    SELECT AVG(salario), MODE() WITHIN GROUP (ORDER BY departamento)
    FROM funcionarios
);
```

### Exemplo 5: Row subquery com CTE

```sql
-- Comparar com linha específica usando CTE
WITH referencia AS (
    SELECT nome, departamento, salario
    FROM funcionarios
    WHERE id = 5
)
SELECT f.nome, f.departamento, f.salario
FROM funcionarios f, referencia r
WHERE (f.nome, f.departamento) = (r.nome, r.departamento);
```

## Row Subquery em Diferentes Bancos

### PostgreSQL

```sql
-- Suporta row subqueries
WHERE (col1, col2) = (SELECT col1, col2 FROM tabela WHERE id = 1);
```

### MySQL

```sql
-- Não suporta row subqueries com =
-- Use múltiplas condições ou JOIN
WHERE col1 = (SELECT col1 FROM ...) AND col2 = (SELECT col2 FROM ...);
```

### SQL Server

```sql
-- Suporta row subqueries limitadas
-- Prefira múltiplas condições ou JOIN
```

### Oracle

```sql
-- Suporta row subqueries
WHERE (col1, col2) = (SELECT col1, col2 FROM tabela WHERE id = 1);
```

## Resumo

- **Use row subquery quando**: Comparar múltiplas colunas simultaneamente, identificadores compostos, banco suporta
- **Evite row subquery quando**: Banco não suporta (MySQL), performance crítica (use JOIN), NULL presente
- **Alternativas**: Múltiplas condições para compatibilidade, JOIN para performance, concatenação para identificadores
- **NULL**: NULL em qualquer coluna quebra a comparação, use COALESCE
- **Erros**: Retorna erro se não retornar exatamente uma linha ou número de colunas não corresponde
- **Performance**: Use JOIN, índices nas colunas comparadas, limite a uma linha
- **Compatibilidade**: PostgreSQL e Oracle suportam, MySQL e SQL Server limitado
- **Regra de ouro**: Row subquery para legibilidade onde suportado, JOIN para performance
