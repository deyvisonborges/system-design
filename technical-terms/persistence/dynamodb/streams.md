# DynamoDB Streams

DynamoDB Streams é um recurso do Amazon DynamoDB que captura mudanças de dados em uma tabela, permitindo que aplicações reajam a essas mudanças em tempo real, como inserções, atualizações e exclusões de itens.

## Definição

DynamoDB Streams é um fluxo ordenado de mudanças de nível de item em uma tabela do DynamoDB, que pode ser consumido por aplicações para processar eventos de mudança de dados em tempo real.

```text
DynamoDB Streams = Captura de mudanças de dados em tempo real
```

## Como Funciona

### 1. Captura de Mudanças

```text
Quando um item é modificado:
1. DynamoDB grava a mudança no stream
2. O stream mantém um registro ordenado
3. Aplicações podem consumir o stream
```

### 2. Tipos de Mudanças

- **INSERT**: Novo item inserido
- **MODIFY**: Item atualizado
- **REMOVE**: Item deletado

### 3. Retenção de Dados

```text
- Período de retenção: 24 horas
- Pode ser estendido até 168 horas (7 dias)
- Após retenção, dados são removidos automaticamente
```

## Tipos de Stream

### 1. KEYS_ONLY

```yaml
# Apenas chaves dos itens modificados
stream_view_type: KEYS_ONLY

# Vantagens:
# - Menor armazenamento
# - Menor custo

# Desvantagens:
# - Sem dados do item
# - Requer fetch adicional
```

### 2. NEW_IMAGE

```yaml
# Apenas nova versão do item
stream_view_type: NEW_IMAGE

# Vantagens:
# - Dados completos do novo item
# - Sem fetch adicional

# Desvantagens:
# - Mais armazenamento
# - Mais custo
```

### 3. OLD_IMAGE

```yaml
# Apenas versão antiga do item
stream_view_type: OLD_IMAGE

# Vantagens:
# - Dados completos do item antigo
# - Útil para auditoria

# Desvantagens:
# - Mais armazenamento
# - Mais custo
```

### 4. NEW_AND_OLD_IMAGES

```yaml
# Ambas as versões do item
stream_view_type: NEW_AND_OLD_IMAGES

# Vantagens:
# - Dados completos de ambas versões
# - Máxima informação

# Desvantagens:
# - Maior armazenamento
# - Maior custo
```

## Criação de Stream

### 1. Via AWS Console

```yaml
# Configuração via Console
stream_specification:
  stream_enabled: true
  stream_view_type: NEW_AND_OLD_IMAGES
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
      StreamSpecification:
        StreamViewType: NEW_AND_OLD_IMAGES
      BillingMode: PAY_PER_REQUEST
```

### 3. Via Terraform

```hcl
# Exemplo de Terraform
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "order_id"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}
```

## Consumo de Stream

### 1. Via Lambda

```python
# Exemplo: Lambda function para processar stream
import json

def lambda_handler(event, context):
    for record in event['Records']:
        # Tipo de operação
        event_name = record['eventName']
        
        # Dados do item
        if event_name == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            print(f"Novo item: {new_image}")
        elif event_name == 'MODIFY':
            old_image = record['dynamodb'].get('OldImage')
            new_image = record['dynamodb']['NewImage']
            print(f"Item modificado: {old_image} -> {new_image}")
        elif event_name == 'REMOVE':
            old_image = record['dynamodb']['OldImage']
            print(f"Item removido: {old_image}")
    
    return {'status': 'success'}
```

### 2. Via Kinesis Client Library (KCL)

```python
# Exemplo: Consumir stream com KCL
from amazon_kclpy import kcl

class RecordProcessor:
    def process_record(self, record):
        # Processar registro do stream
        data = json.loads(record['data'])
        print(f"Processando: {data}")
    
    def shutdown(self, shutdown_input):
        # Limpeza ao encerrar
        print("Encerrando processador")

# Configurar KCL
processor = RecordProcessor()
kcl.process(processor)
```

### 3. Via AWS SDK

```python
# Exemplo: Consumir stream com boto3
import boto3

dynamodb = boto3.client('dynamodbstreams')

# Obter stream ARN
response = dynamodb.describe_table(
    TableName='Orders'
)
stream_arn = response['Table']['LatestStreamArn']

# Obter shards
response = dynamodb.describe_stream(
    StreamArn=stream_arn
)

shards = response['StreamDescription']['Shards']

# Consumir registros
for shard in shards:
    shard_iterator = dynamodb.get_shard_iterator(
        StreamArn=stream_arn,
        ShardId=shard['ShardId'],
        ShardIteratorType='TRIM_HORIZON'
    )['ShardIterator']
    
    records = dynamodb.get_records(
        ShardIterator=shard_iterator
    )['Records']
    
    for record in records:
        print(f"Registro: {record}")
```

## Casos de Uso

### 1. Sincronização de Dados

