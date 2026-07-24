# Otimização de WHERE

A cláusula WHERE é fundamental para filtrar dados e reduzir o conjunto de resultados. Otimizar WHERE é crucial porque filtros eficientes reduzem drasticamente a quantidade de dados processados, melhorando performance de toda a consulta.

## Definição

A cláusula WHERE especifica condições que as linhas devem satisfazer para serem incluídas no resultado. Otimização de WHERE envolve escrever condições que permitem ao banco usar índices eficientemente, evitar full table scans, e reduzir o conjunto de dados o mais cedo possível.

## Como Funciona - Passo a Passo

### Passo 1: Análise das Condições

O otimizador analisa cada condição na cláusula WHERE.

### Passo 2: Seleção de Índices

Para cada condição, o otimizador verifica se há índices apropriados.

### Passo 3: Estimativa de Seletividade

O otimizador estima quantas linhas satisfarão cada condição.

### Passo 4: Ordenação de Condições

Condições mais seletivas (que filtram mais) são executadas primeiro.

### Passo 5: Aplicação dos Filtros

Os filtros são aplicados sequencialmente, reduzindo o conjunto progressivamente.

## Tipos de Condições

### Sargable (Search ARGument ABLE)

Condições que podem usar índices eficientemente.

```sql
-- Sargable
WHERE coluna = valor
WHERE coluna > valor
WHERE coluna BETWEEN valor1 AND valor2
WHERE coluna IN (valor1, valor2)
```

### Non-Sargable

Condições que impedem uso de índices.

```sql
-- Non-Sargable
WHERE UPPER(coluna) = 'VALOR'
WHERE YEAR(coluna) = 2024
WHERE coluna + 10 = 20
WHERE coluna LIKE '%valor'
```

## Exemplos Práticos

### Exemplo 1: Igualdade com Índice

```sql
-- Com índice
CREATE INDEX idx_email ON clientes(email);

SELECT * FROM clientes WHERE email = 'joao@example.com';
```

**Explicação detalhada:**

1. Índice idx_email permite busca direta
2. O banco usa index scan em vez de seq scan
3. Complexidade O(log n) em vez de O(n)
4. Muito eficiente para tabelas grandes

### Exemplo 2: Range com Índice

```sql
-- Com índice
CREATE INDEX idx_data ON pedidos(data);

SELECT * FROM pedidos WHERE data >= '2024-01-01' AND data < '2025-01-01';
```

**Explicação detalhada:**

1. Índice ordenado permite busca de range eficiente
2. O banco busca o início do range e percorre até o fim
3. Evita leitura de linhas fora do range
4. Eficiente para ranges limitados

### Exemplo 3: Função em Coluna (Non-Sargable)

```sql
-- Evite: função em coluna
SELECT * FROM pedidos WHERE YEAR(data) = 2024;

-- Prefira: range em coluna
SELECT * FROM pedidos WHERE data >= '2024-01-01' AND data < '2025-01-01';
```

**Explicação detalhada:**

1. YEAR(data) impede uso de índice em data
2. O banco precisa calcular YEAR para cada linha
3. Full table scan é necessário
4. Range em coluna permite uso de índice

### Exemplo 4: LIKE com Prefixo

```sql
-- Bom: prefixo fixo
SELECT * FROM clientes WHERE nome LIKE 'Jo%';

-- Ruim: wildcard no início
SELECT * FROM clientes WHERE nome LIKE '%Jo%';
```

**Explicação detalhada:**

1. 'Jo%' pode usar índice (B-Tree permite busca por prefixo)
2. '%Jo%' não pode usar índice (precisa verificar todas as linhas)
3. Use prefixo fixo quando possível
4. Considere full-text search para padrões complexos

### Exemplo 5: Múltiplas Condições

```sql
-- Índices apropriados
CREATE INDEX idx_ativo ON clientes(ativo);
CREATE INDEX idx_data ON pedidos(data);

SELECT c.nome, p.data
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE c.ativo = true AND p.data > '2024-01-01';
```

**Explicação detalhada:**

