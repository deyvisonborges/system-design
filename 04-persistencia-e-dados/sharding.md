# Sharding

Dividir os dados em vários nós para distribuir armazenamento e carga.

Sem sharding:

```md
          Banco

+----------------------+
| Usuários 1..100M     |
+----------------------+
```

Com sharding:

```md
          Aplicação
              |
      -----------------
      |       |       |
      ▼       ▼       ▼

Shard A  Shard B  Shard C

1-30M    30-60M   60-100M
```

Isso vale tanto para:

- PostgreSQL
- MySQL
- MongoDB
- Cassandra
- DynamoDB

O conceito é exatamente o mesmo.
