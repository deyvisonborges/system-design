# Election

Election (eleição) é o processo do MongoDB de selecionar um nó primário em um replica set quando o primário atual falha ou se torna indisponível, garantindo alta disponibilidade e continuidade de operações.

## Definição

Election é o processo pelo qual os membros de um replica set elegem um novo nó primário quando o primário atual falha, usando um protocolo de consenso baseado em maioria.

```text
Election = Consenso + Maioria + Novo primário
```

## Como Funciona

### 1. Processo de Eleição

```text
1. Primário falha ou se torna indisponível
2. Réplica detecta falha do primário
3. Réplica inicia eleição
4. Membros elegíveis votam
5. Candidato com maioria vence
6. Novo primário assume
```

### 2. Membros Elegíveis

```text
- Membros com prioridade > 0
- Membros com dados mais recentes
- Membros conectados à maioria
- Membros sem tags de exclusão
```

### 3. Protocolo de Eleição

```text
- Baseado em maioria (quorum)
- Requer maioria de membros
- Evita split-brain
- Garante consistência
```

## Configuração

### 1. Prioridade de Membros

```javascript
// Configurar prioridade de membros
cfg = rs.conf()
cfg.members[0].priority = 2
cfg.members[1].priority = 1
cfg.members[2].priority = 1
rs.reconfig(cfg)
```

### 2. Tags de Eleição

```javascript
// Configurar tags para controle de eleição
cfg = rs.conf()
cfg.members[0].tags = { dc: "east", use: "primary" }
cfg.members[1].tags = { dc: "west", use: "secondary" }
rs.reconfig(cfg)
```

### 3. Timeout de Eleição

```javascript
// Configurar timeout de eleição
rs.reconfig(cfg, {
  settings: {
   electionTimeoutMillis: 10000
  }
})
```

## Vantagens

### 1. Alta Disponibilidade

```text
- Failover automático
- Recuperação rápida
- Continuidade de operações
```

### 2. Consistência

```text
- Protocolo de consenso
- Evita split-brain
- Garante um único primário
```

### 3. Flexibilidade

```text
- Prioridade configurável
- Tags para controle
- Timeout ajustável
```

## Limitações

### 1. Downtime

```text
- Downtime durante eleição
- Latência de failover
- Pode impactar aplicações
```

### 2. Requer Maioria

```text
- Requer maioria de membros
- Não pode eleger sem maioria
- Pode causar indisponibilidade
```

### 3. Complexidade

```text
- Configuração adicional
- Requer planejamento
- Troubleshooting mais complexo
```

## Melhores Práticas

### 1. Configurar Prioridade Adequadamente

```javascript
// Configurar prioridade para controlar eleição
cfg = rs.conf()
cfg.members[0].priority = 2  // Preferido para primário
cfg.members[1].priority = 1
cfg.members[2].priority = 0  // Nunca será primário
rs.reconfig(cfg)
```

### 2. Usar Tags para Controle de Localização

```javascript
// Configurar tags para preferência de localização
cfg = rs.conf()
cfg.members[0].tags = { dc: "east" }
cfg.members[1].tags = { dc: "east" }
cfg.members[2].tags = { dc: "west" }
rs.reconfig(cfg)
```

### 3. Monitorar Eleições

```javascript
// Verificar status do replica set
rs.status()

// Verificar logs de eleição
db.adminCommand({
  getLog: "global"
})
```

### 4. Configurar Timeout de Eleição Adequadamente

```javascript
// Ajustar timeout de eleição conforme necessário
rs.reconfig(cfg, {
  settings: {
    electionTimeoutMillis: 10000  // 10 segundos
  }
})
```

## Trade-offs

### Prioridade Alta vs Baixa

- **Alta**: Mais chance de ser primário, mais carga
- **Baixa**: Menos chance de ser primário, menos carga
- **Escolha**: Alta para nós robustos, baixa para nós de backup

### Tags vs Sem Tags

- **Com tags**: Controle granular, mais complexo
- **Sem tags**: Simples, menos controle
- **Escolha**: Tags para multi-DC, sem tags para single-DC

### Timeout Curto vs Longo

- **Curto**: Failover rápido, mais instável
- **Longo**: Failover lento, mais estável
- **Escolha**: Curto para produção crítica, longo para geral

### _Links_

- <https://www.mongodb.com/docs/manual/core/replica-set-elections/>
- <https://www.mongodb.com/docs/manual/core/replica-set-high-availability/>
- <https://www.mongodb.com/docs/manual/reference/replica-configuration/>
