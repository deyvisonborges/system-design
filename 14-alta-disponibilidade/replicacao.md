# Replicação

Replicação é a cópia de dados entre nós para disponibilidade, tolerância a falhas e desempenho de leitura.

Modos de replicação:

- Síncrona: gravações aguardam confirmação dos replicantes — RPO baixo, latência mais alta.
- Assíncrona: gravação retorna antes da confirmação — menor latência, risco de perda de dados.
- Semissíncrona: combina aspectos dos dois (aguarda confirmação parcial).

Topologias:

- Master-slave / leader-follower: um líder aceita writes; réplicas servem reads.
- Multi-master: múltiplos nós aceitam writes; requer resolução de conflitos.
- Chain replication: encadeamento de réplicas para garantir ordem e durabilidade.

Problemas e mitigação:

- Lag de replicação: monitorar lag e aplicar backpressure em writes críticos.
- Conflicts em multi-master: usar CRDTs, reconciliation, ou constraints de aplicação.
- Re-sincronização: estratégias para reintroduzir réplicas (snapshot + binlog, incremental).

Boas práticas:

- Clasifique dados por prioridade e escolha modo de replicação apropriado.
- Monitore lag, taxa de replicação e integridade.
- Teste failover e recovery de réplicas regularmente.
