# Refresh

Refresh (atualização) é o processo do Elasticsearch de tornar documentos recentemente indexados disponíveis para busca, movendo dados do transaction log para um novo segmento na memória.

## Definição

Refresh é o processo de tornar documentos recentemente indexados visíveis para busca, criando um novo segmento na memória a partir do transaction log.

```text
Refresh = Transaction log → Segmento na memória
```

## Como Funciona

### 1. Processo de Refresh

```text
1. Documento é indexado
2. Documento é escrito no transaction log
3. Refresh é executado (padrão: 1 segundo)
4. Novo segmento é criado na memória
5. Documento fica disponível para busca
```

### 2. Intervalo de Refresh

```text
- Padrão: 1 segundo
- Configurável por índice
- Pode ser desabilitado
- Pode ser executado manualmente
```

### 3. Near Real-time

```text
- Elasticsearch é near real-time
- Latência de ~1 segundo
- Devido ao refresh interval
- Não é real-time verdadeiro
```

## Configuração

### 1. Refresh Interval

```json
PUT /my_index/_settings
{
  "index.refresh_interval": "1s"
}
```

### 2. Desabilitar Refresh

```json
PUT /my_index/_settings
{
  "index.refresh_interval": "-1"
}
```

### 3. Refresh Manual

```json
POST /my_index/_refresh
```

## Vantagens

### 1. Near Real-time

```text
- Documentos disponíveis em ~1 segundo
- Adequado para maioria dos casos de uso
- Balance entre performance e latência
```

### 2. Performance

```text
- Refresh em memória é rápido
- Não requer I/O de disco
- Baixo overhead
```

### 3. Configurável

```text
- Intervalo configurável
- Pode ser ajustado por caso de uso
- Pode ser desabilitado para bulk operations
```

## Limitações

### 1. Não Real-time

```text
- Latência de até 1 segundo
- Não adequado para casos que requerem real-time
- Documentos podem não estar disponíveis imediatamente
```

### 2. Overhead

```text
- Refresh consome recursos
- Cria muitos segmentos pequenos
- Requer merge posterior
```

### 3. Consistência

```text
- Consistência eventual
- Documentos podem não estar visíveis
- Requer espera para consistência forte
```

## Melhores Práticas

### 1. Ajustar Refresh Interval por Caso de Uso

```json
// Para índices de log (menor latência)
PUT /logs/_settings
{
  "index.refresh_interval": "500ms"
}

// Para índices analíticos (maior latência)
PUT /analytics/_settings
{
  "index.refresh_interval": "30s"
}
```

### 2. Desabilitar Refresh para Bulk Operations

```json
// Desabilitar refresh durante bulk indexing
PUT /my_index/_settings
{
  "index.refresh_interval": "-1"
}

// Reabilitar após bulk
PUT /my_index/_settings
{
  "index.refresh_interval": "1s"
}
```

### 3. Usar Refresh Manual quando Necessário

```json
// Após bulk indexing
POST /my_index/_refresh
```

### 4. Monitorar Refresh Activity

```json
GET /_cat/indices/my_index?v&h=index,refresh
GET /_nodes/stats/indices?filter_path=**.refresh
```

## Trade-offs

### Refresh Rápido vs Lento

- **Rápido**: Menor latência, mais overhead
- **Lento**: Maior latência, menos overhead
- **Escolha**: Rápido para logs, lento para analíticos

### Refresh Automático vs Manual

- **Automático**: Sem overhead manual, menos controle
- **Manual**: Controle total, mais overhead
- **Escolha**: Automático para geral, manual para bulk operations

### Near Real-time vs Real-time

- **Near real-time**: ~1s latência, mais eficiente
- **Real-time**: 0s latência, menos eficiente
- **Escolha**: Near real-time para geral, real-time para casos específicos

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-refresh.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/near-real-time.html>
