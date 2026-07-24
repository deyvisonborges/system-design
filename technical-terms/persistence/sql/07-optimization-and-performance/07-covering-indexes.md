# Covering Indexes

Um covering index (índice de cobertura) é um índice que contém todas as colunas necessárias para satisfazer uma consulta, permitindo que o banco recupere os dados diretamente do índice sem acessar a tabela principal. Isso é conhecido como "index-only scan" e pode melhorar drasticamente a performance.

## Definição

Um covering index inclui não apenas as colunas usadas em WHERE, JOIN, ORDER BY, e GROUP BY, mas também as colunas selecionadas no SELECT. Quando todas as colunas necessárias estão no índice, o banco pode executar a consulta usando apenas o índice, evitando o custo de acessar a tabela principal.

## Como Funciona - Passo a Passo

### Passo 1: Criação do Covering Index

O índice é criado com as colunas de filtro mais as colunas selecionadas.

### Passo 2: Execução da Consulta

Quando a consulta é executada, o otimizador verifica se o índice contém todas as colunas necessárias.

### Passo 3: Index-Only Scan

Se o índice cobrir todas as colunas, o banco faz um index-only scan, lendo apenas do índice.

### Passo 4: Evita Acesso à Tabela

O banco não precisa acessar a tabela principal, reduzindo I/O e melhorando performance.

## Sintaxe Básica

### PostgreSQL

```sql
-- Índice composto (covering)
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);

-- Índice com INCLUDE (PostgreSQL 11+)
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);
```

### MySQL

```sql
-- Índice composto (covering)
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

### SQL Server

```sql
-- Índice com INCLUDE
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);
```

### Oracle

```sql
-- Índice composto (covering)
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

## Exemplos Práticos

### Exemplo 1: Covering Index Básico

```sql
-- Consulta
SELECT cliente_id, data, valor
FROM pedidos
WHERE cliente_id = 1;

-- Índice normal (não covering)
CREATE INDEX idx_cliente ON pedidos(cliente_id);

-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

**Explicação detalhada:**

1. Índice normal: precisa acessar tabela para data e valor
2. Covering index: todas as colunas no índice, index-only scan
3. Reduz I/O significativamente
4. Melhora performance especialmente em tabelas grandes

### Exemplo 2: Covering Index com JOIN

```sql
-- Consulta
SELECT c.nome, p.data, p.valor
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id = 1;

-- Covering index para pedidos
CREATE INDEX idx_pedidos_covering ON pedidos(cliente_id, data, valor);
```

**Explicação detalhada:**

1. Índice cobre todas as colunas de pedidos usadas na consulta
2. JOIN pode usar o índice sem acessar tabela pedidos
3. Apenas tabela clientes precisa ser acessada
4. Reduz I/O do join

### Exemplo 3: Covering Index com ORDER BY

```sql
-- Consulta
SELECT cliente_id, data, valor
FROM pedidos
WHERE cliente_id = 1
ORDER BY data DESC;

-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

**Explicação detalhada:**

1. Índice cobre WHERE e ORDER BY
2. Dados já ordenados no índice
3. Index-only scan + ordenação gratuita
4. Muito eficiente

### Exemplo 4: Covering Index com GROUP BY

```sql
-- Consulta
SELECT cliente_id, COUNT(*), SUM(valor)
FROM pedidos
GROUP BY cliente_id;

-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, valor);
```

**Explicação detalhada:**

1. Índice cobre GROUP BY e agregação
2. Agrupamento pode usar índice
3. SUM(valor) usa valor do índice
4. Evita acesso à tabela

### Exemplo 5: Covering Index com INCLUDE (PostgreSQL)

```sql
-- Consulta
SELECT cliente_id, data, valor
FROM pedidos
WHERE cliente_id = 1;

-- Índice com INCLUDE
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);
```

**Explicação detalhada:**

1. INCLUDE adiciona colunas não-chave ao índice
2. Colunas em INCLUDE não participam da ordenação
3. Índice menor que índice composto equivalente
4. Ainda permite index-only scan

