# Scalar Subquery

Uma Scalar Subquery (Subquery Escalar) é uma subquery que retorna exatamente uma coluna e uma linha (um único valor). Ela pode ser usada em qualquer lugar onde uma expressão de valor único é permitida, como em SELECT, WHERE, HAVING, e até mesmo em VALUES.

## Sintaxe Básica

```sql
SELECT coluna1, (SELECT coluna2 FROM tabela2 WHERE condicao) as valor_escalar
FROM tabela1
WHERE coluna3 = (SELECT coluna4 FROM tabela3 WHERE condicao);
```

## Como Funciona - Passo a Passo

### Passo 1: Execução da subquery

A subquery é executada independentemente da query principal.

### Passo 2: Validação do resultado

O banco verifica se a subquery retornou exatamente uma linha e uma coluna.

### Passo 3: Substituição do valor

O valor retornado pela subquery é substituído no lugar da subquery na query principal.

### Passo 4: Continuação da query

A query principal continua sua execução com o valor escalar.

## Exemplos Práticos

### Exemplo 1: Scalar subquery em SELECT

```sql
-- Comparar salário individual com média da empresa
SELECT 
    nome,
    salario,
    (SELECT AVG(salario) FROM funcionarios) as media_empresa
FROM funcionarios;
```

**Explicação detalhada:**

1. A subquery calcula a média salarial de todos os funcionários
2. Retorna um único valor (a média)
3. Esse valor é adicionado como coluna em cada linha
4. Cada funcionário tem seu salário e a média da empresa

### Exemplo 2: Scalar subquery em WHERE

```sql
-- Funcionários com salário acima da média
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

**Explicação detalhada:**

1. A subquery calcula a média salarial
2. Retorna um único valor
3. A query principal filtra funcionários com salário acima desse valor
4. Útil para encontrar outliers

### Exemplo 3: Scalar subquery em HAVING

```sql
-- Departamentos com média salarial acima da média geral
SELECT departamento, AVG(salario) as media_dept
FROM funcionarios
GROUP BY departamento
HAVING AVG(salario) > (SELECT AVG(salario) FROM funcionarios);
```

**Explicação detalhada:**

1. A query principal agrupa por departamento e calcula médias
2. A subquery calcula a média geral
3. HAVING filtra departamentos acima da média geral
4. Útil para comparação entre grupos

### Exemplo 4: Scalar subquery em JOIN

```sql
-- Último pedido de cada cliente
SELECT c.nome, p.data_pedido
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data_pedido = (
    SELECT MAX(data_pedido) 
    FROM pedidos p2 
    WHERE p2.cliente_id = c.id
);
```

**Explicação detalhada:**

1. A subquery correlata encontra a data do último pedido do cliente
2. Retorna um único valor por cliente
3. A query principal filtra pedidos com essa data
4. Retorna o último pedido de cada cliente

### Exemplo 5: Scalar subquery em ORDER BY

```sql
-- Produtos ordenados pela diferença para o preço médio
SELECT nome, preco
FROM produtos
ORDER BY ABS(preco - (SELECT AVG(preco) FROM produtos));
```

**Explicação detalhada:**

1. A subquery calcula o preço médio
2. ORDER BY ordena pela diferença absoluta para a média
3. Produtos mais próximos da média aparecem primeiro
4. Útil para análise de distribuição

## Comportamento com NULL

### Cenário 1: Subquery retorna NULL

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT MAX(salario) FROM funcionarios WHERE departamento = 'Inexistente');
```

**Comportamento:**

- A subquery retorna NULL (não há funcionários no departamento)
- A comparação salario > NULL resulta em UNKNOWN
- Nenhuma linha é retornada
- Use COALESCE para tratar NULL

### Cenário 2: Subquery com COALESCE

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > COALESCE(
    (SELECT MAX(salario) FROM funcionarios WHERE departamento = 'Inexistente'),
    0
);
```

**Comportamento:**

- COALESCE substitui NULL por 0
- A comparação funciona corretamente
- Útil para evitar resultados vazios

## Erros Comuns

### Erro 1: Subquery retorna múltiplas linhas

```sql
-- ERRO: retorna múltiplas linhas
SELECT nome, salario
FROM funcionarios
WHERE salario = (SELECT salario FROM funcionarios);
```

**Solução:** Use IN, ANY, ALL ou adicione LIMIT 1.

### Erro 2: Subquery retorna múltiplas colunas

```sql
-- ERRO: retorna múltiplas colunas
SELECT nome, salario
FROM funcionarios
WHERE salario = (SELECT nome, salario FROM funcionarios WHERE id = 1);
```

**Solução:** Selecione apenas uma coluna.

## Pros e Contras

### Pros

1. **Flexibilidade**: Pode ser usada em múltiplos contextos

```sql
-- Flexível
SELECT nome, (SELECT AVG(salario) FROM funcionarios) FROM funcionarios;
```

1. **Legibilidade**: Expressa claramente a intenção de obter um valor único

2. **Correlação**: Pode ser correlata com a query principal

### Contras

1. **Performance**: Subquery correlata pode ser lenta

```sql
-- Pode ser lento (executa uma vez por linha)
SELECT nome, salario
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);
```

1. **Erros**: Retorna erro se não retornar exatamente uma linha

2. **Complexidade**: Subqueries aninhadas podem ser difíceis de entender

## Cenários a Considerar

### Cenário 1: Valor único independente

**Recomendação:** Usar scalar subquery não correlata

```sql
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) FROM funcionarios;
```

### Cenário 2: Valor correlato por linha

**Recomendação:** Usar scalar subquery correlata ou JOIN

```sql
-- Scalar subquery
SELECT nome, salario
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);

