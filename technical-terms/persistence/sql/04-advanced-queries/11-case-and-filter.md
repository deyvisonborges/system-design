# CASE e FILTER

O operador `CASE` é usado para lógica condicional em SQL, permitindo retornar valores diferentes baseados em condições. A cláusula `FILTER` (PostgreSQL) é usada para filtrar linhas em funções de agregação.

## CASE - Sintaxe Básica

### CASE Simples

```sql
CASE column_name
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ELSE default_result
END
```

### CASE Procurado

```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```

## FILTER - Sintaxe Básica (PostgreSQL)

```sql
aggregate_function(column_name) FILTER (WHERE condition)
```

## Como Funciona - Passo a Passo

### CASE - Passo 1: Avaliação das condições

O banco avalia cada condição WHEN em ordem, de cima para baixo.

### CASE - Passo 2: Retorno do resultado

Quando uma condição é TRUE, o resultado correspondente é retornado e a avaliação para.

### CASE - Passo 3: ELSE

Se nenhuma condição for TRUE, o resultado do ELSE é retornado (ou NULL se não houver ELSE).

### FILTER - Passo 1: Filtragem antes da agregação

A cláusula FILTER filtra linhas antes da função de agregação ser aplicada.

### FILTER - Passo 2: Agregação no resultado filtrado

A função de agregação é aplicada apenas às linhas que satisfazem a condição FILTER.

## Exemplos Práticos - CASE

### Exemplo 1: CASE simples

```sql
-- Classificar produtos por categoria
SELECT 
    nome,
    CASE categoria_id
        WHEN 1 THEN 'Eletrônicos'
        WHEN 2 THEN 'Roupas'
        WHEN 3 THEN 'Alimentos'
        ELSE 'Outros'
    END as categoria
FROM produtos;
```

**Explicação detalhada:**

1. Para cada produto, o banco verifica o valor de `categoria_id`
2. Se for 1, retorna 'Eletrônicos'
3. Se for 2, retorna 'Roupas'
4. Se for 3, retorna 'Alimentos'
5. Se for qualquer outro valor, retorna 'Outros'

### Exemplo 2: CASE procurado

```sql
-- Classificar clientes por faixa de gasto
SELECT 
    nome,
    CASE 
        WHEN total_gasto < 100 THEN 'Baixo'
        WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
        WHEN total_gasto > 500 THEN 'Alto'
        ELSE 'Sem gasto'
    END as faixa_gasto
FROM clientes;
```

**Explicação detalhada:**

1. Para cada cliente, o banco avalia as condições em ordem
2. Se `total_gasto < 100`, retorna 'Baixo'
3. Se `total_gasto BETWEEN 100 AND 500`, retorna 'Médio'
4. Se `total_gasto > 500`, retorna 'Alto'
5. Se nenhuma condição for TRUE (total_gasto é NULL), retorna 'Sem gasto'

### Exemplo 3: CASE com agregação

```sql
-- Contar clientes por faixa de gasto
SELECT 
    CASE 
        WHEN total_gasto < 100 THEN 'Baixo'
        WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
        WHEN total_gasto > 500 THEN 'Alto'
        ELSE 'Sem gasto'
    END as faixa_gasto,
    COUNT(*) as total_clientes
FROM (
    SELECT cliente_id, SUM(valor_total) as total_gasto
    FROM pedidos
    GROUP BY cliente_id
) t
GROUP BY 
    CASE 
        WHEN total_gasto < 100 THEN 'Baixo'
        WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
        WHEN total_gasto > 500 THEN 'Alto'
        ELSE 'Sem gasto'
    END;
```

### Exemplo 4: CASE em ORDER BY

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

## Exemplos Práticos - FILTER

### Exemplo 1: FILTER básico

```sql
-- Contar pedidos por status (PostgreSQL)
SELECT 
    COUNT(*) as total_pedidos,
    COUNT(*) FILTER (WHERE status = 'pendente') as pendentes,
    COUNT(*) FILTER (WHERE status = 'concluido') as concluidos,
    COUNT(*) FILTER (WHERE status = 'cancelado') as cancelados
FROM pedidos;
```

**Explicação detalhada:**

1. `COUNT(*)` conta todos os pedidos
2. `COUNT(*) FILTER (WHERE status = 'pendente')` conta apenas pedidos com status 'pendente'
3. `COUNT(*) FILTER (WHERE status = 'concluido')` conta apenas pedidos com status 'concluido'
4. `COUNT(*) FILTER (WHERE status = 'cancelado')` conta apenas pedidos com status 'cancelado'

### Exemplo 2: FILTER com SUM

```sql
-- Somar valores por status (PostgreSQL)
SELECT 
    cliente_id,
    SUM(valor_total) as total_geral,
    SUM(valor_total) FILTER (WHERE status = 'pendente') as total_pendente,
    SUM(valor_total) FILTER (WHERE status = 'concluido') as total_concluido
FROM pedidos
GROUP BY cliente_id;
```

### Exemplo 3: FILTER com AVG

