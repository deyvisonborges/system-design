# ORDER BY e GROUP BY Performance

ORDER BY e GROUP BY são operações que podem ser extremamente custosas se não otimizadas corretamente. ORDER BY requer ordenação dos dados, enquanto GROUP BY requer agrupamento e agregação. Ambas as operações podem se beneficiar significativamente de índices apropriados.

## Definição

ORDER BY ordena o resultado de uma consulta baseado em uma ou mais colunas. GROUP BY agrupa linhas que têm os mesmos valores em colunas especificadas, geralmente para aplicar funções de agregação. A performance de ambas depende do tamanho do conjunto de dados, presença de índices, e como o banco executa a operação.

## Como Funciona - Passo a Passo

### ORDER BY

### Passo 1: Análise da Ordenação

O otimizador verifica se há índice que corresponde à ordenação solicitada.

### Passo 2: Uso de Índice ou Sort

Se houver índice na ordem correta, o banco lê do índice já ordenado. Caso contrário, faz sort em memória ou disco.

### Passo 3: Aplicação de LIMIT

Se LIMIT estiver presente, o banco pode parar após ler o número necessário de linhas.

### Passo 4: Retorno do Resultado

Resultado ordenado é retornado.

### GROUP BY

### Passo 1: Identificação dos Grupos

O banco identifica valores únicos das colunas de GROUP BY.

### Passo 2: Agrupamento das Linhas

Linhas são agrupadas baseadas nos valores das colunas de GROUP BY.

### Passo 3: Aplicação de Agregações

Funções de agregação (COUNT, SUM, AVG, etc.) são aplicadas a cada grupo.

### Passo 4: Retorno do Resultado

Resultado agrupado é retornado.

## Exemplos Práticos

### Exemplo 1: ORDER BY com Índice

```sql
-- Com índice
CREATE INDEX idx_data ON pedidos(data);

SELECT * FROM pedidos ORDER BY data DESC;
```

**Explicação detalhada:**

1. Índice idx_data já está ordenado
2. O banco lê do índice na ordem desejada
3. Nenhuma ordenação adicional necessária
4. Muito eficiente, especialmente com LIMIT

### Exemplo 2: ORDER BY Sem Índice

```sql
-- Sem índice
SELECT * FROM pedidos ORDER BY valor;

-- Com índice
CREATE INDEX idx_valor ON pedidos(valor);
SELECT * FROM pedidos ORDER BY valor;
```

**Explicação detalhada:**

1. Sem índice, o banco precisa ordenar todas as linhas
2. Sort em memória ou disco (filesort)
3. Operação custosa O(n log n)
4. Com índice, leitura já ordenada

### Exemplo 3: ORDER BY com Múltiplas Colunas

```sql
-- Índice composto
CREATE INDEX idx_data_valor ON pedidos(data, valor);

SELECT * FROM pedidos ORDER BY data DESC, valor DESC;
```

**Explicação detalhada:**

1. Índice composto na ordem correta
2. O banco lê do índice já ordenado
3. Ordem das colunas no índice deve corresponder ao ORDER BY
4. Eficiente para ordenação múltipla

### Exemplo 4: GROUP BY com Índice

```sql
-- Com índice
CREATE INDEX idx_departamento ON funcionarios(departamento);

SELECT departamento, COUNT(*), AVG(salario)
FROM funcionarios
GROUP BY departamento;
```

**Explicação detalhada:**

1. Índice permite agrupamento eficiente
2. O banco pode usar o índice para identificar grupos
3. Evita criação de tabela temporária
4. Melhora performance significativamente

### Exemplo 5: GROUP BY com ORDER BY

```sql
-- Índice composto
CREATE INDEX idx_departamento_salario ON funcionarios(departamento, salario);

SELECT departamento, AVG(salario) as media_salario
FROM funcionarios
GROUP BY departamento
ORDER BY media_salario DESC;
```

**Explicação detalhada:**

1. Índice acelera GROUP BY
2. ORDER BY em resultado de agregação ainda precisa de sort
3. Considere índice em coluna agregada se frequente
4. Ou materialize resultado se usado frequentemente

## Estratégias de Otimização

### Estratégia 1: Índice para ORDER BY

Crie índice na ordem exata do ORDER BY.

```sql
-- ORDER BY usa índice
CREATE INDEX idx_data_valor ON pedidos(data, valor);

SELECT * FROM pedidos ORDER BY data DESC, valor DESC;
```

### Estratégia 2: LIMIT com ORDER BY

