# Chunk Migration

Chunk Migration é o processo do MongoDB de mover chunks (partições de dados) entre shards em um cluster sharded para balancear a distribuição de dados e carga.

## Definição

Chunk Migration é o processo de mover chunks de um shard para outro para balancear a distribuição de dados e carga em um cluster sharded do MongoDB.

```text
Chunk Migration = Chunks + Balanceamento + Redistribuição
```

## Como Funciona

### 1. Processo de Migração

```text
1. Balancer identifica chunks desbalanceados
2. Chunk é selecionado para migração
3. Chunk é movido para o shard de destino
4. Metadados são atualizados
5. Migração é confirmada
```

### 2. Tamanho do Chunk

```text
- Padrão: 64MB
- Configurável
- Chunks maiores = menos chunks, menos overhead
- Chunks menores = mais granularidade, mais overhead
```

### 3. Balancer

```text
- Processo que gerencia migrações
- Executa periodicamente
- Pode ser configurado
- Pode ser desabilitado
```

## Configuração

### 1. Tamanho do Chunk

```javascript
// Configurar tamanho do chunk
sh.enableSharding("mydb")
sh.shardCollection("mydb.mycollection", { _id: 1 })
db.settings.save({ _id: "chunksize", value: 64 })
```

### 2. Configurar Balancer

```javascript
// Habilitar balancer
sh.setBalancerState(true)

// Desabilitar balancer
sh.setBalancerState(false)

// Configurar janela de balanceamento
sh.startBalancer()
sh.stopBalancer()
```

### 3. Configurar Janela de Balanceamento

```javascript
// Configurar janela de balanceamento
db.settings.update(
  { _id: "balancer" },
  { $set: { activeWindow: { start: "23:00", stop: "06:00" } } },
  { upsert: true }
)
```

## Vantagens

### 1. Balanceamento Automático

```text
- Distribuição automática de dados
- Balanceamento de carga
- Melhor performance
```

### 2. Escalabilidade

```text
- Adiciona shards conforme necessário
- Redistribuição automática
- Escala horizontalmente
```

### 3. Flexibilidade

```text
- Configurável
- Pode ser ajustado por caso de uso
- Controle manual quando necessário
```

## Limitações

### 1. Overhead de Migração

```text
- Migração consome recursos
- Pode impactar performance
- Requer I/O de rede
```

### 2. Latência

```text
- Migração pode ser lenta
- Pode impactar latência de queries
- Requer planejamento
```

### 3. Complexidade

```text
- Configuração adicional
- Requer gerenciamento
- Troubleshooting mais complexo
```

## Melhores Práticas

### 1. Configurar Tamanho do Chunk Adequadamente

```javascript
// Para dados pequenos
db.settings.save({ _id: "chunksize", value: 32 })

// Para dados grandes
db.settings.save({ _id: "chunksize", value: 128 })
```

### 2. Configurar Janela de Balanceamento

```javascript
// Balancear durante horários de menor uso
db.settings.update(
  { _id: "balancer" },
  { $set: { activeWindow: { start: "23:00", stop: "06:00" } } },
  { upsert: true }
)
```

### 3. Monitorar Migrações

```javascript
// Verificar status do balancer
sh.getBalancerState()

// Verificar chunks em migração
db.chunks.find({ migrate: { $exists: true } })

// Verificar distribuição de chunks
sh.status()
```

### 4. Desabilitar Balancer durante Manutenção

```javascript
// Desabilitar balancer antes de manutenção
sh.setBalancerState(false)

// Reabilitar após manutenção
sh.setBalancerState(true)
```

## Trade-offs

### Chunks Pequenos vs Grandes

- **Pequenos**: Mais granularidade, mais overhead
- **Grandes**: Menos overhead, menos granularidade
- **Escolha**: 64MB padrão, ajustar conforme necessário

### Balanceamento Automático vs Manual

- **Automático**: Sem overhead manual, menos controle
- **Manual**: Controle total, mais overhead
- **Escolha**: Automático para geral, manual para casos específicos

### Janela de Balanceamento vs Sempre Ativo

- **Janela**: Menor impacto em produção, mais lento
- **Sempre**: Mais rápido, pode impactar produção
- **Escolha**: Janela para produção, sempre para desenvolvimento

### _Links_

- <https://www.mongodb.com/docs/manual/core/sharding-balancer-administration/>
- <https://www.mongodb.com/docs/manual/core/sharding-data-partitioning/>
- <https://www.mongodb.com/docs/manual/tutorial/manage-sharded-cluster-balancer/>
