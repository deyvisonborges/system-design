# Replica Set

Replica Set é um grupo de servidores MongoDB (nós) que mantêm o mesmo conjunto de dados, proporcionando alta disponibilidade e redundância de dados através de replicação automática.

## Definição

Replica Set é um cluster de servidores MongoDB que mantém cópias idênticas dos dados, com um nó primário que aceita escritas e múltiplos nós secundários que replicam dados do primário.

```text
Replica Set = Primário + Secundários + Replicação automática
```

## Como Funciona

### 1. Estrutura do Replica Set

```text
- Primary: Aceita todas as operações de escrita
- Secondary: Replica dados do primary, aceita leituras
- Arbiter: Participa de eleições sem armazenar dados (opcional)
```

### 2. Processo de Replicação

```text
1. Escrita é recebida no primary
2. Primary aplica escrita localmente
3. Primary envia oplog para secondaries
4. Secondaries aplicam oplog
5. Secondaries confirmam replicação
```

### 3. Oplog (Operations Log)

```text
- Log de todas as operações de escrita
- Armazenado em coleção local.oplog.rs
- Usado para replicação
- Tamanho fixo (circular)
```

## Configuração

### 1. Inicializar Replica Set

```javascript
// Inicializar replica set
rs.initiate({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongodb1:27017" },
    { _id: 1, host: "mongodb2:27017" },
    { _id: 2, host: "mongodb3:27017" }
  ]
})
```

### 2. Adicionar Membro

```javascript
// Adicionar membro ao replica set
rs.add("mongodb4:27017")

// Adicionar membro com prioridade
rs.add({ host: "mongodb4:27017", priority: 1 })
```

### 3. Configurar Prioridade

```javascript
// Configurar prioridade de membros
cfg = rs.conf()
cfg.members[0].priority = 2
cfg.members[1].priority = 1
cfg.members[2].priority = 1
rs.reconfig(cfg)
```

## Exemplo Prático

### Configuração de Replica Set de 3 Nós

```javascript
// Inicializar replica set com 3 membros
rs.initiate({
  _id: "production",
  members: [
    { _id: 0, host: "mongo-primary:27017", priority: 2 },
    { _id: 1, host: "mongo-secondary1:27017", priority: 1 },
    { _id: 2, host: "mongo-secondary2:27017", priority: 1 }
  ]
})
```

### Verificar Status

```javascript
// Verificar status do replica set
rs.status()

// Verificar configuração
rs.conf()

// Verificar health
rs.isMaster()
```

### Configurar Read Preference

```javascript
// Ler do primário (padrão)
db.collection.find().readPref("primary")

// Ler de qualquer secundário
db.collection.find().readPref("secondary")

// Ler do secundário mais próximo
db.collection.find().readPref("nearest")
```

## Vantagens

### 1. Alta Disponibilidade

```text
- Failover automático
- Recuperação rápida
- Continuidade de operações
```

### 2. Redundância

```text
- Múltiplas cópias dos dados
- Proteção contra falha de nó
- Backup em tempo real
```

### 3. Escalabilidade de Leitura

```text
- Distribui carga de leitura
- Mais throughput de leitura
- Melhor performance
```

## Limitações

### 1. Custo

```text
- Requer múltiplos servidores
- Mais custo de infraestrutura
- Mais overhead de rede
```

### 2. Latência de Escrita

```text
- Replicação adiciona latência
- Espera por confirmação de secondaries
- Pode impactar throughput de escrita
```

### 3. Complexidade

```text
- Configuração adicional
- Requer gerenciamento
- Troubleshooting mais complexo
```

## Melhores Práticas

### 1. Usar Número Ímpar de Membros

```javascript
// Bom: 3 membros (maoria = 2)
rs.initiate({
  _id: "production",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
})

// Ruim: 2 membros (maoria = 2, mas sem failover)
```

### 2. Configurar Write Concern Adequadamente

```javascript
// Acknowledge de primário apenas (padrão)
db.collection.insertOne({ data: "value" }, { w: 1 })

// Acknowledge de maioria
db.collection.insertOne({ data: "value" }, { w: "majority" })

// Acknowledge de todos os membros
db.collection.insertOne({ data: "value" }, { w: 3 })
```

### 3. Configurar Read Preference Adequadamente

```javascript
// Para dados críticos, ler do primário
db.collection.find().readPref("primary")

// Para dados não críticos, ler de secundários
db.collection.find().readPref("secondary")
```

### 4. Monitorar Replica Set

```javascript
// Verificar status regularmente
rs.status()

// Verificar lag de replicação
rs.printSecondaryReplicationInfo()

// Verificar oplog
db.getCollection("oplog.rs").stats()
```

## Trade-offs

### Write Concern 1 vs Majority

- **w:1**: Mais rápido, menos durabilidade
- **w:majority**: Mais durável, mais lento
- **Escolha**: w:1 para geral, majority para crítico

### Primary vs Secondary Read Preference

- **Primary**: Consistência forte, menos escalabilidade
- **Secondary**: Consistência eventual, mais escalabilidade
- **Escolha**: Primary para crítico, secondary para analítico

### 3 Nós vs 5 Nós

- **3**: Menor custo, menos tolerância a falhas
- **5**: Maior custo, mais tolerância a falhas
- **Escolha**: 3 para geral, 5 para produção crítica

### _Links_

- <https://www.mongodb.com/docs/manual/replication/>
- <https://www.mongodb.com/docs/manual/core/replica-set-architecture/>
- <https://www.mongodb.com/docs/manual/core/replica-set-high-availability/>
