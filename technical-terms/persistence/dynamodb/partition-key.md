# Partition Key

Partition Key (chave de partição) é o atributo principal usado pelo Amazon DynamoDB para distribuir dados entre as partições de uma tabela. É o primeiro atributo da chave primária e determina onde os dados serão armazenados.

## Definição

Partition Key é um atributo único que identifica cada item em uma partição do DynamoDB e é usado para distribuir dados uniformemente entre as partições para escalabilidade.

```text
Partition Key = Distribuidor de dados entre partições
```

## Função da Partition Key

### 1. Distribuição de Dados

- **Hashing**: DynamoDB usa hash da partition key para distribuir dados
- **Partições**: Dados com a mesma partition key vão para a mesma partição
- **Escalabilidade**: Permite distribuição uniforme de carga

### 2. Identificação de Itens

- **Única**: Cada item tem uma partition key única dentro de sua partição
- **Obrigatória**: Todo item deve ter uma partition key
- **Imutável**: Partition key não pode ser alterada após criação

### 3. Padrões de Acesso

- **Query**: Permite consultas eficientes por partition key
- **Performance**: Consultas por partition key são muito rápidas
- **Limitação**: Consultas sem partition key requerem scan

## Tipos de Partition Key

### 1. Simple Primary Key

```python
# Apenas partition key (sem sort key)
table = dynamodb.create_table(
    TableName='Users',
    KeySchema=[
        {'AttributeName': 'user_id', 'KeyType': 'HASH'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'user_id', 'AttributeType': 'S'}
    ]
)

# Cada user_id é único na tabela
table.put_item(Item={
    'user_id': '123',
    'name': 'John',
    'email': 'john@example.com'
})
```

### 2. Composite Primary Key

```python
# Partition key + sort key
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

# customer_id é partition key, order_id é sort key
table.put_item(Item={
    'customer_id': '456',
    'order_id': '123',
    'status': 'completed'
})
```

## Escolha da Partition Key

### 1. Alta Cardinalidade

```python
# Bom: Alta cardinalidade (muitos valores únicos)
partition_key = 'user_id'  # Milhões de valores únicos

# Ruim: Baixa cardinalidade (poucos valores únicos)
partition_key = 'status'  # 3 valores: pending, completed, cancelled

# Ruim: Cardinalidade muito baixa
partition_key = 'is_active'  # 2 valores: true, false
```

### 2. Distribuição Uniforme

```python
# Bom: Distribuição uniforme
partition_key = 'customer_id'  # Distribuído aleatoriamente

# Ruim: Distribuição desigual
partition_key = 'region'  # 80% dos dados em us-east-1

# Ruim: Sequencial
partition_key = 'timestamp'  # Dados recentes na mesma partição
```

### 3. Padrão de Acesso Conhecido

```python
# Escolher baseado em como os dados são acessados

# Se acessa por customer_id: usar customer_id como partition key
table.put_item(Item={
    'customer_id': '456',  # Partition Key
    'order_id': '123'
})

# Se acessa por order_id: usar order_id como partition key
table.put_item(Item={
    'order_id': '123',  # Partition Key
    'customer_id': '456'
})
```

## Padrões de Partition Key

### 1. ID Único

```python
# Usar UUID como partition key
import uuid

partition_key = str(uuid.uuid4())

table.put_item(Item={
    'item_id': partition_key,
    'data': '...'
})
```

### 2. ID Composto

```python
# Usar ID composto para melhor distribuição
partition_key = f'{customer_id}#{order_id}'

table.put_item(Item={
    'pk': partition_key,
    'data': '...'
})
```

### 3. Hash

```python
# Usar hash para distribuição uniforme
import hashlib

def get_partition_key(key):
    return hashlib.md5(key.encode()).hexdigest()

partition_key = get_partition_key(customer_id)

table.put_item(Item={
    'pk': partition_key,
    'data': '...'
})
```

## Problemas Comuns

### 1. Hot Partition

