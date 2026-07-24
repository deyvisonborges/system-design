# Shift Functions (LAG, LEAD, FIRST_VALUE, LAST_VALUE)

As Shift Functions (Funções de Deslocamento) são window functions que permitem acessar dados de outras linhas dentro da mesma partição. Elas são úteis para comparações temporais, cálculos de diferenças e análise de tendências.

## Sintaxe Básica

```sql
SELECT 
    coluna1,
    coluna2,
    LAG(coluna, offset, default) OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as valor_anterior,
    LEAD(coluna, offset, default) OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as valor_proximo,
    FIRST_VALUE(coluna) OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as primeiro_valor,
    LAST_VALUE(coluna) OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as ultimo_valor
FROM tabela;
```

## Componentes das Shift Functions

### 1. LAG

Retorna o valor de uma linha anterior na partição.

### 2. LEAD

Retorna o valor de uma linha posterior na partição.

### 3. FIRST_VALUE

Retorna o primeiro valor na partição.

### 4. LAST_VALUE

Retorna o último valor na partição.

## Como Funciona - Passo a Passo

### Passo 1: Particionamento

Se PARTITION BY for especificado, os dados são divididos em grupos.

### Passo 2: Ordenação

As linhas dentro de cada partição são ordenadas.

### Passo 3: Deslocamento

A função acessa o valor de outra linha baseado no offset especificado.

### Passo 4: Retorno

O valor da linha deslocada é retornado para a linha atual.

## Exemplos Práticos

### Exemplo 1: LAG básico

```sql
-- Comparar valor atual com valor anterior
SELECT 
    data,
    valor,
    LAG(valor) OVER (ORDER BY data) as valor_anterior
FROM vendas;
```

**Explicação detalhada:**

1. ORDER BY data ordena por data
2. LAG(valor) retorna o valor da linha anterior
3. A primeira linha retorna NULL (não há linha anterior)
4. Útil para calcular variações

### Exemplo 2: LEAD básico

```sql
-- Comparar valor atual com valor próximo
SELECT 
    data,
    valor,
    LEAD(valor) OVER (ORDER BY data) as valor_proximo
FROM vendas;
```

**Explicação detalhada:**

1. ORDER BY data ordena por data
2. LEAD(valor) retorna o valor da próxima linha
3. A última linha retorna NULL (não há próxima linha)
4. Útil para previsões simples

### Exemplo 3: LAG com offset

```sql
-- Comparar com valor de 2 dias atrás
SELECT 
    data,
    valor,
    LAG(valor, 2) OVER (ORDER BY data) as valor_2dias_atras
FROM vendas;
```

**Explicação detalhada:**

1. LAG(valor, 2) acessa a linha 2 posições atrás
2. As duas primeiras linhas retornam NULL
3. Útil para comparações com períodos maiores

### Exemplo 4: LAG com valor default

```sql
-- LAG com valor default para NULL
SELECT 
    data,
    valor,
    LAG(valor, 1, 0) OVER (ORDER BY data) as valor_anterior
FROM vendas;
```

**Explicação detalhada:**

1. O terceiro parâmetro (0) é o valor default
2. Quando não há linha anterior, retorna 0 em vez de NULL
3. Útil para evitar NULL em cálculos

### Exemplo 5: FIRST_VALUE e LAST_VALUE

```sql
-- Primeiro e último valor por categoria
SELECT 
    nome,
    categoria,
    valor,
    FIRST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data) as primeiro_valor,
    LAST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ultimo_valor
FROM vendas;
```

**Explicação detalhada:**

1. FIRST_VALUE retorna o primeiro valor da partição
2. LAST_VALUE retorna o último valor da partição
3. LAST_VALUE requer frame específico para funcionar corretamente
4. Útil para comparações com extremos

## Comportamento com NULL

### Cenário 1: LAG/LEAD com NULL nos dados

```sql
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

**Comportamento:**

- Se a linha anterior tiver NULL, LAG retorna NULL
- NULL é tratado como um valor válido
- Offset pula linhas, não valores

### Cenário 2: LAG/LEAD sem linha anterior/próxima

```sql
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

**Comportamento:**

- Primeira linha retorna NULL (sem linha anterior)
- Última linha retorna NULL em LEAD (sem próxima linha)
- Use valor default para evitar NULL

## Pros e Contras

### Pros

1. **Simplicidade**: Mais simples que self JOIN para comparações

