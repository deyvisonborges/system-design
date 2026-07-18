# Auto Scaling

Auto Scaling do DynamoDB é um recurso que ajusta automaticamente a capacidade provisionada de uma tabela ou índice global secundário (GSI) em resposta a mudanças no tráfego da aplicação, garantindo performance consistente enquanto otimiza custos.

## Definição

Auto Scaling monitora a utilização da capacidade e ajusta automaticamente as unidades de capacidade de leitura (RCU) e gravação (WCU) provisionadas para manter a utilização em um nível alvo.

```text
Auto Scaling = Ajuste automático de capacidade baseado em utilização
```

## Como Funciona

### 1. Monitoramento Contínuo

O Auto Scaling monitora continuamente a utilização da capacidade:

```text
Utilização alvo: 70%
Utilização atual: 85% → Escalar para cima
Utilização atual: 50% → Escalar para baixo
Utilização atual: 70% → Manter capacidade atual
```

### 2. Políticas de Escala

- **Scale Out**: Aumenta capacidade quando utilização > alvo
- **Scale In**: Reduz capacidade quando utilização < alvo
- **Cooldown**: Período de espera entre ajustes

### 3. Ajuste Gradual

- **Suave**: Ajustes são feitos gradualmente
- **Preventivo**: Evita oscilações rápidas
- **Controlado**: Limites máximo e mínimo

## Tipos de Auto Scaling

### 1. Target Tracking

Ajusta capacidade para manter utilização em um alvo específico.

```yaml
# Exemplo de target tracking policy
target_tracking_policy:
  target_utilization: 70
  scale_out_cooldown: 60
  scale_in_cooldown: 300
  disable_scale_in: false
```

### 2. Step Scaling

Ajusta capacidade em passos baseados em limiares.

```yaml
# Exemplo de step scaling policy
step_scaling_policy:
  adjustment_type: ChangeInCapacity
  steps:
    - lower_bound: 0
      upper_bound: 50
      metric_interval_upper_bound: 70
      scaling_adjustment: 1
    - lower_bound: 50
      upper_bound: null
      metric_interval_upper_bound: null
      scaling_adjustment: 3
```

## Configuração

### 1. Via AWS Console

```yaml
# Configuração via Console
auto_scaling_configuration:
  table_name: Orders
  capacity_mode: provisioned
  
  read_capacity:
    minimum: 100
    maximum: 10000
    target_utilization: 70
  
  write_capacity:
    minimum: 50
    maximum: 5000
    target_utilization: 70
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
      KeySchema:
        - AttributeName: order_id
          KeyType: HASH
      BillingMode: PROVISIONED
      ProvisionedThroughput:
        ReadCapacityUnits: 100
        WriteCapacityUnits: 50
  
  OrdersTableReadScaling:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10000
      MinCapacity: 100
      ResourceId: table/Orders
      ScalableDimension: dynamodb:table:ReadCapacityUnits
      ServiceNamespace: dynamodb
  
  OrdersTableReadScalingPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: ReadAutoScalingPolicy
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref OrdersTableReadScaling
      TargetTrackingScalingPolicyConfiguration:
        TargetValue: 70
        PredefinedMetricSpecification:
          PredefinedMetricType: DynamoDBReadCapacityUtilization
```

### 3. Via Terraform

```hcl
# Exemplo de Terraform
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  hash_key = "order_id"
  
  read_capacity  = 100
  write_capacity = 50
}

resource "aws_appautoscaling_target" "orders_read" {
  max_capacity       = 10000
  min_capacity       = 100
  resource_id        = "table/Orders"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "orders_read_policy" {
  name               = "orders-read-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.orders_read.resource_id
  scalable_dimension = aws_appautoscaling_target.orders_read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.orders_read.service_namespace
  
  target_tracking_scaling_policy_configuration {
    target_value       = 70
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}
```

## Benefícios

### 1. Otimização de Custos

- **Paga pelo uso**: Paga apenas pela capacidade necessária
- **Sem over-provisioning**: Não provisiona capacidade excessiva
- **Economia**: Economia significativa em tráfego variável

### 2. Performance Consistente

- **Sem throttling**: Evita throttling durante picos
- **Responsivo**: Responde rapidamente a mudanças de tráfego
- **Automático**: Sem intervenção manual

### 3. Simplicidade

- **Sem scripts**: Não requer scripts complexos
- **Gerenciado**: AWS gerencia o escalonamento
- **Foco no negócio**: Foco na aplicação, não infraestrutura

