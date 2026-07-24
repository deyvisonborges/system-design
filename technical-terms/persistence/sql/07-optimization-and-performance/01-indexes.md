# Índices e Estratégias de Indexação

Índices são estruturas de dados que melhoram a velocidade de operações de recuperação de dados em tabelas de banco de dados. Funcionam como um índice de livro, permitindo encontrar informações rapidamente sem percorrer todo o conteúdo.

## Definição

Um índice é uma estrutura separada que contém valores de uma ou mais colunas de uma tabela, organizados de forma a permitir busca rápida. Quando uma consulta usa uma coluna indexada, o banco pode usar o índice para encontrar as linhas desejadas sem fazer uma full table scan.

## Como Funciona - Passo a Passo

### Passo 1: Criação do Índice

O banco cria uma estrutura de dados (geralmente B-Tree) contendo os valores da coluna indexada e ponteiros para as linhas correspondentes na tabela.

### Passo 2: Consulta com Índice

Quando uma consulta usa a coluna indexada em WHERE, JOIN, ORDER BY ou GROUP BY, o otimizador verifica se o índice pode ser usado.

### Passo 3: Busca no Índice

O banco busca no índice em vez de percorrer a tabela completa. A busca no índice é O(log n) em vez de O(n).

### Passo 4: Recuperação das Linhas

Após encontrar os valores no índice, o banco recupera as linhas correspondentes da tabela usando os ponteiros.

## Tipos de Índices

### B-Tree Index

Índice padrão na maioria dos bancos. Balanceado, eficiente para igualdade, range, ORDER BY e GROUP BY.

```sql
CREATE INDEX idx_nome ON clientes(nome);
```

### Hash Index

Índice baseado em hash. Apenas para igualdade, não suporta range ou ordenação.

```sql
CREATE INDEX idx_hash_email ON clientes USING HASH (email); -- PostgreSQL
```

### Composite Index

Índice em múltiplas colunas. A ordem das colunas importa.

```sql
CREATE INDEX idx_composite ON pedidos(cliente_id, data);
```

### Unique Index

Índice que garante unicidade dos valores. Útil para chaves únicas além da PK.

```sql
CREATE UNIQUE INDEX idx_email_unico ON clientes(email);
```

### Full-Text Index

Índice para busca de texto em colunas TEXT/VARCHAR.

```sql
CREATE FULLTEXT INDEX idx_descricao ON produtos(descricao); -- MySQL
```

### Partial Index

Índice que inclui apenas linhas que satisfazem uma condição.

```sql
CREATE INDEX idx_ativos ON clientes(id) WHERE ativo = true; -- PostgreSQL
```

### Expression Index

Índice baseado em expressão ou função.

```sql
CREATE INDEX idx_lower_nome ON clientes(LOWER(nome)); -- PostgreSQL
```

## Sintaxe Básica

### Criar Índice

```sql
-- Índice simples
CREATE INDEX idx_nome ON tabela(coluna);

-- Índice composto
CREATE INDEX idx_composite ON tabela(coluna1, coluna2);

-- Índice único
CREATE UNIQUE INDEX idx_unico ON tabela(coluna);

-- Índice com nome específico
CREATE INDEX idx_tabela_coluna ON tabela(coluna);
```

### Remover Índice

```sql
DROP INDEX idx_nome ON tabela; -- PostgreSQL, SQL Server
DROP INDEX idx_nome; -- MySQL
```

### Listar Índices

```sql
-- PostgreSQL
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'tabela';

-- MySQL
SHOW INDEX FROM tabela;

-- SQL Server
EXEC sp_helpindex 'tabela';
```

## Exemplos Práticos

### Exemplo 1: Índice em WHERE

```sql
-- Sem índice: full table scan
SELECT * FROM clientes WHERE email = 'joao@example.com';

-- Com índice: busca rápida
CREATE INDEX idx_email ON clientes(email);
SELECT * FROM clientes WHERE email = 'joao@example.com';
```

**Explicação detalhada:**

1. Sem índice, o banco percorre todas as linhas da tabela
2. Com índice, o banco busca diretamente no índice
3. A complexidade muda de O(n) para O(log n)
4. Diferença enorme em tabelas grandes

### Exemplo 2: Índice Composto em JOIN

```sql
-- Índice composto para JOIN
CREATE INDEX idx_pedidos_cliente_data ON pedidos(cliente_id, data);

SELECT c.nome, p.data, p.valor
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data > '2024-01-01';
```

**Explicação detalhada:**

1. O índice composto acelera o JOIN (cliente_id) e o filtro (data)
2. A ordem das colunas no índice deve corresponder ao uso
3. cliente_id primeiro porque é usado no JOIN
4. data segundo porque é usado no WHERE

### Exemplo 3: Índice para ORDER BY

```sql
-- Índice para evitar filesort
CREATE INDEX idx_data_valor ON pedidos(data, valor);

SELECT * FROM pedidos ORDER BY data DESC, valor DESC;
```

