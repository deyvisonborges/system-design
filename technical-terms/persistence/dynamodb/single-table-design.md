# Single Table Design

Single Table Design é um padrão de design do Amazon DynamoDB onde múltiplas entidades de dados são armazenadas em uma única tabela, usando chaves compostas e prefixos para diferenciar os tipos de entidades.

## Definição

Single Table Design é uma abordagem que armazena todos os tipos de dados relacionados em uma única tabela do DynamoDB, usando chaves compostas e atributos de tipo para diferenciar as entidades.

```text
Single Table Design = Múltiplas entidades em uma tabela
```

## Por que Usar Single Table Design

### 1. Eficiência de Custo

- **Menos tabelas**: Reduz número de tabelas e custos associados
- **Throughput compartilhado**: Melhor utilização de capacidade provisionada
- **Menos overhead**: Menos gerenciamento de múltiplas tabelas

### 2. Performance

- **Menos latência**: Consultas locais são mais rápidas
- **Batch operations**: Operações em batch mais eficientes
- **Menos round trips**: Menos requisições ao DynamoDB

### 3. Simplicidade

- **Menos complexidade**: Menos tabelas para gerenciar
- **Transações**: Transações mais simples
- **Consistência**: Dados relacionados na mesma tabela

## Conceitos Chave

### 1. Chaves Compostas

```python
# Usar chaves compostas para diferenciar entidades
# PK (Partition Key) + SK (Sort Key)

# Exemplo: Usuário
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'name': 'John',
    'email': 'john@example.com'
})

# Exemplo: Pedidos do usuário
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456',
    'status': 'completed',
    'total': 100.00
})
```

### 2. Prefixos de Chave

```python
# Usar prefixos para identificar tipo de entidade
# USER# para usuários
# ORDER# para pedidos
# PRODUCT# para produtos

table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'entity_type': 'USER'
})

table.put_item(Item={
    'PK': 'ORDER#456',
    'SK': 'DETAILS',
    'entity_type': 'ORDER'
})
```

### 3. Atributo de Tipo

```python
# Adicionar atributo para identificar tipo de entidade
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'entity_type': 'USER',
    'name': 'John'
})

table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456',
    'entity_type': 'ORDER',
    'status': 'completed'
})
```

## Padrões de Acesso

### 1. Hierarquia de Dados

```python
# Estrutura hierárquica de dados
# USER#123 → PROFILE
# USER#123 → ORDER#456 → DETAILS
# USER#123 → ORDER#456 → ITEMS

# Perfil do usuário
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'name': 'John'
})

# Pedido do usuário
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456',
    'status': 'completed'
})

# Itens do pedido
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456#ITEM#1',
    'product_id': '789',
    'quantity': 2
})
```

### 2. Inversão de Relacionamento

```python
# Armazenar relacionamento em ambas direções
# USER#123 → ORDER#456
# ORDER#456 → USER#123

# Do usuário para o pedido
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456',
    'status': 'completed'
})

# Do pedido para o usuário
table.put_item(Item={
    'PK': 'ORDER#456',
    'SK': 'USER#123',
    'name': 'John'
})
```

### 3. Índices Invertidos

```python
# Usar GSI para padrões de acesso alternativos
# GSI1: SK como PK, PK como SK

# Consultar pedidos de um usuário
response = table.query(
    KeyConditionExpression='PK = :pk',
    ExpressionAttributeValues={':pk': 'USER#123'}
)

# Consultar usuário de um pedido (via GSI)
response = table.query(
    IndexName='GSI1',
    KeyConditionExpression='SK = :sk',
    ExpressionAttributeValues={':sk': 'USER#123'}
)
```

## Exemplo Prático

### Sistema de E-commerce

