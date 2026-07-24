# Window Functions

As Window Functions (Funções de Janela) permitem realizar cálculos em um conjunto de linhas relacionadas à linha atual, sem agregar as linhas em um único resultado. Elas operam sobre uma "janela" de dados definida pela cláusula `OVER`.

## Sintaxe Básica

```sql
SELECT 
    coluna1,
    coluna2,
    funcao_janela(coluna) OVER (
        PARTITION BY coluna_grupo
        ORDER BY coluna_ordenacao
        ROWS/RANGE BETWEEN ... AND ...
    ) as resultado
FROM tabela;
```

## Componentes da Window Function

### 1. Função de Janela

A função aplicada sobre a janela (SUM, COUNT, AVG, ROW_NUMBER, etc.).

### 2. OVER Clause

Define a janela sobre a qual a função opera.

### 3. PARTITION BY

Divide o resultado em partições (grupos) separados.

### 4. ORDER BY

Ordena as linhas dentro de cada partição.

### 5. Window Frame

Define o conjunto de linhas dentro da partição (ROWS, RANGE, GROUPS).

## Como Funciona - Passo a Passo

### Passo 1: Particionamento

Se PARTITION BY for especificado, os dados são divididos em grupos.

### Passo 2: Ordenação

As linhas dentro de cada partição são ordenadas.

### Passo 3: Definição do Frame

O frame da janela é definido (quais linhas são incluídas).

### Passo 4: Cálculo

A função é calculada para cada linha baseada no frame definido.

### Passo 5: Retorno

O resultado é retornado junto com as outras colunas.

## Exemplos Práticos

### Exemplo 1: SUM com OVER

```sql
-- Calcular total de vendas por categoria mantendo linhas individuais
SELECT 
    nome,
    categoria,
    valor,
    SUM(valor) OVER (PARTITION BY categoria) as total_categoria
FROM vendas;
```

**Explicação detalhada:**

1. PARTITION BY categoria divide os dados por categoria
2. SUM(valor) calcula o total para cada categoria
3. Cada linha mantém seu valor individual
4. Uma nova coluna mostra o total da categoria

### Exemplo 2: ROW_NUMBER

```sql
-- Numerar linhas dentro de cada categoria
SELECT 
    nome,
    categoria,
    valor,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY valor DESC) as ranking
FROM vendas;
```

**Explicação detalhada:**

1. PARTITION BY categoria cria grupos por categoria
2. ORDER BY valor DESC ordena por valor decrescente
3. ROW_NUMBER() atribui número sequencial
4. Retorna ranking dentro de cada categoria

### Exemplo 3: AVG com OVER

```sql
-- Comparar valor individual com média do grupo
SELECT 
    nome,
    departamento,
    salario,
    AVG(salario) OVER (PARTITION BY departamento) as media_departamento
FROM funcionarios;
```

**Explicação detalhada:**

1. PARTITION BY departamento agrupa por departamento
2. AVG(salario) calcula média salarial por departamento
3. Cada funcionário tem seu salário e a média do departamento
4. Útil para identificar funcionários acima/abaixo da média

### Exemplo 4: LAG e LEAD

```sql
-- Comparar valor atual com anterior e próximo
SELECT 
    data,
    valor,
    LAG(valor) OVER (ORDER BY data) as valor_anterior,
    LEAD(valor) OVER (ORDER BY data) as valor_proximo
FROM vendas;
```

**Explicação detalhada:**

1. LAG(valor) retorna o valor da linha anterior
2. LEAD(valor) retorna o valor da próxima linha
3. ORDER BY data define a ordem temporal
4. Útil para análise de tendências

### Exemplo 5: Window Frame

```sql
-- Média móvel de 3 dias
SELECT 
    data,
    valor,
    AVG(valor) OVER (
        ORDER BY data
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as media_movel_3dias
FROM vendas;
```

**Explicação detalhada:**

1. ROWS BETWEEN 2 PRECEDING AND CURRENT ROW define o frame
2. Inclui a linha atual e as 2 anteriores
3. AVG calcula a média dessas 3 linhas
4. Cria uma média móvel suavizada

## Comportamento com NULL

### Cenário 1: Window Functions com NULL

```sql
SELECT 
    nome,
    salario,
    SUM(salario) OVER (PARTITION BY departamento) as total
FROM funcionarios;
```

**Comportamento:**

- NULL é tratado como valor na partição
- SUM ignora NULL (como esperado)
- COUNT conta NULL se for a coluna da partição

