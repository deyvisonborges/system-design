# Analyzer

Analyzer (analisador) é um componente do Elasticsearch que processa texto antes da indexação e da busca, transformando o texto em tokens que são armazenados no índice invertido. É composto por um tokenizer e zero ou mais filtros.

## Definição

Analyzer é uma pipeline de processamento que converte texto em tokens, aplicando normalização, tokenização e filtragem para permitir buscas eficientes e flexíveis.

```text
Analyzer = Tokenizer + Char Filters + Token Filters
```

## Componentes do Analyzer

### 1. Character Filters

```text
- Pré-processamento do texto antes da tokenização
- Exemplos: HTML stripping, character replacement
- Executados na ordem especificada
```

### 2. Tokenizer

```text
- Divide o texto em tokens (palavras)
- Exemplos: whitespace, standard, pattern
- Obrigatório no analyzer
```

### 3. Token Filters

```text
- Pós-processamento dos tokens
- Exemplos: lowercase, stop words, stemming
- Executados na ordem especificada
```

## Tipos de Analyzers

### 1. Standard Analyzer

```json
// Analyzer padrão do Elasticsearch
{
  "analyzer": "standard",
  "type": "standard",
  "tokenizer": "standard",
  "filter": [
    "lowercase",
    "stop"
  ]
}

// Uso:
// Divide em palavras, converte para minúsculas, remove stop words
```

### 2. Simple Analyzer

```json
// Divide por não-letras, converte para minúsculas
{
  "analyzer": "simple",
  "type": "simple",
  "tokenizer": "lowercase"
}

// Uso:
// "Hello World" → ["hello", "world"]
```

### 3. Whitespace Analyzer

```json
// Divide apenas por whitespace
{
  "analyzer": "whitespace",
  "type": "whitespace",
  "tokenizer": "whitespace"
}

// Uso:
// "Hello World" → ["Hello", "World"]
```

### 4. Keyword Analyzer

```json
// Não tokeniza, retorna o texto como único token
{
  "analyzer": "keyword",
  "type": "keyword",
  "tokenizer": "keyword"
}

// Uso:
// "Hello World" → ["Hello World"]
```

### 5. Pattern Analyzer

```json
// Usa regex para tokenizar
{
  "analyzer": "pattern",
  "type": "pattern",
  "tokenizer": "pattern",
  "filter": ["lowercase"],
  "pattern": "\\W+"
}

// Uso:
// Divide por não-palavras
```

### 6. Language Analyzers

```json
// Analyzers específicos para idiomas
{
  "analyzer": "english",
  "type": "english",
  "tokenizer": "standard",
  "filter": [
    "english_stop",
    "lowercase",
    "english_stemmer"
  ]
}

// Uso:
// Stemming e stop words específicos do inglês
```

## Custom Analyzers

### 1. Criar Custom Analyzer

```json
PUT /my_index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter": ["html_strip"],
          "filter": ["lowercase", "my_stop_words"]
        },
        "filter": {
          "my_stop_words": {
            "type": "stop",
            "stopwords": ["and", "or", "the"]
          }
        }
      }
    }
  }
}
```

### 2. Usar Custom Analyzer

```json
PUT /my_index/_mapping
{
  "properties": {
    "content": {
      "type": "text",
      "analyzer": "my_custom_analyzer"
    }
  }
}
```

### 3. Testar Analyzer

```json
POST /my_index/_analyze
{
  "analyzer": "my_custom_analyzer",
  "text": "Hello World, this is a test"
}

// Resposta:
{
  "tokens": [
    {"token": "hello"},
    {"token": "world"},
    {"token": "test"}
  ]
}
```

## Character Filters

### 1. HTML Strip

```json
{
  "char_filter": "html_strip"
}

// Remove tags HTML
// "<p>Hello</p>" → "Hello"
```

### 2. Mapping

```json
{
  "char_filter": {
    "my_mapping": {
      "type": "mapping",
      "mappings": [
        "– => -",
        "’ => '"
      ]
    }
  }
}

// Substitui caracteres
```

### 3. Pattern Replace

```json
{
  "char_filter": {
    "my_pattern": {
      "type": "pattern_replace",
      "pattern": "(\\d+)-(?=\\d)",
      "replacement": "$1"
    }
  }
}

// Substitui por padrão regex
```

## Tokenizers

### 1. Standard Tokenizer

```json
{
  "tokenizer": "standard"
}

// Divide por pontuação e whitespace
// "Hello, World!" → ["Hello", "World"]
```

