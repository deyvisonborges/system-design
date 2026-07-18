# Hot Partition

Hot Partition (partição quente) é um problema no Amazon DynamoDB onde uma partição específica recebe muito mais tráfego do que outras, causando throttling e degradação de performance, mesmo que a capacidade total da tabela não tenha sido excedida.

## Definição

Hot Partition ocorre quando o tráfego não é distribuído uniformemente entre as partições, fazendo com que uma partição específica exceda sua capacidade provisionada.

```text
Hot Partition = Tráfego desigual entre partições
```

## Causas de Hot Partition

### 1. Chave de Partição com Pouca Cardinalidade

```python
# Exemplo: Usar status como partition key
# Poucos valores possíveis: 'pending', 'completed', 'cancelled'

table.put_item(Item={
    'status': 'pending',  # Partition Key - ruim!
    'order_id': '123',
    'customer_id': '456'
})

# Problema:
# - Todos os pedidos 'pending' vão para a mesma partição
# - Partição 'pending' fica sobrecarregada
# - Outras partições ficam subutilizadas
```

### 2. Padrão de Acesso Sequencial

```python
# Exemplo: Usar timestamp como partition key
# Timestamps são sequenciais

table.put_item(Item={
    'timestamp': '2024-01-01T00:00:00Z',  # Partition Key - ruim!
    'order_id': '123',
    'customer_id': '456'
})

# Problema:
# - Todos os pedidos do mesmo período vão para a mesma partição
# - Partição fica sobrecarregada durante picos
```

### 3. Acesso a Dados Recentes

```python
# Exemplo: Consultar apenas dados recentes
# A maioria dos acessos é para dados recentes

response = table.query(
    KeyConditionExpression='created_at >= :date',
    ExpressionAttributeValues={
        ':date': '2024-01-01'
    }
)

# Problema:
# - Dados recentes estão na mesma partição
# - Partição fica sobrecarregada
```

## Sintomas de Hot Partition

### 1. Throttling com Capacidade Disponível

```text
Capacidade provisionada: 1000 RCU
Capacidade consumida: 500 RCU (média)
Throttling: Sim

# Isso indica hot partition
# Uma partição está excedendo sua capacidade
# Mesmo que a média esteja abaixo do provisionado
```

### 2. Latência Alta para Algumas Requisições

```python
# Algumas requisições têm latência alta
# Outras têm latência normal

# Isso indica que uma partição está sobrecarregada
# Requisições para essa partição têm latência alta
```

### 3. Erros Intermittent

```python
# Erros de throttling intermitentes
# Mesmo com baixa utilização média

try:
    response = table.get_item(Key={'order_id': '123'})
except Exception as e:
    print(f"Throttling: {e}")
```

## Prevenção de Hot Partition

### 1. Escolher Chave de Partição Adequada

```python
# Bom: Usar customer_id como partition key
# Muitos valores únicos, distribuição uniforme

table.put_item(Item={
    'customer_id': '456',  # Partition Key - bom!
    'order_id': '123',
    'status': 'pending'
})

# Vantagens:
# - Muitos valores únicos
# - Distribuição uniforme
# - Sem hot partition
```

### 2. Usar Prefixo ou Sufixo

```python
# Adicionar prefixo para distribuir dados

# Ruim:
partition_key = '2024-01-01'

# Bom:
partition_key = f'{customer_id}#{date}'

table.put_item(Item={
    'pk': f'{customer_id}#{date}',  # Partition Key
    'order_id': '123'
})
```

### 3. Usar Hash

```python
# Usar hash da chave para distribuir dados

import hashlib

def get_partition_key(key):
    """Gera hash da chave"""
    return hashlib.md5(key.encode()).hexdigest()

partition_key = get_partition_key(customer_id)

table.put_item(Item={
    'pk': partition_key,  # Partition Key
    'order_id': '123'
})
```

## Solução de Hot Partition

### 1. Redistribuir Dados

```python
# Se hot partition já existe, redistribuir dados

# 1. Criar nova tabela com melhor partition key
new_table = dynamodb.create_table(
    TableName='Orders_New',
    KeySchema=[
        {'AttributeName': 'customer_id', 'KeyType': 'HASH'},
        {'AttributeName': 'order_id', 'KeyType': 'RANGE'}
    ],
    # ...
)

# 2. Migrar dados para nova tabela
for item in old_table.scan()['Items']:
    new_table.put_item(Item=item)

# 3. Trocar tabelas
# 4. Deletar tabela antiga
```

### 2. Usar Write Sharding