**Explicação detalhada:**

1. Sem índice, o banco precisa ordenar o resultado (filesort)
2. Com índice na ordem correta, os dados já estão ordenados
3. O banco apenas lê o índice na ordem
4. Evita operação custosa de ordenação

### Exemplo 4: Índice Parcial

```sql
-- Índice apenas para clientes ativos
CREATE INDEX idx_clientes_ativos ON clientes(id) WHERE ativo = true;

SELECT * FROM clientes WHERE ativo = true AND nome LIKE 'Jo%';
```

**Explicação detalhada:**

1. O índice contém apenas linhas onde ativo = true
2. Menor índice = mais rápido e menos espaço
3. Útil quando apenas uma parte dos dados é frequentemente acessada
4. Reduz custo de manutenção do índice

### Exemplo 5: Índice para GROUP BY

```sql
-- Índice para acelerar agrupamento
CREATE INDEX idx_departamento ON funcionarios(departamento);

SELECT departamento, COUNT(*), AVG(salario)
FROM funcionarios
GROUP BY departamento;
```

**Explicação detalhada:**

1. O índice permite agrupamento sem ordenação adicional
2. O banco pode usar o índice para contar grupos
3. Evita criação de tabela temporária
4. Melhora performance significativamente

## Quando Criar Índices

### Colunas em WHERE

Colunas frequentemente usadas em cláusulas WHERE.

```sql
WHERE email = 'joao@example.com'  -- Crie índice em email
WHERE data > '2024-01-01'         -- Crie índice em data
```

### Colunas em JOIN

Colunas usadas em condições de JOIN.

```sql
JOIN pedidos p ON c.id = p.cliente_id  -- Crie índice em cliente_id
```

### Colunas em ORDER BY

Colunas usadas para ordenação.

```sql
ORDER BY data DESC  -- Crie índice em data
```

### Colunas em GROUP BY

Colunas usadas para agrupamento.

```sql
GROUP BY departamento  -- Crie índice em departamento
```

### Colunas Únicas

Colunas que devem ter valores únicos.

```sql
CREATE UNIQUE INDEX idx_email ON clientes(email);
```

## Quando NÃO Criar Índices

### Tabelas Pequenas

Em tabelas com poucas linhas, full table scan pode ser mais rápido que usar índice.

```sql
-- Tabela com < 1000 linhas pode não precisar de índice
```

### Colunas Raramente Usadas

Colunas raramente usadas em WHERE, JOIN, ORDER BY ou GROUP BY.

```sql
-- Coluna de comentários raramente filtrada
```

### Colunas com Alta Cardinalidade Baixa

Colunas com poucos valores distintos (ex: booleano).

```sql
-- ativo (true/false) tem baixa cardinalidade
-- Índice pode não ser eficiente
```

### Tabelas com Muitas Escritas

Índices tornam INSERT, UPDATE e DELETE mais lentos.

```sql
-- Tabela de logs com muitos inserts pode não ter índices
```

### Colunas Frequentemente Atualizadas

Colunas que mudam frequentemente causam muita manutenção de índice.

```sql
-- status que muda constantemente
```

## Estratégias de Indexação

### Estratégia 1: Índice Composto com Ordem Correta

A ordem das colunas em índices compostos deve corresponder ao uso.

```sql
-- Bom: ordem corresponde ao uso
CREATE INDEX idx_composite ON pedidos(cliente_id, data);

-- Consulta usa ambas as colunas
WHERE cliente_id = 1 AND data > '2024-01-01'

-- Consulta usa apenas primeira coluna (índice ainda funciona)
WHERE cliente_id = 1

-- Consulta usa apenas segunda coluna (índice NÃO funciona)
WHERE data > '2024-01-01'
```

### Estratégia 2: Covering Index

Índice que inclui todas as colunas necessárias, evitando acesso à tabela.

```sql
-- Covering index
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);

-- Consulta não precisa acessar a tabela
SELECT cliente_id, data, valor FROM pedidos WHERE cliente_id = 1;
```

### Estratégia 3: Índice Parcial para Subconjuntos

Use índices parciais quando apenas parte dos dados é frequentemente acessada.

```sql
-- Índice apenas para dados recentes
CREATE INDEX idx_recentes ON pedidos(data) WHERE data > '2024-01-01';
```

### Estratégia 4: Evitar Funções em Colunas Indexadas

Funções em colunas indexadas impedem uso do índice.

```sql
-- Evite: função em coluna
WHERE YEAR(data) = 2024

-- Prefira: range em coluna
WHERE data >= '2024-01-01' AND data < '2025-01-01'
```

### Estratégia 5: Monitorar e Remover Índices Não Usados

Índices não usados consomem espaço e tornam escritas mais lentas.

