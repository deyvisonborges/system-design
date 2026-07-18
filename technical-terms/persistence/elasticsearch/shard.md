# Shard

Shard (fragmento) é uma unidade de distribuição de dados no Elasticsearch. Cada índice é dividido em múltiplos shards, e cada shard pode ser distribuído em diferentes nós, permitindo escalabilidade horizontal.

## Definição

Shard é uma parte de um índice que contém um subconjunto dos dados. Shards permitem distribuir dados em múltiplos nós, escalando horizontalmente e melhorando a performance.

```text
Shard = Parte do índice + Distribuição + Escalabilidade
```

## Como Funciona

### 1. Tipos de Shards

```text
- Primary shard: Shard original que aceita escritas
- Replica shard: Cópia do primary shard
- Número de primary shards configurável na criação
- Número de replica shards configurável dinamicamente
```

### 2. Distribuição de Shards

```text
1. Índice é criado com N primary shards
2. Cada primary shard é distribuído em um nó
3. Réplicas são distribuídas em nós diferentes
4. Elasticsearch gerencia distribuição automaticamente
```

### 3. Routing

```text
- Documents são roteados para shards baseados em _id
- Hash do _id determina o shard
- Pode ser customizado com routing
- Garante distribuição uniforme
```

## Configuração

### 1. Número de Shards

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

### 2. Custom Routing

```json
POST /my_index/_doc/1?routing=user123
{
  "title": "Document 1"
}
```

### 3. Shard Allocation

```json
PUT /my_index/_settings
{
  "index.routing.allocation.include._tier_preference": "data_hot"
}
```

## Vantagens

### 1. Escalabilidade Horizontal

```text
- Distribui dados em múltiplos nós
- Escala horizontalmente
- Maior throughput
```

### 2. Performance

```text
- Paralelismo de busca
- Distribuição de carga
- Melhor latência
```

### 3. Alta Disponibilidade

```text
- Shards distribuídos em nós diferentes
- Failover automático
- Recuperação rápida
```

## Limitações

### 1. Número de Shards Fixo

```text
- Primary shards não podem ser alterados
- Requer reindexação para mudar
- Planejamento antecipado necessário
```

### 2. Overhead

```text
- Cada shard tem overhead
- Muitos shards = mais overhead
- Requer recursos adicionais
```

### 3. Complexidade

```text
- Configuração adicional
- Requer gerenciamento
- Troubleshooting mais complexo
```

## Melhores Práticas

### 1. Planejar Número de Shards

```json
// Para índices pequenos (< 50GB)
PUT /small_index
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 1
    }
  }
}

// Para índices grandes (> 50GB)
PUT /large_index
{
  "settings": {
    "index": {
      "number_of_shards": 3,
      "number_of_replicas": 1
    }
  }
}
```

### 2. Usar Custom Routing quando Apropriado

```json
// Para dados relacionados ao usuário
POST /my_index/_doc/1?routing=user123
{
  "user_id": "user123",
  "title": "Document 1"
}
```

### 3. Monitorar Shard Allocation

```json
GET /_cat/shards/my_index?v
GET /_cat/allocation?v
```

### 4. Usar ILM para Gerenciar Shards

```json
PUT /_ilm/policy/my_policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "50GB"
          }
        }
      }
    }
  }
}
```

## Trade-offs

### Mais Shards vs Menos Shards

- **Mais**: Mais escalabilidade, mais overhead
- **Menos**: Menos overhead, menos escalabilidade
- **Escolha**: 1 shard por 50GB de dados

### Primary vs Replica Shards

- **Primary**: Aceita escritas, obrigatório
- **Replica**: Apenas leitura, opcional
- **Escolha**: Pelo menos 1 réplica para produção

### Automatic vs Custom Routing

- **Automatic**: Distribuição uniforme, simples
- **Custom**: Controle total, mais complexo
- **Escolha**: Automatic para geral, custom para casos específicos

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-shard.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/scalability.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html>
