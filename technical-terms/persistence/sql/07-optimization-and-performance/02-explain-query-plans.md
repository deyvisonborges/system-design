# EXPLAIN e Planos de Execução

EXPLAIN é um comando SQL que mostra como o banco de dados planeja executar uma consulta. Analisar o plano de execução é essencial para entender gargalos de performance e identificar oportunidades de otimização.

## Definição

O plano de execução (query plan) é o conjunto de passos que o otimizador do banco de dados decide usar para executar uma consulta. EXPLAIN revela esse plano, mostrando quais índices serão usados, como as tabelas serão acessadas, e em que ordem as operações ocorrerão.

## Como Funciona - Passo a Passo

### Passo 1: Análise da Consulta

O otimizador analisa a consulta SQL, identificando tabelas, colunas, joins, filtros e ordenações.

### Passo 2: Geração de Planos Alternativos

O otimizador gera múltiplos planos possíveis para executar a consulta.

### Passo 3: Estimativa de Custos

Cada plano é avaliado com base em estatísticas das tabelas (tamanho, cardinalidade, distribuição de dados).

### Passo 4: Seleção do Melhor Plano

O plano com menor custo estimado é escolhido para execução.

### Passo 5: EXPLAIN Mostra o Plano

EXPLAIN revela o plano selecionado sem executar a consulta.

## Sintaxe Básica

### EXPLAIN Básico

```sql
EXPLAIN SELECT * FROM clientes WHERE id = 1;
```

### EXPLAIN ANALYZE (PostgreSQL)

```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id = 1;
```

### EXPLAIN FORMAT (PostgreSQL, MySQL)

```sql
EXPLAIN (FORMAT JSON) SELECT * FROM clientes WHERE id = 1;
EXPLAIN (FORMAT TEXT, VERBOSE) SELECT * FROM clientes WHERE id = 1;
```

## Componentes do Plano de Execução

### Tipos de Acesso (Scan Methods)

#### Seq Scan (Sequential Scan)

Leitura sequencial completa da tabela. Geralmente indica falta de índice apropriado.

```sql
-- PostgreSQL
Seq Scan on clientes  (cost=0.00..35.50 rows=2550 width=4)
```

#### Index Scan

Uso de índice para encontrar linhas específicas.

```sql
-- PostgreSQL
Index Scan using idx_clientes_id on clientes  (cost=0.29..8.31 rows=1 width=4)
```

#### Index Only Scan

Acesso apenas ao índice, sem ler a tabela (covering index).

```sql
-- PostgreSQL
Index Only Scan using idx_covering on pedidos  (cost=0.42..8.44 rows=1 width=4)
```

### Tipos de Join

#### Nested Loop Join

Para cada linha da tabela externa, busca correspondências na tabela interna. Eficiente para tabelas pequenas ou quando índices estão disponíveis.

```sql
-- PostgreSQL
Nested Loop  (cost=0.29..16.55 rows=1 width=8)
```

#### Hash Join

Cria hash table da tabela menor e faz join com tabela maior. Eficiente para tabelas grandes sem índices.

```sql
-- PostgreSQL
Hash Join  (cost=8.31..24.82 rows=1 width=8)
```

#### Merge Join

Ordena ambas as tabelas e faz merge join. Eficiente quando dados já estão ordenados.

```sql
-- PostgreSQL
Merge Join  (cost=1000.00..2000.00 rows=10000 width=8)
```

### Operações Adicionais

#### Sort

Ordenação dos resultados. Pode indicar falta de índice para ORDER BY.

```sql
-- PostgreSQL
Sort  (cost=8.31..8.32 rows=1 width=8)
  Sort Key: data DESC
```

#### Hash

Criação de hash table para hash join ou agregação.

```sql
-- PostgreSQL
Hash  (cost=8.31..8.31 rows=1 width=4)
```

#### Aggregate

Operação de agregação (COUNT, SUM, AVG, etc.).

```sql
-- PostgreSQL
Aggregate  (cost=8.31..8.32 rows=1 width=8)
```

#### Limit

Aplicação de LIMIT para restringir número de linhas.

```sql
-- PostgreSQL
Limit  (cost=0.00..8.31 rows=10 width=4)
```

## Métricas Importantes

### Cost

Custo estimado da operação. Unidade arbitrária do banco. Menor é melhor.

```sql
-- PostgreSQL
(cost=0.29..8.31 rows=1 width=4)
-- 0.29 = custo de inicialização
-- 8.31 = custo total
```

### Rows

Número estimado de linhas processadas.

```sql
-- PostgreSQL
(rows=1 width=4)
-- 1 linha estimada
```

### Width

Tamanho médio de cada linha em bytes.

```sql
-- PostgreSQL
(rows=1 width=4)
-- 4 bytes por linha
```

### Actual Time (EXPLAIN ANALYZE)

