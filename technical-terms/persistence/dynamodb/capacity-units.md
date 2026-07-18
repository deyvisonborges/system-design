# Capacity Units

Capacity Units (unidades de capacidade) são as unidades de medida usadas pelo Amazon DynamoDB para especificar e cobrar pela capacidade de leitura e gravação provisionada de uma tabela ou índice global secundário (GSI).

## Definição

Capacity Units representam a combinação de throughput e tamanho dos itens que o DynamoDB pode processar por segundo.

```text
Capacity Units = Throughput + Tamanho do item
```

## Tipos de Capacity Units

### 1. Read Capacity Units (RCU)

Uma RCU representa uma leitura fortemente consistente de um item de até 4 KB por segundo.

```text
1 RCU = 1 leitura fortemente consistente de até 4 KB por segundo
```

#### Cálculo de RCU

```python
# Exemplo de cálculo de RCU
def calculate_rcu(item_size_kb, reads_per_second, consistency='strong'):
    """
    Calcula RCU necessários
    
    Args:
        item_size_kb: Tamanho do item em KB
        reads_per_second: Leituras por segundo
        consistency: 'strong' ou 'eventual'
    """
    # Número de itens lidos por operação
    items_per_read = max(1, item_size_kb / 4)
    
    # Fator de consistência
    consistency_factor = 1 if consistency == 'strong' else 0.5
    
    # RCU necessários
    rcu = items_per_read * reads_per_second * consistency_factor
    
    return rcu

# Exemplo
# Item de 8 KB, 100 leituras por segundo, consistência forte
rcu = calculate_rcu(8, 100, 'strong')
print(f"RCU necessários: {rcu}")  # 200 RCU

# Item de 8 KB, 100 leituras por segundo, consistência eventual
rcu = calculate_rcu(8, 100, 'eventual')
print(f"RCU necessários: {rcu}")  # 100 RCU
```

### 2. Write Capacity Units (WCU)

Uma WCU representa uma gravação de um item de até 1 KB por segundo.

```text
1 WCU = 1 gravação de até 1 KB por segundo
```

#### Cálculo de WCU

```python
# Exemplo de cálculo de WCU
def calculate_wcu(item_size_kb, writes_per_second):
    """
    Calcula WCU necessários
    
    Args:
        item_size_kb: Tamanho do item em KB
        writes_per_second: Gravações por segundo
    """
    # Número de itens gravados por operação
    items_per_write = max(1, item_size_kb / 1)
    
    # WCU necessários
    wcu = items_per_write * writes_per_second
    
    return wcu

# Exemplo
# Item de 5 KB, 50 gravações por segundo
wcu = calculate_wcu(5, 50)
print(f"WCU necessários: {wcu}")  # 250 WCU
```

## Consistência de Leitura

### 1. Strongly Consistent

- **Custo**: 1 RCU por 4 KB
- **Garantia**: Retorna o dado mais recente
- **Latência**: Maior latência
- **Uso**: Quando dados críticos devem ser consistentes

```python
# Exemplo de leitura fortemente consistente
response = table.get_item(
    Key={'order_id': '123'},
    ConsistentRead=True  # Strong consistency
)
```

### 2. Eventually Consistent

- **Custo**: 0.5 RCU por 4 KB
- **Garantia**: Pode retornar dado desatualizado
- **Latência**: Menor latência
- **Uso**: Quando latência é mais importante que consistência

```python
# Exemplo de leitura eventualmente consistente
response = table.get_item(
    Key={'order_id': '123'},
    ConsistentRead=False  # Eventual consistency (padrão)
)
```

## Cálculo de Capacidade

### Exemplo 1: Tabela de Pedidos

```python
# Exemplo: Tabela de pedidos
# - Tamanho médio do item: 2 KB
# - 1000 leituras por segundo
# - 100 gravações por segundo
# - Consistência eventual

item_size = 2  # KB
reads_per_second = 1000
writes_per_second = 100

# RCU (eventual consistency)
rcu = calculate_rcu(item_size, reads_per_second, 'eventual')
print(f"RCU: {rcu}")  # 500 RCU

# WCU
wcu = calculate_wcu(item_size, writes_per_second)
print(f"WCU: {wcu}")  # 200 WCU
```

### Exemplo 2: Tabela de Logs

```python
# Exemplo: Tabela de logs
# - Tamanho médio do item: 10 KB
# - 100 leituras por segundo
# - 500 gravações por segundo
# - Consistência eventual

item_size = 10  # KB
reads_per_second = 100
writes_per_second = 500

# RCU (eventual consistency)
rcu = calculate_rcu(item_size, reads_per_second, 'eventual')
print(f"RCU: {rcu}")  # 125 RCU

# WCU
wcu = calculate_wcu(item_size, writes_per_second)
print(f"WCU: {wcu}")  # 5000 WCU
```

