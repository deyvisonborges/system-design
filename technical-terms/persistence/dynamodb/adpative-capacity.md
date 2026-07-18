# Adaptive Capacity

Adaptive Capacity (capacidade adaptativa) é um recurso do Amazon DynamoDB que ajusta automaticamente a capacidade de leitura e gravação provisionada de uma tabela ou índice global secundário (GSI) em resposta a mudanças no tráfego da aplicação.

## Definição

Adaptive Capacity permite que o DynamoDB aumente temporariamente a capacidade provisionada de uma partição específica quando ela detecta que o tráfego está excedendo a capacidade provisionada, sem necessidade de intervenção manual.

```text
Adaptive Capacity = Escalonamento automático de capacidade por partição
```

## Como Funciona

### 1. Detecção de Tráfego

O DynamoDB monitora continuamente o tráfego de cada partição:

```text
Partição A: 100 RCU provisionado, 150 RPU detectado → Adaptive Capacity ativado
Partição B: 100 RCU provisionado, 80 RPU detectado → Normal
Partição C: 100 RCU provisionado, 200 RPU detectado → Adaptive Capacity ativado
```

### 2. Aumento Temporário

Quando uma partição excede sua capacidade provisionada:

- O DynamoDB aumenta temporariamente a capacidade da partição
- O aumento pode ser até 2x ou 3x da capacidade provisionada
- O aumento é automático e transparente para a aplicação

### 3. Ajuste Gradual

Após o pico de tráfego:

- A capacidade é gradualmente reduzida de volta ao nível provisionado
- O ajuste é suave para evitar impactos na aplicação
- O processo é totalmente gerenciado pelo DynamoDB

## Benefícios

### 1. Absorção de Picos de Tráfego

- **Sem throttling**: Evita erros de throttling durante picos
- **Sem intervenção**: Não requer ajuste manual de capacidade
- **Automático**: Funciona automaticamente sem configuração

### 2. Redução de Custos

- **Provisionamento otimizado**: Não é necessário over-provisionar para picos
- **Pagar pelo uso**: Paga apenas pela capacidade provisionada
- **Eficiente**: Uso mais eficiente dos recursos

### 3. Simplicidade Operacional

- **Sem scripts**: Não requer scripts de auto-scaling
- **Sem monitoramento complexo**: Menos necessidade de monitoramento
- **Foco no negócio**: Foco na lógica da aplicação, não em infraestrutura

## Limitações

### 1. Duração Limitada

- **Temporário**: O aumento é temporário, não permanente
- **Duração**: Geralmente dura de minutos a horas
- **Não substitui**: Não substitui provisionamento adequado

### 2. Capacidade Máxima

- **Limite**: O aumento tem um limite máximo
- **Não ilimitado**: Não pode escalar indefinidamente
- **Depende da região**: Varia por região e tipo de instância

### 3. Não Garantido

- **Best effort**: É um "best effort", não garantido
- **Pode não ocorrer**: Em alguns casos pode não ser ativado
- **Depende da carga**: Depende do padrão de tráfego

## Quando o Adaptive Capacity é Ativado

### 1. Picos Súbitos

```python
# Exemplo: Pico de tráfego durante promoção
# Tráfego normal: 100 RPS
# Tráfego de pico: 500 RPS

# Com Adaptive Capacity:
# - Partição detecta aumento
# - Capacidade aumentada automaticamente
# - Sem throttling
# - Após pico, capacidade reduzida gradualmente
```

### 2. Distribuição Desigual de Dados

```python
# Exemplo: Hot partition
# Partição A: 80% dos dados, 80% do tráfego
# Partição B: 10% dos dados, 10% do tráfego
# Partição C: 10% dos dados, 10% do tráfego

# Com Adaptive Capacity:
# - Partição A recebe capacidade adicional
# - Partições B e C mantêm capacidade normal
# - Tráfesco distribuído mais eficientemente
```

### 3. Padrões de Tráfego Variáveis

