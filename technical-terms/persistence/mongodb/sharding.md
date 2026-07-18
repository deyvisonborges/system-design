# Sharding

Sharding (fragmentação) é o processo de distribuir dados em múltiplos servidores MongoDB (shards) para escalar horizontalmente, permitindo que grandes conjuntos de dados sejam distribuídos em várias máquinas.

## Definição

Sharding é um método de distribuição de dados que divide grandes conjuntos de dados em partições menores (chunks) e as distribui em múltiplos servidores (shards), permitindo escalabilidade horizontal.

```text
Sharding = Chunks + Shards + Balanceamento
```

## Como Funciona

### 1. Componentes do Sharded Cluster

```text
- Shards: Servidores que armazenam dados
- Config Servers: Armazenam metadados do cluster
- Query Routers (mongos): Roteiam queries para shards apropriados
```

### 2. Shard Key

```text
- Campo usado para distribuir dados
- Determina em qual shard um documento fica
- Imutável após a criação
- Crítico para performance
```

### 3. Chunks

```text
- Partições de dados baseadas na shard key
- Tamanho padrão: 64MB
- Distribuídos entre shards
- Balanceados automaticamente
```

## Configuração

### 1. Habilitar Sharding

```javascript
// Habilitar sharding em um banco de dados
sh.enableSharding("mydb")

// Shard uma coleção
sh.shardCollection("mydb.mycollection", { _id: "hashed" })
```

### 2. Shard Key Range

```javascript
// Shard key baseada em range
sh.shardCollection("mydb.orders", { customer_id: 1 })

// Shard key baseada em hash
sh.shardCollection("mydb.users", { _id: "hashed" })
```

### 3. Configurar Shard Key

```javascript
// Shard key composta
sh.shardCollection("mydb.orders", { customer_id: 1, created_at: 1 })
```

## Exemplo Prático

### Configurar Sharded Cluster

```javascript
// Conectar ao mongos
mongos --host mongos-router --port 27017

// Habilitar sharding no banco
sh.enableSharding("myapp")

// Shard coleção com hash
sh.shardCollection("myapp.users", { _id: "hashed" })

// Shard coleção com range
sh.shardCollection("myapp.orders", { customer_id: 1 })
```

### Verificar Status

```javascript
// Verificar status do sharding
sh.status()

// Verificar distribuição de chunks
db.chunks.find({ ns: "myapp.orders" })

// Verificar balanceamento
sh.balancerStatus()
```

## Vantagens

### 1. Escalabilidade Horizontal

```text
- Adiciona shards conforme necessário
- Distribui dados em múltiplos servidores
- Escala para grandes volumes de dados
```

### 2. Performance

```text
- Distribui carga de queries
- Paralelismo de operações
- Melhor throughput
```

### 3. Alta Disponibilidade

```text
- Shards podem ser replica sets
- Failover automático
- Recuperação rápida
```

## Limitações

### 1. Complexidade

```text
- Configuração complexa
- Requer planejamento
- Troubleshooting mais complexo
```

### 2. Shard Key Imutável

```text
- Shard key não pode ser alterada
- Requer planejamento antecipado
- Difícil de mudar depois
```

### 3. Queries Sem Shard Key

```text
- Queries sem shard key são lentas
- Scatter-gather queries
- Pode impactar performance
```

## Melhores Práticas

### 1. Escolher Shard Key Adequadamente

```javascript
// Bom: Shard key com boa cardinalidade
sh.shardCollection("myapp.users", { _id: "hashed" })

// Bom: Shard key para queries frequentes
sh.shardCollection("myapp.orders", { customer_id: 1 })

// Ruim: Shard key com baixa cardinalidade
sh.shardCollection("myapp.orders", { status: 1 })
```

### 2. Usar Hashed Shard Key para Distribuição Uniforme

```javascript
// Hashed shard key para distribuição uniforme
sh.shardCollection("myapp.users", { _id: "hashed" })

// Range shard key para queries de range
sh.shardCollection("myapp.logs", { timestamp: 1 })
```

### 3. Monitorar Balanceamento

```javascript
// Verificar status do balancer
sh.balancerStatus()

// Verificar distribuição de chunks
sh.status()

// Configurar janela de balanceamento
db.settings.update(
  { _id: "balancer" },
  { $set: { activeWindow: { start: "23:00", stop: "06:00" } } },
  { upsert: true }
)
```

### 4. Usar Tags para Controle de Localização

```javascript
// Configurar tags para shards
sh.addShardTag("shard01", "east")
sh.addShardTag("shard02", "west")

// Configurar tag ranges para shard key
sh.addTagRange("myapp.users", { minKey: 0 }, { maxKey: 1000 }, "east")
```

## Trade-offs

### Hashed vs Range Shard Key

- **Hashed**: Distribuição uniforme, queries de range lentas
- **Range**: Queries de range rápidas, distribuição desigual
- **Escolha**: Hashed para geral, range para queries de range

### Single Shard Key vs Composta

- **Single**: Simples, menos flexível
- **Composta**: Mais flexível, mais complexo
- **Escolha**: Single para geral, composta para casos específicos

### Sharding vs Replica Set

- **Sharding**: Escalabilidade horizontal, complexo
- **Replica set**: Alta disponibilidade, simples
- **Escolha**: Sharding para grandes volumes, replica set para HA

### _Links_

- <https://www.mongodb.com/docs/manual/sharding/>
- <https://www.mongodb.com/docs/manual/core/sharded-cluster-architecture/>
- <https://www.mongodb.com/docs/manual/tutorial/deploy-shard-cluster/>
