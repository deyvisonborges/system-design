# Definicoes

A consistência eventual é um modelo usado em sistemas distribuídos para alcançar alta disponibilidade. Em um sistema com consistência eventual , inconsistências são permitidas por um curto período até que o problema de dados distribuídos seja resolvido.

Este modelo não se aplica a transações ACID distribuídas entre microsserviços. A consistência eventual utiliza o modelo de banco de dados BASE .

Enquanto o modelo ACID proporciona um sistema consistente, o modelo BASE oferece alta disponibilidade.

#### A sigla BASE significa:

- Básicamente Disponível : garante a disponibilidade dos dados replicando-os nos nós do cluster de banco de dados .
- Estado flexível : devido ao bloqueio da consistência forte, os dados podem mudar ao longo do tempo. A responsabilidade pela consistência é delegada aos desenvolvedores.
- Consistência eventual : a consistência imediata pode não ser possível com o BASE, mas será fornecida eventualmente (em pouco tempo).