### Cenário 2: ORDER BY com NULL

```sql
SELECT 
    nome,
    salario,
    ROW_NUMBER() OVER (ORDER BY salario) as ranking
FROM funcionarios;
```

**Comportamento:**

- NULL é considerado menor que qualquer valor
- Linhas com NULL aparecem primeiro em ORDER BY ASC
- Linhas com NULL aparecem por último em ORDER BY DESC

## Pros e Contras

### Pros

1. **Manutenção de linhas**: Window functions não reduzem o número de linhas

```sql
-- Mantém todas as linhas
SELECT nome, valor, SUM(valor) OVER () as total FROM vendas;
```

1. **Flexibilidade**: Permite cálculos complexos sem subqueries

```sql
-- Sem subqueries complexas
SELECT nome, valor, AVG(valor) OVER (PARTITION BY categoria) FROM vendas;
```

1. **Performance**: Geralmente mais eficiente que subqueries equivalentes

### Contras

1. **Complexidade**: Sintaxe pode ser complexa para iniciantes

```sql
-- Sintaxe complexa
SELECT nome, valor, 
       SUM(valor) OVER (PARTITION BY categoria ORDER BY data ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM vendas;
```

1. **Compatibilidade**: Nem todos os bancos suportam todas as funções

2. **Performance**: Pode ser lento em grandes conjuntos sem índices

## Cenários a Considerar

### Cenário 1: Ranking e ordenação

**Recomendação:** Usar window functions (ROW_NUMBER, RANK, DENSE_RANK)

```sql
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor DESC) as ranking FROM vendas;
```

### Cenário 2: Agregação sem redução

**Recomendação:** Usar window functions (SUM, AVG, COUNT com OVER)

```sql
SELECT nome, valor, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
```

### Cenário 3: Comparação temporal

**Recomendação:** Usar LAG/LEAD

```sql
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

### Cenário 4: Médias móveis

**Recomendação:** Usar window frame

```sql
SELECT data, valor, AVG(valor) OVER (ORDER BY data ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) FROM vendas;
```

### Cenário 5: Top N por grupo

**Recomendação:** Usar ROW_NUMBER com subquery

```sql
SELECT * FROM (
    SELECT nome, categoria, valor,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY valor DESC) as rn
    FROM vendas
) t WHERE rn <= 3;
```

## Window Functions vs Alternativas

### Window Functions vs GROUP BY

```sql
-- Window Function (mantém linhas)
SELECT nome, valor, SUM(valor) OVER (PARTITION BY categoria) as total
FROM vendas;

-- GROUP BY (reduz linhas)
SELECT categoria, SUM(valor) as total
FROM vendas
GROUP BY categoria;
```

**Escolha:** Window function para manter linhas, GROUP BY para agregação pura.

### Window Functions vs Subqueries

```sql
-- Window Function (mais eficiente)
SELECT nome, valor, AVG(valor) OVER (PARTITION BY categoria) FROM vendas;

-- Subquery (menos eficiente)
SELECT v.nome, v.valor, a.media
FROM vendas v
JOIN (SELECT categoria, AVG(valor) as media FROM vendas GROUP BY categoria) a
  ON v.categoria = a.categoria;
```

**Escolha:** Window function para performance e legibilidade.

### Window Functions vs Self JOIN

```sql
-- Window Function (mais simples)
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;

-- Self JOIN (mais complexo)
SELECT v1.data, v1.valor, v2.valor as valor_anterior
FROM vendas v1
LEFT JOIN vendas v2 ON v1.data = v2.data + INTERVAL '1 day';
```

**Escolha:** Window function para simplicidade, Self JOIN para casos específicos.

## Dicas de Performance

1. **Use índices**: Índices nas colunas de PARTITION BY e ORDER BY melhoram performance

```sql
-- Índice em (categoria, valor) ajuda
SELECT nome, valor, SUM(valor) OVER (PARTITION BY categoria ORDER BY valor) FROM vendas;
```

1. **Limite o frame**: Use frames específicos em vez de UNBOUNDED quando possível

```sql
-- Mais eficiente que UNBOUNDED
AVG(valor) OVER (ORDER BY data ROWS BETWEEN 10 PRECEDING AND CURRENT ROW)
```

1. **Evite window functions desnecessárias**: Use agregação simples quando possível

```sql
-- Se precisa apenas do total, use GROUP BY
SELECT categoria, SUM(valor) FROM vendas GROUP BY categoria;
```

1. **Filtre antes de window functions**: Use WHERE para reduzir o conjunto

```sql
-- Bom para performance
SELECT nome, valor, SUM(valor) OVER (PARTITION BY categoria)
FROM vendas
WHERE data > '2024-01-01';
```

## Tipos de Window Functions

### Agregação

- SUM, AVG, COUNT, MIN, MAX

```sql
SELECT nome, valor, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
```

### Ranking

- ROW_NUMBER, RANK, DENSE_RANK, NTILE

```sql
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor DESC) FROM vendas;
```

### Offset

- LAG, LEAD, FIRST_VALUE, LAST_VALUE

```sql
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

