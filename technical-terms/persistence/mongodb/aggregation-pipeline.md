# Aggregation Pipeline

Aggregation Pipeline é um framework do MongoDB para processamento de dados que permite transformar e combinar documentos em uma coleção usando uma sequência de operações (stages).

## Definição

Aggregation Pipeline é um framework que processa documentos através de uma sequência de stages, cada um transformando os documentos e passando o resultado para o próximo stage.

```text
Aggregation Pipeline = Stages + Transformação + Pipeline
```

## Como Funciona

### 1. Processo de Agregação

```text
1. Documentos entram no primeiro stage
2. Stage transforma documentos
3. Resultado é passado para o próximo stage
4. Processo se repete até o último stage
5. Resultado final é retornado
```

### 2. Stages Comuns

```text
- $match: Filtra documentos
- $group: Agrupa documentos
- $project: Seleciona campos
- $sort: Ordena documentos
- $limit: Limita número de documentos
- $lookup: Join com outra coleção
- $unwind: Desagrega arrays
- $addFields: Adiciona novos campos
```

### 3. Execução

```text
- Pipeline é executado em ordem
- Cada stage opera no resultado do anterior
- Otimização automática pelo MongoDB
- Pode usar índices para performance
```

## Exemplo Prático

### Agregação Simples

```javascript
// Contar documentos por status
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customer_id", total: { $sum: "$amount" } } },
  { $sort: { total: -1 } }
])
```

### Agregação com Lookup

```javascript
// Join com outra coleção
db.orders.aggregate([
  { $match: { status: "completed" } },
  {
    $lookup: {
      from: "customers",
      localField: "customer_id",
      foreignField: "_id",
      as: "customer"
    }
  },
  { $unwind: "$customer" },
  {
    $project: {
      _id: 1,
      amount: 1,
      customer_name: "$customer.name"
    }
  }
])
```

### Agregação Complexa

```javascript
// Agregação múltipla
db.orders.aggregate([
  { $match: { created_at: { $gte: new Date("2024-01-01") } } },
  {
    $group: {
      _id: {
        year: { $year: "$created_at" },
        month: { $month: "$created_at" },
        status: "$status"
      },
      total: { $sum: "$amount" },
      count: { $sum: 1 },
      avg: { $avg: "$amount" }
    }
  },
  { $sort: { "_id.year": 1, "_id.month": 1 } }
])
```

## Stages Principais

### 1. $match

```javascript
// Filtra documentos
{ $match: { status: "completed" } }
// Similar a WHERE em SQL
```

### 2. $group

```javascript
// Agrupa documentos
{
  $group: {
    _id: "$customer_id",
    total: { $sum: "$amount" },
    count: { $sum: 1 }
  }
}
// Similar a GROUP BY em SQL
```

### 3. $project

```javascript
// Seleciona campos
{
  $project: {
    _id: 1,
    title: 1,
    calculated_field: { $multiply: ["$price", 1.1] }
  }
}
// Similar a SELECT em SQL
```

### 4. $lookup

```javascript
// Join com outra coleção
{
  $lookup: {
    from: "customers",
    localField: "customer_id",
    foreignField: "_id",
    as: "customer"
  }
}
// Similar a JOIN em SQL
```

### 5. $unwind

```javascript
// Desagrega arrays
{ $unwind: "$items" }
// Transforma array em documentos individuais
```

## Vantagens

### 1. Flexibilidade

```text
- Múltiplas operações em uma query
- Transformações complexas
- Processamento de dados poderoso
```

### 2. Performance

```text
- Otimização automática
- Uso de índices
- Execução eficiente
```

### 3. Expressivo

```text
- Sintaxe clara
- Operadores poderosos
- Fácil de entender
```

## Desvantagens

### 1. Complexidade

```text
- Queries complexas podem ser difíceis
- Requer entendimento do pipeline
- Debugging pode ser desafiador
```

### 2. Performance de Agregação

```text
- Agregações grandes podem ser lentas
- Requer memória
- Pode impactar performance do cluster
```

### 3. Limites

```text
- Limite de 16MB por documento
- Limite de 100MB por stage
- Requer tuning para grandes datasets
```

## Melhores Práticas

### 1. Usar $match Early

```javascript
// Bom: Filtrar no início
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customer_id", total: { $sum: "$amount" } } }
])

// Ruim: Filtrar no final
db.orders.aggregate([
  { $group: { _id: "$customer_id", total: { $sum: "$amount" } } },
  { $match: { total: { $gt: 100 } } }
])
```

### 2. Usar Índices

```javascript
// Criar índice para campos usados em $match
db.orders.createIndex({ status: 1, created_at: 1 })

// Usar campos indexados em $match
db.orders.aggregate([
  { $match: { status: "completed", created_at: { $gte: new Date("2024-01-01") } } }
])
```

### 3. Usar $project para Selecionar Campos

```javascript
// Selecionar apenas campos necessários
db.orders.aggregate([
  { $match: { status: "completed" } },
  {
    $project: {
      _id: 1,
      amount: 1,
      customer_id: 1
    }
  }
])
```

### 4. Usar allowDiskUse para Grandes Agregações

```javascript
// Permitir uso de disco para agregações grandes
db.orders.aggregate([
  { $group: { _id: "$customer_id", total: { $sum: "$amount" } } }
], { allowDiskUse: true })
```

## Trade-offs

### Aggregation Pipeline vs Map-Reduce

- **Aggregation**: Mais simples, mais eficiente
- **Map-Reduce**: Mais flexível, mais complexo
- **Escolha**: Aggregation para geral, map-reduce para casos específicos

### Aggregation vs Application-side Processing

- **Aggregation**: Processamento no banco, menos rede
- **Application**: Mais controle, mais rede
- **Escolha**: Aggregation para processamento de dados, application para lógica de negócio

### Single Pipeline vs Múltiplos Pipelines

- **Single**: Simples, menos overhead
- **Múltiplos**: Mais flexível, mais overhead
- **Escolha**: Single para geral, múltiplos para casos complexos

### _Links_

- <https://www.mongodb.com/docs/manual/core/aggregation-pipeline/>
- <https://www.mongodb.com/docs/manual/reference/operator/aggregation/>
- <https://www.mongodb.com/docs/manual/core/aggregation-pipeline-limits/>
