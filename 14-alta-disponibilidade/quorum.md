# Quorum

Quorum é o número mínimo de nós necessários para tomar decisões seguras num sistema distribuído. Quorums previnem decisões conflitantes e ajudam a evitar split-brain.

Tipos e fórmulas:

- Majority quorum: mais da metade dos nós (⌈N/2⌉). Simples e comum em Raft.
- Read/Write quorums (R/W): por exemplo em sistemas baseados em quorum, garantir R + W > N para consistência.
- Weighted quorum: nós têm pesos diferentes (útil para topologias heterogêneas).

Considerações práticas:

- Trade-off disponibilidade x consistência: quorum estrito diminui disponibilidade durante partições.
- Quorum e latência: maior geodistribuição pode aumentar latência de quorum.

Exemplo R/W:

- N = 3, W = 2, R = 2 => R + W = 4 > N (consistente reads)

Checklist:

- Defina N, R, W ao projetar storage distribuído.
- Teste comportamento sob partições e perda de nós.