1. Ambas as condições podem usar índices
2. Filtro em clientes reduz conjunto antes do join
3. Filtro em pedidos reduz conjunto após join
4. Ordem das condições pode afetar performance

## Estratégias de Otimização

### Estratégia 1: Evite Funções em Colunas Indexadas

Funções em colunas impedem uso de índices.

```sql
-- Evite
WHERE YEAR(data) = 2024
WHERE UPPER(nome) = 'JOAO'
WHERE DATE(data) = '2024-01-01'

-- Prefira
WHERE data >= '2024-01-01' AND data < '2025-01-01'
WHERE nome = 'Joao' OR nome = 'joao'
WHERE data >= '2024-01-01' AND data < '2024-01-02'
```

### Estratégia 2: Use Condições Sargable

Escreva condições que podem usar índices.

```sql
-- Sargable
WHERE coluna = valor
WHERE coluna > valor
WHERE coluna BETWEEN valor1 AND valor2
WHERE coluna IN (valor1, valor2)
WHERE coluna IS NULL
```

### Estratégia 3: Use IN em vez de OR

IN é geralmente mais eficiente que múltiplos OR.

```sql
-- Menos eficiente
WHERE coluna = valor1 OR coluna = valor2 OR coluna = valor3

-- Mais eficiente
WHERE coluna IN (valor1, valor2, valor3)
```

### Estratégia 4: Filtre o Mais Cedo Possível

Condições mais seletivas devem vir primeiro.

```sql
-- Bom: condição mais seletiva primeiro
WHERE cliente_id = 1 AND data > '2024-01-01'

-- Se cliente_id = 1 retorna poucas linhas, filtro em data é rápido
```

### Estratégia 5: Use BETWEEN para Ranges

BETWEEN é mais legível e pode usar índices.

```sql
-- Menos legível
WHERE data >= '2024-01-01' AND data <= '2024-12-31'

-- Mais legível
WHERE data BETWEEN '2024-01-01' AND '2024-12-31'
```

## Padrões Problemáticos

### Padrão 1: Função em Coluna

```sql
-- Problema
WHERE YEAR(data) = 2024

-- Solução
WHERE data >= '2024-01-01' AND data < '2025-01-01'
```

### Padrão 2: Wildcard no Início de LIKE

```sql
-- Problema
WHERE nome LIKE '%silva'

-- Solução
WHERE nome LIKE 'silva%'
-- Ou use full-text search
```

### Padrão 3: OR em Colunas Diferentes

```sql
-- Problema (pode impedir uso de índice)
WHERE coluna1 = valor1 OR coluna2 = valor2

-- Solução (use UNION se apropriado)
SELECT * FROM tabela WHERE coluna1 = valor1
UNION
SELECT * FROM tabela WHERE coluna2 = valor2
```

### Padrão 4: Negativo

```sql
-- Problema (pode impedir uso de índice)
WHERE coluna <> valor
WHERE NOT (coluna = valor)

-- Solução (use positivo quando possível)
WHERE coluna > valor OR coluna < valor
```

### Padrão 5: Cálculo em Coluna

```sql
-- Problema
WHERE preco * 1.1 > 100

-- Solução
WHERE preco > 100 / 1.1
```

## Pros e Contras

### Condições Sargable

**Pros:**

- Podem usar índices
- Mais eficientes
- Escaláveis

**Contras:**

- Podem requerer reescrita
- Menos intuitivas às vezes

### Condições Non-Sargable

**Pros:**

- Mais intuitivas
- Mais flexíveis

**Contras:**

- Não usam índices
- Full table scan
- Não escaláveis

## Cenários a Considerar

### Cenário 1: Filtro por Data

**Recomendação:** Use range em vez de função

```sql
-- Evite
WHERE YEAR(data) = 2024

-- Prefira
WHERE data >= '2024-01-01' AND data < '2025-01-01'
```

### Cenário 2: Busca de Texto

**Recomendação:** LIKE com prefixo ou full-text search

