# GSI (Global Secondary Index)

GSI (Global Secondary Index) é um índice no Amazon DynamoDB que permite consultas usando uma chave de partição diferente da chave de partição da tabela principal, com sua própria capacidade de throughput provisionada.

## Definição

GSI é um índice secundário que pode ter uma chave de partição diferente da tabela principal e espalha dados em todas as partições da tabela, permitindo consultas globais.

```text
GSI = Índice com chave de partição própria + throughput próprio
```

## Características do GSI

### 1. Chave de Partição Diferente

- **Partition Key**: Pode ser diferente da tabela principal
- **Sort Key**: Opcional, pode ser diferente da tabela principal
- **Flexibilidade**: Permite múltiplos padrões de acesso

### 2. Throughput Próprio

- **RCU/WCU**: Capacidade de throughput provisionada separada
- **Auto-scaling**: Auto-scaling independente da tabela
- **Custo**: Cobrado separadamente

### 3. Consistência Eventual

- **Sincronização**: Assíncrona da tabela principal
- **Latência**: Pode ter latência de propagação
- **Consistência**: Apenas eventual consistency

## Quando Usar GSI

### 1. Múltiplos Padrões de Acesso

```python
# Exemplo: Tabela de pedidos
# - Padrão 1: Consultar por customer_id (chave principal)
# - Padrão 2: Consultar por product_id (GSI)

# Tabela principal
table.put_item(Item={
    'order_id': '123',      # Partition Key
    'customer_id': '456',   # Sort Key
    'product_id': '789',
    'status': 'completed'
})

# GSI por product_id
gsi_product_id = table.query(
    IndexName='ProductIndex',
    KeyConditionExpression='product_id = :pid',
    ExpressionAttributeValues={':pid': '789'}
)
```

### 2. Consultas por Atributos Não-Chave

```python
# Exemplo: Consultar pedidos por status
# Status não é chave principal, usar GSI

gsi_status = table.query(
    IndexName='StatusIndex',
    KeyConditionExpression='status = :status',
    ExpressionAttributeValues={':status': 'completed'}
)
```

### 3. Agregação de Dados

```python
# Exemplo: Contar pedidos por região
gsi_region = table.query(
    IndexName='RegionIndex',
    KeyConditionExpression='region = :region',
    ExpressionAttributeValues={':region': 'us-east-1'}
)
```

## Criação de GSI

### 1. Via AWS Console

```yaml
# Configuração via Console
global_secondary_index:
  index_name: ProductIndex
  key_schema:
    - attribute_name: product_id
      key_type: HASH
    - attribute_name: created_at
      key_type: RANGE
  
  projection:
    type: ALL  # ou INCLUDE ou KEYS_ONLY
  
  provisioned_throughput:
    read_capacity_units: 100
    write_capacity_units: 50
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
        - AttributeName: order_id
          AttributeType: S
        - AttributeName: customer_id
          AttributeType: S
        - AttributeName: product_id
          AttributeType: S
        - AttributeName: created_at
          AttributeType: S
      KeySchema:
        - AttributeName: order_id
          KeyType: HASH
        - AttributeName: customer_id
          KeyType: RANGE
      GlobalSecondaryIndexes:
        - IndexName: ProductIndex
          KeySchema:
            - AttributeName: product_id
              KeyType: HASH
            - AttributeName: created_at
              KeyType: RANGE
          Projection:
            ProjectionType: ALL
          ProvisionedThroughput:
            ReadCapacityUnits: 100
            WriteCapacityUnits: 50
      BillingMode: PROVISIONED
```

### 3. Via Terraform

```hcl
# Exemplo de Terraform
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  hash_key       = "order_id"
  range_key      = "customer_id"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  attribute {
    name = "customer_id"
    type = "S"
  }
  
  attribute {
    name = "product_id"
    type = "S"
  }
  
  attribute {
    name = "created_at"
    type = "S"
  }
  
  global_secondary_index {
    name               = "ProductIndex"
    hash_key           = "product_id"
    range_key          = "created_at"
    write_capacity     = 50
    read_capacity      = 100
    projection_type    = "ALL"
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

## Limitações do GSI

### 1. Limite de GSIs

```text
- Máximo de 20 GSIs por tabela
- Cada GSI tem seu próprio throughput
- GSIs consomem WCU da tabela principal
```

### 2. Consistência Eventual

```python
# GSI não suporta leitura fortemente consistente
# Apenas eventual consistency

