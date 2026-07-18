# Indexes

Indexes (índices) são estruturas de dados no MongoDB que melhoram a performance de queries ao permitir busca eficiente de documentos sem precisar escanear toda a coleção.

## Definição

Index é uma estrutura de dados que armazena uma parte dos dados de uma coleção em um formato otimizado para busca, permitindo queries rápidas sem escanear todos os documentos.

```text
Index = Estrutura de dados + Performance de busca + Otimização
```

## Como Funciona

### 1. Estrutura do Índice

```text
- Índice é uma árvore B-tree
- Armazena valores de campos ordenados
- Aponta para documentos originais
- Permite busca O(log n)
```

### 2. Tipos de Índices

```text
- Single field: Índice em um campo
- Compound: Índice em múltiplos campos
- Multikey: Índice em arrays
- Text: Índice de texto completo
- Geospatial: Índice de dados geoespaciais
- Hash: Índice de hash
- Wildcard: Índice em todos os campos
```

### 3. Execução de Query

```text
1. Query é recebida
2. MongoDB verifica se há índice adequado
3. Índice é usado para encontrar documentos
4. Documentos são retornados
```

## Exemplo Prático

### Criar Índice Single Field

```javascript
// Criar índice em um campo
db.users.createIndex({ email: 1 })

// 1 = ascendente, -1 = descendente
db.users.createIndex({ created_at: -1 })
```

### Criar Índice Compound

```javascript
// Criar índice composto
db.orders.createIndex({ customer_id: 1, status: 1, created_at: -1 })

// Query usa índice
db.orders.find({ customer_id: ObjectId("..."), status: "completed" })
```

### Criar Índice Multikey

```javascript
// Índice em array é criado automaticamente
db.posts.createIndex({ tags: 1 })

// Query usa índice
db.posts.find({ tags: "mongodb" })
```

### Criar Índice Text

```javascript
// Criar índice de texto
db.posts.createIndex({ title: "text", content: "text" })

// Query de texto
db.posts.find({ $text: { $search: "mongodb database" } })
```

## Tipos de Índices

### 1. Single Field Index

```javascript
// Índice em campo único
db.users.createIndex({ email: 1 })
```

### 2. Compound Index

```javascript
// Índice composto
db.orders.createIndex({ customer_id: 1, status: 1 })
```

### 3. Multikey Index

```javascript
// Índice em array (automático)
db.posts.createIndex({ tags: 1 })
```

### 4. Text Index

```javascript
// Índice de texto completo
db.posts.createIndex({ content: "text" })
```

### 5. Geospatial Index

```javascript
// Índice 2dsphere
db.places.createIndex({ location: "2dsphere" })
```

### 6. Hash Index

```javascript
// Índice de hash (para sharding)
db.users.createIndex({ _id: "hashed" })
```

## Vantagens

### 1. Performance

```text
- Queries muito mais rápidas
- Não escaneia toda a coleção
- O(log n) ao invés de O(n)
```

### 2. Eficiência

```text
- Menos uso de CPU
- Menos uso de memória
- Menos I/O de disco
```

### 3. Ordenação

```text
- Índices podem ser usados para sorting
- Evita sorting em memória
- Melhor performance para sort
```

## Limitações

### 1. Espaço em Disco

```text
- Índices ocupam espaço
- Pode aumentar tamanho do banco
- Requer gerenciamento
```

### 2. Custo de Escrita

```text
- Índices devem ser atualizados em cada escrita
- Pode impactar performance de escrita
- Requer planejamento
```

### 3. Memória

```text
- Índices usam memória
- Pode impactar performance se não cabem em RAM
- Requer monitoramento
```

## Melhores Práticas

### 1. Criar Índices para Queries Frequentes

```javascript
// Identificar queries lentas
db.users.find({ email: "user@example.com" })

// Criar índice
db.users.createIndex({ email: 1 })
```

### 2. Usar Índices Compostos Adequadamente

```javascript
// Bom: Índice composto para query com múltiplos campos
db.orders.createIndex({ customer_id: 1, status: 1, created_at: -1 })

// Query usa índice
db.orders.find({ customer_id: ObjectId("..."), status: "completed" })
```

### 3. Usar ESR Rule (Equality, Sort, Range)

```javascript
// Bom: Ordem correta do índice composto
db.orders.createIndex({ customer_id: 1, status: 1, created_at: -1 })

// Query usa índice eficientemente
db.orders.find({ customer_id: ObjectId("..."), status: "completed" })
  .sort({ created_at: -1 })
```

### 4. Monitorar Uso de Índices

```javascript
// Verificar uso de índices
db.users.getIndexes()

// Verificar estatísticas de índices
db.users.aggregate([
  { $indexStats: {} }
])
```

### 5. Remover Índices Não Usados

```javascript
// Remover índice
db.users.dropIndex("email_1")

// Remover todos os índices exceto _id
db.users.dropIndexes()
```

## Trade-offs

### Mais Índices vs Menos Índices

- **Mais**: Mais performance de leitura, mais custo de escrita
- **Menos**: Menor custo de escrita, menos performance de leitura
- **Escolha**: Índices apenas para queries frequentes

### Single Field vs Compound

- **Single**: Simples, menos espaço
- **Compound**: Mais flexível, mais espaço
- **Escolha**: Compound para queries com múltiplos campos

### Ascendente vs Descendente

- **Ascendente**: Padrão, adequado para maioria
- **Descendente**: Para sorting descendente
- **Escolha**: Ascendente para geral, descendente quando necessário

### _Links_

- <https://www.mongodb.com/docs/manual/indexes/>
- <https://www.mongodb.com/docs/manual/core/indexes/>
- <https://www.mongodb.com/docs/manual/indexes/index-types/>
