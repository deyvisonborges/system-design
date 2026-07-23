# FULL JOIN

O `FULL JOIN` (ou `FULL OUTER JOIN`) retorna todas as linhas de ambas as tabelas. Se houver correspondência, retorna os dados combinados. Se não houver correspondência, retorna NULL para as colunas da tabela sem correspondência.

## Sintaxe Básica

```sql
SELECT column1, column2, ...
FROM table1
FULL JOIN table2 ON table1.column = table2.column;
```

## Como Funciona - Passo a Passo

### Passo 1: Produto cartesiano

O banco cria um produto cartesiano das duas tabelas (todas as combinações possíveis).

### Passo 2: Aplicação da condição ON

A condição ON é aplicada para filtrar as combinações.

### Passo 3: Retorno de todas as linhas de ambas

Todas as linhas de ambas as tabelas são retornadas. Se não houver correspondência, NULL é usado para as colunas da tabela sem correspondência.

## Exemplos Práticos

### Exemplo 1: FULL JOIN básico

```sql
-- Listar todos os clientes e todos os pedidos (com ou sem correspondência)
SELECT c.nome, p.id as pedido_id, p.data_pedido
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `clientes`
2. O banco retorna todas as linhas da tabela `pedidos`
3. Se houver correspondência, retorna os dados combinados
4. Se não houver correspondência, retorna NULL para as colunas da tabela sem correspondência

### Exemplo 2: FULL JOIN com WHERE

```sql
-- Listar clientes sem pedidos E pedidos sem cliente
SELECT c.nome, p.id as pedido_id, p.data_pedido
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL OR p.id IS NULL;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas de ambas as tabelas
2. O WHERE filtra para manter apenas linhas onde `c.id IS NULL` (pedidos sem cliente) ou `p.id IS NULL` (clientes sem pedidos)
3. Retorna clientes sem pedidos e pedidos sem cliente

### Exemplo 3: FULL JOIN com múltiplas tabelas

```sql
-- Listar todas as categorias e todos os produtos (com ou sem correspondência)
SELECT c.nome as categoria, p.nome as produto
FROM produtos p
FULL JOIN categorias c ON p.categoria_id = c.id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas da tabela `categorias`
2. O banco retorna todas as linhas da tabela `produtos`
3. Se houver correspondência, retorna os dados combinados
4. Se não houver correspondência, retorna NULL para as colunas da tabela sem correspondência

### Exemplo 4: FULL JOIN com agregação

```sql
-- Contar total de clientes e pedidos (com e sem correspondência)
SELECT 
    COUNT(DISTINCT c.id) as total_clientes,
    COUNT(DISTINCT p.id) as total_pedidos,
    COUNT(DISTINCT CASE WHEN c.id IS NOT NULL AND p.id IS NOT NULL THEN c.id END) as com_correspondencia
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas de ambas as tabelas
2. Conta o total de clientes distintos
3. Conta o total de pedidos distintos
4. Conta o número de correspondências

### Exemplo 5: FULL JOIN com COALESCE

```sql
-- Listar clientes e pedidos com identificação unificada
SELECT 
    COALESCE(c.nome, 'Cliente desconhecido') as cliente,
    COALESCE(p.id::text, 'Sem pedido') as pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Explicação detalhada:**

1. O banco retorna todas as linhas de ambas as tabelas
2. COALESCE substitui NULL por valores padrão
3. Retorna uma lista unificada de clientes e pedidos

## Comportamento com NULL

### Cenário 1: FULL JOIN com NULL na coluna de junção

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se `cliente_id` for NULL em pedidos, essas linhas são retornadas com NULL em clientes
- Se `id` for NULL em clientes, essas linhas são retornadas com NULL em pedidos
- FULL JOIN retorna todas as linhas de ambas, mesmo com NULL na coluna de junção

### Cenário 2: FULL JOIN com NULL no resultado

```sql
SELECT c.nome, p.id as pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

**Comportamento:**

- Se um cliente não tiver pedidos, as colunas de pedidos serão NULL
- Se um pedido não tiver cliente, as colunas de clientes serão NULL
- Isso é normal e esperado em FULL JOIN

