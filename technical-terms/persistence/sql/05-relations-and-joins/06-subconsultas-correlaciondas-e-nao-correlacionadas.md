# Subconsultas Correlacionadas vs. Não Correlacionadas

## O conceito central

Uma subconsulta é uma query dentro de outra query. A diferença crítica está em **se a subconsulta depende de valores da query externa**.

### Não correlacionada

A subconsulta é independente. Ela pode rodar sozinha, sem a query externa, e produz o mesmo resultado sempre.

```sql
SELECT nome, salario
FROM funcionarios
WHERE salario > (
    SELECT AVG(salario) FROM funcionarios
);
```

A subconsulta `SELECT AVG(salario) FROM funcionarios` é executada **uma única vez**. O resultado (um número) é reutilizado para comparar com cada linha da tabela externa.

### Correlacionada

A subconsulta referencia uma coluna da query externa. Ela não pode ser executada isoladamente — depende de cada linha processada fora.

```sql
SELECT f.nome, f.salario, f.departamento_id
FROM funcionarios f
WHERE f.salario > (
    SELECT AVG(f2.salario)
    FROM funcionarios f2
    WHERE f2.departamento_id = f.departamento_id  -- referencia f (externa)
);
```

Aqui `f.departamento_id` vem da linha externa. Conceitualmente, o banco precisa recalcular a subconsulta **para cada linha** de `f`.

## Por que isso importa (o impacto real)

**Performance.** Isso é o motivo #1 de existir essa distinção na prática. Se você tem 1 milhão de linhas em `funcionarios`, uma subconsulta correlacionada mal escrita pode, na teoria ingênua, executar 1 milhão de vezes — um scan completo repetido a cada linha. Isso vira O(n²) ou pior.

Na prática, otimizadores modernos (Postgres, SQL Server, Oracle) muitas vezes **reescrevem** subconsultas correlacionadas como JOINs internamente (semi-join, anti-join, hash join), então nem sempre o desastre acontece. Mas isso não é garantido — depende do otimizador, dos índices, do tamanho das tabelas e de como a query foi escrita. Você não deve confiar cegamente nisso.

**Onde isso costuma surgir:**

- Checagens de existência (`EXISTS`, `NOT EXISTS`, `IN` com subquery correlacionada)
- Comparações "top-N por grupo" (maior salário por departamento, pedido mais recente por cliente)
- Deduplicação e regras de negócio linha-a-linha

## Como resolver / otimizar

### 1. Prefira `EXISTS`/`NOT EXISTS` a `IN`/`NOT IN` quando houver correlação

`EXISTS` para no primeiro match (short-circuit) e lida melhor com NULLs.

```sql
-- Correlacionada, mas eficiente com índice em cliente_id
SELECT c.nome
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);
```

Garanta um índice em `pedidos.cliente_id` — sem ele, isso vira scan repetido.

### 2. Reescreva como JOIN quando possível

Frequentemente o mesmo resultado lógico:

```sql
-- Em vez de subquery correlacionada, use JOIN + agregação
SELECT f.nome, f.salario
FROM funcionarios f
JOIN (
    SELECT departamento_id, AVG(salario) AS media
    FROM funcionarios
    GROUP BY departamento_id
) m ON m.departamento_id = f.departamento_id
WHERE f.salario > m.media;
```

Isso calcula as médias **uma vez por departamento**, não uma vez por funcionário.

### 3. Use window functions para "top-N por grupo"

Esse é o caso clássico onde subconsulta correlacionada é substituída com folga:

```sql
SELECT nome, salario, departamento_id
FROM (
    SELECT nome, salario, departamento_id,
           RANK() OVER (PARTITION BY departamento_id ORDER BY salario DESC) AS rk
    FROM funcionarios
) t
WHERE rk = 1;
```

Muito mais eficiente que uma correlacionada tentando achar o máximo por grupo linha a linha.

### 4. Sempre olhe o EXPLAIN / EXPLAIN ANALYZE

A teoria diz "correlacionada roda N vezes", mas a realidade é o plano de execução. Rode `EXPLAIN ANALYZE` e procure por:

- `Nested Loop` com subquery sendo re-executada (ruim, sem índice)
- `Hash Semi Join` / `Anti Join` (o otimizador já reescreveu pra você — bom)

## Resumo prático

| | Não correlacionada | Correlacionada |
|---|---|---|
| Depende da query externa? | Não | Sim |
| Roda sozinha? | Sim | Não |
| Execução (conceitual) | Uma vez | Uma vez por linha externa |
| Risco de performance | Baixo | Alto se sem índice/otimização |
| Quando usar | Comparar contra agregado fixo | Checar relação linha-a-linha (EXISTS) |
| Alternativa comum | — | JOIN, window function |
