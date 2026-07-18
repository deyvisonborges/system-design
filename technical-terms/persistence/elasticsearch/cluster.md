# Cluster

Cluster é um conjunto de um ou mais nós do Elasticsearch que juntos armazenam todos os dados e fornecem capacidades de indexação e busca distribuídas através de todos os nós.

## Definição

Cluster é uma coleção de nós que trabalham juntos para distribuir dados, balancear carga e fornecer alta disponibilidade e escalabilidade para operações de busca e indexação.

```
Cluster = Múltiplos nós trabalhando juntos
```

## Componentes do Cluster

### 1. Nós (Nodes)

```text
- Master-eligible nodes: Gerenciam o cluster
- Data nodes: Armazenam dados e executam operações
- Coordinating nodes: Distribuem requisições
- Ingest nodes: Processam dados antes da indexação
```

### 2. Índices (Indices)

```text
- Coleção de documentos
- Distribuídos em shards
- Mapeamento define estrutura
```

### 3. Shards

```text
- Divisões de um índice
- Primary shards: Shards originais
- Replica shards: Cópias dos primary
```

## Tipos de Nós

### 1. Master-eligible Node

```json
// Nó elegível para ser master
{
  "node.roles": ["master"]
}

// Responsabilidades:
// - Gerenciar estado do cluster
// - Criar/excluir índices
// - Atribuir shards
// - Monitorar saúde do cluster
```

### 2. Data Node

```json
// Nó que armazena dados
{
  "node.roles": ["data"]
}

// Responsabilidades:
// - Armazenar shards
// - Executar operações CRUD
// - Executar agregações
// - Executar buscas
```

### 3. Coordinating Node

```json
// Nó que coordena requisições
{
  "node.roles": []
}

// Responsabilidades:
// - Distribuir requisições
// - Agregar resultados
// - Balancear carga
```

### 4. Ingest Node

```json
// Nó que processa dados
{
  "node.roles": ["ingest"]
}

// Responsabilidades:
// - Processar documentos antes da indexação
// - Aplicar ingest pipelines
```

### 5. Machine Learning Node

```json
// Nó para ML
{
  "node.roles": ["ml"]
}

// Responsabilidades:
// - Executar jobs de ML
// - Treinar modelos
```

## Configuração de Cluster

### 1. Configuração Básica

```yaml
# elasticsearch.yml
cluster.name: my-cluster
node.name: node-1
network.host: 0.0.0.0
discovery.seed_hosts: ["node-1", "node-2", "node-3"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]
```

### 2. Configuração de Roles

```yaml
# Master node
node.roles: ["master"]

# Data node
node.roles: ["data"]

# Coordinating node
node.roles: []

# Combined node
node.roles: ["master", "data", "ingest"]
```

### 3. Configuração de Descoberta

```yaml
# Descoberta automática
discovery.seed_hosts: ["192.168.1.1", "192.168.1.2"]

# Descoberta manual
cluster.initial_master_nodes: ["node-1"]
```

## Estado do Cluster

### 1. Green

```text
- Todos os primary e replica shards estão alocados
- Cluster totalmente funcional
- Alta disponibilidade
```

### 2. Yellow

```text
- Todos os primary shards alocados
- Alguns replica shards não alocados
- Cluster funcional, mas sem alta disponibilidade
```

### 3. Red

```text
- Alguns primary shards não alocados
- Cluster parcialmente funcional
- Dados podem estar indisponíveis
```

## Operações de Cluster

### 1. Adicionar Nó

```bash
# Iniciar novo nó com configuração
bin/elasticsearch -Ecluster.name=my-cluster \
                 -Enode.name=new-node \
                 -Ediscovery.seed_hosts=["existing-node"]

# O nó se junta automaticamente ao cluster
```

### 2. Remover Nó

```bash
# Desligar nó graceful
POST /_cluster/nodes/_shutdown

# Ou excluir nó da configuração
# E reiniciar cluster
```

### 3. Rebalancear Shards

```json
POST /_cluster/settings
{
  "persistent": {
    "cluster.routing.rebalance.enable": "all"
  }
}
```

## Melhores Práticas

### 1. Separar Roles

```yaml
# Separar master e data nodes
# Master nodes: 3-5 nós dedicados
node.roles: ["master"]

# Data nodes: Múltiplos nós
node.roles: ["data"]

# Coordinating nodes: 2-3 nós
node.roles: []
```

### 2. Número de Master Nodes

```text
- Mínimo: 3 master-eligible nodes
- Recomendado: 3 ou 5 (ímpar)
- Evitar: 1 (single point of failure)
```

### 3. Alocar Recursos Adequadamente

```yaml
# Heap size: 50% da RAM, máximo 31GB
ES_JAVA_OPTS="-Xms16g -Xmx16g"

# Deixar 50% da RAM para filesystem
# 32GB RAM → 16GB heap + 16GB filesystem
```

### 4. Monitorar Saúde do Cluster

```json
GET /_cluster/health

// Resposta:
{
  "cluster_name": "my-cluster",
  "status": "green",
  "number_of_nodes": 3,
  "number_of_data_nodes": 3,
  "active_primary_shards": 5,
  "active_shards": 10,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0
}
```

## Exemplo Prático

### Cluster de Produção

```yaml
# 3 master nodes (dedicados)
node-1:
  node.roles: ["master"]
  node.name: master-1
  discovery.seed_hosts: ["master-2", "master-3"]

node-2:
  node.roles: ["master"]
  node.name: master-2
  discovery.seed_hosts: ["master-1", "master-3"]

node-3:
  node.roles: ["master"]
  node.name: master-3
  discovery.seed_hosts: ["master-1", "master-2"]

# 5 data nodes
data-1:
  node.roles: ["data"]
  node.name: data-1
  discovery.seed_hosts: ["master-1"]

data-2:
  node.roles: ["data"]
  node.name: data-2
  discovery.seed_hosts: ["master-1"]

# ... data-3, data-4, data-5

# 2 coordinating nodes
coordinator-1:
  node.roles: []
  node.name: coordinator-1
  discovery.seed_hosts: ["master-1"]

coordinator-2:
  node.roles: []
  node.name: coordinator-2
  discovery.seed_hosts: ["master-1"]
```

### Cluster de Desenvolvimento

```yaml
# 1 nó com todas as roles
node-1:
  node.roles: ["master", "data", "ingest"]
  node.name: dev-node
  cluster.initial_master_nodes: ["dev-node"]
```

## Limitações

### 1. Número de Shards

```text
- Limite: 1000 shards por nó
- Mais shards = mais overhead
- Planejar shards baseado em tamanho futuro
```

### 2. Número de Nós

```text
- Mínimo: 1 (desenvolvimento)
- Produção: Mínimo 3 (master + data)
- Escalabilidade: Adicionar nós conforme necessário
```

### 3. Latência de Rede

```text
- Nós devem estar na mesma região
- Latência alta impacta performance
- Considerar cross-cluster para multi-região
```

## Trade-offs

### Single Node vs Multi-node

- **Single node**: Simples, barato, sem HA
- **Multi-node**: Complexo, caro, HA
- **Escolha**: Single para dev, multi para prod

### Dedicated vs Combined Roles

- **Dedicated**: Melhor performance, mais custo
- **Combined**: Menor custo, menos performance
- **Escolha**: Dedicated para prod, combined para pequeno

### On-premise vs Cloud

- **On-premise**: Controle total, mais overhead
- **Cloud**: Gerenciado, menos controle
- **Escolha**: Cloud para simplicidade, on-premise para controle

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/important-configuration.html>
