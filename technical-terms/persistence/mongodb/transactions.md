# Transactions

Transactions (transações) no MongoDB permitem executar múltiplas operações de forma atômica, garantindo que todas as operações tenham sucesso ou nenhuma seja aplicada, mantendo a consistência dos dados.

## Definição

Transaction é uma sequência de operações de banco de dados que são executadas como uma unidade atômica, garantindo ACID (Atomicidade, Consistência, Isolamento, Durabilidade).

```text
Transaction = ACID + Atomicidade + Consistência
```

## Como Funciona

### 1. Propriedades ACID

```text
- Atomicidade: Todas as operações ou nenhuma
- Consistência: Dados permanecem consistentes
- Isolamento: Transações não interferem entre si
- Durabilidade: Dados persistem após commit
```

### 2. Tipos de Transações

```text
- Multi-document transactions: Transações em múltiplos documentos/coleções
- Single-document transactions: Atômicas por padrão
- Replica set transactions: Requer replica set
- Sharded cluster transactions: Requer sharded cluster
```

### 3. Processo de Transação

```text
1. Iniciar transação
2. Executar operações
3. Commit ou abort
4. Confirmar ou reverter alterações
```

## Exemplo Prático

### Transação Simples

```javascript
// Iniciar sessão
const session = db.getMongo().startSession()

try {
  // Iniciar transação
  session.startTransaction()

  // Operações dentro da transação
  db.accounts.updateOne(
    { _id: 1 },
    { $inc: { balance: -100 } },
    { session }
  )

  db.accounts.updateOne(
    { _id: 2 },
    { $inc: { balance: 100 } },
    { session }
  )

  // Commit da transação
  session.commitTransaction()
} catch (error) {
  // Abort em caso de erro
  session.abortTransaction()
  throw error
} finally {
  session.endSession()
}
```

### Transação com Retry

```javascript
// Transação com retry automático
const session = db.getMongo().startSession()
session.startTransaction()

try {
  db.accounts.updateOne(
    { _id: 1 },
    { $inc: { balance: -100 } },
    { session }
  )

  db.accounts.updateOne(
    { _id: 2 },
    { $inc: { balance: 100 } },
    { session }
  )

  session.commitTransaction()
} catch (error) {
  if (error.hasErrorLabel("TransientTransactionError")) {
    // Retry da transação
    session.abortTransaction()
    // Lógica de retry
  } else if (error.hasErrorLabel("UnknownTransactionCommitResult")) {
    // Verificar resultado do commit
  } else {
    session.abortTransaction()
  }
} finally {
  session.endSession()
}
```

### Transação em Sharded Cluster

```javascript
// Transação em sharded cluster
const session = db.getMongo().startSession()
session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" }
})

try {
  db.accounts.updateOne(
    { _id: 1 },
    { $inc: { balance: -100 } },
    { session }
  )

  db.orders.insertOne(
    { account_id: 1, amount: 100 },
    { session }
  )

  session.commitTransaction()
} catch (error) {
  session.abortTransaction()
} finally {
  session.endSession()
}
```

## Read Concern

### 1. Níveis de Read Concern

```javascript
// local (padrão)
db.collection.find().readConcern("local")

// majority
db.collection.find().readConcern("majority")

// linearizable
db.collection.find().readConcern("linearizable")

// snapshot
db.collection.find().readConcern("snapshot")
```

### 2. Configuração de Read Concern

```javascript
// Configurar read concern na transação
session.startTransaction({
  readConcern: { level: "snapshot" }
})
```

## Write Concern

### 1. Níveis de Write Concern

```javascript
// w:1 (padrão)
db.collection.insertOne({ data: "value" }, { w: 1 })

// w:majority
db.collection.insertOne({ data: "value" }, { w: "majority" })

// w:0 (fire and forget)
db.collection.insertOne({ data: "value" }, { w: 0 })

// j:true (journal)
db.collection.insertOne({ data: "value" }, { w: 1, j: true })
```

### 2. Configuração de Write Concern

```javascript
// Configurar write concern na transação
session.startTransaction({
  writeConcern: { w: "majority", j: true }
})
```

## Vantagens

### 1. Consistência

```text
- Garante consistência de dados
- Operações atômicas
- Evita estados inconsistentes
```

### 2. Integridade

```text
- Mantém integridade referencial
- Operações complexas
- Garante regras de negócio
```

### 3. Confiabilidade

```text
- Operações ACID
- Durabilidade garantida
- Recuperação de falhas
```

## Limitações

### 1. Performance

```text
- Transações são mais lentas
- Requer locks
- Pode impactar throughput
```

### 2. Complexidade

```text
- Requer gerenciamento de sessões
- Retry logic necessário
- Mais código
```

### 3. Requisitos

```text
- Requer replica set ou sharded cluster
- WiredTiger storage engine
- MongoDB 4.0+
```

## Melhores Práticas

### 1. Manter Transações Curtas

```javascript
// Bom: Transação curta
session.startTransaction()
db.accounts.updateOne({ _id: 1 }, { $inc: { balance: -100 } }, { session })
db.accounts.updateOne({ _id: 2 }, { $inc: { balance: 100 } }, { session })
session.commitTransaction()

// Ruim: Transação longa com muitas operações
```

### 2. Usar Retry Logic

```javascript
// Implementar retry para transient errors
const runTransactionWithRetry = async (session, callback) => {
  while (true) {
    try {
      session.startTransaction()
      await callback(session)
      session.commitTransaction()
      break
    } catch (error) {
      if (error.hasErrorLabel("TransientTransactionError")) {
        continue
      }
      session.abortTransaction()
      throw error
    }
  }
}
```

### 3. Configurar Read/Write Concern Adequadamente

```javascript
// Para dados críticos
session.startTransaction({
  readConcern: { level: "majority" },
  writeConcern: { w: "majority" }
})

// Para dados não críticos
session.startTransaction({
  readConcern: { level: "local" },
  writeConcern: { w: 1 }
})
```

### 4. Usar Índices Adequados

```javascript
// Criar índices para campos usados em transações
db.accounts.createIndex({ _id: 1 })
db.orders.createIndex({ account_id: 1 })
```

## Trade-offs

### Transactions vs Operações Individuais

- **Transactions**: Consistência, mais lento
- **Individuais**: Mais rápido, menos consistência
- **Escolha**: Transactions para operações críticas, individuais para geral

### Read Concern Local vs Majority

- **Local**: Mais rápido, menos consistência
- **Majority**: Mais consistência, mais lento
- **Escolha**: Local para geral, majority para crítico

### Write Concern 1 vs Majority

- **w:1**: Mais rápido, menos durabilidade
- **w:majority**: Mais durável, mais lento
- **Escolha**: w:1 para geral, majority para crítico

### _Links_

- <https://www.mongodb.com/docs/manual/core/transactions/>
- <https://www.mongodb.com/docs/manual/core/read-concern/>
- <https://www.mongodb.com/docs/manual/core/write-concern/>
