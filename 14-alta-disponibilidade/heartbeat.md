# Heartbeat (sinal de vida)

Heartbeat é um sinal periódico emitido por um componente para indicar que está operacional. Serve como base para detecção de falhas, timeouts e para coordenadores decidirem sobre failover ou manutenção.

Boas práticas:

- Intervalo: escolha um intervalo compatível com o SLA (ex.: 1s–30s). Curto demais aumenta overhead; longo demais aumenta RTO.
- TTL e tolerância: use janelas (ex.: considerar falha após N heartbeats perdidos) e adicione jitter para evitar sincronização acidental.
- Conteúdo do heartbeat: inclua timestamp, status resumido, carga (CPU/mem), versão do binário e métricas de saúde relevantes.

Implementação:

- Push: agente envia heartbeat para um coordenador/monitor.
- Pull: coordenador consulta periodicamente os nós.
- Storage: heartbeats podem ser registrados em store leve (etcd, Redis with expirations) usando TTLs.

Considerações:

- Segurança: autenticar e validar mensagens de heartbeat para evitar spoofing.
- Rede intermitente: diferenciar perda de conectividade temporária de falha do processo.
- Escalabilidade: agrupe ou amostre heartbeats em grandes clusters para reduzir carga no coordenador.

Exemplo (pseudocódigo):

```pseudo
loop every interval + jitter:
 status = collectHealth()
 sendHeartbeat({id, timestamp, status})
```

Checklist rápido:

- Definir intervalos e thresholds compatíveis com RTO.
- Instrumentar métricas no heartbeat.
- Testar perda de heartbeats e comportamento de failover.
