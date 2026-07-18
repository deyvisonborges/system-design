# Node

Node (nó) é uma instância individual do Elasticsearch que armazena dados e participa do cluster. Cada nó é identificado por um nome único e pode ter diferentes roles (master-eligible, data, coordinating, ingest, ML).

## Definição

Node é uma instância do Elasticsearch que faz parte de um cluster, armazena dados e executa operações de busca e indexação. Cada nó tem um nome único e pode ter um ou mais roles.

```text
Node = Instância do Elasticsearch + Roles + Dados
```

## Tipos de Nós

### 1. Master-eligible Node

```yaml
# elasticsearch.yml
node.roles: [ master ]
```

```text
- Participa da eleição do master
- Gerencia estado do cluster
- Não armazena dados (recomendado)
- Requer poucos recursos
```

### 2. Data Node

```yaml
# elasticsearch.yml
node.roles: [ data ]
```

```text
- Armazena dados
- Executa operações de CRUD
- Executa agregações
- Requer muitos recursos (CPU, RAM, Disco)
```

### 3. Coordinating Node

```yaml
# elasticsearch.yml
node.roles: [ ]
```

```text
- Distribui requisições
- Coleta resultados
- Não armazena dados
- Requer CPU e RAM
```

### 4. Ingest Node

```yaml
# elasticsearch.yml
node.roles: [ ingest ]
```

```text
- Executa ingest pipelines
- Pré-processa documentos
- Não armazena dados
- Requer CPU
```

### 5. ML Node

```yaml
# elasticsearch.yml
node.roles: [ ml ]
```

```text
- Executa jobs de machine learning
- Treina modelos
- Não armazena dados
- Requer CPU e RAM
```

## Configuração

### 1. Nome do Nó

```yaml
# elasticsearch.yml
node.name: node-1
```

### 2. Roles do Nó

```yaml
# elasticsearch.yml
node.roles: [ data, ingest ]
```

### 3. Bind Address

```yaml
# elasticsearch.yml
network.host: 0.0.0.0
http.port: 9200
transport.port: 9300
```

### 4. Discovery

```yaml
# elasticsearch.yml
discovery.seed_hosts: ["node-1", "node-2"]
cluster.initial_master_nodes: ["node-1"]
```

## Exemplo Prático

### Configuração de Data Node

```yaml
# elasticsearch.yml
cluster.name: my-cluster
node.name: data-1
node.roles: [ data ]
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["master-1", "master-2"]
```

### Configuração de Master-eligible Node

```yaml
# elasticsearch.yml
cluster.name: my-cluster
node.name: master-1
node.roles: [ master ]
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["master-2", "master-3"]
cluster.initial_master_nodes: ["master-1", "master-2", "master-3"]
```

### Configuração de Coordinating Node

```yaml
# elasticsearch.yml
cluster.name: my-cluster
node.name: coordinating-1
node.roles: [ ]
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["master-1", "master-2"]
```

## Vantagens

### 1. Especialização

```text
- Nós especializados por função
- Melhor uso de recursos
- Melhor performance
```

### 2. Escalabilidade

```text
- Adicionar nós conforme necessário
- Escala horizontalmente
- Distribuição de carga
```

### 3. Alta Disponibilidade

```text
- Múltiplos nós previnem falhas
- Failover automático
- Recuperação rápida
```

## Limitações

### 1. Complexidade

```text
- Configuração complexa
- Requer planejamento
- Curva de aprendizado
```

### 2. Custo

```text
- Múltiplos nós = mais custo
- Requer infraestrutura
- Manutenção adicional
```

### 3. Overhead de Rede

```text
- Comunicação entre nós
- Latência de rede
- Overhead de coordenação
```

## Melhores Práticas

### 1. Separar Roles

```yaml
# Master-eligible nodes (3)
node.roles: [ master ]

# Data nodes (múltiplos)
node.roles: [ data ]

# Coordinating nodes (2-3)
node.roles: [ ]
```

### 2. Configurar Discovery Adequadamente

```yaml
# Em produção, usar discovery.seed_hosts
discovery.seed_hosts: ["master-1", "master-2", "master-3"]

# Não usar cluster.initial_master_nodes após inicialização
```

### 3. Monitorar Nós

```json
GET /_cat/nodes?v
GET /_nodes/stats
```

### 4. Usar Hot-Warm Architecture

```yaml
# Hot nodes (dados recentes)
node.roles: [ data_hot ]

# Warm nodes (dados antigos)
node.roles: [ data_warm ]

# Cold nodes (arquivo)
node.roles: [ data_cold ]
```

## Trade-offs

### Dedicated vs Co-located Roles

- **Dedicated**: Melhor performance, mais custo
- **Co-located**: Menor custo, menos performance
- **Escolha**: Dedicated para produção, co-located para desenvolvimento

### Hot-Warm vs Single Tier

- **Hot-warm**: Otimizado para custo, complexo
- **Single tier**: Simples, menos otimizado
- **Escolha**: Hot-warm para produção, single tier para desenvolvimento

### On-premise vs Cloud

- **On-premise**: Controle total, mais overhead
- **Cloud**: Menor overhead, menos controle
- **Escolha**: Cloud para geral, on-premise para requisitos específicos

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html>
