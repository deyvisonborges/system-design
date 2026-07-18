# Document Model

Document Model é o paradigma de dados do MongoDB onde dados são armazenados como documentos BSON (Binary JSON), permitindo estruturas flexíveis e aninhadas, ao contrário de tabelas relacionais rígidas.

## Definição

Document Model é um paradigma de dados NoSQL onde informações são armazenadas como documentos BSON com esquema flexível, permitindo estruturas aninhadas e dinâmicas.

```text
Document Model = BSON + Flexibilidade + Estrutura aninhada
```

## Como Funciona

### 1. Estrutura do Documento

```text
- Documento é uma unidade de dados
- Armazenado como BSON
- Pode conter campos aninhados
- Esquema flexível
```

### 2. BSON

```text
- Binary JSON
- Tipos de dados ricos
- Suporta tipos binários
- Eficiente para armazenamento
```

### 3. Coleções

```text
- Grupo de documentos
- Não requer schema fixo
- Documentos podem ter estruturas diferentes
- Similar a tabelas relacionais
```

## Exemplo Prático

### Documento Simples

```javascript
// Documento de usuário
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  name: "John Doe",
  email: "john@example.com",
  age: 30,
  created_at: ISODate("2024-01-01T00:00:00Z")
}
```

### Documento com Estrutura Aninhada

```javascript
// Documento de pedido com itens aninhados
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  customer_id: ObjectId("507f1f77bcf86cd799439011"),
  status: "completed",
  items: [
    {
      product_id: ObjectId("507f1f77bcf86cd799439013"),
      name: "Product 1",
      quantity: 2,
      price: 100.00
    },
    {
      product_id: ObjectId("507f1f77bcf86cd799439014"),
      name: "Product 2",
      quantity: 1,
      price: 50.00
    }
  ],
  total: 250.00,
  shipping_address: {
    street: "123 Main St",
    city: "New York",
    state: "NY",
    zip: "10001"
  },
  created_at: ISODate("2024-01-01T00:00:00Z")
}
```

### Documento com Arrays

```javascript
// Documento com tags e categorias
{
  _id: ObjectId("507f1f77bcf86cd799439015"),
  title: "Blog Post",
  content: "Content of the blog post",
  tags: ["mongodb", "nosql", "database"],
  categories: ["technology", "programming"],
  comments: [
    {
      user_id: ObjectId("507f1f77bcf86cd799439011"),
      text: "Great post!",
      created_at: ISODate("2024-01-02T00:00:00Z")
    }
  ]
}
```

## Tipos de Dados BSON

### 1. Tipos Básicos

```javascript
{
  string: "text",
  number: 42,
  float: 3.14,
  boolean: true,
  null: null,
  date: ISODate("2024-01-01T00:00:00Z")
}
```

### 2. Tipos Avançados

```javascript
{
  object_id: ObjectId("507f1f77bcf86cd799439011"),
  binary: BinData(0, "base64data"),
  array: [1, 2, 3],
  object: { nested: "value" },
  regex: /pattern/,
  javascript: new Code("function() {}")
}
```

## Vantagens

### 1. Flexibilidade

```text
- Esquema flexível
- Estrutura dinâmica
- Fácil de evoluir
```

### 2. Estrutura Natural

```text
- Documentos aninhados
- Arrays nativos
- Mapeamento natural para objetos
```

### 3. Performance

```text
- Acesso a dados relacionados em um documento
- Menos joins
- Melhor performance para certos casos
```

## Limitações

### 1. Tamanho do Documento

```text
- Limite de 16MB por documento
- Requer planejamento
- Pode limitar uso
```

### 2. Redundância

```text
- Dados podem ser duplicados
- Requer gerenciamento
- Pode aumentar tamanho
```

### 3. Consistência

```text
- Esquema flexível pode levar a inconsistências
- Requer validação de aplicação
- Difícil de garantir consistência
```

## Melhores Práticas

### 1. Usar Estrutura Aninhada com Moderação

```javascript
// Bom: Nível razoável de aninhamento
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  name: "John Doe",
  address: {
    street: "123 Main St",
    city: "New York"
  }
}

// Ruim: Aninhamento excessivo
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  level1: {
    level2: {
      level3: {
        level4: {
          level5: "value"
        }
      }
    }
  }
}
```

### 2. Usar Arrays para Relações One-to-Many

```javascript
// Bom: Usar array para itens de pedido
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  items: [
    { product_id: ObjectId("507f1f77bcf86cd799439013"), quantity: 2 },
    { product_id: ObjectId("507f1f77bcf86cd799439014"), quantity: 1 }
  ]
}
```

### 3. Usar Referências para Relações Many-to-Many

```javascript
// Bom: Usar referências para muitos documentos
{
  _id: ObjectId("507f1f77bcf86cd799439015"),
  title: "Blog Post",
  author_id: ObjectId("507f1f77bcf86cd799439011"),
  category_ids: [
    ObjectId("507f1f77bcf86cd799439016"),
    ObjectId("507f1f77bcf86cd799439017")
  ]
}
```

### 4. Usar Validação de Schema

```javascript
// Criar validação de schema
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email"],
      properties: {
        name: { bsonType: "string" },
        email: { bsonType: "string" },
        age: { bsonType: "int", minimum: 0 }
      }
    }
  }
})
```

## Trade-offs

### Embed vs Reference

- **Embed**: Melhor performance, mais redundância
- **Reference**: Menos redundância, mais queries
- **Escolha**: Embed para one-to-few, reference para one-to-many/many-to-many

### Schema Flexível vs Schema Rígido

- **Flexível**: Mais flexível, menos consistência
- **Rígido**: Mais consistência, menos flexível
- **Escolha**: Flexível para desenvolvimento, rígido para produção

### Documentos Grandes vs Documentos Pequenos

- **Grandes**: Menos documentos, mais overhead
- **Pequenos**: Mais documentos, menos overhead
- **Escolha**: Manter documentos abaixo de 16MB, usar referências quando necessário

### _Links_

- <https://www.mongodb.com/docs/manual/core/document/>
- <https://www.mongodb.com/docs/manual/reference/bson-types/>
- <https://www.mongodb.com/docs/manual/core/data-modeling/>
