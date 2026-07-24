# Correlated vs Non-Correlated Subqueries

As subqueries podem ser classificadas em correlatas (correlated) e não correlatas (non-correlated) baseando-se em sua dependência da query principal. Esta distinção é fundamental para entender o desempenho e o comportamento das subqueries.

## Sintaxe Básica

### Non-Correlated Subquery

```sql
SELECT coluna1, coluna2
FROM tabela1
WHERE coluna3 = (SELECT coluna4 FROM tabela2 WHERE condicao_independente);
```

### Correlated Subquery

```sql
SELECT coluna1, coluna2
FROM tabela1 f1
WHERE coluna3 > (SELECT AVG(coluna4) FROM tabela2 f2 WHERE f2.departamento = f1.departamento);
```

## Como Funciona - Passo a Passo

### Non-Correlated Subquery

### Passo 1: Execução independente

A subquery é executada uma vez, independentemente da query principal.

### Passo 2: Retorno do resultado

A subquery retorna um resultado (valor, lista ou tabela).

### Passo 3: Substituição

O resultado é substituído na query principal.

### Passo 4: Execução da query principal

A query principal é executada com o resultado da subquery.

### Correlated Subquery

### Passo 1: Execução da query principal

A query principal começa a processar linhas.

### Passo 2: Execução da subquery por linha

Para cada linha da query principal, a subquery é executada novamente.

### Passo 3: Uso de valores da query principal

A subquery usa valores da linha atual da query principal.

### Passo 4: Filtragem

A linha é mantida ou descartada baseada no resultado da subquery.

## Exemplos Práticos

### Exemplo 1: Non-Correlated Subquery

```sql
-- Funcionários com salário acima da média geral
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

**Explicação detalhada:**

1. A subquery calcula a média salarial de todos os funcionários
2. Executa uma vez, independentemente da query principal
3. Retorna um único valor (a média)
4. A query principal filtra funcionários acima desse valor
5. Eficiente: subquery executada apenas uma vez

### Exemplo 2: Correlated Subquery

```sql
-- Funcionários com salário acima da média do departamento
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

**Explicação detalhada:**

1. A subquery referencia f1.departamento da query principal
2. Para cada funcionário, a subquery é executada novamente
3. Calcula a média do departamento específico
4. Compara o salário individual com a média do departamento
5. Pode ser lento: subquery executada uma vez por linha

### Exemplo 3: Non-Correlated com IN

```sql
-- Clientes que fizeram pedidos
SELECT nome, email
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```

**Explicação detalhada:**

1. A subquery retorna todos os cliente_id de pedidos
2. Executa uma vez, independentemente
3. IN verifica se o id está na lista
4. Eficiente para conjuntos moderados

### Exemplo 4: Correlated com EXISTS

```sql
-- Clientes que fizeram pedidos (versão correlata)
SELECT nome, email
FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Explicação detalhada:**

1. A subquery referencia c.id da query principal
2. Para cada cliente, verifica se existe pedido
3. EXISTS pode parar ao encontrar primeira correspondência
4. Pode ser eficiente com índices apropriados

### Exemplo 5: Non-Correlated em FROM

```sql
-- Departamentos com média salarial acima de 5000
SELECT departamento, media_salario
FROM (
    SELECT departamento, AVG(salario) as media_salario
    FROM funcionarios
    GROUP BY departamento
) as dept_media
WHERE media_salario > 5000;
```

**Explicação detalhada:**

1. A subquery cria tabela derivada com médias
2. Executa uma vez, independentemente
3. A query principal filtra o resultado
4. Eficiente: subquery executada apenas uma vez

## Comportamento com NULL

### Cenário 1: Non-Correlated com NULL

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios WHERE departamento = 'Inexistente');
```

**Comportamento:**

- A subquery retorna NULL (não há funcionários)
- A comparação salario > NULL resulta em UNKNOWN
- Nenhuma linha é retornada
- Use COALESCE para tratar NULL

### Cenário 2: Correlated com NULL

```sql
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

**Comportamento:**

- Se departamento for NULL, a subquery pode retornar NULL
- A comparação resulta em UNKNOWN
- A linha não é retornada
- Use COALESCE ou filtre NULLs

## Pros e Contras

### Non-Correlated Subquery

### Pros

1. **Performance**: Executa uma vez, geralmente mais eficiente

```sql
-- Eficiente
SELECT nome FROM funcionarios WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

1. **Simplicidade**: Mais fácil de entender e otimizar

2. **Cache**: O banco pode cachear o resultado

### Contras

1. **Limitação**: Não pode usar valores da query principal

2. **Contexto**: Menos flexível para comparações contextuais

### Correlated Subquery

### Pros

1. **Flexibilidade**: Pode usar valores da query principal

```sql
-- Flexível
SELECT nome FROM funcionarios f1 WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

1. **Contexto**: Permite comparações dentro de grupos

2. **Precisão**: Cálculos específicos por linha

### Contras

1. **Performance**: Executa uma vez por linha, pode ser lento

```sql
-- Pode ser lento
SELECT nome FROM funcionarios f1 WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

1. **Complexidade**: Mais difícil de entender e otimizar

2. **Escalabilidade**: Performance degrada com mais linhas

## Cenários a Considerar

### Cenário 1: Cálculo independente

**Recomendação:** Usar non-correlated subquery

```sql
SELECT nome FROM funcionarios WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

### Cenário 2: Cálculo dependente por linha

**Recomendação:** Usar correlated subquery ou JOIN

```sql
-- Correlated subquery
SELECT nome FROM funcionarios f1 WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- JOIN (mais eficiente)
SELECT f1.nome FROM funcionarios f1 JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m ON f1.departamento = m.departamento WHERE f1.salario > m.media;
```

### Cenário 3: Verificação de existência

**Recomendação:** Usar EXISTS (correlated) ou IN (non-correlated)

```sql
-- EXISTS (correlated, pode parar cedo)
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);