```python
# Sincronizar dados com outro sistema
def sync_to_elasticsearch(record):
    """Sincroniza item com Elasticsearch"""
    if record['eventName'] == 'INSERT':
        es.index(index='orders', id=record['dynamodb']['Keys']['order_id']['S'])
    elif record['eventName'] == 'MODIFY':
        es.update(index='orders', id=record['dynamodb']['Keys']['order_id']['S'])
    elif record['eventName'] == 'REMOVE':
        es.delete(index='orders', id=record['dynamodb']['Keys']['order_id']['S'])
```

### 2. Auditoria

```python
# Registrar mudanças para auditoria
def audit_log(record):
    """Registra mudança em log de auditoria"""
    audit_table.put_item(Item={
        'timestamp': datetime.utcnow().isoformat(),
        'operation': record['eventName'],
        'table': 'Orders',
        'item_id': record['dynamodb']['Keys']['order_id']['S'],
        'old_value': record['dynamodb'].get('OldImage'),
        'new_value': record['dynamodb'].get('NewImage')
    })
```

### 3. Notificações

```python
# Enviar notificações sobre mudanças
def send_notification(record):
    """Envia notificação sobre mudança"""
    if record['eventName'] == 'INSERT':
        sns.publish(
            TopicArn='arn:aws:sns:...',
            Message=f"Novo pedido: {record['dynamodb']['NewImage']}"
        )
```

## Melhores Práticas

### 1. Escolher View Type Adequado

```yaml
# Escolher baseado no uso

# KEYS_ONLY: Quando apenas precisa da chave
stream_view_type: KEYS_ONLY

# NEW_IMAGE: Quando precisa do novo item
stream_view_type: NEW_IMAGE

# OLD_IMAGE: Quando precisa do item antigo (auditoria)
stream_view_type: OLD_IMAGE

# NEW_AND_OLD_IMAGES: Quando precisa de ambos
stream_view_type: NEW_AND_OLD_IMAGES
```

### 2. Processamento Idempotente

```python
# Garantir processamento idempotente
def process_record(record):
    """Processa registro de forma idempotente"""
    record_id = record['eventID']
    
    # Verificar se já processou
    if already_processed(record_id):
        return
    
    # Processar
    process_change(record)
    
    # Marcar como processado
    mark_as_processed(record_id)
```

### 3. Tratamento de Erros

```python
# Tratar erros adequadamente
def lambda_handler(event, context):
    for record in event['Records']:
        try:
            process_record(record)
        except Exception as e:
            print(f"Erro ao processar: {e}")
            # Enviar para DLQ ou retry
            continue
```

## Exemplo Prático

### Sincronização com Elasticsearch

```python
# Exemplo: Sincronizar DynamoDB com Elasticsearch
import boto3
import json

dynamodb = boto3.client('dynamodbstreams')
es = Elasticsearch(['http://localhost:9200'])

def lambda_handler(event, context):
    for record in event['Records']:
        event_name = record['eventName']
        
        if event_name == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            es.index(
                index='orders',
                id=new_image['order_id']['S'],
                body=new_image
            )
        elif event_name == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            es.update(
                index='orders',
                id=new_image['order_id']['S'],
                body={'doc': new_image}
            )
        elif event_name == 'REMOVE':
            old_image = record['dynamodb']['OldImage']
            es.delete(
                index='orders',
                id=old_image['order_id']['S']
            )
    
    return {'status': 'success'}
```

## Limitações

### 1. Retenção Limitada

```text
- Máximo de 7 dias de retenção
- Após retenção, dados são perdidos
- Não pode ser estendido além de 7 dias
```

### 2. Ordem de Processamento

```python
# Registros são ordenados por shard
# Não há garantia de ordem entre shards
# Requer coordenação para ordem global
```

### 3. Custo Adicional

```yaml
# Custos adicionais:
# - Custo por GB de dados no stream
# - Custo de leitura do stream
# - Custo de processamento (Lambda, etc.)
```

## Trade-offs

### KEYS_ONLY vs NEW_AND_OLD_IMAGES

- **KEYS_ONLY**: Menor custo, menos informação
- **NEW_AND_OLD_IMAGES**: Maior custo, máxima informação
- **Escolha**: KEYS_ONLY para simples, NEW_AND_OLD para completo

### Stream vs Polling

- **Stream**: Tempo real, evento-driven, mais complexo
- **Polling**: Simples, não real-time, mais overhead
- **Escolha**: Stream para real-time, polling para batch

### Lambda vs Custom Consumer

- **Lambda**: Gerenciado, simples, limitações
- **Custom**: Flexível, mais controle, mais complexo
- **Escolha**: Lambda para simples, custom para avançado

### _Links_

- <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html>
- <https://docs.aws.amazon.com/lambda/latest/dg/with-ddb.html>
- <https://aws.amazon.com/blogs/database/cross-region-replication-with-amazon-dynamodb-streams/>