```sql
-- Prefixo (pode usar índice)
WHERE nome LIKE 'Jo%'

-- Full-text search (para padrões complexos)
WHERE to_tsvector('portuguese', nome) @@ to_tsquery('João & Silva')
```

### Cenário 3: Múltiplos Valores

**Recomendação:** Use IN em vez de OR

```sql
-- IN (mais eficiente)
WHERE id IN (1, 2, 3, 4, 5)

-- OR (menos eficiente)
WHERE id = 1 OR id = 2 OR id = 3 OR id = 4 OR id = 5
```

### Cenário 4: Condições Complexas

**Recomendação:** Separe em múltiplas consultas se necessário

```sql
-- Consulta complexa pode ser lenta
WHERE (condicao1 AND condicao2) OR (condicao3 AND condicao4)

-- Separe se possível
SELECT * FROM tabela WHERE condicao1 AND condicao2
UNION
SELECT * FROM tabela WHERE condicao3 AND condicao4
```

## Dicas de Performance

1. **Sempre verifique se índices estão sendo usados**

```sql
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Evite funções em colunas indexadas**

```sql
-- Evite
WHERE YEAR(data) = 2024

-- Prefira
WHERE data >= '2024-01-01' AND data < '2025-01-01'
```

1. **Use LIKE com prefixo fixo**

```sql
-- Bom
WHERE nome LIKE 'Jo%'

-- Ruim
WHERE nome LIKE '%Jo%'
```

1. **Filtre o mais cedo possível**

```sql
-- Condições mais seletivas primeiro
WHERE cliente_id = 1 AND data > '2024-01-01'
```

1. **Use índices parciais para subconjuntos**

```sql
-- Índice apenas para dados ativos
CREATE INDEX idx_ativos ON clientes(id) WHERE ativo = true;
```

## WHERE em Diferentes Bancos

### PostgreSQL

- Índices de expressão para funções
- Índices parciais com WHERE
- Full-text search integrado

```sql
-- Índice de expressão
CREATE INDEX idx_lower_nome ON clientes(LOWER(nome));

-- Índice parcial
CREATE INDEX idx_ativos ON clientes(id) WHERE ativo = true;
```

### MySQL

- Índices de função limitados
- Full-text index para colunas TEXT
- Índices invisíveis (MySQL 8.0+)

```sql
-- Full-text index
CREATE FULLTEXT INDEX idx_descricao ON produtos(descricao);

-- Índice invisível
CREATE INDEX idx_nome ON clientes(nome) INVISIBLE;
```

### SQL Server

- Índices filtrados (parciais)
- Índices incluídos
- Full-text search

```sql
-- Índice filtrado
CREATE INDEX idx_ativos ON clientes(id) WHERE ativo = 1;

-- Índice incluído
CREATE INDEX idx_nome ON clientes(nome) INCLUDE (email);
```

### Oracle

- Function-based indexes
- Índices bitmap para baixa cardinalidade
- Full-text search (Oracle Text)

```sql
-- Function-based index
CREATE INDEX idx_lower_nome ON clientes(LOWER(nome));

-- Bitmap index
CREATE BITMAP INDEX idx_ativo ON clientes(ativo);
```

## Resumo

- **Sargable**: Condições que podem usar índices (=, >, <, BETWEEN, IN)
- **Non-Sargable**: Condições que impedem índices (funções em colunas, wildcard no início)
- **Funções**: Evite funções em colunas indexadas, use ranges
- **LIKE**: Use prefixo fixo para usar índice, full-text para padrões complexos
- **IN vs OR**: IN é geralmente mais eficiente que múltiplos OR
- **Ordem**: Condições mais seletivas primeiro
- **Índices**: Verifique com EXPLAIN se índices estão sendo usados
- **Índices parciais**: Use para subconjuntos frequentemente acessados
- **Índices de expressão**: Use quando precisa de função em coluna (PostgreSQL, Oracle)
- **Compatibilidade**: Cada banco tem recursos específicos para otimização de WHERE
- **Regra de ouro**: Escreva condições sargáveis, evite funções em colunas, filtre o mais cedo possível