```python
# Distribuir escritas entre múltiplas chaves

def get_shard_key(customer_id, num_shards=10):
    """Distribui entre shards"""
    hash_value = int(hashlib.md5(customer_id.encode()).hexdigest(), 16)
    shard = hash_value % num_shards
    return f'{customer_id}#shard{shard}'

# Escrever em múltiplos shards
shard_key = get_shard_key(customer_id)
table.put_item(Item={
    'pk': shard_key,
    'order_id': '123'
})
```

### 3. Usar Random Suffix

```python
# Adicionar sufixo aleatório para distribuir dados

import random

def get_random_partition_key(base_key):
    """Adiciona sufixo aleatório"""
    suffix = random.randint(0, 9)
    return f'{base_key}#{suffix}'

partition_key = get_random_partition_key(customer_id)
table.put_item(Item={
    'pk': partition_key,
    'order_id': '123'
})
```

## Monitoramento de Hot Partition

### Métricas Importantes

- **ConsumedReadCapacityUnits**: Por partição
- **ConsumedWriteCapacityUnits**: Por partição
- **ThrottledRequests**: Por partição
- **Latência**: Por partição

### Exemplo de Monitoramento

```python
# Monitorar por partição
def check_partition_hotspot(table_name):
    """Verifica hot partitions"""
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ConsumedReadCapacityUnits',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name}
        ],
        StartTime=datetime.utcnow() - timedelta(hours=1),
        EndTime=datetime.utcnow(),
        Period=60,
        Statistics=['Maximum']
    )
    
    max_consumed = max(dp['Maximum'] for dp in response['Datapoints'])
    
    if max_consumed > 3000:  # Limite por partição
        print(f"ALERTA: Possível hot partition")
        print(f"Max consumed: {max_consumed}")
    
    return response
```

## Exemplo Prático

### Tabela de Pedidos com Hot Partition

```python
# Exemplo: Tabela com hot partition
# Ruim: usar status como partition key

table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'status', 'KeyType': 'HASH'},  # Ruim!
        {'AttributeName': 'order_id', 'KeyType': 'RANGE'}
    ],
    # ...
)

# Problema:
# - Todos os pedidos 'pending' vão para a mesma partição
# - Se 80% dos pedidos são 'pending', partição fica sobrecarregada
# - Throttling ocorre mesmo com baixa utilização média

# Solução:
# - Usar customer_id como partition key
# - Criar GSI por status se necessário

table = dynamodb.create_table(
    TableName='Orders',
    KeySchema=[
        {'AttributeName': 'customer_id', 'KeyType': 'HASH'},  # Bom!
        {'AttributeName': 'order_id', 'KeyType': 'RANGE'}
    ],
    GlobalSecondaryIndexes=[
        {
            'IndexName': 'StatusIndex',
            'KeySchema': [
                {'AttributeName': 'status', 'KeyType': 'HASH'},
                {'AttributeName': 'created_at', 'KeyType': 'RANGE'}
            ],
            'Projection': {'ProjectionType': 'ALL'},
            'ProvisionedThroughput': {
                'ReadCapacityUnits': 100,
                'WriteCapacityUnits': 50
            }
        }
    ],
    # ...
)
```

## Melhores Práticas

### 1. Alta Cardinalidade

```python
# Escolher chave de partição com alta cardinalidade
# Muitos valores únicos

# Ruim: status (3 valores)
# Bom: customer_id (milhões de valores)
# Bom: order_id (bilhões de valores)
```

### 2. Distribuição Uniforme

```python
# Garantir distribuição uniforme de tráfego

# Ruim: timestamp (sequencial)
# Bom: customer_id (aleatório)
# Bom: hash (distribuído)
```

### 3. Padrão de Acesso Conhecido

```python
# Considerar padrão de acesso ao escolher chave

# Se acessa por customer_id: usar customer_id como partition key
# Se acessa por order_id: usar order_id como partition key
# Se acessa por múltiplos padrões: usar GSI
```

## Trade-offs

### Distribuição vs Simplicidade

- **Distribuição uniforme**: Mais complexo, melhor performance
- **Simplicidade**: Mais simples, risco de hot partition
- **Escolha**: Distribuição para tráfego alto, simplicidade para baixo

### GSI vs Hot Partition

- **GSI**: Custo adicional, sem hot partition
- **Hot Partition**: Sem custo adicional, performance degradada
- **Escolha**: GSI para padrões frequentes, aceitar hot partition para raros

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html>
- <https://aws.amazon.com/blogs/database/choosing-the-right-partition-key-is-key-to-scaling-your-dynamodb-table/>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-uniform-load.html>
