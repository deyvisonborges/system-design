# LSI (Local Secondary Index)

LSI (Local Secondary Index) é um índice no Amazon DynamoDB que usa a mesma chave de partição da tabela principal, mas permite uma chave de ordenação diferente. Os dados do LSI são armazenados na mesma partição da tabela principal.

## Definição

LSI é um índice secundário que compartilha a chave de partição da tabela principal e permite uma chave de ordenação diferente, com throughput compartilhado com a tabela.

```text
LSI = Mesma partition key + diferente sort key + throughput compartilhado
```

## Características do LSI

### 1. Mesma Chave de Partição

- **Partition Key**: Deve ser igual à tabela principal
- **Sort Key**: Pode ser diferente da tabela principal
- **Escopo**: Local à partição da tabela principal

### 2. Throughput Compartilhado

- **RCU/WCU**: Compartilha throughput com a tabela principal
- **Sem auto-scaling independente**: Escala com a tabela
- **Custo**: Sem custo adicional de throughput

### 3. Strong Consistency

- **Sincronização**: Síncrona com a tabela principal
- **Latência**: Menor latência que GSI
- **Consistência**: Suporta leitura fortemente consistente

## Quando Usar LSI

### 1. Variações da Mesma Chave

```python
# Exemplo: Tabela de pedidos
# - Padrão 1: Consultar por customer_id + order_id (chave principal)
# - Padrão 2: Consultar por customer_id + created_at (LSI)

# Tabela principal
table.put_item(Item={
    'customer_id': '456',   # Partition Key
    'order_id': '123',      # Sort Key
    'created_at': '2024-01-01',
    'status': 'completed'
})

# LSI por created_at
lsi_created_at = table.query(
    IndexName='CreatedAtIndex',
    KeyConditionExpression='customer_id = :cid AND created_at > :date',
    ExpressionAttributeValues={
        ':cid': '456',
        ':date': '2024-01-01'
    }
)
```

### 2. Ordenação Diferente

```python
# Exemplo: Ordenar por diferentes atributos
# - Chave principal: customer_id + order_id
# - LSI: customer_id + created_at

# Consultar pedidos de um cliente ordenados por data
response = table.query(
    IndexName='CreatedAtIndex',
    KeyConditionExpression='customer_id = :cid',
    ExpressionAttributeValues={':cid': '456'},
    ScanIndexForward=False  # Ordenação decrescente
)
```

### 3. Consultas Locais

```python
# Exemplo: Consultar dados de uma partição específica
# LSI é eficiente para consultas dentro da mesma partição

response = table.query(
    IndexName='StatusIndex',
    KeyConditionExpression='customer_id = :cid AND status = :status',
    ExpressionAttributeValues={
        ':cid': '456',
        ':status': 'completed'
    }
)
```

## Criação de LSI

### 1. Via AWS Console

```yaml
# Configuração via Console
local_secondary_index:
  index_name: CreatedAtIndex
  key_schema:
    - attribute_name: customer_id
      key_type: HASH  # Deve ser igual à tabela principal
    - attribute_name: created_at
      key_type: RANGE
  
  projection:
    type: ALL  # ou INCLUDE ou KEYS_ONLY
```

### 2. Via CloudFormation

```yaml
# Exemplo de CloudFormation
Resources:
  OrdersTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: Orders
      AttributeDefinitions:
        - AttributeName: customer_id
          AttributeType: S
        - AttributeName: order_id
          AttributeType: S
        - AttributeName: created_at
          AttributeType: S
      KeySchema:
        - AttributeName: customer_id
          KeyType: HASH
        - AttributeName: order_id
          KeyType: RANGE
      LocalSecondaryIndexes:
        - IndexName: CreatedAtIndex
          KeySchema:
            - AttributeName: customer_id
              KeyType: HASH
            - AttributeName: created_at
              KeyType: RANGE
          Projection:
            ProjectionType: ALL
      BillingMode: PROVISIONED
```

### 3. Via Terraform

```hcl
# Exemplo de Terraform
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  hash_key       = "customer_id"
  range_key      = "order_id"
  
  attribute {
    name = "customer_id"
    type = "S"
  }
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  attribute {
    name = "created_at"
    type = "S"
  }
  
  local_secondary_index {
    name            = "CreatedAtIndex"
    range_key       = "created_at"
    projection_type = "ALL"
  }
}
```

## Tipos de Projeção

### 1. KEYS_ONLY

```yaml
# Apenas chaves do índice e tabela principal
projection:
  type: KEYS_ONLY

# Vantagens:
# - Menor armazenamento
# - Menor custo de WCU

# Desvantagens:
# - Requer fetch adicional para obter outros atributos
```

### 2. INCLUDE

