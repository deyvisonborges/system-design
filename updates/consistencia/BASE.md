# Definicoes para BASE

BASE é um acrônimo para Basically Available (basicamente disponível), Soft State (estado suave) e Eventually Consistent (eventualmente consistente). O modelo BASE é uma alternativa ao modelo ACID, com uma abordagem mais flexível para o processamento de transações em sistemas distribuídos.

- `Basicamente disponível`: garante que o sistema esteja sempre disponível, mesmo que ele não esteja funcionando em sua capacidade total.

- `Estado suave`: permite que o estado do sistema possa mudar ao longo do tempo, mesmo sem entrada de dados externos.

- `Eventualmente consistente`: garante que os dados serão eventualmente consistentes após as transações serem processadas. O modelo BASE não garante a consistência imediata dos dados, mas sim que eles serão eventualmente consistentes.

Em resumo, o modelo ACID prioriza a consistência dos dados em detrimento da disponibilidade, enquanto o modelo BASE prioriza a disponibilidade dos dados em detrimento da consistência imediata. A escolha entre ACID e BASE depende do contexto de uso do sistema e das necessidades do negócio.

## Exemplo de Caso de Uso

Imagine que você está em uma rede social que permite postagens de fotos e vídeos. Quando você posta uma foto, ela é armazenada em um servidor e depois é copiada para outros servidores em diferentes partes do mundo, permitindo que outras pessoas acessem seu conteúdo. No entanto, se um amigo tentar ver sua foto antes dela ser copiada para todos os servidores, ele pode receber um erro temporário.

Mas isso não é um grande problema porque o mais importante é que o conteúdo esteja disponível para todo mundo o mais rápido possível, mesmo que algumas pessoas precisem esperar um pouquinho.

É tipo aquela frase: “antes disponível do que perfeito”. E é isso BASE faz!