-- JOIN (pode ser mais eficiente)
SELECT f.nome, f.salario
FROM funcionarios f
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f.departamento = m.departamento
WHERE f.salario > m.media;
```

### Cenário 3: Performance crítica

**Recomendação:** Usar JOIN ou CTE

```sql
-- CTE
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT nome, salario FROM funcionarios f, media m WHERE f.salario > m.media;
```

## Scalar Subquery vs Alternativas

### Scalar Subquery vs JOIN

```sql
-- Scalar Subquery (mais simples)
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) as media
FROM funcionarios;

-- JOIN (mais eficiente para correlatas)
SELECT f.nome, f.salario, m.media
FROM funcionarios f
CROSS JOIN (SELECT AVG(salario) as media FROM funcionarios) m;
```

**Escolha:** Scalar subquery para simplicidade, JOIN para performance.

### Scalar Subquery vs CTE

```sql
-- Scalar Subquery
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) FROM funcionarios;

-- CTE (mais legível para múltiplas subqueries)
WITH media AS (SELECT AVG(salario) as media FROM funcionarios)
SELECT nome, salario, media FROM funcionarios, media;
```

**Escolha:** Scalar subquery para uso único, CTE para reuso.

## Dicas de Performance

1. **Evite subqueries correlatas**: Use JOIN ou CTE quando possível

```sql
-- Evite (executa uma vez por linha)
SELECT nome, salario
FROM funcionarios f
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento);

-- Prefira JOIN
SELECT f.nome, f.salario
FROM funcionarios f
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f.departamento = m.departamento
WHERE f.salario > m.media;
```

1. **Use índices**: Índices nas colunas usadas na subquery

```sql
-- Índice em salario ajuda
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

1. **Use LIMIT 1**: Quando possível, limite a uma linha

```sql
-- Garante uma linha
SELECT nome, salario
FROM funcionarios
WHERE salario = (SELECT salario FROM funcionarios ORDER BY salario LIMIT 1);
```

## Exemplos Avançados

### Exemplo 1: Múltiplas scalar subqueries

```sql
SELECT 
    nome,
    salario,
    (SELECT AVG(salario) FROM funcionarios) as media_geral,
    (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento) as media_dept,
    salario - (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f.departamento) as diferenca_media
FROM funcionarios f;
```

### Exemplo 2: Scalar subquery em CASE

```sql
SELECT 
    nome,
    salario,
    CASE 
        WHEN salario > (SELECT AVG(salario) FROM funcionarios) THEN 'Acima da média'
        WHEN salario < (SELECT AVG(salario) FROM funcionarios) THEN 'Abaixo da média'
        ELSE 'Na média'
    END as classificacao
FROM funcionarios;
```

### Exemplo 3: Scalar subquery em UPDATE

```sql
-- Atualizar com base em valor calculado
UPDATE produtos
SET preco = preco * 1.1
WHERE preco < (SELECT AVG(preco) FROM produtos);
```

### Exemplo 4: Scalar subquery em INSERT

```sql
-- Inserir com valor calculado
INSERT INTO historico_salarios (funcionario_id, salario, media_empresa)
SELECT id, salario, (SELECT AVG(salario) FROM funcionarios)
FROM funcionarios;
```

### Exemplo 5: Scalar subquery com agregação complexa

```sql
SELECT 
    departamento,
    COUNT(*) as num_funcionarios,
    AVG(salario) as media_dept,
    AVG(salario) / (SELECT AVG(salario) FROM funcionarios) as razao_media_geral
FROM funcionarios
GROUP BY departamento;
```

## Scalar Subquery em Diferentes Bancos

### PostgreSQL, MySQL, SQL Server, Oracle

Todas suportam scalar subqueries da mesma forma.

## Resumo

- **Use scalar subquery quando**: Precisa de um valor único, subquery simples, uso único
- **Evite scalar subquery quando**: Performance crítica (use JOIN), múltiplos usos (use CTE), subquery correlata complexa
- **Alternativas**: JOIN para performance, CTE para reuso, variáveis para múltiplos usos
- **NULL**: Subquery pode retornar NULL, use COALESCE para tratar
- **Erros**: Retorna erro se não retornar exatamente uma linha e uma coluna
- **Performance**: Evite subqueries correlatas, use índices, prefira JOIN/CTE
- **Compatibilidade**: Suportado em PostgreSQL, MySQL, SQL Server, Oracle
- **Regra de ouro**: Scalar subquery para simplicidade, JOIN/CTE para performance