LIMIT é muito eficiente com índice apropriado.

```sql
-- Com índice, LIMIT é muito eficiente
SELECT * FROM pedidos ORDER BY data DESC LIMIT 10;

-- O banco lê apenas 10 linhas do índice
```

### Estratégia 3: Índice para GROUP BY

Crie índice nas colunas de GROUP BY.

```sql
-- GROUP BY usa índice
CREATE INDEX idx_departamento ON funcionarios(departamento);

SELECT departamento, COUNT(*) FROM funcionarios GROUP BY departamento;
```

### Estratégia 4: Evite ORDER BY em Grandes Conjuntos

Se não precisa de ordenação, evite ORDER BY.

```sql
-- Se não precisa ordenado, não use ORDER BY
SELECT * FROM pedidos WHERE cliente_id = 1;

-- Em vez de
SELECT * FROM pedidos WHERE cliente_id = 1 ORDER BY data;
```

### Estratégia 5: Use HAVING em vez de WHERE após GROUP BY

HAVING filtra após agrupamento, WHERE filtra antes.

```sql
-- WHERE filtra antes (mais eficiente)
SELECT departamento, AVG(salario)
FROM funcionarios
WHERE departamento IN ('Vendas', 'TI')
GROUP BY departamento;

-- HAVING filtra depois (menos eficiente)
SELECT departamento, AVG(salario)
FROM funcionarios
GROUP BY departamento
HAVING departamento IN ('Vendas', 'TI');
```

## Padrões Problemáticos

### Padrão 1: ORDER BY Sem Índice

```sql
-- Problema
SELECT * FROM pedidos ORDER BY valor;

-- Solução
CREATE INDEX idx_valor ON pedidos(valor);
```

### Padrão 2: ORDER BY em Expressão

```sql
-- Problema (não usa índice)
SELECT * FROM pedidos ORDER BY YEAR(data);

-- Solução (use range ou índice de expressão)
SELECT * FROM pedidos WHERE data >= '2024-01-01' AND data < '2025-01-01' ORDER BY data;
```

### Padrão 3: GROUP BY Sem Índice

```sql
-- Problema
SELECT departamento, COUNT(*) FROM funcionarios GROUP BY departamento;

-- Solução
CREATE INDEX idx_departamento ON funcionarios(departamento);
```

### Padrão 4: GROUP BY com Muitas Colunas

```sql
-- Problema (muitas colunas em GROUP BY)
SELECT col1, col2, col3, COUNT(*) FROM tabela GROUP BY col1, col2, col3;

-- Solução (considere reduzir ou índice composto)
CREATE INDEX idx_composite ON tabela(col1, col2, col3);
```

### Padrão 5: ORDER BY e GROUP BY Juntos

```sql
-- Problema (pode ser lento)
SELECT departamento, AVG(salario) FROM funcionarios GROUP BY departamento ORDER BY AVG(salario);

-- Solução (materialize se frequente)
CREATE VIEW dept_media AS SELECT departamento, AVG(salario) as media FROM funcionarios GROUP BY departamento;
CREATE INDEX idx_media ON dept_media(media);
```

## Pros e Contras

### ORDER BY com Índice

**Pros:**

- Leitura já ordenada
- Muito eficiente com LIMIT
- Evita sort custoso

**Contras:**

- Índices consomem espaço
- Escritas mais lentas
- Manutenção necessária

### ORDER BY Sem Índice

**Pros:**

- Sem custo de índice
- Flexível

**Contras:**

- Sort custoso O(n log n)
- Pode usar memória ou disco
- Não escalável

### GROUP BY com Índice

**Pros:**

- Agrupamento eficiente
- Evita tabela temporária
- Melhora performance

**Contras:**

- Índice necessário
- Custo de manutenção

### GROUP BY Sem Índice

**Pros:**

- Sem custo de índice
- Flexível

**Contras:**

- Tabela temporária
- Sort necessário
- Mais lento

## Cenários a Considerar

### Cenário 1: Paginação com ORDER BY

**Recomendação:** Use índice + LIMIT

```sql
-- Eficiente com índice
CREATE INDEX idx_data ON pedidos(data);

SELECT * FROM pedidos ORDER BY data DESC LIMIT 10 OFFSET 0;
SELECT * FROM pedidos ORDER BY data DESC LIMIT 10 OFFSET 10;
```

### Cenário 2: Relatórios com GROUP BY

**Recomendação:** Índice em colunas de GROUP BY

