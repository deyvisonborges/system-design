Uma query cara é qualquer consulta ao banco de dados cujo custo de execução seja elevado.
O "custo" não significa apenas tempo de resposta, mas também consumo de recursos:

- CPU
- Memória
- Disco (I/O)
- Rede
- Locks
- Cache do banco

Uma query pode responder em 300 ms e ainda ser considerada cara se consumir muitos recursos.

Exemplo

```sql
SELECT *
FROM propostas p
JOIN clientes c
    ON c.id = p.cliente_id
JOIN parcelas pa
    ON pa.proposta_id = p.id
JOIN contratos ct
    ON ct.proposta_id = p.id
WHERE c.cpf = '12345678900'
ORDER BY p.data_criacao DESC;
```

Essa consulta:

- faz vários JOINs
- retorna muitas colunas (SELECT *)
- ordena o resultado
- talvez leia milhões de linhas

Mesmo retornando apenas uma proposta, o banco pode precisar percorrer uma quantidade enorme de dados.

## Como identificar uma query cara?

Ferramentas comuns:

- EXPLAIN
- EXPLAIN ANALYZE
- Query Plan
- Slow Query Log
- APM (Datadog, New Relic etc.)

## Como resolver?

- criar índices
- remover SELECT *
- paginação
- cache
- desnormalização
- materialized views
- particionamento
- CQRS
- pré-processamento
