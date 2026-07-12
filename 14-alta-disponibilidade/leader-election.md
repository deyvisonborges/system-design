# Eleição de Líder

Eleição de líder é o mecanismo pelo qual um conjunto de nós escolhe um coordenador primário para decisões que exigem autoridade única (ex.: escrever num particionamento, coordenar tarefas).

Algoritmos comuns:

- Bully algorithm: simples, baseado em identificadores; sensível a partições.
- Raft: algoritmo de consenso legível e amplamente adotado (etcd, Consul). Garante segurança e disponibilidade com quorum.
- Paxos: mais teórico e complexo; variantes como Multi-Paxos são usadas em sistemas distribuídos críticos.

Recomendações de projeto:

- Use algoritmos testados (ex.: Raft via etcd/zookeeper/consul) em vez de implementar do zero.
- Durável vs volátil: persistir logs de eleição quando necessário para evitar regressões durante reboots.
- Fencing: após eleição, use leases/tokens para impedir antigos líderes de fazerem operações (avoid split-brain).

Problemas a evitar:

- Flapping de líder: eleição repetida — mitigar com backoff, estabilidade e check de elegibilidade.
- Split brain: evitar com quorum e com checks de rede/partition detection.

Exemplo de uso:

- Coordenação de writes num shard, agendamento centralizado, liderar tarefas de manutenção.
