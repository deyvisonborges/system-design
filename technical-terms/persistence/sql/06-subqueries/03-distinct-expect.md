# DISTINCT

A cláusula `DISTINCT` remove linhas duplicadas do resultado de uma consulta, retornando apenas valores únicos. É usada para eliminar duplicatas e garantir que cada linha no resultado seja única.

## Sintaxe Básica

```sql
SELECT DISTINCT coluna1, coluna2, ...
FROM tabela
WHERE condicao;
```

## Como Funciona - Passo a Passo

### Passo 1: Execução da consulta

A consulta é executada normalmente, retornando todas as linhas que satisfazem as condições.

### Passo 2: Identificação de duplicatas

O banco identifica linhas duplicadas baseando-se em todas as colunas selecionadas.

### Passo 3: Remoção de duplicatas

As linhas duplicadas são removidas, mantendo apenas uma cópia de cada conjunto único.

### Passo 4: Ordenação (opcional)

O resultado pode ser ordenado se ORDER BY for especificado.

## Exemplos Práticos

### Exemplo 1: DISTINCT básico

```sql
-- Listar cidades únicas onde há clientes
SELECT DISTINCT cidade
FROM clientes;
```

**Explicação detalhada:**

1. A consulta seleciona todas as cidades da tabela clientes
2. DISTINCT remove cidades duplicadas
3. Retorna cada cidade apenas uma vez
4. Útil para saber quais cidades têm clientes

### Exemplo 2: DISTINCT em múltiplas colunas

```sql
-- Listar combinações únicas de cidade e estado
SELECT DISTINCT cidade, estado
FROM clientes;
```

**Explicação detalhada:**

1. A consulta seleciona cidade e estado
2. DISTINCT remove combinações duplicadas de (cidade, estado)
3. Retorna cada combinação única
4. Diferentes cidades com mesmo estado são mantidas

### Exemplo 3: DISTINCT com COUNT

```sql
-- Contar cidades únicas
SELECT COUNT(DISTINCT cidade) as num_cidades
FROM clientes;
```

**Explicação detalhada:**

1. DISTINCT remove cidades duplicadas
2. COUNT conta o número de cidades únicas
3. Retorna o total de cidades diferentes
4. Útil para estatísticas

### Exemplo 4: DISTINCT com JOIN

```sql
-- Listar clientes únicos que fizeram pedidos
SELECT DISTINCT c.nome, c.email
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O JOIN pode retornar múltiplas linhas por cliente (se tiver múltiplos pedidos)
2. DISTINCT remove duplicatas de clientes
3. Retorna cada cliente apenas uma vez
4. Útil para listar clientes com pedidos

### Exemplo 5: DISTINCT com ORDER BY

```sql
-- Listar cidades únicas ordenadas
SELECT DISTINCT cidade
FROM clientes
ORDER BY cidade;
```

**Explicação detalhada:**

1. DISTINCT remove cidades duplicadas
2. ORDER BY ordena o resultado
3. Retorna cidades únicas em ordem alfabética
4. A ordenação é aplicada após DISTINCT

## Comportamento com NULL

### Cenário 1: DISTINCT com NULL

```sql
SELECT DISTINCT email
FROM clientes;
```

**Comportamento:**

- NULL é tratado como um valor
- Múltiplos NULL são considerados duplicatas
- DISTINCT retorna apenas um NULL

### Cenário 2: DISTINCT em múltiplas colunas com NULL

```sql
SELECT DISTINCT cidade, estado
FROM clientes;
```

**Comportamento:**

- Combinações com NULL são tratadas normalmente
- (NULL, 'SP') é diferente de ('São Paulo', NULL)
- DISTINCT remove apenas combinações idênticas

## Pros e Contras

### Pros

1. **Simplicidade**: DISTINCT é simples de usar

```sql
-- Simples
SELECT DISTINCT cidade FROM clientes;
```

1. **Legibilidade**: Expressa claramente a intenção de remover duplicatas

```sql
-- Legível
SELECT DISTINCT categoria FROM produtos;
```

1. **Flexibilidade**: Pode ser usado em múltiplas colunas

### Contras

1. **Performance**: DISTINCT pode ser lento em grandes conjuntos de dados

```sql
-- Pode ser lento em tabela grande
SELECT DISTINCT * FROM tabela_grande;
```

1. **Ordenação**: DISTINCT pode requerer ordenação interna para identificar duplicatas

2. **Limitações**: Não pode ser usado com certas funções de agregação

## Cenários a Considerar

### Cenário 1: Listar valores únicos

**Recomendação:** Usar `DISTINCT`

```sql
SELECT DISTINCT categoria FROM produtos;
```

### Cenário 2: Contar valores únicos

**Recomendação:** Usar `COUNT(DISTINCT)`

```sql
SELECT COUNT(DISTINCT cliente_id) FROM pedidos;
```

### Cenário 3: Remover duplicatas de JOIN

**Recomendação:** Usar `DISTINCT`

```sql
SELECT DISTINCT c.nome FROM clientes c JOIN pedidos p ON c.id = p.cliente_id;
```

### Cenário 4: Performance crítica

**Recomendação:** Considerar GROUP BY ou EXISTS

```sql
-- GROUP BY pode ser mais eficiente
SELECT cidade FROM clientes GROUP BY cidade;
```

### Cenário 5: DISTINCT em todas as colunas

**Recomendação:** Evitar se possível

```sql
-- Evite DISTINCT *
SELECT DISTINCT * FROM tabela;
```

## DISTINCT vs Alternativas

### DISTINCT vs GROUP BY

```sql
-- DISTINCT (mais simples)
SELECT DISTINCT cidade FROM clientes;