```python
# Exemplo: Sistema de e-commerce com single table design
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.create_table(
    TableName='ECommerce',
    KeySchema=[
        {'AttributeName': 'PK', 'KeyType': 'HASH'},
        {'AttributeName': 'SK', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'PK', 'AttributeType': 'S'},
        {'AttributeName': 'SK', 'AttributeType': 'S'},
        {'AttributeName': 'GSI1PK', 'AttributeType': 'S'},
        {'AttributeName': 'GSI1SK', 'AttributeType': 'S'}
    ],
    GlobalSecondaryIndexes=[
        {
            'IndexName': 'GSI1',
            'KeySchema': [
                {'AttributeName': 'GSI1PK', 'KeyType': 'HASH'},
                {'AttributeName': 'GSI1SK', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'ALL'}
        }
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 1000,
        'WriteCapacityUnits': 500
    }
)

# Usuário
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'GSI1PK': 'USER#PROFILE#123',
    'GSI1SK': 'USER#123',
    'entity_type': 'USER',
    'name': 'John',
    'email': 'john@example.com'
})

# Pedido
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'ORDER#456',
    'GSI1PK': 'ORDER#456',
    'GSI1SK': 'USER#123',
    'entity_type': 'ORDER',
    'status': 'completed',
    'total': 100.00
})

# Produto
table.put_item(Item={
    'PK': 'PRODUCT#789',
    'SK': 'DETAILS',
    'GSI1PK': 'PRODUCT#789',
    'GSI1SK': 'PRODUCT#789',
    'entity_type': 'PRODUCT',
    'name': 'Laptop',
    'price': 999.99
})

# Consultar pedidos de um usuário
response = table.query(
    KeyConditionExpression='PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues={
        ':pk': 'USER#123',
        ':sk': 'ORDER#'
    }
)

# Consultar usuário de um pedido
response = table.query(
    IndexName='GSI1',
    KeyConditionExpression='GSI1PK = :pk',
    ExpressionAttributeValues={':pk': 'ORDER#456'}
)
```

## Melhores Práticas

### 1. Nomenclatura Consistente

```python
# Usar nomenclatura consistente para chaves
# ENTITY_TYPE#ID para PK
# RELATIONSHIP_TYPE#ID ou ATTRIBUTE para SK

# Bom:
PK = 'USER#123'
SK = 'PROFILE'

PK = 'USER#123'
SK = 'ORDER#456'

# Ruim:
PK = '123'
SK = 'user'

PK = '456'
SK = 'order'
```

### 2. Atributo de Tipo

```python
# Sempre incluir atributo de tipo
table.put_item(Item={
    'PK': 'USER#123',
    'SK': 'PROFILE',
    'entity_type': 'USER',  # Importante!
    'name': 'John'
})
```

### 3. Documentação de Chaves

```yaml
# Documentar padrões de chave
key_patterns:
  user_profile:
    PK: "USER#{user_id}"
    SK: "PROFILE"
  
  user_order:
    PK: "USER#{user_id}"
    SK: "ORDER#{order_id}"
  
  product_details:
    PK: "PRODUCT#{product_id}"
    SK: "DETAILS"
```

## Limitações

### 1. Complexidade de Design

```python
# Design mais complexo que múltiplas tabelas
# Requer planejamento cuidadoso
# Difícil de mudar após implementação
```

### 2. Consultas Complexas

```python
# Consultas podem ser mais complexas
# Requer múltiplos índices para padrões diferentes
# Scan pode ser necessário em alguns casos
```

### 3. Tamanho da Tabela

```yaml
# Limite de 10 GB por partição
# Se exceder, considerar particionamento
# Pode ser necessário dividir em múltiplas tabelas
```

## Trade-offs

### Single Table vs Multiple Tables

- **Single Table**: Menor custo, melhor performance, mais complexo
- **Multiple Tables**: Mais simples, maior custo, mais overhead
- **Escolha**: Single table para dados relacionados, multiple para independentes

### Simplicidade vs Eficiência

- **Simplicidade**: Múltiplas tabelas, mais fácil de entender
- **Eficiência**: Single table, melhor performance e custo
- **Escolha**: Balancear baseado em equipe e requisitos

### Flexibilidade vs Performance

- **Flexibilidade**: Múltiplas tabelas, mais flexível para mudanças
- **Performance**: Single table, melhor performance otimizada
- **Escolha**: Single table para padrões estáveis, multiple para dinâmicos

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-single-table-design.html>
- <https://aws.amazon.com/blogs/database/single-table-design-with-amazon-dynamodb/>
- <https://www.alexdebrie.com/posts/dynamodb-single-table/>