```yaml
# Chaves + atributos específicos
projection:
  type: INCLUDE
  non_key_attributes:
    - status
    - total_amount

# Vantagens:
# - Balanceamento entre armazenamento e consultas
# - Atributos frequentemente acessados incluídos

# Desvantagens:
# - Mais armazenamento que KEYS_ONLY
```

### 3. ALL

```yaml
# Todos os atributos
projection:
  type: ALL

# Vantagens:
# - Consultas completas sem fetch adicional
# - Simplicidade

# Desvantagens:
# - Maior armazenamento
# - Maior custo de WCU
```

## Limitações do LSI

### 1. Limite de LSIs

```text
- Máximo de 5 LSIs por tabela
- Deve ser criado na criação da tabela
- Não pode ser adicionado após criação
```

### 2. Mesma Partition Key

```python
# LSI deve usar a mesma partition key da tabela
# Não pode ter partition key diferente

# Ruim:
LSI: product_id (HASH) + created_at (RANGE)
Tabela: customer_id (HASH) + order_id (RANGE)

# Bom:
LSI: customer_id (HASH) + created_at (RANGE)
Tabela: customer_id (HASH) + order_id (RANGE)
```

### 3. Tamanho do Item

```yaml
# Limite de 10 GB por partição (tabela + LSIs)
# Se exceder, não pode adicionar mais LSIs
# Considere usar GSI se necessário
```

## Melhores Práticas

### 1. Usar para Variações Locais

```python
# Usar LSI para variações da mesma partition key
# Não para padrões de acesso completamente diferentes

# Bom: customer_id + order_id → customer_id + created_at
# Ruim: customer_id + order_id → product_id + created_at (usar GSI)
```

### 2. Otimizar Projeção

```yaml
# Usar projeção apropriada para cada caso

# KEYS_ONLY:
# - Quando atributos não-chave raramente acessados
# - Quando armazenamento é preocupação

# INCLUDE:
# - Quando alguns atributos frequentemente acessados
# - Balanceamento entre custo e performance

# ALL:
# - Quando todos os atributos frequentemente acessados
# - Quando simplicidade é prioridade
```

### 3. Monitorar Tamanho da Partição

```python
# Monitorar tamanho da partição
# Se exceder 10 GB, considerar GSI

def check_partition_size(table_name):
    """Verifica tamanho da partição"""
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ConsumedStorage',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name}
        ],
        StartTime=datetime.utcnow() - timedelta(hours=1),
        EndTime=datetime.utcnow(),
        Period=300,
        Statistics=['Maximum']
    )
    
    return response
```

## Exemplo Prático

### Tabela de Pedidos com LSI

```python
# Exemplo: Tabela de pedidos com LSI
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
        {'AttributeName': 'order_id', 'AttributeType': 'S'},
        {'AttributeName': 'created_at', 'AttributeType': 'S'},
        {'AttributeName': 'status', 'AttributeType': 'S'}
    ],
    LocalSecondaryIndexes=[
        {
            'IndexName': 'CreatedAtIndex',
            'KeySchema': [
                {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
                {'AttributeName': 'created_at', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'ALL'}
        },
        {
            'IndexName': 'StatusIndex',
            'KeySchema': [
                {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
                {'AttributeName': 'status', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'INCLUDE', 'NonKeyAttributes': ['total_amount']}
        }
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 500,
        'WriteCapacityUnits': 200
    }
)

# Consultar por created_at
response = table.query(
    IndexName='CreatedAtIndex',
    KeyConditionExpression='customer_id = :cid AND created_at > :date',
    ExpressionAttributeValues={
        ':cid': '456',
        ':date': '2024-01-01'
    }
)

# Consultar por status
response = table.query(
    IndexName='StatusIndex',
    KeyConditionExpression='customer_id = :cid AND status = :status',
    ExpressionAttributeValues={
        ':cid': '456',
        ':status': 'completed'
    }
)
```

## Trade-offs

### LSI vs GSI

- **LSI**: Mesma partition key, throughput compartilhado, strong consistency
- **GSI**: Partition key diferente, throughput próprio, eventual consistency
- **Escolha**: LSI para variações da mesma chave, GSI para padrões diferentes

### LSI vs Scan

- **LSI**: Consultas eficientes, sem custo adicional, limitado a 5
- **Scan**: Consultas ineficientes, sem custo adicional, sem limite
- **Escolha**: LSI para consultas frequentes, scan para consultas raras

### KEYS_ONLY vs ALL

- **KEYS_ONLY**: Menor custo, mais lento (fetch adicional)
- **ALL**: Maior custo, mais rápido (sem fetch)
- **Escolha**: KEYS_ONLY para dados raramente acessados, ALL para frequentemente

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.html>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.Projections.html>
- <https://aws.amazon.com/blogs/database/amazon-dynamodb-local-secondary-indexes-internal-and-architectural-overview/>