Tempo real gasto na operação (em milissegundos).

```sql
-- PostgreSQL
(actual time=0.015..0.017 rows=1 loops=1)
-- 0.015ms = tempo de inicialização
-- 0.017ms = tempo total
```

### Loops

Número de vezes que a operação foi executada.

```sql
-- PostgreSQL
(actual time=0.015..0.017 rows=1 loops=1)
-- Executou 1 vez
```

## Exemplos Práticos

### Exemplo 1: EXPLAIN Básico

```sql
EXPLAIN SELECT * FROM clientes WHERE id = 1;
```

**Saída PostgreSQL:**

```
Index Scan using idx_clientes_id on clientes  (cost=0.29..8.31 rows=1 width=4)
  Index Cond: (id = 1)
```

**Explicação detalhada:**

1. `Index Scan`: Usando índice idx_clientes_id
2. `cost=0.29..8.31`: Custo de 0.29 a 8.31
3. `rows=1`: Estima 1 linha retornada
4. `width=4`: 4 bytes por linha
5. `Index Cond`: Condição do índice (id = 1)

### Exemplo 2: Seq Scan vs Index Scan

```sql
-- Sem índice
EXPLAIN SELECT * FROM clientes WHERE nome = 'João';

-- Com índice
CREATE INDEX idx_nome ON clientes(nome);
EXPLAIN SELECT * FROM clientes WHERE nome = 'João';
```

**Saída sem índice:**

```
Seq Scan on clientes  (cost=0.00..35.50 rows=2550 width=4)
  Filter: (nome = 'João'::text)
```

**Saída com índice:**

```
Index Scan using idx_nome on clientes  (cost=0.29..8.31 rows=1 width=4)
  Index Cond: (nome = 'João'::text)
```

**Explicação detalhada:**

1. Sem índice: Seq Scan (leitura completa da tabela)
2. Com índice: Index Scan (busca direta no índice)
3. Custo muito menor com índice (8.31 vs 35.50)
4. Linhas estimadas mais precisas com índice

### Exemplo 3: EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id = 1;
```

**Saída PostgreSQL:**

```
Index Scan using idx_clientes_id on clientes  (cost=0.29..8.31 rows=1 width=4) (actual time=0.015..0.017 rows=1 loops=1)
  Index Cond: (id = 1)
Planning Time: 0.123 ms
Execution Time: 0.045 ms
```

**Explicação detalhada:**

1. `actual time=0.015..0.017`: Tempo real de execução
2. `rows=1`: Linhas realmente retornadas
3. `loops=1`: Executou 1 vez
4. `Planning Time`: Tempo para gerar o plano
5. `Execution Time`: Tempo total de execução

### Exemplo 4: Join com Nested Loop

```sql
EXPLAIN SELECT c.nome, p.data
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id = 1;
```

**Saída PostgreSQL:**

```
Nested Loop  (cost=0.29..16.55 rows=1 width=8)
  ->  Index Scan using idx_clientes_id on clientes c  (cost=0.29..8.31 rows=1 width=4)
        Index Cond: (id = 1)
  ->  Index Scan using idx_pedidos_cliente on pedidos p  (cost=0.00..8.23 rows=1 width=4)
        Index Cond: (cliente_id = c.id)
```

**Explicação detalhada:**

1. `Nested Loop`: Join usando nested loop
2. Primeiro busca cliente por id (índice)
3. Para cada cliente, busca pedidos (índice)
4. Eficiente quando ambos têm índices

### Exemplo 5: Hash Join

```sql
EXPLAIN SELECT c.nome, COUNT(p.id)
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.nome;
```

**Saída PostgreSQL:**

```
Hash Join  (cost=8.31..24.82 rows=100 width=8)
  Hash Cond: (p.cliente_id = c.id)
  ->  Seq Scan on pedidos p  (cost=0.00..15.00 rows=1000 width=4)
  ->  Hash  (cost=8.31..8.31 rows=100 width=4)
        ->  Seq Scan on clientes c  (cost=0.00..8.31 rows=100 width=4)
```

**Explicação detalhada:**

1. `Hash Join`: Join usando hash
2. Cria hash de clientes
3. Faz join com pedidos usando hash
4. Eficiente para tabelas grandes sem índices

## Interpretando o Plano

### Identificando Problemas

#### Full Table Scan

```
Seq Scan on tabela  (cost=0.00..1000.00 rows=100000 width=4)
```

**Problema:** Leitura completa da tabela. Considere adicionar índice.

#### Sort Expensive

```
Sort  (cost=1000.00..2000.00 rows=100000 width=8)
  Sort Key: data DESC
