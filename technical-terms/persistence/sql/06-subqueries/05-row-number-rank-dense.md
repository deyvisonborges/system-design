# ROW_NUMBER, RANK, DENSE_RANK

As funções de ranking `ROW_NUMBER`, `RANK` e `DENSE_RANK` são window functions que atribuem rankings às linhas baseadas em uma ordem especificada. Cada função trata empates de forma diferente.

## Sintaxe Básica

```sql
SELECT 
    coluna1,
    coluna2,
    ROW_NUMBER() OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as row_num,
    RANK() OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as rank,
    DENSE_RANK() OVER (PARTITION BY coluna_grupo ORDER BY coluna_ordenacao) as dense_rank
FROM tabela;
```

## Diferenças Entre as Funções

### ROW_NUMBER

Atribui um número sequencial único para cada linha, mesmo que haja empates.

```sql
-- Sem empates: 1, 2, 3, 4, 5
-- Com empates: 1, 2, 3, 4, 5 (empates são quebrados arbitrariamente)
```

### RANK

Atribui o mesmo ranking para empates, mas pula números subsequentes.

```sql
-- Sem empates: 1, 2, 3, 4, 5
-- Com empates: 1, 2, 2, 4, 5 (pula o 3)
```

### DENSE_RANK

Atribui o mesmo ranking para empates, mas não pula números subsequentes.

```sql
-- Sem empates: 1, 2, 3, 4, 5
-- Com empates: 1, 2, 2, 3, 4 (não pula o 3)
```

## Exemplos Práticos

### Exemplo 1: ROW_NUMBER básico

```sql
SELECT nome, salario, ROW_NUMBER() OVER (ORDER BY salario DESC) as ranking
FROM funcionarios;
```

### Exemplo 2: RANK com empates

```sql
SELECT nome, valor_venda, RANK() OVER (ORDER BY valor_venda DESC) as ranking
FROM vendas;
```

### Exemplo 3: DENSE_RANK sem pulos

```sql
SELECT nome, valor_venda, DENSE_RANK() OVER (ORDER BY valor_venda DESC) as ranking
FROM vendas;
```

### Exemplo 4: Ranking por grupo

```sql
SELECT nome, departamento, salario,
       ROW_NUMBER() OVER (PARTITION BY departamento ORDER BY salario DESC) as ranking_dept
FROM funcionarios;
```

### Exemplo 5: Comparação das três funções

```sql
SELECT nome, salario,
       ROW_NUMBER() OVER (ORDER BY salario DESC) as row_num,
       RANK() OVER (ORDER BY salario DESC) as rank,
       DENSE_RANK() OVER (ORDER BY salario DESC) as dense_rank
FROM funcionarios;
```

## Comportamento com NULL

NULL é considerado menor que qualquer valor em ORDER BY. Linhas com NULL aparecem primeiro em ORDER BY ASC e por último em ORDER BY DESC.

## Pros e Contras

### Pros

1. **Flexibilidade**: Três opções diferentes para tratar empates
2. **Controle**: PARTITION BY permite ranking por grupos
3. **Padrão SQL**: Funções suportadas por todos os bancos principais

### Contras

1. **Complexidade**: Diferença entre RANK e DENSE_RANK pode ser confusa
2. **Performance**: Pode ser lento em grandes conjuntos sem índices
3. **Arbitrariedade**: ROW_NUMBER quebra empates arbitrariamente

## Cenários a Considerar

### Cenário 1: Ranking único

**Recomendação:** Usar `ROW_NUMBER`

```sql
ROW_NUMBER() OVER (ORDER BY valor DESC)
```

### Cenário 2: Empates com pulos

**Recomendação:** Usar `RANK`

```sql
RANK() OVER (ORDER BY valor DESC)
```

### Cenário 3: Empates sem pulos

**Recomendação:** Usar `DENSE_RANK`

```sql
DENSE_RANK() OVER (ORDER BY valor DESC)
```

### Cenário 4: Top N por grupo

**Recomendação:** Usar `ROW_NUMBER` com PARTITION BY

```sql
ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY valor DESC)
```

## ROW_NUMBER vs RANK vs DENSE_RANK

```sql
-- ROW_NUMBER (único, quebra empates)
ROW_NUMBER() OVER (ORDER BY salario DESC)

-- RANK (empates, pula números)
RANK() OVER (ORDER BY salario DESC)

-- DENSE_RANK (empates, não pula números)
DENSE_RANK() OVER (ORDER BY salario DESC)
```

**Escolha:** ROW_NUMBER para ranking único, RANK para empates com pulos, DENSE_RANK para empates sem pulos.

## Dicas de Performance

1. **Use índices**: Índices nas colunas de ORDER BY melhoram performance
2. **Limite o resultado**: Use WHERE antes da window function
3. **Evite PARTITION BY desnecessário**: Use apenas quando necessário

## Exemplos Avançados

### Exemplo 1: Top 3 por departamento

```sql
WITH ranking AS (
    SELECT nome, departamento, salario,
           ROW_NUMBER() OVER (PARTITION BY departamento ORDER BY salario DESC) as rn
    FROM funcionarios
)
SELECT * FROM ranking WHERE rn <= 3;
```

### Exemplo 2: Percentil com NTILE

```sql
SELECT nome, salario, NTILE(100) OVER (ORDER BY salario DESC) as percentil
FROM funcionarios;
```

### Exemplo 3: Identificar empates

```sql
SELECT nome, salario,
       RANK() OVER (ORDER BY salario DESC) as rank,
       ROW_NUMBER() OVER (ORDER BY salario DESC) as row_num
FROM funcionarios
WHERE RANK() OVER (ORDER BY salario DESC) <> ROW_NUMBER() OVER (ORDER BY salario DESC);
```

## Ranking em Diferentes Bancos

### PostgreSQL, MySQL 8.0+, SQL Server, Oracle

Todas suportam ROW_NUMBER, RANK e DENSE_RANK da mesma forma.

## Resumo

- **Use ROW_NUMBER quando**: Precisa de ranking único, top N por grupo
- **Use RANK quando**: Empates com pulos são aceitáveis (competições)
- **Use DENSE_RANK quando**: Empates sem pulos são desejados (classificação contínua)
- **NULL**: NULL é considerado menor que qualquer valor
- **Performance**: Use índices em ORDER BY, filtre antes da window function
- **Compatibilidade**: Suportado em PostgreSQL, MySQL 8.0+, SQL Server, Oracle
- **Regra de ouro**: ROW_NUMBER para unicidade, RANK para competições, DENSE_RANK para classificação