```sql
-- Média de preço por categoria e status (PostgreSQL)
SELECT 
    categoria_id,
    AVG(preco) as preco_medio_geral,
    AVG(preco) FILTER (WHERE ativo = 1) as preco_medio_ativo
FROM produtos
GROUP BY categoria_id;
```

## Comportamento com NULL

### Cenário 1: CASE com NULL

```sql
SELECT 
    nome,
    CASE cidade
        WHEN NULL THEN 'Sem cidade'
        ELSE cidade
    END as cidade_formatada
FROM clientes;
```

**Comportamento:**

- A comparação `cidade = NULL` sempre retorna UNKNOWN
- Portanto, o CASE nunca retornará 'Sem cidade'
- Use `IS NULL` em vez de `= NULL`

**Solução:**

```sql
SELECT 
    nome,
    CASE 
        WHEN cidade IS NULL THEN 'Sem cidade'
        ELSE cidade
    END as cidade_formatada
FROM clientes;
```

### Cenário 2: FILTER com NULL

```sql
SELECT 
    COUNT(*) FILTER (WHERE cidade IS NOT NULL) as com_cidade,
    COUNT(*) FILTER (WHERE cidade IS NULL) as sem_cidade
FROM clientes;
```

**Comportamento:**

- `FILTER (WHERE cidade IS NOT NULL)` conta apenas linhas onde cidade não é NULL
- `FILTER (WHERE cidade IS NULL)` conta apenas linhas onde cidade é NULL

## Pros e Contras

### CASE - Pros

1. **Flexibilidade**: Permite lógica condicional complexa

```sql
-- Flexível
CASE 
    WHEN condicao1 THEN resultado1
    WHEN condicao2 THEN resultado2
    ELSE resultado_padrao
END
```

1. **Legibilidade**: Expressa claramente a intenção condicional

2. **Versatilidade**: Pode ser usado em SELECT, WHERE, ORDER BY, GROUP BY

### CASE - Contras

1. **Complexidade**: CASE complexos podem ser difíceis de entender

2. **Performance**: CASE em colunas sem índice pode ser lento

3. **NULL handling**: Comparação com NULL requer `IS NULL`

### FILTER - Pros

1. **Eficiência**: Mais eficiente que múltiplas queries

```sql
-- Uma query com FILTER
SELECT 
    COUNT(*) FILTER (WHERE status = 'pendente') as pendentes,
    COUNT(*) FILTER (WHERE status = 'concluido') as concluidos
FROM pedidos;

-- Equivalente com múltiplas queries (menos eficiente)
SELECT COUNT(*) FROM pedidos WHERE status = 'pendente';
SELECT COUNT(*) FROM pedidos WHERE status = 'concluido';
```

1. **Legibilidade**: Mais legível que CASE com SUM

```sql
-- FILTER (mais legível)
SUM(valor) FILTER (WHERE status = 'concluido')

-- CASE (menos legível)
SUM(CASE WHEN status = 'concluido' THEN valor ELSE 0 END)
```

### FILTER - Contras

1. **Compatibilidade**: FILTER é específico do PostgreSQL

2. **Alternativa necessária**: Em outros bancos, usar CASE

## Cenários a Considerar

### Cenário 1: Classificação simples

**Recomendação:** Usar `CASE` simples

```sql
CASE categoria_id
    WHEN 1 THEN 'Eletrônicos'
    WHEN 2 THEN 'Roupas'
    ELSE 'Outros'
END
```

### Cenário 2: Classificação com condições complexas

**Recomendação:** Usar `CASE` procurado

```sql
CASE 
    WHEN total_gasto < 100 THEN 'Baixo'
    WHEN total_gasto BETWEEN 100 AND 500 THEN 'Médio'
    ELSE 'Alto'
END
```

### Cenário 3: Agregação condicional (PostgreSQL)

**Recomendação:** Usar `FILTER`

```sql
SUM(valor) FILTER (WHERE status = 'concluido')
```

### Cenário 4: Agregação condicional (outros bancos)

**Recomendação:** Usar `CASE` com agregação

```sql
SUM(CASE WHEN status = 'concluido' THEN valor ELSE 0 END)
```

### Cenário 5: Ordenação customizada

**Recomendação:** Usar `CASE` em ORDER BY

```sql
ORDER BY CASE status
    WHEN 'urgente' THEN 1
    WHEN 'alta' THEN 2
    ELSE 3
END
```

## CASE vs Alternativas

### CASE vs IF/ELSE

```sql
-- CASE (padrão SQL)
CASE WHEN condicao THEN resultado ELSE resultado_padrao END

-- IF/ELSE (MySQL específico)
IF(condicao, resultado, resultado_padrao)
```

**Escolha:** `CASE` é padrão SQL, `IF/ELSE` é específico do MySQL.

### CASE vs DECODE (Oracle)

```sql
-- CASE (padrão SQL)
CASE coluna WHEN valor1 THEN resultado1 ELSE resultado_padrao END

-- DECODE (Oracle específico)
DECODE(coluna, valor1, resultado1, resultado_padrao)
```

