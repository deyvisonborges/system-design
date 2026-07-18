# Mapping

Mapping (mapeamento) é o processo de definir como documentos e seus campos são armazenados e indexados no Elasticsearch, especificando tipos de dados, analisadores e outras configurações para cada campo.

## Definição

Mapping define a estrutura de um índice do Elasticsearch, especificando o tipo de cada campo, como ele deve ser analisado e indexado, e quais operações são permitidas.

```text
Mapping = Definição de estrutura + Tipos de dados + Analyzers
```

## Tipos de Dados

### 1. Tipos Principais

```json
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      },
      "status": {
        "type": "keyword"
      },
      "price": {
        "type": "double"
      },
      "created_at": {
        "type": "date"
      },
      "is_active": {
        "type": "boolean"
      },
      "location": {
        "type": "geo_point"
      }
    }
  }
}
```

### 2. Text vs Keyword

```json
// Text: Analisado, buscável, não agregável
{
  "title": {
    "type": "text",
    "analyzer": "standard"
  }
}

// Keyword: Não analisado, exato, agregável
{
  "status": {
    "type": "keyword"
  }
}

// Ambos: Texto para busca, keyword para agregações
{
  "title": {
    "type": "text",
    "fields": {
      "keyword": {
        "type": "keyword",
        "ignore_above": 256
      }
    }
  }
}
```

### 3. Tipos Numéricos

```json
{
  "price": {
    "type": "double"
  },
  "quantity": {
    "type": "integer"
  },
  "rating": {
    "type": "float"
  },
  "count": {
    "type": "long"
  }
}
```

### 4. Tipos de Data

```json
{
  "created_at": {
    "type": "date",
    "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
  }
}
```

## Configurações de Mapping

### 1. Analyzer

```json
{
  "title": {
    "type": "text",
    "analyzer": "standard",
    "search_analyzer": "standard"
  }
}
```

### 2. Norms

```json
{
  "content": {
    "type": "text",
    "norms": false
  }
}
// Desabilita norms para economizar espaço
// Norms são usados para scoring
```

### 3. Index

```json
{
  "description": {
    "type": "text",
    "index": false
  }
}
// Campo não é indexado (não buscável)
// Mas pode ser recuperado
```

### 4. Doc Values

```json
{
  "status": {
    "type": "keyword",
    "doc_values": false
  }
}
// Desabilita doc_values para economizar espaço
// Doc_values são usados para agregações/sorting
```

## Exemplo Prático

### Mapping Completo

```json
PUT /products
{
  "mappings": {
    "properties": {
      "id": {
        "type": "keyword"
      },
      "title": {
        "type": "text",
        "analyzer": "standard",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "description": {
        "type": "text",
        "analyzer": "portuguese"
      },
      "price": {
        "type": "double"
      },
      "quantity": {
        "type": "integer"
      },
      "status": {
        "type": "keyword"
      },
      "category": {
        "type": "keyword"
      },
      "tags": {
        "type": "keyword"
      },
      "created_at": {
        "type": "date",
        "format": "yyyy-MM-dd HH:mm:ss||epoch_millis"
      },
      "updated_at": {
        "type": "date",
        "format": "yyyy-MM-dd HH:mm:ss||epoch_millis"
      },
      "location": {
        "type": "geo_point"
      }
    }
  }
}
```

### Dynamic Mapping

```json
// Dynamic mapping automático
POST /products/_doc/1
{
  "title": "Product 1",
  "price": 100.00,
  "new_field": "value"
}
// Elasticsearch infere o tipo de new_field

// Desabilitar dynamic mapping
PUT /products
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "title": {
        "type": "text"
      }
    }
  }
}
// Erro ao tentar indexar campo não mapeado
```

## Vantagens

### 1. Controle de Estrutura

```text
- Define estrutura explícita
- Evita erros de tipo
- Melhor performance
```

### 2. Otimização de Busca

```text
- Analyzers específicos por campo
- Tipos otimizados para uso
- Melhor relevância
```

### 3. Economia de Espaço

```text
- Desabilitar features não usadas
- Doc values, norms, index
- Menor tamanho de índice
```

## Limitações

### 1. Imutabilidade

```text
- Mapping não pode ser alterado
- Exceto novos campos
- Requer reindexação para mudanças
```

### 2. Complexidade

```text
- Requer planejamento
- Mais complexo que schema-less
- Curva de aprendizado
```

### 3. Overhead

```text
- Mapping ocupa espaço
- Mais overhead que schema-less
- Requer gerenciamento
```

## Melhores Práticas

### 1. Definir Mapping Antecipadamente

```json
// Criar índice com mapping explícito
PUT /products
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      }
    }
  }
}
```

### 2. Usar Text e Keyword

```json
// Para campos que precisam de busca e agregação
{
  "title": {
    "type": "text",
    "fields": {
      "keyword": {
        "type": "keyword"
      }
    }
  }
}
```

### 3. Configurar Dynamic Mapping

```json
// Em produção, usar dynamic: strict
{
  "mappings": {
    "dynamic": "strict"
  }
}

// Ou dynamic: false (ignora campos desconhecidos)
{
  "mappings": {
    "dynamic": false
  }
}
```

### 4. Otimizar para Uso

```json
// Desabilitar features não usadas
{
  "description": {
    "type": "text",
    "norms": false,
    "index": true
  }
}
```

## Trade-offs

### Explicit vs Dynamic Mapping

- **Explicit**: Controle total, mais complexo
- **Dynamic**: Automático, menos controle
- **Escolha**: Explicit para produção, dynamic para desenvolvimento

### Text vs Keyword

- **Text**: Buscável, não agregável
- **Keyword**: Agregável, busca exata
- **Escolha**: Text para busca, keyword para filtros/agregações

### Single Field vs Multi Field

- **Single**: Simples, menos espaço
- **Multi**: Flexível, mais espaço
- **Escolha**: Multi para campos usados em busca e agregação

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-mapping.html>