-- GROUP BY (mais flexível)
SELECT cidade FROM clientes GROUP BY cidade;
```

**Escolha:** DISTINCT para simplicidade, GROUP BY para flexibilidade com agregações.

### DISTINCT vs EXISTS

```sql
-- DISTINCT
SELECT DISTINCT c.nome FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;

-- EXISTS (mais eficiente em alguns casos)
SELECT c.nome FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Escolha:** DISTINCT para simplicidade, EXISTS para performance em certos casos.

### DISTINCT vs ROW_NUMBER()

```sql
-- DISTINCT
SELECT DISTINCT coluna FROM tabela;

-- ROW_NUMBER() (mais controle)
SELECT coluna FROM (
    SELECT coluna, ROW_NUMBER() OVER (PARTITION BY coluna ORDER BY coluna) as rn
    FROM tabela
) t WHERE rn = 1;
```

**Escolha:** DISTINCT para simplicidade, ROW_NUMBER() para controle avançado.

## Dicas de Performance

1. **Use índices**: DISTINCT pode usar índices nas colunas

```sql
-- Pode usar índice em cidade
SELECT DISTINCT cidade FROM clientes;
```

1. **Limite o resultado**: Use WHERE para reduzir o conjunto antes de DISTINCT

```sql
-- Bom para performance
SELECT DISTINCT cidade FROM clientes WHERE estado = 'SP';
```

1. **Evite DISTINCT em muitas colunas**: Mais colunas = mais lento

```sql
-- Pode ser lento
SELECT DISTINCT col1, col2, col3, col4, col5 FROM tabela;
```

1. **Considere GROUP BY**: GROUP BY pode ser mais eficiente em alguns bancos

```sql
-- Pode ser mais eficiente
SELECT cidade FROM clientes GROUP BY cidade;
```

## Exemplos Avançados

### Exemplo 1: DISTINCT com CASE

```sql
-- Classificar clientes baseado em pedidos
SELECT DISTINCT 
    c.nome,
    CASE 
        WHEN p.id IS NOT NULL THEN 'Com pedido'
        ELSE 'Sem pedido'
    END as status
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

### Exemplo 2: DISTINCT em subquery

```sql
-- Encontrar produtos vendidos
SELECT DISTINCT produto_id
FROM itens_pedido
WHERE pedido_id IN (SELECT id FROM pedidos WHERE data_pedido > '2024-01-01');
```

### Exemplo 3: DISTINCT com agregação

```sql
-- Estatísticas por categoria
SELECT 
    categoria,
    COUNT(DISTINCT produto_id) as num_produtos,
    COUNT(DISTINCT cliente_id) as num_clientes
FROM vendas
GROUP BY categoria;
```

### Exemplo 4: DISTINCT com HAVING

```sql
-- Categorias com mais de 10 produtos únicos
SELECT categoria
FROM produtos
GROUP BY categoria
HAVING COUNT(DISTINCT produto_id) > 10;
```

### Exemplo 5: DISTINCT múltiplas vezes

```sql
-- Análise complexa com DISTINCT
SELECT 
    COUNT(DISTINCT cliente_id) as total_clientes,
    COUNT(DISTINCT produto_id) as total_produtos,
    COUNT(DISTINCT cidade) as total_cidades
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id;
```

## DISTINCT em Diferentes Bancos

### PostgreSQL

```sql
-- DISTINCT padrão
SELECT DISTINCT cidade FROM clientes;

-- DISTINCT ON (PostgreSQL específico)
SELECT DISTINCT ON (cidade) cidade, nome
FROM clientes
ORDER BY cidade, nome;
```

### MySQL

```sql
-- DISTINCT padrão
SELECT DISTINCT cidade FROM clientes;
```

### SQL Server

```sql
-- DISTINCT padrão
SELECT DISTINCT cidade FROM clientes;
```

### Oracle

```sql
-- DISTINCT padrão
SELECT DISTINCT cidade FROM clientes;
```

## DISTINCT ON (PostgreSQL)

### Sintaxe

```sql
SELECT DISTINCT ON (coluna) coluna, outra_coluna
FROM tabela
ORDER BY coluna, outra_coluna;
```

### Exemplo

```sql
-- Primeiro cliente de cada cidade
SELECT DISTINCT ON (cidade) cidade, nome
FROM clientes
ORDER BY cidade, nome;
```

**Explicação:**

- DISTINCT ON mantém apenas a primeira linha de cada grupo
- ORDER BY determina qual linha é mantida
- Específico do PostgreSQL

## Resumo

- **Use DISTINCT quando**: Remover duplicatas simples, listar valores únicos, contar valores únicos
- **Evite DISTINCT quando**: Performance crítica (considere GROUP BY ou EXISTS), precisa de controle avançado (use ROW_NUMBER)
- **Alternativas**: GROUP BY para agregações, EXISTS para performance, ROW_NUMBER() para controle avançado
- **NULL**: NULL é tratado como valor, múltiplos NULL são considerados duplicatas
- **Performance**: DISTINCT pode ser lento, use índices e WHERE para otimizar
- **Compatibilidade**: DISTINCT é padrão SQL, suportado por todos os bancos
- **DISTINCT ON**: Específico do PostgreSQL, mantém primeira linha de cada grupo
- **Regra de ouro**: DISTINCT para simplicidade, GROUP BY para agregações
