# Sort Key

Sort Key (chave de ordenação) é o atributo opcional usado pelo Amazon DynamoDB para ordenar itens dentro de uma partição. É o segundo atributo da chave primária e permite consultas eficientes e ordenação de dados.

## Definição

Sort Key é um atributo que, combinado com a Partition Key, forma a chave primária composta do DynamoDB, permitindo ordenação e consulta eficiente de itens dentro de uma partição.

```text
Sort Key = Ordenador de itens dentro de uma partição
```

## Função da Sort Key

### 1. Ordenação de Itens

- **Ordenação natural**: Itens são ordenados pela sort key
- **Range queries**: Permite consultas por intervalo
- **Ordenação reversa**: Pode ordenar em ordem reversa

### 2. Identificação Única

- **Composta com PK**: PK + SK forma chave única
- **Múltiplos itens**: Permite múltiplos itens com mesmo PK
- **Flexibilidade**: SK pode ser repetido dentro de PK

### 3. Padrões de Consulta

- **Range queries**: Consultas por intervalo de SK
- **Begins with**: Consultas por prefixo de SK
- **Between**: Consultas entre valores de SK

## Tipos de Sort Key

### 1. String

```python
# Sort key do tipo string
table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
        {'AttributeName': 'order_id', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'customer_id', 'AttributeType': 'S'},
        {'AttributeName': 'order_id', 'AttributeType': 'S'}
    ]
)

# Ordenação lexicográfica
table.put_item(Item={
    'customer_id': '456',
    'order_id': 'ORDER#001'
})

table.put_item(Item={
    'customer_id': '456',
    'order_id': 'ORDER#002'
})
```

### 2. Number

```python
# Sort key do tipo número
table = dynamodb.create_table(
    TableName='Scores',
    KeySchema=[
        {'AttributeName': 'game_id', 'KeyType': 'HASH'},
        {'AttributeName': 'score', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'game_id', 'AttributeType': 'S'},
        {'AttributeName': 'score', 'AttributeType': 'N'}
    ]
)

# Ordenação numérica
table.put_item(Item={
    'game_id': '123',
    'score': 100
})

table.put_item(Item={
    'game_id': '123',
    'score': 200
})
```

### 3. Binary

```python
# Sort key do tipo binary
table = dynamodb.create_table(
    TableName='Files',
    KeySchema=[
        {'AttributeName': 'user_id', 'KeyType': 'HASH'},
        {'AttributeName': 'file_hash', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'user_id', 'AttributeType': 'S'},
        {'AttributeName': 'file_hash', 'AttributeType': 'B'}
    ]
)
```

## Padrões de Sort Key

### 1. Timestamp

```python
# Usar timestamp como sort key
from datetime import datetime

table.put_item(Item={
    'customer_id': '456',
    'created_at': datetime.utcnow().isoformat(),
    'order_id': '123'
})

# Consultar pedidos recentes
response = table.query(
    KeyConditionExpression='customer_id = :cid AND created_at > :date',
    ExpressionAttributeValues={
        ':cid': '456',
        ':date': '2024-01-01'
    }
)
```

### 2. Contador Sequencial

```python
# Usar contador sequencial
table.put_item(Item={
    'customer_id': '456',
    'sequence': 1,
    'data': '...'
})

table.put_item(Item={
    'customer_id': '456',
    'sequence': 2,
    'data': '...'
})
```

### 3. Prefixo Hierárquico

```python
# Usar prefixo hierárquico
table.put_item(Item={
    'customer_id': '456',
    'SK': 'ORDER#123#ITEM#1',
    'product_id': '789'
})

table.put_item(Item={
    'customer_id': '456',
    'SK': 'ORDER#123#ITEM#2',
    'product_id': '790'
})

# Consultar itens de um pedido
response = table.query(
    KeyConditionExpression='customer_id = :cid AND begins_with(SK, :sk)',
    ExpressionAttributeValues={
        ':cid': '456',
        ':sk': 'ORDER#123#ITEM#'
    }
)
```

## Operações com Sort Key

### 1. Query por Intervalo