-- IN (non-correlated)
SELECT nome FROM clientes WHERE id IN (SELECT cliente_id FROM pedidos);
```

### Cenário 4: Performance crítica

**Recomendação:** Converter correlated para JOIN ou CTE

```sql
-- CTE (mais eficiente)
WITH dept_media AS (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento)
SELECT f.nome FROM funcionarios f JOIN dept_media m ON f.departamento = m.departamento WHERE f.salario > m.media;
```

## Correlated vs Non-Correlated vs Alternativas

### Correlated Subquery vs JOIN

```sql
-- Correlated Subquery (pode ser lento)
SELECT f1.nome, f1.salario
FROM funcionarios f1
WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- JOIN (mais eficiente)
SELECT f1.nome, f1.salario
FROM funcionarios f1
JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m
  ON f1.departamento = m.departamento
WHERE f1.salario > m.media;
```

**Escolha:** JOIN para performance, correlated subquery para simplicidade em conjuntos pequenos.

### Correlated Subquery vs CTE

```sql
-- Correlated Subquery
SELECT f1.nome, f1.salario
FROM funcionarios f1
WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);

-- CTE (mais eficiente e legível)
WITH dept_media AS (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento)
SELECT f.nome, f.salario FROM funcionarios f JOIN dept_media m ON f.departamento = m.departamento WHERE f.salario > m.media;
```

**Escolha:** CTE para performance e legibilidade, correlated subquery para casos simples.

### Non-Correlated Subquery vs Variável

```sql
-- Non-Correlated Subquery
SELECT nome, salario, (SELECT AVG(salario) FROM funcionarios) as media FROM funcionarios;

-- Variável (MySQL)
SET @media = (SELECT AVG(salario) FROM funcionarios);
SELECT nome, salario, @media as media FROM funcionarios;
```

**Escolha:** Variável para múltiplos usos, subquery para uso único.

## Dicas de Performance

1. **Converta correlated para JOIN**: JOIN é geralmente mais eficiente

```sql
-- Mais eficiente
SELECT f1.nome FROM funcionarios f1 JOIN (SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento) m ON f1.departamento = m.departamento WHERE f1.salario > m.media;
```

1. **Use EXISTS em vez de IN**: EXISTS pode parar ao encontrar primeira correspondência

```sql
-- Mais eficiente em alguns casos
SELECT nome FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

1. **Use índices**: Índices nas colunas de junção melhoram performance

```sql
-- Índice em departamento ajuda
SELECT f1.nome FROM funcionarios f1 WHERE f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

1. **Filtre antes**: Reduza o conjunto antes da subquery correlata

```sql
-- Bom para performance
SELECT nome, salario FROM funcionarios f1 WHERE f1.salario > 5000 AND f1.salario > (SELECT AVG(f2.salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

## Exemplos Avançados

### Exemplo 1: Múltiplas correlated subqueries

```sql
-- Comparação com múltiplas métricas
SELECT nome, salario, departamento
FROM funcionarios f1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento)
  AND salario < (SELECT MAX(salario) FROM funcionarios f3 WHERE f3.departamento = f1.departamento);
```

### Exemplo 2: Correlated subquery em SELECT

```sql
-- Diferença para a média do departamento
SELECT 
    nome,
    salario,
    departamento,
    salario - (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento) as diferenca_media
FROM funcionarios f1;
```

### Exemplo 3: Correlated subquery em UPDATE

```sql
-- Atualizar baseado em cálculo correlato
UPDATE funcionarios f1
SET bonus = salario * 0.1
WHERE salario > (SELECT AVG(salario) FROM funcionarios f2 WHERE f2.departamento = f1.departamento);
```

### Exemplo 4: Non-Correlated com CTE

```sql
-- Comparar períodos diferentes
WITH media_2023 AS (SELECT AVG(valor) as media FROM vendas WHERE YEAR(data) = 2023),
     media_2022 AS (SELECT AVG(valor) as media FROM vendas WHERE YEAR(data) = 2022)
SELECT m2023.media as media_2023, m2022.media as media_2022, m2023.media - m2022.media as diferenca
FROM media_2023, media_2022;
```

### Exemplo 5: Correlated subquery com window function

```sql
-- Comparar com ranking do departamento
SELECT nome, salario, departamento,
       (SELECT COUNT(*) FROM funcionarios f2 WHERE f2.departamento = f1.departamento AND f2.salario > f1.salario) + 1 as ranking_dept
FROM funcionarios f1;
```

## Correlated vs Non-Correlated em Diferentes Bancos

### PostgreSQL, MySQL, SQL Server, Oracle

Todas suportam correlated e non-correlated subqueries da mesma forma. A otimização pode variar entre bancos.

## Resumo

- **Use non-correlated quando**: Cálculo independente, performance crítica, resultado único
- **Use correlated quando**: Precisa de valores da linha atual, comparações contextuais, conjuntos pequenos
- **Converta para JOIN quando**: Performance crítica, correlated subquery lenta, grandes conjuntos
- **Use CTE quando**: Precisa reuso, legibilidade, múltiplas operações
- **Performance**: Non-correlated é geralmente mais eficiente, correlated executa por linha
- **Índices**: Índices nas colunas de junção melhoram performance de correlated subqueries
- **Compatibilidade**: Suportado em PostgreSQL, MySQL, SQL Server, Oracle
- **Regra de ouro**: Non-correlated para performance, correlated para flexibilidade, JOIN para grandes conjuntos
