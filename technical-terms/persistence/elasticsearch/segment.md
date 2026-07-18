# Segment

Segment é uma unidade imutável de armazenamento no Elasticsearch que contém documentos indexados. Segmentos são criados durante o refresh e combinados durante o merge.

## Definição

Segment é uma unidade imutável de armazenamento que contém documentos indexados e estruturas de busca (inverted index, stored fields, doc values). Segmentos são criados durante o refresh e combinados durante o merge.

```text
Segment = Unidade imutável + Inverted index + Stored fields
```

## Como Funciona

### 1. Criação de Segmentos

```text
1. Documentos são indexados
2. Refresh é executado
3. Novo segmento é criado na memória
4. Segmento é escrito no disco
5. Segmento fica disponível para busca
```

### 2. Estrutura do Segmento

```text
- Inverted index: Estrutura de busca
- Stored fields: Dados originais
- Doc values: Valores para agregações/sorting
- Norms: Metadados para scoring
- Term vectors: Informações de termos
```

### 3. Imutabilidade

```text
- Segmentos são imutáveis
- Não podem ser modificados
- Atualizações criam novos segmentos
- Deletions são marcadas (bitmaps)
```

## Vantagens

### 1. Imutabilidade

```text
- Não requer locks
- Cache eficiente
- Simples de gerenciar
```

### 2. Performance

```text
- Cache-friendly
- Acesso sequencial
- Compressão eficiente
```

### 3. Consistência

```text
- Segmentos são consistentes
- Não há corrupção parcial
- Fácil de recuperar
```

## Limitações

### 1. Custo de Atualização

```text
- Atualizações criam novos segmentos
- Deletions são marcadas, não removidas
- Requer merge para limpar
```

### 2. Muitos Segmentos

```text
- Muitos segmentos pequenos
- Overhead de file descriptors
- Requer merge
```

### 3. Espaço em Disco

```text
- Segmentos ocupam espaço
- Deletions não liberam espaço imediatamente
- Requer merge para liberar
```

## Melhores Práticas

### 1. Monitorar Número de Segmentos

```json
GET /_cat/segments/my_index?v
GET /_cat/indices/my_index?v&h=index,segments
```

### 2. Configurar Merge Policy

```json
PUT /my_index/_settings
{
  "index.merge.policy.type": "tiered",
  "index.merge.policy.max_merge_at_once": 10,
  "index.merge.policy.segments_per_tier": 10
}
```

### 3. Usar Force Merge para Índices Estáticos

```json
POST /my_index/_forcemerge?max_num_segments=1
```

### 4. Configurar Refresh Interval

```json
PUT /my_index/_settings
{
  "index.refresh_interval": "30s"
}
```

## Trade-offs

### Muitos Segmentos vs Poucos Segmentos

- **Muitos**: Mais overhead, mais flexível
- **Poucos**: Menos overhead, menos flexível
- **Escolha**: Merge para reduzir segmentos em índices estáticos

### Segmentos na Memória vs Disco

- **Memória**: Mais rápido, menos espaço
- **Disco**: Mais lento, mais espaço
- **Escolha**: Elasticsearch gerencia automaticamente

### Force Merge vs Merge Automático

- **Force merge**: Controle total, custo alto
- **Merge automático**: Sem overhead, menos controle
- **Escolha**: Force merge para índices estáticos, automático para geral

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-segment.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-merge.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html>