```sql
-- Simples
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

1. **Performance**: Geralmente mais eficiente que self JOIN

2. **Flexibilidade**: Offset customizável e valor default

### Contras

1. **Complexidade**: LAST_VALUE requer frame específico

```sql
-- Complexo
LAST_VALUE(valor) OVER (ORDER BY data ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
```

1. **Compatibilidade**: Nem todos os bancos suportam todas as funções

2. **NULL**: Pode retornar NULL quando não há linha anterior/próxima

## Cenários a Considerar

### Cenário 1: Comparação temporal

**Recomendação:** Usar LAG/LEAD

```sql
LAG(valor) OVER (ORDER BY data)
```

### Cenário 2: Cálculo de diferença

**Recomendação:** Usar LAG com aritmética

```sql
valor - LAG(valor) OVER (ORDER BY data) as diferenca
```

### Cenário 3: Comparação com extremos

**Recomendação:** Usar FIRST_VALUE/LAST_VALUE

```sql
FIRST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data)
```

### Cenário 4: Média móvel

**Recomendação:** Usar window frame com agregação

```sql
AVG(valor) OVER (ORDER BY data ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

## Shift Functions vs Alternativas

### Shift Functions vs Self JOIN

```sql
-- Shift Function (mais simples)
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;

-- Self JOIN (mais complexo)
SELECT v1.data, v1.valor, v2.valor as valor_anterior
FROM vendas v1
LEFT JOIN vendas v2 ON v1.data = v2.data + INTERVAL '1 day';
```

**Escolha:** Shift function para simplicidade, Self JOIN para casos específicos.

### Shift Functions vs Subqueries

```sql
-- Shift Function (mais eficiente)
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;

-- Subquery (menos eficiente)
SELECT v1.data, v1.valor, 
       (SELECT valor FROM vendas v2 WHERE v2.data < v1.data ORDER BY v2.data DESC LIMIT 1) as valor_anterior
FROM vendas v1;
```

**Escolha:** Shift function para performance e legibilidade.

## Dicas de Performance

1. **Use índices**: Índices nas colunas de ORDER BY melhoram performance

```sql
-- Índice em data ajuda
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
```

1. **Limite o offset**: Offsets grandes podem ser lentos

```sql
-- Evite offsets muito grandes
LAG(valor, 100) OVER (ORDER BY data)
```

1. **Use PARTITION BY**: Particionamento reduz o conjunto de dados

```sql
-- Mais eficiente com PARTITION BY
LAG(valor) OVER (PARTITION BY categoria ORDER BY data)
```

1. **Filtre antes**: Use WHERE para reduzir o conjunto

```sql
-- Bom para performance
SELECT data, valor, LAG(valor) OVER (ORDER BY data)
FROM vendas
WHERE data > '2024-01-01';
```

## Exemplos Avançados

### Exemplo 1: Cálculo de variação percentual

```sql
SELECT 
    data,
    valor,
    LAG(valor) OVER (ORDER BY data) as valor_anterior,
    ((valor - LAG(valor) OVER (ORDER BY data)) / LAG(valor) OVER (ORDER BY data) * 100) as variacao_pct
FROM vendas;
```

### Exemplo 2: Detectar picos

```sql
SELECT 
    data,
    valor,
    LAG(valor) OVER (ORDER BY data) as anterior,
    LEAD(valor) OVER (ORDER BY data) as proximo,
    CASE 
        WHEN valor > LAG(valor) OVER (ORDER BY data) 
         AND valor > LEAD(valor) OVER (ORDER BY data) 
        THEN 'Pico'
        ELSE NULL
    END as pico
FROM vendas;
```

### Exemplo 3: Soma cumulativa

```sql
SELECT 
    data,
    valor,
    SUM(valor) OVER (ORDER BY data ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as soma_cumulativa
FROM vendas;
```

### Exemplo 4: Comparação com média móvel

```sql
SELECT 
    data,
    valor,
    AVG(valor) OVER (ORDER BY data ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as media_movel,
    valor - AVG(valor) OVER (ORDER BY data ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as diferenca_media
FROM vendas;
```

### Exemplo 5: Primeiro e último por grupo

```sql
SELECT 
    nome,
    categoria,
    valor,
    FIRST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data) as primeiro,
    LAST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ultimo
FROM vendas;
```

## Shift Functions em Diferentes Bancos

### PostgreSQL

```sql
-- Suporta todas as shift functions
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
SELECT data, valor, LEAD(valor) OVER (ORDER BY data) FROM vendas;
SELECT data, valor, FIRST_VALUE(valor) OVER (ORDER BY data) FROM vendas;
```

### MySQL (8.0+)

```sql
-- Suporta LAG, LEAD, FIRST_VALUE, LAST_VALUE a partir do MySQL 8.0
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
SELECT data, valor, LEAD(valor) OVER (ORDER BY data) FROM vendas;
```

### SQL Server

```sql
-- Suporta todas as shift functions
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
SELECT data, valor, LEAD(valor) OVER (ORDER BY data) FROM vendas;
```

### Oracle

```sql
-- Suporta todas as shift functions
SELECT data, valor, LAG(valor) OVER (ORDER BY data) FROM vendas;
SELECT data, valor, LEAD(valor) OVER (ORDER BY data) FROM vendas;
```

## LAST_VALUE e Window Frame

LAST_VALUE requer atenção especial ao window frame para funcionar corretamente.

### Sem frame (comportamento padrão)

```sql
-- Pode não retornar o último valor esperado
LAST_VALUE(valor) OVER (PARTITION BY categoria ORDER BY data)
```

### Com frame correto

```sql
-- Retorna o último valor da partição
LAST_VALUE(valor) OVER (
    PARTITION BY categoria 
    ORDER BY data 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```

## Resumo

- **Use LAG quando**: Precisa comparar com valor anterior, calcular diferenças
- **Use LEAD quando**: Precisa comparar com valor próximo, previsões simples
- **Use FIRST_VALUE quando**: Precisa comparar com primeiro valor do grupo
- **Use LAST_VALUE quando**: Precisa comparar com último valor do grupo (use frame correto)
- **NULL**: LAG/LEAD retornam NULL quando não há linha anterior/próxima, use valor default
- **Performance**: Use índices em ORDER BY, limite offset, use PARTITION BY
- **Compatibilidade**: Suportado em PostgreSQL, MySQL 8.0+, SQL Server, Oracle
- **Regra de ouro**: Shift functions para comparações temporais, self JOIN apenas quando necessário