## Melhores Práticas

### 1. Definir Limites Adequados

```yaml
# Limites adequados são importantes
auto_scaling_limits:
  minimum:
    # Mínimo deve ser suficiente para tráfego base
    # Não muito baixo para evitar oscilações
    read: 100
    write: 50
  
  maximum:
    # Máximo deve ser suficiente para pico esperado
    # Não muito alto para evitar custos excessivos
    read: 10000
    write: 5000
```

### 2. Utilização Alvo Apropriada

```yaml
# Utilização alvo típica: 70%
# - 70% permite absorver picos sem escalar
# - 50% é mais conservador, mais custo
# - 90% é mais agressivo, mais risco de throttling

target_utilization:
  recommended: 70
  conservative: 50
  aggressive: 90
```

### 3. Cooldown Adequado

```yaml
# Cooldown evita oscilações rápidas
cooldown:
  scale_out:
    # Tempo mínimo entre escalamentos para cima
    # Tipicamente 60 segundos
    recommended: 60
  
  scale_in:
    # Tempo mínimo entre escalamentos para baixo
    # Tipicamente 300 segundos (mais longo)
    recommended: 300
```

## Monitoramento

### Métricas Importantes

- **ConsumedReadCapacityUnits**: Unidades de leitura consumidas
- **ConsumedWriteCapacityUnits**: Unidades de gravação consumidas
- **ProvisionedReadCapacityUnits**: Unidades de leitura provisionadas
- **ProvisionedWriteCapacityUnits**: Unidades de gravação provisionadas
- **ReadThrottleEvents**: Eventos de throttling de leitura
- **WriteThrottleEvents**: Eventos de throttling de gravação

### Exemplo de Monitoramento

```python
# Exemplo de monitoramento com boto3
import boto3
from datetime import datetime, timedelta

cloudwatch = boto3.client('cloudwatch')

def get_auto_scaling_metrics(table_name):
    """Obtém métricas de auto-scaling"""
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/DynamoDB',
        MetricName='ProvisionedReadCapacityUnits',
        Dimensions=[
            {'Name': 'TableName', 'Value': table_name}
        ],
        StartTime=datetime.utcnow() - timedelta(hours=1),
        EndTime=datetime.utcnow(),
        Period=300,
        Statistics=['Average', 'Maximum', 'Minimum']
    )
    return response

# Uso
metrics = get_auto_scaling_metrics('Orders')
print(f"Auto-scaling metrics: {metrics}")
```

## Exemplo Prático

### Tabela de Pedidos com Auto Scaling

```python
# Exemplo: Tabela de pedidos com auto-scaling
import boto3

dynamodb = boto3.client('dynamodb')

# Cria tabela com auto-scaling
response = dynamodb.register_scalable_target(
    ServiceNamespace='dynamodb',
    ResourceId='table/Orders',
    ScalableDimension='dynamodb:table:ReadCapacityUnits',
    MinCapacity=100,
    MaxCapacity=10000
)

# Configura política de target tracking
response = dynamodb.put_scaling_policy(
    PolicyName='OrdersReadScaling',
    ServiceNamespace='dynamodb',
    ResourceId='table/Orders',
    ScalableDimension='dynamodb:table:ReadCapacityUnits',
    PolicyType='TargetTrackingScaling',
    TargetTrackingScalingPolicyConfiguration={
        'TargetValue': 70,
        'PredefinedMetricSpecification': {
            'PredefinedMetricType': 'DynamoDBReadCapacityUtilization'
        },
        'ScaleOutCooldown': 60,
        'ScaleInCooldown': 300
    }
)
```

## Trade-offs

### Auto Scaling vs Provisionamento Manual

- **Auto Scaling**: Automático, otimizado para custo, menos controle
- **Provisionamento Manual**: Controle total, previsível, mais trabalho
- **Escolha**: Auto Scaling para tráfego variável, manual para estável

### Auto Scaling vs On-Demand

- **Auto Scaling**: Provisionado, custo previsível, requer configuração
- **On-Demand**: Paga por uso, custo imprevisível, sem configuração
- **Escolha**: Auto Scaling para padrões conhecidos, on-demand para imprevisível

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.html>
- <https://aws.amazon.com/blogs/database/amazon-dynamodb-auto-scaling-support-with-dynamic-application-load/>
- <https://aws.amazon.com/blogs/database/how-to-use-aws-application-auto-scaling-with-amazon-dynamodb/>