**Escolha:** `CASE` é padrão SQL, `DECODE` é específico do Oracle.

### FILTER vs CASE com agregação

```sql
-- FILTER (PostgreSQL, mais legível)
SUM(valor) FILTER (WHERE status = 'concluido')

-- CASE (padrão SQL, menos legível)
SUM(CASE WHEN status = 'concluido' THEN valor ELSE 0 END)
```

**Escolha:** `FILTER` no PostgreSQL, `CASE` em outros bancos.

## Dicas de Performance

1. **Use índices em condições CASE**: Índices podem melhorar performance

```sql
-- Se preco tiver índice
CASE WHEN preco > 100 THEN 'Caro' ELSE 'Barato' END
```

1. **Ordem das condições CASE**: Coloque condições mais prováveis primeiro

```sql
-- Mais eficiente se maioria for 'ativo'
CASE WHEN status = 'ativo' THEN 1 ELSE 0 END
```

1. **FILTER vs CASE**: FILTER pode ser mais eficiente que CASE com agregação

```sql
-- FILTER (mais eficiente no PostgreSQL)
SUM(valor) FILTER (WHERE status = 'concluido')

-- CASE (menos eficiente)
SUM(CASE WHEN status = 'concluido' THEN valor ELSE 0 END)
```

## Exemplos Avançados

### Exemplo 1: CASE com múltiplas condições

```sql
-- Classificação complexa
SELECT 
    nome,
    CASE 
        WHEN idade < 18 THEN 'Menor'
        WHEN idade BETWEEN 18 AND 25 THEN 'Jovem'
        WHEN idade BETWEEN 26 AND 60 THEN 'Adulto'
        WHEN idade > 60 THEN 'Idoso'
        ELSE 'Desconhecido'
    END as faixa_etaria
FROM clientes;
```

### Exemplo 2: CASE aninhado

```sql
-- CASE aninhado
SELECT 
    nome,
    CASE 
        WHEN cidade = 'São Paulo' THEN 
            CASE 
                WHEN bairro = 'Centro' THEN 'SP Centro'
                ELSE 'SP Outros'
            END
        ELSE 'Outra cidade'
    END as localizacao
FROM clientes;
```

### Exemplo 3: FILTER com múltiplas agregações

```sql
-- Estatísticas por cliente (PostgreSQL)
SELECT 
    cliente_id,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as valor_total,
    AVG(valor_total) as valor_medio,
    SUM(valor_total) FILTER (WHERE status = 'concluido') as valor_concluido,
    COUNT(*) FILTER (WHERE status = 'pendente') as pedidos_pendentes
FROM pedidos
GROUP BY cliente_id;
```

### Exemplo 4: CASE com NULL handling

```sql
-- Tratamento de NULL
SELECT 
    nome,
    CASE 
        WHEN email IS NULL THEN 'Sem email'
        WHEN email LIKE '%@gmail.com' THEN 'Gmail'
        WHEN email LIKE '%@yahoo.com' THEN 'Yahoo'
        ELSE 'Outro provedor'
    END as tipo_email
FROM clientes;
```

### Exemplo 5: FILTER com GROUP BY

```sql
-- Estatísticas por mês (PostgreSQL)
SELECT 
    EXTRACT(MONTH FROM data_pedido) as mes,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as valor_total,
    SUM(valor_total) FILTER (WHERE status = 'concluido') as valor_concluido
FROM pedidos
GROUP BY EXTRACT(MONTH FROM data_pedido);
```

## CASE em Diferentes Bancos

### MySQL

```sql
-- CASE padrão
CASE WHEN condicao THEN resultado ELSE resultado_padrao END

-- IF (MySQL específico)
IF(condicao, resultado, resultado_padrao)
```

### PostgreSQL

```sql
-- CASE padrão
CASE WHEN condicao THEN resultado ELSE resultado_padrao END

-- FILTER (PostgreSQL específico)
SUM(valor) FILTER (WHERE condicao)
```

### SQL Server

```sql
-- CASE padrão
CASE WHEN condicao THEN resultado ELSE resultado_padrao END

-- IIF (SQL Server específico)
IIF(condicao, resultado, resultado_padrao)
```

### Oracle

```sql
-- CASE padrão
CASE WHEN condicao THEN resultado ELSE resultado_padrao END

-- DECODE (Oracle específico)
DECODE(coluna, valor1, resultado1, resultado_padrao)
```

## Resumo

- **Use CASE quando**: Lógica condicional, classificação, transformação de dados
- **Use FILTER quando**: Agregação condicional no PostgreSQL, múltiplas agregações em uma query
- **Alternativas**: IF/ELSE (MySQL), IIF (SQL Server), DECODE (Oracle) para casos simples
- **NULL**: Use IS NULL em vez de = NULL em CASE
- **Performance**: Índices podem melhorar performance de CASE, FILTER é mais eficiente que CASE com agregação
- **Compatibilidade**: CASE é padrão SQL, FILTER é específico do PostgreSQL
- **Regra de ouro**: CASE para lógica condicional, FILTER para agregação condicional no PostgreSQL