```python
# Problema: Poucos valores de partition key
# Isso causa hot partition

table.put_item(Item={
    'status': 'pending',  # Ruim como partition key
    'order_id': '123'
})

# Solução: Usar chave com alta cardinalidade
table.put_item(Item={
    'customer_id': '456',  # Bom como partition key
    'order_id': '123'
})
```

### 2. Cardinalidade Insuficiente

```python
# Problema: Cardinalidade insuficiente
# Não escala bem com crescimento

table.put_item(Item={
    'category': 'electronics',  # Poucas categorias
    'product_id': '123'
})

# Solução: Usar ID único
table.put_item(Item={
    'product_id': '123',  # Único
    'category': 'electronics'
})
```

### 3. Padrão de Acesso Desconhecido

```python
# Problema: Partition key não corresponde ao padrão de acesso
# Consultas ineficientes

table.put_item(Item={
    'order_id': '123',  # Partition key
    'customer_id': '456'
})

# Se acessa por customer_id, isso é ineficiente
# Requer scan ou GSI

# Solução: Usar customer_id como partition key
table.put_item(Item={
    'customer_id': '456',  # Partition key
    'order_id': '123'
})
```

## Melhores Práticas

### 1. Priorizar Alta Cardinalidade

```python
# Escolher partition key com alta cardinalidade
# Muitos valores únicos

# Bom: user_id (milhões de valores)
# Bom: order_id (bilhões de valores)
# Bom: customer_id (milhões de valores)

# Ruim: status (3 valores)
# Ruim: region (10 valores)
# Ruim: is_active (2 valores)
```

### 2. Garantir Distribuição Uniforme

```python
# Garantir distribuição uniforme
# Evitar hot partitions

# Bom: UUID (distribuído aleatoriamente)
# Bom: customer_id (distribuído aleatoriamente)
# Bom: hash (distribuído uniformemente)

# Ruim: timestamp (sequencial)
# Ruim: auto-increment (sequencial)
# Ruim: data (distribuição desigual)
```

### 3. Considerar Padrão de Acesso

```python
# Escolher partition key baseado em padrão de acesso
# A maioria das consultas deve ser por partition key

# Se acessa por customer_id: usar customer_id
# Se acessa por order_id: usar order_id
# Se acessa por múltiplos: usar GSI
```

## Exemplo Prático

### Tabela de Pedidos

```python
# Exemplo: Tabela de pedidos com partition key adequada
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
        {'AttributeName': 'order_id', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'customer_id', 'AttributeType': 'S'},
        {'AttributeName': 'order_id', 'AttributeType': 'S'}
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 500,
        'WriteCapacityUnits': 200
    }
)

# Inserir dados
table.put_item(Item={
    'customer_id': '456',  # Partition Key - alta cardinalidade
    'order_id': '123',     # Sort Key
    'status': 'completed',
    'total_amount': 100.00
})

# Consultar por customer_id (eficiente)
response = table.query(
    KeyConditionExpression='customer_id = :cid',
    ExpressionAttributeValues={':cid': '456'}
)
```

## Trade-offs

### Cardinalidade vs Simplicidade

- **Alta cardinalidade**: Melhor distribuição, mais complexo
- **Baixa cardinalidade**: Mais simples, risco de hot partition
- **Escolha**: Alta cardinalidade para tráfego alto

### Distribuição vs Acesso

- **Distribuição uniforme**: Melhor escalabilidade, pode não corresponder ao acesso
- **Acesso otimizado**: Melhor performance, pode ter hot partition
- **Escolha**: Balancear entre distribuição e padrão de acesso

### Simples vs Composto

- **Simples**: Fácil de usar, limitado a um atributo
- **Composto**: Mais flexível, mais complexo
- **Escolha**: Simples para acesso único, composto para múltiplos

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.PartitionKey.html>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html>
- <https://aws.amazon.com/blogs/database/choosing-the-right-partition-key-is-key-to-scaling-your-dynamodb-table/>