### 2. Whitespace Tokenizer

```json
{
  "tokenizer": "whitespace"
}

// Divide apenas por whitespace
// "Hello, World!" → ["Hello,", "World!"]
```

### 3. Letter Tokenizer

```json
{
  "tokenizer": "letter"
}

// Divide por não-letras
// "Hello123World" → ["Hello", "World"]
```

### 4. Lowercase Tokenizer

```json
{
  "tokenizer": "lowercase"
}

// Divide por não-letras e converte para minúsculas
// "Hello World" → ["hello", "world"]
```

### 5. N-Gram Tokenizer

```json
{
  "tokenizer": {
    "my_ngram": {
      "type": "ngram",
      "min_gram": 2,
      "max_gram": 3
    }
  }
}

// Cria n-grams
// "Hello" → ["He", "Hel", "el", "ell", "ll", "lo"]
```

## Token Filters

### 1. Lowercase Filter

```json
{
  "filter": "lowercase"
}

// Converte tokens para minúsculas
// "Hello" → "hello"
```

### 2. Stop Filter

```json
{
  "filter": {
    "my_stop": {
      "type": "stop",
      "stopwords": ["and", "or", "the"]
    }
  }
}

// Remove stop words
```

### 3. Stemmer Filter

```json
{
  "filter": {
    "my_stemmer": {
      "type": "stemmer",
      "language": "english"
    }
  }
}

// Aplica stemming
// "running" → "run"
```

### 4. Synonym Filter

```json
{
  "filter": {
    "my_synonyms": {
      "type": "synonym",
      "synonyms": [
        "laptop, notebook",
        "tv, television"
      ]
    }
  }
}

// Expande com sinônimos
```

### 5. Snowball Filter

```json
{
  "filter": {
    "my_snowball": {
      "type": "snowball",
      "language": "Portuguese"
    }
  }
}

// Stemming mais agressivo
```

## Exemplo Prático

### Analyzer para Busca em Português

```json
PUT /products
{
  "settings": {
    "analysis": {
      "analyzer": {
        "portuguese_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter": ["html_strip"],
          "filter": [
            "lowercase",
            "portuguese_stop",
            "portuguese_stemmer",
            "asciifolding"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "portuguese_analyzer"
      },
      "description": {
        "type": "text",
        "analyzer": "portuguese_analyzer"
      }
    }
  }
}
```

### Analyzer para Códigos de Produto

```json
PUT /products
{
  "settings": {
    "analysis": {
      "analyzer": {
        "product_code_analyzer": {
          "type": "custom",
          "tokenizer": "pattern",
          "filter": ["lowercase"],
          "pattern": "[^-]+"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "product_code": {
        "type": "text",
        "analyzer": "product_code_analyzer"
      }
    }
  }
}

// "PROD-123-ABC" → ["prod", "123", "abc"]
```

## Melhores Práticas

### 1. Escolher Analyzer Adequado

```json
// Para texto natural: standard ou language analyzer
{
  "analyzer": "english"
}

// Para códigos/IDs: keyword ou pattern
{
  "analyzer": "keyword"
}

// Para email/nomes: simple ou whitespace
{
  "analyzer": "simple"
}
```

### 2. Testar Analyzer

```json
// Sempre testar antes de usar em produção
POST /_analyze
{
  "analyzer": "my_analyzer",
  "text": "Texto de teste"
}
```

### 3. Usar Analyzer Diferente para Busca

```json
{
  "properties": {
    "content": {
      "type": "text",
      "analyzer": "standard",
      "search_analyzer": "simple"
    }
  }
}

// Indexação: mais processamento
// Busca: menos processamento
```

## Trade-offs

### Standard vs Keyword

- **Standard**: Tokeniza, permite busca parcial, mais overhead
- **Keyword**: Não tokeniza, busca exata, mais rápido
- **Escolha**: Standard para texto, keyword para IDs/códigos

### Custom vs Built-in

- **Custom**: Flexível, otimizado, mais complexo
- **Built-in**: Simples, testado, menos flexível
- **Escolha**: Built-in para casos comuns, custom para específicos

### Stemming vs Não Stemming

- **Stemming**: Mais resultados, menos precisão, mais overhead
- **Não stemming**: Mais preciso, menos resultados, mais rápido
- **Escolha**: Stemming para busca ampla, sem stemming para precisa

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-analyzers.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenizers.html>
