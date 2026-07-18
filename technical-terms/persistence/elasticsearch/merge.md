# Merge

Merge (mesclagem) é o processo do Elasticsearch de combinar múltiplos segmentos menores em segmentos maiores, reduzindo o número de segmentos e melhorando a performance de busca e o uso de recursos.

## Definição

Merge é o processo de combinar segmentos menores em segmentos maiores para reduzir o número de segmentos, melhorando a performance de busca e reduzindo o uso de recursos como file descriptors e memória.

```text
Merge = Segmentos pequenos → Segmentos grandes
```

## Como Funciona

### 1. Processo de Merge

```text
1. Múltiplos segmentos são identificados para merge
2. Segmentos são lidos e combinados
3. Novo segmento maior é criado
4. Segmentos antigos são deletados
5. Sistema é atualizado
```

### 2. Tipos de Merge

```text
- Merge automático: Executado pelo Elasticsearch automaticamente
- Merge forçado: Executado manualmente via API
- Merge de segmentos específicos: Merge de segmentos selecionados
```

### 3. Política de Merge

```text
- Tiered merge: Merge em camadas (padrão)
- Log byte size merge: Merge baseado em tamanho
- Log doc merge: Merge baseado em número de documentos
```

## Configuração de Merge

### 1. Merge Policy

```json
PUT /my_index/_settings
{
  "index.merge.policy": {
    "type": "tiered"
  }
}
```

### 2. Merge Scheduler

```json
PUT /my_index/_settings
{
  "index.merge.scheduler.max_thread_count": 4
}
```

### 3. Segmentos por Merge

```json
PUT /my_index/_settings
{
  "index.merge.policy.max_merge_at_once": 10,
  "index.merge.policy.segments_per_tier": 10
}
```

## Vantagens

### 1. Menos Segmentos

```text
- Menos file descriptors
- Menos uso de memória
- Melhor performance de busca
```

### 2. Melhor Performance

```text
- Menos segmentos para buscar
- Menos overhead de merge
- Melhor cache hit rate
```

### 3. Economia de Recursos

```text
- Menos file descriptors
- Menos memória
- Menos I/O
```

## Limitações

### 1. Custo de Merge

```text
- Merge consome CPU e I/O
- Pode impactar performance
- Requer recursos adicionais
```

### 2. Latência de Merge

```text
- Merge pode ser lento
- Documentos podem não estar disponíveis durante merge
- Pode impactar latência de indexação
```

### 3. Complexidade

```text
- Configuração complexa
- Requer tuning
- Difícil de prever comportamento
```

## Melhores Práticas

### 1. Configurar Merge Policy Adequadamente

```json
PUT /my_index/_settings
{
  "index.merge.policy.type": "tiered",
  "index.merge.policy.max_merge_at_once": 10,
  "index.merge.policy.segments_per_tier": 10
}
```

### 2. Monitorar Merge Activity

```json
GET /_cat/segments/my_index?v
GET /_nodes/stats/indices?filter_path=**.merges
```

### 3. Usar Force Merge com Cuidado

```json
// Force merge para reduzir segmentos
POST /my_index/_forcemerge?max_num_segments=1

// Use apenas em índices não ativos
// Evita em índices com escrita frequente
```

### 4. Configurar Merge Scheduler

```json
PUT /_cluster/settings
{
  "persistent": {
    "index.merge.scheduler.max_thread_count": 4
  }
}
```

## Trade-offs

### Merge Automático vs Manual

- **Automático**: Sem overhead manual, menos controle
- **Manual**: Controle total, mais overhead
- **Escolha**: Automático para geral, manual para manutenção

### Tiered vs Log Byte Size

- **Tiered**: Balanceado, padrão
- **Log byte size**: Mais agressivo, menos segmentos
- **Escolha**: Tiered para geral, log byte size para índices estáticos

### Force Merge vs Não Force Merge

- **Force merge**: Menos segmentos, custo alto
- **Não force merge**: Mais segmentos, custo baixo
- **Escolha**: Force merge para índices estáticos, não force para índices ativos

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-merge.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-merge-policy.html>