```python
# Exemplo: Tráfego sazonal
# Manhã: Baixo tráfego
# Tarde: Tráfico moderado
# Noite: Pico de tráfego

# Com Adaptive Capacity:
# - Capacidade ajustada automaticamente
# - Sem necessidade de provisionamento manual
# - Custo otimizado
```

## Monitoramento

### Métricas Importantes

- **ConsumedReadCapacityUnits**: Unidades de capacidade de leitura consumidas
- **ConsumedWriteCapacityUnits**: Unidades de capacidade de gravação consumidas
- **ThrottledRequests**: Requisições throttled (deve ser zero com Adaptive Capacity)
- **ProvisionedReadCapacityUnits**: Unidades de capacidade de leitura provisionadas
- **ProvisionedWriteCapacityUnits**: Unidades de capacidade de gravação provisionadas

### Exemplo de Monitoramento com CloudWatch

```python
# Exemplo de monitoramento com boto3
import boto3

cloudwatch = boto3.client('cloudwatch')

def get_dynamodb_metrics(table_name):
    """Obtém métricas do DynamoDB"""
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ConsumedReadCapacityUnits',
        Dimensions=[
            {
                'Name': 'TableName', 
                'Value': table_name
            }
        ],
        StartTime=datetime.utcnow() - timedelta(minutes=5),
        EndTime=datetime.utcnow(),
        Period=60,
        Statistics=['Sum', 'Average']
    )
    return response

# Uso
metrics = get_dynamodb_metrics('my-table')
print(f"Consumed RCU: {metrics}")
```

## Melhores Práticas

### 1. Não Depender Exclusivamente

```yaml
# Não confiar apenas em Adaptive Capacity
# Provisionar capacidade base adequada

# Exemplo de provisionamento correto:
provisioning:
  base_capacity: 1000 RCU
  auto_scaling:
    min_capacity: 1000
    max_capacity: 10000
    target_utilization: 70%
  
# Adaptive Capacity atua como complemento
# para picos inesperados acima do auto-scaling
```

### 2. Monitorar Throttling

```python
# Monitorar throttling para identificar problemas
def check_throttling(table_name):
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ThrottledRequests',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name}
        ],
        StartTime=datetime.utcnow() - timedelta(minutes=5),
        EndTime=datetime.utcnow(),
        Period=60,
        Statistics=['Sum']
    )
    
    throttled = sum(dp['Sum'] for dp in response['Datapoints'])
    
    if throttled > 0:
        print(f"ALERTA: {throttled} requisições throttled")
        # Considerar aumentar capacidade provisionada
```

### 3. Usar Auto-Scaling

```yaml
# Combinar Adaptive Capacity com Auto-Scaling
auto_scaling_policy:
  target_tracking:
    target_utilization: 70%
    scale_in_cooldown: 300
    scale_out_cooldown: 60
  
  # Adaptive Capacity lida com picos rápidos
  # Auto-Scaling lida com tendências de longo prazo
```

## Exemplo Prático

### Tabela de Pedidos

```python
# Exemplo: Tabela de pedidos com Adaptive Capacity
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
        'ReadCapacityUnits': 100,
        'WriteCapacityUnits': 50
    }
)

# Durante Black Friday:
# - Tráfego aumenta para 500 RCU
# - Adaptive Capacity aumenta automaticamente
# - Sem throttling
# - Após Black Friday, capacidade reduzida
```

## Trade-offs

### Adaptive Capacity vs Provisionamento Manual

- **Adaptive Capacity**: Automático, mas limitado e temporário
- **Provisionamento Manual**: Controle total, mas requer gerenciamento
- **Combinação**: Usar ambos para melhor resultado

### Adaptive Capacity vs Auto-Scaling

- **Adaptive Capacity**: Resposta rápida, por partição, temporário
- **Auto-Scaling**: Resposta mais lenta, por tabela, permanente
- **Complementar**: Usar ambos para cobertura completa

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.AdaptiveCapacity.html>
- <https://aws.amazon.com/blogs/database/how-to-use-adaptive-capacity-in-amazon-dynamodb-to-handle-unexpected-traffic/>
- <https://aws.amazon.com/blogs/database/amazon-dynamodb-auto-scaling-support-with-dynamic-application-load/>