```python
# Consultar por intervalo de sort key
response = table.query(
    KeyConditionExpression='customer_id = :cid AND order_id BETWEEN :start AND :end',
    ExpressionAttributeValues={
        ':cid': '456',
        ':start': 'ORDER#001',
        ':end': 'ORDER#100'
    }
)
```

### 2. Query por Prefixo

```python
# Consultar por prefixo de sort key
response = table.query(
    KeyConditionExpression='customer_id = :cid AND begins_with(order_id, :prefix)',
    ExpressionAttributeValues={
        ':cid': '456',
        ':prefix': 'ORDER#'
    }
)
```

### 3. Ordenação Reversa

```python
# Ordenar em ordem reversa
response = table.query(
    KeyConditionExpression='customer_id = :cid',
    ExpressionAttributeValues={':cid': '456'},
    ScanIndexForward=False  # Ordenação decrescente
)
```

## Melhores Práticas

### 1. Escolher Tipo Adequado

```python
# Escolher tipo baseado no uso

# String para IDs e timestamps
SK = 'ORDER#123'
SK = '2024-01-01T00:00:00Z'

# Number para valores numéricos
SK = 100
SK = 3.14

# Binary para hashes
SK = b'\x00\x01\x02'
```

### 2. Usar Prefixos Consistentes

```python
# Usar prefixos consistentes para hierarquia
SK = 'ORDER#123#ITEM#1'
SK = 'ORDER#123#ITEM#2'
SK = 'ORDER#456#ITEM#1'

# Não usar
SK = 'ORDER123ITEM1'
SK = 'ITEM1ORDER123'
```

### 3. Considerar Ordenação

```python
# Considerar ordenação ao escolher sort key

# Bom para ordenação temporal
SK = '2024-01-01T00:00:00Z'

# Bom para ordenação numérica
SK = 100

# Ruim para ordenação (UUID)
SK = str(uuid.uuid4())
```

## Exemplo Prático

### Tabela de Pedidos

```python
# Exemplo: Tabela de pedidos com sort key
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
        {'AttributeName': 'created_at', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'customer_id', 'AttributeType': 'S'},
        {'AttributeName': 'created_at', 'AttributeType': 'S'}
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 500,
        'WriteCapacityUnits': 200
    }
)

# Inserir dados
table.put_item(Item={
    'customer_id': '456',
    'created_at': '2024-01-01T00:00:00Z',
    'order_id': '123',
    'status': 'completed'
})

table.put_item(Item={
    'customer_id': '456',
    'created_at': '2024-01-02T00:00:00Z',
    'order_id': '124',
    'status': 'pending'
})

# Consultar pedidos recentes
response = table.query(
    KeyConditionExpression='customer_id = :cid AND created_at > :date',
    ExpressionAttributeValues={
        ':cid': '456',
        ':date': '2024-01-01T00:00:00Z'
    }
)

# Consultar pedidos ordenados por data
response = table.query(
    KeyConditionExpression='customer_id = :cid',
    ExpressionAttributeValues={':cid': '456'},
    ScanIndexForward=False  # Mais recentes primeiro
)
```

## Limitações

### 1. Tamanho do Item

```yaml
# Limite de 400 KB por item
# Sort key conta para esse limite
# Considerar ao escolher sort key
```

### 2. Tipo Imutável

```python
# Tipo de sort key não pode ser alterado após criação
# Se necessário, criar nova tabela
```

### 3. Ordenação Fixa

```python
# Ordenação é baseada no tipo
# String: lexicográfica
# Number: numérica
# Não pode alterar ordenação
```

## Trade-offs

### String vs Number

- **String**: Flexível, ordenação lexicográfica, maior overhead
- **Number**: Eficiente, ordenação numérica, limitado a números
- **Escolha**: String para IDs, number para valores numéricos

### Simples vs Composto

- **Simples**: Fácil de usar, limitado a um valor
- **Composto**: Mais flexível, mais complexo
- **Escolha**: Simples para ordenação simples, composto para hierarquia

### Timestamp vs Contador

- **Timestamp**: Ordenação temporal, pode ter gaps
- **Contador**: Sequencial, sem gaps, requer gerenciamento
- **Escolha**: Timestamp para dados temporais, contador para sequencial

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html>
- <https://aws.amazon.com/blogs/database/amazon-dynamodb-core-components-part-1/>