```sql
-- Identificar índices não usados (PostgreSQL)
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

## Pros e Contras

### Pros

1. **Performance**: Melhora drasticamente performance de leitura

```sql
-- Consulta que demorava segundos agora demora milissegundos
SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Ordenação**: Evita filesort para ORDER BY

2. **Agrupamento**: Acelera GROUP BY

3. **Unicidade**: Garante integridade de dados

### Contras

1. **Espaço**: Índices consomem espaço em disco

```sql
-- Índice pode aumentar tamanho do banco em 20-50%
```

1. **Escrita**: Torna INSERT, UPDATE, DELETE mais lentos

```sql
-- Cada INSERT precisa atualizar todos os índices
```

1. **Manutenção**: Índices fragmentados precisam de reconstrução

2. **Complexidade**: Índices incorretos podem piorar performance

## Cenários a Considerar

### Cenário 1: Tabela de Leitura Intensa

**Recomendação:** Muitos índices para acelerar leituras

```sql
-- Tabela de produtos lida frequentemente
CREATE INDEX idx_nome ON produtos(nome);
CREATE INDEX idx_categoria ON produtos(categoria);
CREATE INDEX idx_preco ON produtos(preco);
```

### Cenário 2: Tabela de Escrita Intensa

**Recomendação:** Poucos índices, apenas essenciais

```sql
-- Tabela de logs com muitos inserts
CREATE INDEX idx_data ON logs(data); -- Apenas índice essencial
```

### Cenário 3: Tabela com Consultas Variadas

**Recomendação:** Índices compostos para padrões comuns

```sql
-- Consultas frequentes por cliente e data
CREATE INDEX idx_cliente_data ON pedidos(cliente_id, data);
```

### Cenário 4: Tabela com Filtros Complexos

**Recomendação:** Índices parciais para subconjuntos

```sql
-- Apenas pedidos recentes são frequentemente acessados
CREATE INDEX idx_recentes ON pedidos(data) WHERE data > '2024-01-01';
```

## Dicas de Performance

1. **Analise o plano de execução**: Use EXPLAIN para verificar se índices estão sendo usados

```sql
EXPLAIN SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Use índices compostos com cuidado**: A ordem das colunas importa

```sql
-- Ordem correta
CREATE INDEX idx_composite ON pedidos(cliente_id, data);
```

1. **Evite SELECT ***: Selecione apenas colunas necessárias

```sql
-- Bom
SELECT id, nome FROM clientes WHERE email = 'joao@example.com';

-- Ruim
SELECT * FROM clientes WHERE email = 'joao@example.com';
```

1. **Monitore fragmentação**: Reconstrua índices fragmentados

```sql
-- PostgreSQL
REINDEX INDEX idx_nome;

-- MySQL
OPTIMIZE TABLE tabela;
```

1. **Use covering indexes**: Inclua todas as colunas necessárias no índice

```sql
CREATE INDEX idx_covering ON pedidos(cliente_id, data, valor);
```

## Índices em Diferentes Bancos

### PostgreSQL

- Suporta B-Tree, Hash, GiST, GIN, SP-GiST, BRIN
- Índices parciais com WHERE
- Índices de expressão
- Índices concorrentes (CONCURRENTLY)

```sql
CREATE INDEX CONCURRENTLY idx_nome ON tabela(coluna);
```

### MySQL

- B-Tree (padrão), Hash (apenas MEMORY), FULLTEXT
- Índices de texto completo
- Índices espaciais
- Índices invisíveis (MySQL 8.0+)

```sql
CREATE INDEX idx_nome ON tabela(coluna) INVISIBLE;
```

### SQL Server

- Clustered e Non-Clustered
- Índices filtrados (parciais)
- Índices columnstore
- Índices incluídos (covering)

```sql
CREATE INDEX idx_nome ON tabela(coluna) INCLUDE (outra_coluna);
```

### Oracle

- B-Tree, Bitmap, Function-based
- Índices reversos
- Índices partitioned
- Índices compressados

```sql
CREATE INDEX idx_nome ON tabela(coluna) COMPRESS;
```

## Resumo

- **Use índices quando**: Colunas em WHERE, JOIN, ORDER BY, GROUP BY, alta cardinalidade
- **Evite índices quando**: Tabelas pequenas, colunas raramente usadas, alta escrita, baixa cardinalidade
- **Índice composto**: Ordem das colunas deve corresponder ao uso
- **Covering index**: Inclui todas as colunas necessárias, evita acesso à tabela
- **Índice parcial**: Apenas para subconjunto de dados, menor e mais rápido
- **Funções**: Evite funções em colunas indexadas, use ranges
- **Manutenção**: Monitore e remova índices não usados, reconstrua fragmentados
- **Performance**: Use EXPLAIN para verificar uso de índices
- **Compatibilidade**: Cada banco tem tipos específicos de índices
- **Regra de ouro**: Índices melhoram leitura mas pioram escrita, equilibre conforme uso
