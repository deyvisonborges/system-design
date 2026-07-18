# WiredTiger

WiredTiger é o storage engine padrão do MongoDB desde a versão 3.2, proporcionando melhor performance, compressão de dados e suporte a transações ACID em nível de documento.

## Definição

WiredTiger é o storage engine do MongoDB que gerencia como dados são armazenados em disco e em memória, proporcionando compressão, checkpoints e suporte a transações.

```text
WiredTiger = Storage engine + Compressão + Transações
```

## Como Funciona

### 1. Arquitetura

```text
- Document-level locking: Bloqueio em nível de documento
- Compression: Compressão de dados (snappy, zlib, zstd)
- Checkpoints: Pontos de recuperação consistentes
- Journal: Log de transações para recuperação
```

### 2. Cache

```text
- WiredTiger Cache: Cache em memória para dados
- Evita I/O de disco frequente
- Configurável (wiredTigerCacheSizeGB)
- Gerenciado automaticamente
```

### 3. Compressão

```text
- Snappy: Compressão rápida, menor compressão (padrão)
- Zlib: Compressão maior, mais lento
- Zstd: Compressão moderna, balanceada
- Aplicável a coleções e índices
```

## Configuração

### 1. Configurar Cache

```javascript
// Configurar tamanho do cache (mongod.conf)
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 4
```

### 2. Configurar Compressão

```javascript
// Configurar compressão de coleção
db.createCollection("mycollection", {
  storageEngine: {
    wiredTiger: {
      configString: "block_compressor=snappy"
    }
  }
})

// Configurar compressão de índice
db.collection.createIndex(
  { field: 1 },
  { storageEngine: { wiredTiger: { configString: "block_compressor=snappy" } } }
)
```

### 3. Configurar Journal

```javascript
// Configurar journal (mongod.conf)
storage:
  journal:
    enabled: true
    commitIntervalMs: 100
```

## Exemplo Prático

### Criar Coleção com Compressão

```javascript
// Criar coleção com compressão snappy
db.createCollection("logs", {
  storageEngine: {
    wiredTiger: {
      configString: "block_compressor=snappy"
    }
  }
})

// Criar coleção com compressão zlib
db.createCollection("archive", {
  storageEngine: {
    wiredTiger: {
      configString: "block_compressor=zlib"
    }
  }
})
```

### Verificar Estatísticas

```javascript
// Verificar estatísticas do WiredTiger
db.serverStatus().wiredTiger

// Verificar cache
db.serverStatus().wiredTiger.cache

// Verificar compressão
db.collection.stats()
```

## Vantagens

### 1. Performance

```text
- Document-level locking
- Melhor concorrência
- Cache eficiente
```

### 2. Compressão

```text
- Economia de espaço em disco
- Menos I/O de disco
- Opções de compressão configuráveis
```

### 3. Transações

```text
- Suporte a transações ACID
- Journal para recuperação
- Checkpoints consistentes
```

## Limitações

### 1. Memória

```text
- Requer memória adequada
- Cache pode ser grande
- Pode impactar performance se insuficiente
```

### 2. CPU

```text
- Compressão consome CPU
- Pode impactar performance
- Requer balanceamento
```

### 3. Complexidade

```text
- Configuração adicional
- Requer tuning
- Mais parâmetros para gerenciar
```

## Melhores Práticas

### 1. Configurar Cache Adequadamente

```javascript
// Configurar cache para 50% da RAM (recomendado)
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 8  // Para servidor com 16GB RAM
```

### 2. Escolher Compressão Adequada

```javascript
// Para dados ativos: snappy (rápido)
db.createCollection("active_data", {
  storageEngine: {
    wiredTiger: {
      configString: "block_compressor=snappy"
    }
  }
})

// Para dados de arquivo: zlib (maior compressão)
db.createCollection("archive", {
  storageEngine: {
    wiredTiger: {
      configString: "block_compressor=zlib"
    }
  }
})
```

### 3. Configurar Journal Adequadamente

```javascript
// Para produção: journal habilitado
storage:
  journal:
    enabled: true
    commitIntervalMs: 100

// Para desenvolvimento: journal desabilitado (mais rápido)
storage:
  journal:
    enabled: false
```

### 4. Monitorar WiredTiger

```javascript
// Verificar estatísticas regularmente
db.serverStatus().wiredTiger

// Verificar cache hit ratio
db.serverStatus().wiredTiger.cache

// Verificar compressão
db.collection.stats()
```

## Trade-offs

### Snappy vs Zlib vs Zstd

- **Snappy**: Rápido, menor compressão (padrão)
- **Zlib**: Mais compressão, mais lento
- **Zstd**: Balanceado, moderno
- **Escolha**: Snappy para geral, zlib/zstd para arquivo

### Journal Habilitado vs Desabilitado

- **Habilitado**: Durabilidade, mais lento
- **Desabilitado**: Mais rápido, menos durável
- **Escolha**: Habilitado para produção, desabilitado para desenvolvimento

### Cache Grande vs Pequeno

- **Grande**: Mais cache hit, mais memória
- **Pequeno**: Menos memória, mais I/O
- **Escolha**: 50% da RAM para geral

### _Links_

- <https://www.mongodb.com/docs/manual/core/wiredtiger/>
- <https://www.mongodb.com/docs/manual/administration/production-notes/>
- <https://www.mongodb.com/docs/manual/reference/configuration-options/>