# Isso pode causar:
# - Dados desatualizados
# - Latência de propagação
# - Necessidade de considerar em design
```

### 3. Custo Adicional

```yaml
# Custos adicionais:
# - Throughput provisionado do GSI
# - Armazenamento do GSI
# - WCU adicionais para escrita no GSI
```

## Melhores Práticas

### 1. Escolher Chaves Adequadas

```python
# Escolher chaves que distribuem dados uniformemente
# Evitar hot partitions

# Ruim: status como partition key
# - Poucos valores possíveis
# - Hot partition

# Bom: customer_id como partition key
# - Muitos valores únicos
# - Distribuição uniforme
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

### 3. Monitorar Utilização

```python
# Monitorar utilização do GSI
def get_gsi_metrics(table_name, index_name):
    """Obtém métricas do GSI"""
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ConsumedReadCapacityUnits',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name},
            {'Name': 'GlobalSecondaryIndexName', 'Value': index_name}
        ],
        StartTime=datetime.utcnow() - timedelta(hours=1),
        EndTime=datetime.utcnow(),
        Period=300,
        Statistics=['Average']
    )
    return response
```

## Exemplo Prático

### Tabela de Pedidos com GSI

```python
# Exemplo: Tabela de pedidos com múltiplos GSIs
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'order_id', 'KeyType': 'HASH'},
        {'AttributeName': 'customer_id', 'KeyType': 'RANGE'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'order_id', 'AttributeType': 'S'},
        {'AttributeName': 'customer_id', 'AttributeType': 'S'},
        {'AttributeName': 'product_id', 'AttributeType': 'S'},
        {'AttributeName': 'created_at', 'AttributeType': 'S'},
        {'AttributeName': 'status', 'AttributeType': 'S'}
    ],
    GlobalSecondaryIndexes=[
        {
            'IndexName': 'ProductIndex',
            'KeySchema': [
                {'AttributeName': 'product_id', 'KeyType': 'HASH'},
                {'AttributeName': 'created_at', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'ALL'},
            'ProvisionedThroughput': {
                'ReadCapacityUnits': 100,
                'WriteCapacityUnits': 50
            }
        },
        {
            'IndexName': 'StatusIndex',
            'KeySchema': [
                {'AttributeName': 'status', 'KeyType': 'HASH'},
                {'AttributeName': 'created_at', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'INCLUDE', 'NonKeyAttributes': ['total_amount']},
            'ProvisionedThroughput': {
                'ReadCapacityUnits': 50,
                'WriteCapacityUnits': 25
            }
        }
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 500,
        'WriteCapacityUnits': 200
    }
)

# Consultar por product_id
response = table.query(
    IndexName='ProductIndex',
    KeyConditionExpression='product_id = :pid',
    ExpressionAttributeValues={':pid': '789'}
)

# Consultar por status
response = table.query(
    IndexName='StatusIndex',
    KeyConditionExpression='status = :status',
    ExpressionAttributeValues={':status': 'completed'}
)
```

## Trade-offs

### GSI vs LSI

- **GSI**: Chave de partição diferente, throughput próprio, eventual consistency
- **LSI**: Mesma chave de partição, throughput compartilhado, strong consistency
- **Escolha**: GSI para padrões diferentes, LSI para variações da mesma chave

### GSI vs Scan

- **GSI**: Consultas eficientes, custo adicional, setup complexo
- **Scan**: Consultas ineficientes, sem custo adicional, setup simples
- **Escolha**: GSI para consultas frequentes, scan para consultas raras

### KEYS_ONLY vs ALL

- **KEYS_ONLY**: Menor custo, mais lento (fetch adicional)
- **ALL**: Maior custo, mais rápido (sem fetch)
- **Escolha**: KEYS_ONLY para dados raramente acessados, ALL para frequentemente

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.Projections.html>
- <https://aws.amazon.com/blogs/database/amazon-dynamodb-global-secondary-indexes-internal-and-architectural-overview/>
