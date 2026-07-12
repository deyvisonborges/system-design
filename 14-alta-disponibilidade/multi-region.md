# Multi-região (Multi-region)

Arquiteturas multi-região visam alta disponibilidade geográfica, tolerância a desastres e proximidade ao usuário para menor latência.

Modelos operacionais:

- Active-active multi-region: todas as regiões atendem tráfego; melhora latência e tolerância, requer sincronização e resolução de conflitos.
- Active-passive multi-region: região secundária standby, recebe tráfego apenas após failover; mais simples, RPO/RTO dependem da replicação.

Considerações de dados:

- Replicação: assíncrona reduz latência, porém aumenta RPO; síncrona garante consistência, mas impacta latência e disponibilidade.
- Conflicts: multi-master exige estratégias de resolução (CRDTs, last-write-wins, application-specific reconciliation).

Direcionamento de tráfego e DNS:

- GeoDNS / Anycast / Global Load Balancer para rotear usuários à região mais próxima.
- Use health checks de ponta a ponta antes de incluir uma região no pool.

Compliance e custos:

- Requisitos legais de residência de dados podem limitar replicação entre regiões.
- Custos aumentam com replicação cross-region e largura de banda.

DR e exercícios:

- Defina runbooks de DR, RTO/RPO por serviço.
- Execute drills de failover regional e failback.

Checklist rápido:

- Classifique dados por criticidade e escolha estratégia de replicação por classe.
- Planeje routing, caches e invalidações cross-region.
- Monitoramento e queres de integridade por região.
