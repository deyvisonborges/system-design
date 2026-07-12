# Failover

Failover é o processo de transferir automaticamente (ou manualmente) cargas e serviços de uma instância ou região com falha para outra saudável, minimizando o tempo de inatividade.

Principais padrões:

- Active-passive: um ou mais nós standby recebem o tráfego somente após falha do primário. Simples, menor complexidade, RTO depende do tempo de detecção e comutação.
- Active-active: múltiplas réplicas atendem tráfego simultaneamente. Melhora capacidade e tolerância a falhas, mas complica consistência e coordenação.
- Gradual failover: redirecionamento por etapas (ex.: desviar 10% → 100%) para reduzir risco de comportamento incorreto.

Detecção e acionadores:

- Health checks (HTTP, TCP, gRPC) com thresholds e janelas de falha.
- Heartbeats e TTL em sistemas de coordenação.
- Métricas e alertas (latência, erros, saturação) que disparam failover planejado.

Tipos de failover:

- Automático: reduz RTO, exige alta confiança nos checks e na infraestrutura.
- Manual / assistido: seguro para mudanças de estado complexas (migração de dados, upgrade), reduz risco de failover incorreto.

Considerações de dados e estado:

- Consistência: decidir entre síncrono (menor perda de dados) e assíncrono (menor latência) na replicação.
- Idempotência: operações precisam ser idempotentes para evitar duplicação após retry/failover.
- Outbox / transactional outbox: garantir delivery de mensagens durante failover.

Problemas comuns:

- Split brain: dois nós assumem ser primário — mitigar com quorum e fencing (leases, tokens).
- Failover flapping: comutações repetidas por thresholds agressivos — mitigar com backoff e janelas maiores.
- Perda de sessão/stateful: prefira sessão externalizada (sticky sessions com replicação ou store central).

Checklist de boas práticas:

- Defina SLAs, RTO e RPO claramente.
- Teste failover periodicamente (chaos engineering, drills).
- Use health checks adequados e thresholds com jitter.
- Garanta observabilidade (traces, logs, métricas) durante failover.
- Planeje rollback e verificação pós-failover (consistência de dados, integridade).

Referências rápidas:

- Fencing (leases/tokens), transactional outbox, circuit breakers, health-check design.