## Vantagens do Covering Index

### 1. Redução de I/O

O banco lê apenas o índice, não a tabela.

```sql
-- Menos I/O
SELECT cliente_id, data, valor FROM pedidos WHERE cliente_id = 1;
```

### 2. Melhor Cache

Índices são menores e cabem mais facilmente em cache.

```sql
-- Índice em cache é muito rápido
```

### 3. Evita Random I/O

Acesso sequencial ao índice em vez de random I/O na tabela.

```sql
-- Acesso sequencial é mais rápido
```

### 4. Melhor Performance em Joins

Joins podem usar apenas índices.

```sql
-- Join mais eficiente
SELECT c.nome, p.data FROM clientes c JOIN pedidos p ON c.id = p.cliente_id;
```

## Desvantagens do Covering Index

### 1. Maior Tamanho do Índice

Índices com mais colunas consomem mais espaço.

```sql
-- Índice maior
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

### 2. Escritas Mais Lentas

Mais colunas no índice = mais trabalho em INSERT/UPDATE/DELETE.

```sql
-- Escritas mais lentas
INSERT INTO pedidos (cliente_id, data, valor) VALUES (1, '2024-01-01', 100);
```

### 3. Manutenção Necessária

Índices precisam ser mantidos e reconstruídos.

```sql
-- Manutenção periódica necessária
REINDEX INDEX idx_covering;
```

### 4. Complexidade

Índices compostos complexos podem ser difíceis de gerenciar.

```sql
-- Muitos índices covering podem ser confusos
```

## Quando Usar Covering Indexes

### Cenário 1: Consultas Frequentes com Colunas Específicas

**Recomendação:** Crie covering index para consultas muito frequentes.

```sql
-- Consulta muito frequente
SELECT cliente_id, data, valor FROM pedidos WHERE cliente_id = 1;

-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

### Cenário 2: Tabelas Grandes com Muitas Colunas

**Recomendação:** Covering index evita ler colunas não necessárias.

```sql
-- Tabela grande com muitas colunas
SELECT id, nome, email FROM usuarios WHERE ativo = true;

-- Covering index (evita ler outras colunas)
CREATE INDEX idx_covering ON usuarios(ativo) INCLUDE (id, nome, email);
```

### Cenário 3: Joins Frequentes

**Recomendação:** Covering index para tabelas em join.

```sql
-- Join frequente
SELECT c.nome, p.data FROM clientes c JOIN pedidos p ON c.id = p.cliente_id;

-- Covering index para pedidos
CREATE INDEX idx_covering ON pedidos(cliente_id, data);
```

### Cenário 4: Relatórios com Agregações

**Recomendação:** Covering index para GROUP BY e agregações.

```sql
-- Relatório frequente
SELECT cliente_id, COUNT(*), SUM(valor) FROM pedidos GROUP BY cliente_id;

-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, valor);
```

## Quando NÃO Usar Covering Indexes

### Cenário 1: Consultas Raras

**Recomendação:** Não crie covering index para consultas raras.

```sql
-- Consulta rara
SELECT * FROM pedidos WHERE cliente_id = 1 AND data > '2024-01-01';

-- Índice normal é suficiente
CREATE INDEX idx_cliente_data ON pedidos(cliente_id, data);
```

### Cenário 2: Tabelas com Muitas Escritas

**Recomendação:** Evite covering indexes em tabelas com muitas escritas.

```sql
-- Tabela de logs com muitos inserts
-- Não crie covering index
```

### Cenário 3: SELECT *

**Recomendação:** Covering index não ajuda com SELECT *.

```sql
-- SELECT * não se beneficia de covering index
SELECT * FROM pedidos WHERE cliente_id = 1;
```

### Cenário 4: Muitas Colunas no SELECT

**Recomendação:** Covering index com muitas colunas pode ser muito grande.

```sql
-- Muitas colunas
SELECT col1, col2, col3, col4, col5, col6, col7, col8 FROM tabela WHERE id = 1;

-- Índice seria muito grande, não vale a pena
```

