# Otimização e Performance em SQL

## Definição

Otimização e performance em SQL envolve técnicas e práticas para melhorar a eficiência das consultas, reduzir o tempo de resposta e minimizar o uso de recursos do banco de dados. Isso inclui o uso estratégico de índices, análise de planos de execução, otimização de joins, e compreensão de como o banco de dados processa consultas.

## Por que é Importante

- **Tempo de Resposta**: Consultas otimizadas retornam resultados mais rapidamente
- **Escalabilidade**: Sistema suporta mais usuários e dados com os mesmos recursos
- **Custo**: Reduz custos de infraestrutura (CPU, memória, armazenamento)
- **Experiência do Usuário**: Interface mais responsiva
- **Concorrência**: Menor bloqueio de recursos, permitindo mais operações simultâneas

## Pilares da Otimização

### 1. Índices

Estruturas de dados que aceleram a recuperação de dados. Índices bem projetados são a forma mais eficaz de melhorar performance.

Ver [01-indexes.md](./01-indexes.md)

### 2. Análise de Planos de Execução

Compreender como o banco executa consultas permite identificar gargalos e oportunidades de otimização.

Ver [02-explain-query-plans.md](./02-explain-query-plans.md)

### 3. Otimização de JOINs

JOINs são operações custosas. Estratégias corretas de join e ordenação de tabelas impactam significativamente a performance.

Ver [03-joins-performance.md](./03-joins-performance.md)

### 4. Otimização de WHERE

Filtros eficientes reduzem o conjunto de dados processado. Uso correto de índices e evitação de funções em colunas indexadas.

Ver [04-where-clause-optimization.md](./04-where-clause-optimization.md)

### 5. ORDER BY e GROUP BY

Operações de ordenação e agrupamento podem ser custosas. Índices e estratégias específicas melhoram performance.

Ver [05-order-group-performance.md](./05-order-group-performance.md)

### 6. Performance de Subqueries

Subqueries podem ser ineficientes. Entender quando usar subqueries, CTEs, ou JOINs é crucial.

Ver [06-subqueries-performance.md](./06-subqueries-performance.md)

### 7. Covering Indexes

Índices que incluem todas as colunas necessárias, evitando acesso à tabela principal (index-only scan).

Ver [07-covering-indexes.md](./07-covering-indexes.md)

### 8. N+1 Problem

Problema comum em ORMs onde múltiplas consultas são executadas em vez de uma única consulta otimizada.

Ver [08-n-plus-one-problem.md](./08-n-plus-one-problem.md)

## Princípios Fundamentais

### Princípio da Menor Quantidade de Dados

Sempre filtre o máximo possível o mais cedo na consulta.

```sql
-- Bom: filtra antes do JOIN
SELECT c.nome, p.data
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE c.ativo = true AND p.data > '2024-01-01';

-- Ruim: filtra depois do JOIN
SELECT c.nome, p.data
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data > '2024-01-01' AND c.ativo = true;
```

### Princípio do Índice Apropriado

Colunas usadas em WHERE, JOIN, ORDER BY e GROUP BY devem ter índices.

```sql
-- Crie índice para colunas frequentemente usadas
CREATE INDEX idx_pedidos_cliente_data ON pedidos(cliente_id, data);
```

### Princípio da Evitação de Full Table Scan

Evite operações que requerem leitura completa da tabela quando índices podem ser usados.

```sql
-- Evite: função em coluna indexada
WHERE YEAR(data) = 2024

-- Prefira: range em coluna indexada
WHERE data >= '2024-01-01' AND data < '2025-01-01'
```

### Princípio da Seleção Seletiva

Selecione apenas as colunas necessárias, não use SELECT *.

```sql
-- Bom: colunas específicas
SELECT id, nome, email FROM clientes;

-- Ruim: todas as colunas
SELECT * FROM clientes;
```

## Métricas de Performance

### Tempo de Execução

Tempo total para executar a consulta. Medido em milissegundos ou segundos.

### Linhas Lidas (Rows Examined)

Número de linhas que o banco examinou para retornar o resultado. Menor é melhor.

### Linhas Retornadas (Rows Returned)

Número de linhas no resultado final. A razão rows_examined / rows_returned indica eficiência.

### Uso de Índices

Se a consulta usou índices ou fez full table scan.

### Uso de Temp Tables

Se o banco criou tabelas temporárias para executar a consulta (indica operações custosas).

### Uso de Filesort

Se o banco fez ordenação em disco (indica falta de índice apropriado).

## Ferramentas de Diagnóstico

### EXPLAIN

Mostra o plano de execução da consulta, revelando como o banco processará a query.

```sql
EXPLAIN SELECT * FROM clientes WHERE id = 1;
```

### EXPLAIN ANALYZE

Executa a consulta e mostra o tempo real de cada etapa (PostgreSQL).

```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id = 1;
```

### Slow Query Log

Log de consultas lentas, identificando oportunidades de otimização.

### Profiling

Ferramentas de profiling que mostram onde o tempo é gasto durante a execução.

## Estratégias Gerais

### 1. Design do Schema

- Normalização adequada
- Tipos de dados corretos
- Chaves primárias e estrangeiras
- Índices apropriados

### 2. Escrita de Queries

- Filtre o mais cedo possível
- Evite SELECT *
- Use JOINs eficientes
- Prefira índices a full table scans

### 3. Manutenção

- Atualize estatísticas do banco
- Reconstrua índices fragmentados
- Monitore performance regularmente
- Revise e otimize consultas lentas

### 4. Arquitetura

- Considere particionamento de tabelas
- Use replicação para leituras
- Considere caching (Redis, Memcached)
- Arquitetura de leitura/escrita separada quando necessário

## Tópicos Relacionados

- **Índices**: Ver [01-indexes.md](./01-indexes.md)
- **EXPLAIN**: Ver [02-explain-query-plans.md](./02-explain-query-plans.md)
- **JOINs**: Ver [03-joins-performance.md](./03-joins-performance.md)
- **WHERE**: Ver [04-where-clause-optimization.md](./04-where-clause-optimization.md)
- **ORDER/GROUP**: Ver [05-order-group-performance.md](./05-order-group-performance.md)
- **Subqueries**: Ver [06-subqueries-performance.md](./06-subqueries-performance.md)
- **Covering Indexes**: Ver [07-covering-indexes.md](./07-covering-indexes.md)
- **N+1 Problem**: Ver [08-n-plus-one-problem.md](./08-n-plus-one-problem.md)
