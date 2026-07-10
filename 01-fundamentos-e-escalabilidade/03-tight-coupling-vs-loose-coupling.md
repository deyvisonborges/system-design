# Definicoes

São conceitos de arquitetura de software que definem o nível de dependência entre diferentes partes de um sistema. Em termos simples: eles ditam se a mudança em uma classe ou serviço vai "quebrar" ou exigir grandes alterações em outro.

## Tight Coupling

Ocorre quando duas classes ou módulos dependem excessivamente um do outro.

- `Como funciona`:
  - O módulo A "sabe" muito sobre a implementação interna do módulo B. Se o módulo B mudar, o módulo A provavelmente precisará ser reescrito.
- `Exemplo prático`:
  - Uma classe Carro instancia diretamente um MotorGasolina dentro de seu próprio código. Se você quiser mudar para um MotorEletrico, terá que alterar a classe Carro inteira
- `Problemas comuns`:
  - Difícil testar: Você não consegue testar o Carro sozinho sem ter um MotorGasolina real funcionando em segundo plano.Baixa reusabilidade: Você não consegue reaproveitar o Carro com outro tipo de motor facilmente.Efeito cascata: Alterar uma parte do código quebra outras áreas dependentes.

- mais interdependencia
- mais coordenacao
- mais fluxos de condicoes

## Loose Coupling

É o padrão ideal. Ocorre quando as partes de um sistema são independentes e comunicam-se entre si através de contratos ou abstrações (interfaces), e não dependendo de implementações concretas

- `Como funciona`:
  - Um componente apenas "sabe" o que o outro faz, mas não como ele faz. A criação e a ligação das partes são feitas externamente.
- `Exemplo prático`: A classe Carro depende de uma InterfaceMotor e não de um motor específico. O MotorGasolina ou MotorEletrico são passados de fora. Se você quiser mudar o motor, basta criar uma nova classe que siga a interface, sem alterar a classe Carro.
- `Benefícios principais`:
  - Flexibilidade: É muito mais fácil trocar peças (ex: trocar um banco de dados MySQL por um MongoDB) sem reescrever a lógica de negócios.
  - Testabilidade: Você pode criar um "motor falso" (mock) e injetá-lo no Carro para testá-lo isoladamente.
  - Manutenção: Mudar algo em um módulo não afeta o outro, desde que o contrato seja respeitado

- menos interdependencia
- menos coordenacao
- fluxos de condicoes

## Como alcançar o Loose Coupling?

Para tirar suas aplicações de um estado de acoplamento forte para um acoplamento fraco, existem práticas e padrões consagrados:

- `Interfaces`: Sempre programe voltado para interfaces e não para classes concretas.
- `Dependency Injection (Injeção de Dependência)`: Em vez de instanciar dependências internamente (usando new), passe (injete) as dependências necessárias através do construtor ou de métodos.
- `Arquitetura Orientada a Eventos`: Componentes não chamam uns aos outros diretamente. Eles disparam eventos e quem precisa saber reage a eles (muito usado em microsserviços).