## Estratégias de Otimização

### Estratégia 1: INCLUDE vs Índice Composto

Use INCLUDE quando possível (PostgreSQL, SQL Server).

```sql
-- Índice composto (todas colunas participam da ordenação)
CREATE INDEX idx_composite ON pedidos(cliente_id, data, valor);

-- INCLUDE (colunas não-chave não participam da ordenação)
CREATE INDEX idx_include ON pedidos(cliente_id) INCLUDE (data, valor);
```

### Estratégia 2: Ordem das Colunas

Ordem das colunas importa em índices compostos.

```sql
-- Ordem correta (WHERE primeiro)
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);

-- Consulta usa índice
WHERE cliente_id = 1 ORDER BY data
```

### Estratégia 3: Limite o Número de Colunas

Inclua apenas colunas necessárias.

```sql
-- Bom (apenas colunas necessárias)
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);

-- Ruim (colunas desnecessárias)
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor, status, observacoes);
```

### Estratégia 4: Monitore Uso

Monitore se covering indexes estão sendo usados.

```sql
-- PostgreSQL
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE indexname = 'idx_covering';
```

### Estratégia 5: Remova Índices Não Usados

Remova covering indexes não usados.

```sql
-- Remover índice não usado
DROP INDEX idx_covering;
```

## Covering Index em Diferentes Bancos

### PostgreSQL

- Suporta INCLUDE (PostgreSQL 11+)
- Index-only scan automático quando possível
- Índices parciais podem ser covering

```sql
-- INCLUDE
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);

-- Índice parcial covering
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor) WHERE cliente_id = 1;
```

### MySQL

- Índices compostos funcionam como covering
- Não suporta INCLUDE
- Index condition pushdown

```sql
-- Índice composto covering
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

### SQL Server

- Suporta INCLUDE
- Covering indexes muito eficientes
- Índices filtrados podem ser covering

```sql
-- INCLUDE
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);

-- Índice filtrado covering
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor) WHERE cliente_id = 1;
```

### Oracle

- Índices compostos funcionam como covering
- Não suporta INCLUDE nativamente
- Index fast full scan

```sql
-- Índice composto covering
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

## Dicas de Performance

1. **Use EXPLAIN para verificar index-only scan**

```sql
EXPLAIN SELECT cliente_id, data, valor FROM pedidos WHERE cliente_id = 1;
```

1. **Priorize consultas mais frequentes**

```sql
-- Crie covering index para consultas mais frequentes
```

1. **Use INCLUDE quando disponível**

```sql
-- INCLUDE reduz tamanho do índice
CREATE INDEX idx_covering ON pedidos(cliente_id) INCLUDE (data, valor);
```

1. **Monitore tamanho do índice**

```sql
-- Verifique se índice não está muito grande
SELECT pg_size_pretty(pg_relation_size('idx_covering'));
```

1. **Balanceie leitura vs escrita**

```sql
-- Mais leituras = mais covering indexes
-- Mais escritas = menos covering indexes
```

## Resumo

- **Covering Index**: Índice que contém todas as colunas da consulta
- **Index-Only Scan**: Leitura apenas do índice, sem acessar tabela
- **Vantagens**: Reduz I/O, melhor cache, evita random I/O, melhor performance
- **Desvantagens**: Maior tamanho, escritas mais lentas, manutenção necessária
- **INCLUDE**: Adiciona colunas não-chave ao índice (PostgreSQL, SQL Server)
- **Ordem**: Ordem das colunas importa em índices compostos
- **Quando usar**: Consultas frequentes, tabelas grandes, joins frequentes, relatórios
- **Quando evitar**: Consultas raras, muitas escritas, SELECT *, muitas colunas
- **Monitoramento**: Verifique uso com EXPLAIN, monitore tamanho, remova não usados
- **Compatibilidade**: Todos suportam, INCLUDE disponível em PostgreSQL e SQL Server
- **Regra de ouro**: Use covering indexes para consultas frequentes críticas, monitore e ajuste