### Estatística

- PERCENT_RANK, CUME_DIST, STDDEV, VAR

```sql
SELECT nome, valor, PERCENT_RANK() OVER (ORDER BY valor) FROM vendas;
```

## Exemplos Avançados

### Exemplo 1: Múltiplas window functions

```sql
-- Análise completa com múltiplas métricas
SELECT 
    nome,
    categoria,
    valor,
    SUM(valor) OVER (PARTITION BY categoria) as total_categoria,
    AVG(valor) OVER (PARTITION BY categoria) as media_categoria,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY valor DESC) as ranking,
    LAG(valor) OVER (PARTITION BY categoria ORDER BY valor) as valor_anterior
FROM vendas;
```

### Exemplo 2: Window function em CTE

```sql
-- Top 3 produtos por categoria
WITH ranking AS (
    SELECT 
        nome,
        categoria,
        valor,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY valor DESC) as rn
    FROM vendas
)
SELECT nome, categoria, valor
FROM ranking
WHERE rn <= 3;
```

### Exemplo 3: Window frame complexo

```sql
-- Soma cumulativa com reset em mudança de categoria
SELECT 
    nome,
    categoria,
    valor,
    SUM(valor) OVER (
        PARTITION BY categoria
        ORDER BY data
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as soma_cumulativa
FROM vendas;
```

### Exemplo 4: FIRST_VALUE e LAST_VALUE

```sql
-- Primeiro e último valor por grupo
SELECT 
    nome,
    categoria,
    valor,
    FIRST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data) as primeiro_valor,
    LAST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ultimo_valor
FROM vendas;
```

### Exemplo 5: NTILE para quartis

```sql
-- Dividir em quartis
SELECT 
    nome,
    valor,
    NTILE(4) OVER (ORDER BY valor) as quartil
FROM vendas;
```

## Window Functions em Diferentes Bancos

### PostgreSQL

```sql
-- Suporta todas as window functions
SELECT nome, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor) FROM vendas;
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

### MySQL (8.0+)

```sql
-- Suporta window functions a partir do MySQL 8.0
SELECT nome, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor) FROM vendas;
```

### SQL Server

```sql
-- Suporta todas as window functions
SELECT nome, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor) FROM vendas;
```

### Oracle

```sql
-- Suporta todas as window functions
SELECT nome, SUM(valor) OVER (PARTITION BY categoria) FROM vendas;
SELECT nome, ROW_NUMBER() OVER (ORDER BY valor) FROM vendas;
```

## Window Frame Options

### ROWS

Baseado em posição física das linhas.

```sql
ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
```

### RANGE

Baseado em valores das colunas de ORDER BY.

```sql
RANGE BETWEEN INTERVAL '1 DAY' PRECEDING AND CURRENT ROW
```

### GROUPS

Baseado em grupos de valores iguais.

```sql
GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING
```

## Resumo

- **Use window functions quando**: Precisa de agregação sem redução de linhas, ranking, comparação temporal, médias móveis
- **Evite window functions quando**: Precisa apenas de agregação simples (use GROUP BY), performance crítica sem índices
- **Alternativas**: GROUP BY para agregação pura, subqueries para casos específicos, self JOIN para comparação temporal
- **NULL**: NULL é tratado como valor em PARTITION BY, considerado menor que qualquer valor em ORDER BY
- **Performance**: Use índices em PARTITION BY e ORDER BY, limite o frame, filtre antes de window functions
- **Compatibilidade**: Suportado em PostgreSQL, MySQL 8.0+, SQL Server, Oracle
- **Tipos**: Agregação, ranking, offset, estatística
- **Regra de ouro**: Window functions para cálculos sobre conjuntos relacionados, GROUP BY para agregação pura