```

**Problema:** Ordenação custosa. Considere índice para ORDER BY.

#### High Rows Estimated

```
Seq Scan on tabela  (cost=0.00..1000.00 rows=1000000 width=4)
```

**Problema:** Estimativa muito alta pode indicar estatísticas desatualizadas.

#### Nested Loop com Muitas Iterações

```
Nested Loop  (cost=0.29..10000.00 rows=100000 width=8)
  ->  Seq Scan on tabela1  (cost=0.00..100.00 rows=1000 width=4)
  ->  Index Scan on tabela2  (cost=0.00..10.00 rows=100 width=4)
```

**Problema:** Nested loop com muitas iterações. Considere hash join.

## Otimizações Baseadas no Plano

### Adicionar Índice para Seq Scan

```sql
-- Plano mostra Seq Scan
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';

-- Solução: adicionar índice
CREATE INDEX idx_email ON clientes(email);
```

### Adicionar Índice para Sort

```sql
-- Plano mostra Sort
EXPLAIN SELECT * FROM pedidos ORDER BY data DESC;

-- Solução: adicionar índice
CREATE INDEX idx_data ON pedidos(data);
```

### Atualizar Estatísticas

```sql
-- Estimativas incorretas
ANALYZE clientes; -- PostgreSQL
ANALYZE TABLE clientes; -- MySQL
UPDATE STATISTICS clientes; -- SQL Server
```

### Reescrever Consulta

```sql
-- Consulta ineficiente
EXPLAIN SELECT * FROM tabela WHERE YEAR(data) = 2024;

-- Reescrever para usar índice
EXPLAIN SELECT * FROM tabela WHERE data >= '2024-01-01' AND data < '2025-01-01';
```

## EXPLAIN em Diferentes Bancos

### PostgreSQL

```sql
-- Básico
EXPLAIN SELECT * FROM clientes WHERE id = 1;

-- Com execução real
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id = 1;

-- Formatos diferentes
EXPLAIN (FORMAT JSON) SELECT * FROM clientes WHERE id = 1;
EXPLAIN (FORMAT TEXT, VERBOSE) SELECT * FROM clientes WHERE id = 1;
```

### MySQL

```sql
-- Básico
EXPLAIN SELECT * FROM clientes WHERE id = 1;

-- Formato JSON
EXPLAIN FORMAT=JSON SELECT * FROM clientes WHERE id = 1;

-- Formato TREE (MySQL 8.0+)
EXPLAIN FORMAT=TREE SELECT * FROM clientes WHERE id = 1;

-- Com execução (MySQL 8.0.18+)
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id = 1;
```

### SQL Server

```sql
-- Básico
EXPLAIN SELECT * FROM clientes WHERE id = 1;

-- Plano gráfico
SET SHOWPLAN_TEXT ON;
SELECT * FROM clientes WHERE id = 1;

-- Plano estimado
SET SHOWPLAN_XML ON;
SELECT * FROM clientes WHERE id = 1;

-- Plano real com estatísticas
SET STATISTICS PROFILE ON;
SELECT * FROM clientes WHERE id = 1;
```

### Oracle

```sql
-- Básico
EXPLAIN PLAN FOR SELECT * FROM clientes WHERE id = 1;

-- Ver plano
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Com execução real
SET AUTOTRACE ON;
SELECT * FROM clientes WHERE id = 1;
```

## Dicas de Performance

1. **Sempre use EXPLAIN antes de otimizar**: Entenda o plano atual antes de fazer mudanças

```sql
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Compare planos antes e depois**: Verifique se a otimização realmente melhorou

```sql
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';
CREATE INDEX idx_email ON clientes(email);
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Use EXPLAIN ANALYZE para tempo real**: Veja o tempo real de execução

```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Ative VERBOSE para mais detalhes**: Veja mais informações sobre o plano

```sql
EXPLAIN (VERBOSE) SELECT * FROM clientes WHERE id = 1;
```

1. **Monitore planos em produção**: Planos podem mudar com crescimento dos dados

## Resumo

- **EXPLAIN**: Mostra plano de execução sem executar a consulta
- **EXPLAIN ANALYZE**: Executa e mostra tempo real (PostgreSQL)
- **Seq Scan**: Leitura completa da tabela, geralmente indica falta de índice
- **Index Scan**: Uso de índice, geralmente mais eficiente
- **Nested Loop**: Join para tabelas pequenas ou com índices
- **Hash Join**: Join para tabelas grandes sem índices
- **Merge Join**: Join quando dados já ordenados
- **Cost**: Custo estimado, menor é melhor
- **Rows**: Linhas estimadas/processadas
- **Actual Time**: Tempo real de execução (EXPLAIN ANALYZE)
- **Otimização**: Adicione índices para Seq Scan, atualize estatísticas, reescreva consultas
- **Compatibilidade**: Cada banco tem sintaxe específica para EXPLAIN
- **Regra de ouro**: Sempre analise o plano antes de otimizar, e compare antes/depois