## Pros e Contras

### Pros

1. **Preserva dados**: Retorna todas as linhas de ambas as tabelas

```sql
-- Todos os clientes e todos os pedidos
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
```

1. **Completude**: Permite ver todas as correspondências e não correspondências

2. **Análise de dados**: Útil para análise de integridade de dados

### Contras

1. **Performance**: Pode ser o tipo de JOIN mais lento

```sql
-- Pode ser o mais lento
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
```

1. **NULL handling**: Precisa tratar NULL no resultado

2. **Tamanho do resultado**: Pode retornar muitas linhas

3. **Compatibilidade**: Não suportado em MySQL (requer workaround)

## Cenários a Considerar

### Cenário 1: Análise de integridade de dados

**Recomendação:** Usar `FULL JOIN`

```sql
-- Encontrar clientes sem pedidos e pedidos sem cliente
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL OR p.id IS NULL
```

### Cenário 2: Relatórios completos

**Recomendação:** Usar `FULL JOIN`

```sql
-- Relatório completo de clientes e pedidos
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
```

### Cenário 3: Sincronização de dados

**Recomendação:** Usar `FULL JOIN`

```sql
-- Identificar diferenças entre duas tabelas
FROM tabela1 t1
FULL JOIN tabela2 t2 ON t1.id = t2.id
WHERE t1.id IS NULL OR t2.id IS NULL
```

### Cenário 4: Migração de dados

**Recomendação:** Usar `FULL JOIN`

```sql
-- Verificar se todos os dados foram migrados
FROM tabela_origem o
FULL JOIN tabela_destino d ON o.id = d.id
WHERE d.id IS NULL
```

### Cenário 5: FULL JOIN não disponível (MySQL)

**Recomendação:** Usar UNION de LEFT JOIN e RIGHT JOIN

```sql
-- Equivalente a FULL JOIN em MySQL
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
UNION
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

## FULL JOIN vs Alternativas

### FULL JOIN vs LEFT JOIN + RIGHT JOIN

```sql
-- FULL JOIN (todas as linhas de ambas)
SELECT c.nome, p.id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- Equivalente com LEFT JOIN + RIGHT JOIN (UNION)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
UNION
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `FULL JOIN` é mais simples e legível quando disponível.

### FULL JOIN vs INNER JOIN

```sql
-- FULL JOIN (todas as linhas de ambas)
SELECT c.nome, p.id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- INNER JOIN (apenas correspondências)
SELECT c.nome, p.id
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `FULL JOIN` para todas as linhas, `INNER JOIN` para apenas correspondências.

### FULL JOIN vs LEFT JOIN

```sql
-- FULL JOIN (todas as linhas de ambas)
SELECT c.nome, p.id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- LEFT JOIN (todas as linhas da esquerda)
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Escolha:** `FULL JOIN` para preservar linhas de ambas, `LEFT JOIN` para apenas esquerda.

## Dicas de Performance

1. **Use índices nas colunas de junção**: Índices podem melhorar performance significativamente

```sql
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);

-- Pode usar índice
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
```

1. **Filtre antes de JOIN**: Use WHERE para reduzir o número de linhas antes do JOIN

```sql
-- Bom (filtra antes)
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
WHERE c.cidade = 'São Paulo' OR p.data_pedido > '2024-01-01'
```

1. **Use FULL JOIN apenas quando necessário**: Se precisa apenas de uma tabela, LEFT JOIN é mais eficiente

```sql
-- Se precisa apenas de clientes, LEFT JOIN é mais eficiente
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
```

1. **Evite FULL JOIN em colunas sem índice**: Pode resultar em full table scan

```sql
-- Pode ser lento se colunas não tiverem índice
FROM tabela1 t1
FULL JOIN tabela2 t2 ON t1.coluna_sem_indice = t2.coluna_sem_indice
```

## Exemplos Avançados

### Exemplo 1: FULL JOIN com subquery

