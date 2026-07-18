# Inverted Index

Inverted Index (índice invertido) é uma estrutura de dados usada pelo Elasticsearch para permitir buscas eficientes de texto, mapeando termos para documentos que os contêm, ao contrário de índices tradicionais que mapeiam documentos para termos.

## Definição

Inverted Index é uma estrutura que mapeia cada termo único para a lista de documentos que contêm esse termo, permitindo buscas rápidas de texto completo.

```text
Inverted Index = Termo → Lista de Documentos
```

## Como Funciona

### 1. Estrutura do Índice

```text
Termo          →  Documentos
--------------------------------
"elasticsearch" →  [1, 3, 5, 7]
"search"        →  [1, 2, 3, 4, 5]
"database"      →  [2, 4, 6, 8]
"index"         →  [1, 3, 5, 7, 9]
```

### 2. Processo de Indexação

```text
1. Documento é recebido
2. Texto é analisado (tokenização, normalização)
3. Termos são extraídos
4. Índice invertido é atualizado
```

### 3. Processo de Busca

```text
1. Query é recebida
2. Query é analisada (tokenização, normalização)
3. Termos são buscados no índice
4. Documentos correspondentes são retornados
```

## Componentes do Inverted Index

### 1. Terms Dictionary

```text
- Estrutura ordenada de termos
- Similar a um dicionário
- Permite busca rápida de termos
- Armazenado em disco
```

### 2. Terms Index

```text
- Índice do terms dictionary
- FST (Finite State Transducer)
- Compacto e eficiente
- Armazenado em memória
```

### 3. Posting Lists

```text
- Lista de documentos para cada termo
- Contém document IDs e posições
- Comprimida para economizar espaço
- Armazenada em disco
```

## Exemplo Prático

### Indexação de Documentos

```json
// Documento 1
{
  "id": 1,
  "title": "Elasticsearch Guide",
  "content": "Learn Elasticsearch search engine"
}

// Documento 2
{
  "id": 2,
  "title": "Database Systems",
  "content": "Learn about database systems"
}

// Após indexação:
// "elasticsearch" → [1]
// "guide" → [1]
// "learn" → [1, 2]
// "search" → [1]
// "engine" → [1]
// "database" → [2]
// "systems" → [2]
// "about" → [2]
```

### Busca no Índice

```json
// Query: "elasticsearch search"
// 1. Analisar query: ["elasticsearch", "search"]
// 2. Buscar "elasticsearch": [1]
// 3. Buscar "search": [1]
// 4. Interseção: [1]
// 5. Retornar documento 1

// Query: "learn database"
// 1. Analisar query: ["learn", "database"]
// 2. Buscar "learn": [1, 2]
// 3. Buscar "database": [2]
// 4. Interseção: [2]
// 5. Retornar documento 2
```

## Vantagens

### 1. Busca Rápida

```text
- Busca O(1) para termos
- Não precisa ler todos os documentos
- Eficiente para grandes volumes
```

### 2. Busca de Texto Completo

```text
- Suporta busca de texto
- Stemming, stop words, sinônimos
- Busca aproximada (fuzzy)
```

### 3. Escalabilidade

```text
- Índice pode ser particionado (shards)
- Distribuído em múltiplos nós
- Escala horizontalmente
```

## Limitações

### 1. Espaço em Disco

```text
- Índice invertido ocupa espaço
- Pode ser maior que dados originais
- Requer gerenciamento
```

### 2. Custo de Indexação

```text
- Indexação é cara
- Requer processamento
- Pode impactar performance de escrita
```

### 3. Não Ideal para Todos os Tipos de Dados

```text
- Não ideal para dados numéricos
- Não ideal para dados estruturados
- Melhor para texto não estruturado
```

## Melhores Práticas

### 1. Escolher Analyzer Adequado

```json
// Para texto natural
{
  "analyzer": "standard"
}

// Para código/IDs
{
  "analyzer": "keyword"
}

// Para idiomas específicos
{
  "analyzer": "portuguese"
}
```

### 2. Usar Mappings Adequados

```json
// Definir tipos de campos
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "standard"
      },
      "status": {
        "type": "keyword"
      },
      "created_at": {
        "type": "date"
      }
    }
  }
}
```

### 3. Monitorar Tamanho do Índice

```json
// Verificar tamanho do índice
GET /my_index/_stats

// Monitorar crescimento
// Configurar ILM (Index Lifecycle Management)
```

### 4. Usar Synonyms

```json
// Configurar sinônimos
{
  "settings": {
    "analysis": {
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
  }
}
```

## Trade-offs

### Inverted Index vs Forward Index

- **Inverted**: Busca rápida, indexação cara
- **Forward**: Busca lenta, indexação barata
- **Escolha**: Inverted para busca, forward para recuperação de documento

### Text vs Keyword

- **Text**: Analisado, buscável, não agregável
- **Keyword**: Não analisado, exato, agregável
- **Escolha**: Text para busca, keyword para filtros/agregações

### Standard vs Custom Analyzer

- **Standard**: Simples, testado, menos flexível
- **Custom**: Flexível, otimizado, mais complexo
- **Escolha**: Standard para geral, custom para específico

### _Links_

- <https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/inverted-index.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html>