```sql
-- Índice para agrupamento
CREATE INDEX idx_departamento ON funcionarios(departamento);

SELECT departamento, COUNT(*), AVG(salario) FROM funcionarios GROUP BY departamento;
```

### Cenário 3: Top N por Grupo

**Recomendação:** Window function ou subquery

```sql
-- Window function
SELECT nome, salario, departamento,
       ROW_NUMBER() OVER (PARTITION BY departamento ORDER BY salario DESC) as rn
FROM funcionarios;

-- Ou subquery com índice
CREATE INDEX idx_departamento_salario ON funcionarios(departamento, salario);
```

### Cenário 4: Agregação Complexa

**Recomendação:** Materialize se usado frequentemente

```sql
-- Materialize resultado
CREATE TABLE dept_stats (
    departamento VARCHAR(50),
    num_func INT,
    media_salario DECIMAL(10,2),
    atualizado_em TIMESTAMP
);

-- Atualize periodicamente
INSERT INTO dept_stats
SELECT departamento, COUNT(*), AVG(salario), NOW()
FROM funcionarios
GROUP BY departamento;
```

## Dicas de Performance

1. **Sempre crie índice para ORDER BY frequente**

```sql
CREATE INDEX idx_data ON pedidos(data);
```

1. **Use LIMIT com ORDER BY para paginação**

```sql
SELECT * FROM pedidos ORDER BY data DESC LIMIT 10 OFFSET 0;
```

1. **Crie índice para GROUP BY**

```sql
CREATE INDEX idx_departamento ON funcionarios(departamento);
```

1. **Use WHERE antes de GROUP BY**

```sql
-- Filtre antes
SELECT departamento, AVG(salario)
FROM funcionarios
WHERE ativo = true
GROUP BY departamento;
```

1. **Evite ORDER BY se não necessário**

```sql
-- Se não precisa ordenado, não use ORDER BY
SELECT * FROM pedidos WHERE cliente_id = 1;
```

## ORDER BY e GROUP BY em Diferentes Bancos

### PostgreSQL

- Índices podem ser usados para ORDER BY e GROUP BY
- Índices de expressão para ORDER BY em funções
- Índices parciais para subconjuntos

```sql
-- Índice de expressão
CREATE INDEX idx_year_data ON pedidos((YEAR(data)));

-- Índice parcial
CREATE INDEX idx_recentes ON pedidos(data) WHERE data > '2024-01-01';
```

### MySQL

- Índices usados para ORDER BY se ordem corresponder
- Filesort para ORDER BY sem índice
- Temporary table para GROUP BY sem índice

```sql
-- Índice para ORDER BY
CREATE INDEX idx_data_valor ON pedidos(data, valor);

-- Verifica se usa filesort
EXPLAIN SELECT * FROM pedidos ORDER BY valor;
```

### SQL Server

- Índices clustered e non-clustered para ORDER BY
- Índices filtrados para subconjuntos
- Sort operator visível no plano de execução

```sql
-- Índice filtrado
CREATE INDEX idx_recentes ON pedidos(data) WHERE data > '2024-01-01';

-- Ver plano de execução
SET SHOWPLAN_TEXT ON;
SELECT * FROM pedidos ORDER BY data;
```

### Oracle

- Índices para ORDER BY e GROUP BY
- Índices bitmap para GROUP BY em baixa cardinalidade
- Sort operation visível no plano

```sql
-- Bitmap index para GROUP BY
CREATE BITMAP INDEX idx_departamento ON funcionarios(departamento);

-- Ver plano
EXPLAIN PLAN FOR SELECT departamento, COUNT(*) FROM funcionarios GROUP BY departamento;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

## Resumo

- **ORDER BY**: Use índice na ordem exata, evita sort custoso
- **GROUP BY**: Use índice nas colunas de agrupamento, evita tabela temporária
- **Índice composto**: Ordem das colunas deve corresponder ao ORDER BY/GROUP BY
- **LIMIT**: Muito eficiente com índice, lê apenas linhas necessárias
- **WHERE vs HAVING**: WHERE filtra antes (mais eficiente), HAVING filtra depois
- **Expressões**: Evite ORDER BY em expressões, use índice de expressão se necessário
- **Materialização**: Considere materializar agregações frequentes
- **Paginação**: Use índice + LIMIT para paginação eficiente
- **Compatibilidade**: Cada banco tem otimizações específicas
- **Regra de ouro**: Índices para ORDER BY e GROUP BY, WHERE antes de GROUP BY, evite ORDER BY desnecessário