```sql
-- Comparar vendas de dois períodos
SELECT 
    COALESCE(p1.produto, p2.produto) as produto,
    p1.vendas as vendas_periodo1,
    p2.vendas as vendas_periodo2
FROM (SELECT produto_id, SUM(quantidade) as vendas FROM vendas WHERE periodo = 1 GROUP BY produto_id) p1
FULL JOIN (SELECT produto_id, SUM(quantidade) as vendas FROM vendas WHERE periodo = 2 GROUP BY produto_id) p2 ON p1.produto_id = p2.produto_id;
```

### Exemplo 2: FULL JOIN com múltiplas tabelas

```sql
-- Relatório completo de clientes, pedidos e produtos
SELECT c.nome, p.id as pedido_id, prod.nome as produto
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id
FULL JOIN itens_pedido ip ON p.id = ip.pedido_id
FULL JOIN produtos prod ON ip.produto_id = prod.id;
```

### Exemplo 3: FULL JOIN com CASE

```sql
-- Classificar correspondências
SELECT 
    CASE 
        WHEN c.id IS NOT NULL AND p.id IS NOT NULL THEN 'Correspondência'
        WHEN c.id IS NOT NULL AND p.id IS NULL THEN 'Cliente sem pedido'
        WHEN c.id IS NULL AND p.id IS NOT NULL THEN 'Pedido sem cliente'
    END as status,
    c.nome,
    p.id as pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

### Exemplo 4: FULL JOIN para encontrar diferenças

```sql
-- Encontrar clientes que mudaram de cidade
SELECT 
    c1.nome,
    c1.cidade as cidade_antiga,
    c2.cidade as cidade_nova
FROM clientes c1
FULL JOIN clientes_backup c2 ON c1.id = c2.id
WHERE c1.cidade <> c2.cidade OR (c1.cidade IS NULL AND c2.cidade IS NOT NULL) OR (c1.cidade IS NOT NULL AND c2.cidade IS NULL);
```

### Exemplo 5: FULL JOIN com agregação

```sql
-- Estatísticas completas de correspondências
SELECT 
    COUNT(DISTINCT c.id) as total_clientes,
    COUNT(DISTINCT p.id) as total_pedidos,
    COUNT(DISTINCT CASE WHEN c.id IS NOT NULL AND p.id IS NOT NULL THEN c.id END) as correspondencias,
    COUNT(DISTINCT CASE WHEN c.id IS NOT NULL AND p.id IS NULL THEN c.id END) as clientes_sem_pedidos,
    COUNT(DISTINCT CASE WHEN c.id IS NULL AND p.id IS NOT NULL THEN p.id END) as pedidos_sem_cliente
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;
```

## FULL JOIN em Diferentes Bancos

### PostgreSQL

```sql
-- FULL JOIN padrão
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- FULL OUTER JOIN (equivalente)
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### SQL Server

```sql
-- FULL JOIN padrão
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- FULL OUTER JOIN (equivalente)
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### Oracle

```sql
-- FULL JOIN padrão
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;

-- FULL OUTER JOIN (equivalente)
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

### MySQL (Workaround)

```sql
-- MySQL não suporta FULL JOIN, use UNION de LEFT JOIN e RIGHT JOIN
SELECT c.nome, p.id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
UNION
SELECT c.nome, p.id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

## Resumo

- **Use FULL JOIN quando**: Precisa preservar todas as linhas de ambas as tabelas, análise de integridade de dados
- **Evite FULL JOIN quando**: Precisa apenas de uma tabela (use LEFT JOIN), performance é crítica
- **Alternativas**: LEFT JOIN + RIGHT JOIN com UNION (para MySQL), INNER JOIN para apenas correspondências
- **NULL**: FULL JOIN retorna NULL para colunas da tabela sem correspondência
- **Performance**: FULL JOIN pode ser o mais lento, use índices nas colunas de junção
- **Compatibilidade**: FULL JOIN não é suportado em MySQL, requer workaround
- **Filtragem**: Use IS NULL para encontrar linhas sem correspondência
- **Regra de ouro**: FULL JOIN para análise de integridade, LEFT JOIN para preservar uma tabela