## Custo de Capacity Units

### Preços (aproximados)

```text
Região us-east-1:
- RCU: $0.00013 por hora por unidade
- WCU: $0.00065 por hora por unidade

Custo mensal:
- 100 RCU: $9.36 por mês
- 100 WCU: $46.80 por mês
```

### Cálculo de Custo

```python
# Exemplo de cálculo de custo
def calculate_monthly_cost(rcu, wcu):
    """
    Calcula custo mensal aproximado
    
    Args:
        rcu: RCU provisionados
        wcu: WCU provisionados
    """
    # Preços por hora (us-east-1)
    rcu_price_per_hour = 0.00013
    wcu_price_per_hour = 0.00065
    
    # Horas por mês
    hours_per_month = 730
    
    # Custo mensal
    rcu_cost = rcu * rcu_price_per_hour * hours_per_month
    wcu_cost = wcu * wcu_price_per_hour * hours_per_month
    total_cost = rcu_cost + wcu_cost
    
    return {
        'rcu_cost': rcu_cost,
        'wcu_cost': wcu_cost,
        'total_cost': total_cost
    }

# Exemplo
cost = calculate_monthly_cost(500, 200)
print(f"Custo mensal: ${cost['total_cost']:.2f}")
```

## On-Demand vs Provisioned

### On-Demand Capacity

```yaml
# On-Demand: Paga pelo uso
billing_mode: PAY_PER_REQUEST

# Vantagens:
# - Sem provisionamento
# - Escala automaticamente
# - Custo imprevisível

# Desvantagens:
# - Custo mais alto por operação
# - Sem controle de custo
# - Não ideal para padrões previsíveis
```

### Provisioned Capacity

```yaml
# Provisioned: Capacidade fixa
billing_mode: PROVISIONED

# Vantagens:
# - Custo previsível
# - Custo menor por operação
# - Controle de capacidade

# Desvantagens:
# - Requer provisionamento
# - Pode ter throttling
# - Requer auto-scaling para tráfego variável
```

## Melhores Práticas

### 1. Estimar Capacidade Adequadamente

```python
# Estimar capacidade baseado em uso esperado
def estimate_capacity(
    item_size_kb,
    reads_per_second,
    writes_per_second,
    consistency='eventual'
):
    """
    Estima capacidade necessária
    """
    rcu = calculate_rcu(item_size_kb, reads_per_second, consistency)
    wcu = calculate_wcu(item_size_kb, writes_per_second)
    
    # Adicionar buffer de 20%
    rcu_with_buffer = rcu * 1.2
    wcu_with_buffer = wcu * 1.2
    
    return {
        'rcu': int(rcu_with_buffer),
        'wcu': int(wcu_with_buffer)
    }

# Exemplo
capacity = estimate_capacity(2, 1000, 100, 'eventual')
print(f"Capacidade estimada: {capacity}")
```

### 2. Usar Auto-Scaling

```yaml
# Combinar provisionamento com auto-scaling
provisioned_capacity:
  read:
    minimum: 100
    maximum: 10000
    target_utilization: 70
  
  write:
    minimum: 50
    maximum: 5000
    target_utilization: 70
```

### 3. Monitorar Utilização

```python
# Monitorar utilização para ajustar capacidade
def check_utilization(table_name):
    """
    Verifica utilização de capacidade
    """
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ConsumedReadCapacityUnits',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name}
        ],
        StartTime=datetime.utcnow() - timedelta(hours=1),
        EndTime=datetime.utcnow(),
        Period=300,
        Statistics=['Average']
    )
    
    return response
```

## Exemplo Prático

### Configuração de Tabela

```python
# Exemplo: Criar tabela com capacidade provisionada
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
        {'AttributeName': 'customer_id', 'AttributeType': 'S'}
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 500,  # 500 RCU
        'WriteCapacityUnits': 200  # 200 WCU
    }
)
```

## Trade-offs

### RCU vs WCU

- **RCU**: Para leituras, mais barato, pode usar consistência eventual
- **WCU**: Para gravações, mais caro, sempre forte consistência
- **Balanceamento**: Ajustar baseado na proporção de leituras/gravações

### Strong vs Eventual Consistency

- **Strong**: Mais caro, mais lento, dados consistentes
- **Eventual**: Mais barato, mais rápido, dados podem ser desatualizados
- **Escolha**: Strong para dados críticos, eventual para outros

### Provisioned vs On-Demand

- **Provisioned**: Custo previsível, requer planejamento
- **On-Demand**: Custo imprevisível, sem planejamento
- **Escolha**: Provisioned para padrões conhecidos, on-demand para imprevisível

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html>
- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ProvisionedThroughput.html>
- <https://aws.amazon.com/dynamodb/pricing/>
