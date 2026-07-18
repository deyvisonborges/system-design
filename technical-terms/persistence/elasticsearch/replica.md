# Replica

Replica (réplica) é uma cópia de um shard primário no Elasticsearch, proporcionando alta disponibilidade e escalabilidade de leitura. Réplicas podem ser usadas para failover e distribuição de carga de busca.

## Definição

Replica é uma cópia de um shard primário que armazena os mesmos dados e pode servir requisições de busca, proporcionando redundância e escalabilidade.

```text
Replica = Cópia do shard primário + Alta disponibilidade + Escalabilidade de leitura
```

## Como Funciona

### 1. Processo de Replicação

```text
1. Documento é indexado no shard primário
2. Documento é replicado para todas as réplicas
3. Réplica confirma recebimento
4. Indexação é considerada completa
```

### 2. Tipos de Réplicas

```text
- Primary shard: Shard original que aceita escritas
- Replica shard: Cópia do primary shard
- Número de réplicas configurável por índice
```

### 3. Consistência

```text
- Por padrão, espera pelo menos uma réplica
- Configurável (wait_for_active_shards)
- Pode ser ajustado por caso de uso
```

## Configuração

### 1. Número de Réplicas

```json
PUT /my_index
{
  "settings": {
    "index": {
      "number_of_shards": 3,
      "number_of_replicas": 2
    }
  }
}
```

### 2. Alterar Número de Réplicas

```json
PUT /my_index/_settings
{
  "index": {
    "number_of_replicas": 1
  }
}
```

### 3. Wait for Active Shards

```json
POST /my_index/_doc/1?wait_for_active_shards=2
{
  "title": "Document 1"
}
```

## Vantagens

### 1. Alta Disponibilidade

```text
- Failover automático em caso de falha
- Dados redundantes
- Recuperação rápida
```

### 2. Escalabilidade de Leitura

```text
- Distribui carga de busca
- Mais throughput de leitura
- Melhor performance
```

### 3. Redundância

```text
- Múltiplas cópias dos dados
- Proteção contra falha de nó
- Backup em tempo real
```

## Limitações

### 1. Custo

```text
- Réplicas ocupam espaço em disco
- Mais custo de armazenamento
- Mais overhead de rede
```

### 2. Latência de Escrita

```text
- Replicação adiciona latência
- Espera por confirmação de réplicas
- Pode impactar throughput de escrita
```

### 3. Complexidade

```text
- Configuração adicional
- Requer gerenciamento
- Mais nós necessários
```

## Melhores Práticas

### 1. Configurar Réplicas Adequadamente

```json
// Para produção, usar pelo menos 1 réplica
PUT /my_index
{
  "settings": {
    "index": {
      "number_of_shards": 3,
      "number_of_replicas": 1
    }
  }
}
```

### 2. Ajustar Wait for Active Shards

```json
// Para escritas críticas
POST /my_index/_doc/1?wait_for_active_shards=all

// Para escritas não críticas
POST /my_index/_doc/1?wait_for_active_shards=1
```

### 3. Monitorar Status de Réplicas

```json
GET /_cat/indices/my_index?v
GET /_cat/shards/my_index?v
```

### 4. Usar Auto-expand Réplicas

```json
PUT /my_index/_settings
{
  "index.auto_expand_replicas": "0-1"
}
```

## Trade-offs

### Mais Réplicas vs Menos Réplicas

- **Mais**: Maior HA, mais custo
- **Menos**: Menor custo, menor HA
- **Escolha**: 1-2 réplicas para produção

### Synchronous vs Asynchronous Replication

- **Synchronous**: Consistência forte, mais latência
- **Asynchronous**: Consistência eventual, menos latência
- **Escolha**: Synchronous para crítico, asynchronous para geral

### Local vs Cross-AZ Réplicas

- **Local**: Menor latência, menos HA
- **Cross-AZ**: Maior latência, maior HA
- **Escolha**: Cross-AZ para produção, local para desenvolvimento

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/replica-shard.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html>
