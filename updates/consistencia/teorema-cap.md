# Teorema CAP

O teorema CAP é um conceito importante em sistemas distribuídos. Ele diz que, em um sistema distribuído, você só pode garantir no máximo dois dos três princípios abaixo ao mesmo tempo:

- Consistência (Consistency)
- Disponibilidade (Availability)
- Tolerância a Partições (Partition Tolerance)

Na prática, em um sistema distribuído, falhas de rede ou problemas entre nós acabam acontecendo. Por causa disso, a tolerância a partições é quase sempre necessária. Então, o verdadeiro trade-off costuma ser entre consistência e disponibilidade.

## O que significa cada conceito?

- `Consistência`: todos os nós do sistema veem os mesmos dados no mesmo momento.
- `Disponibilidade`: o sistema continua respondendo mesmo quando há falhas ou atrasos.
- `Tolerância a partições`: o sistema continua funcionando mesmo quando partes da rede ficam isoladas.

## Resumo simples

Em sistemas distribuídos, você normalmente precisa escolher:

- Priorizar consistência e aceitar que o sistema pode ficar indisponível por algum tempo.
- Priorizar disponibilidade e aceitar que os dados podem ficar temporariamente diferentes em diferentes nós.

## Exemplo prático

Imagine um sistema de banco online:

- Se o sistema prioriza consistência, ao sacar dinheiro ele garante que o saldo seja atualizado corretamente em todos os servidores antes de confirmar a operação.
- Se prioriza disponibilidade, ele pode responder rápido mesmo que alguns servidores estejam com dados atrasados por um momento.

## Exemplo mais intuitivo

Pense em um sistema de reserva de hotéis:

- Se o usuário tenta reservar um quarto e o sistema quer garantir que ninguém mais reserve o mesmo quarto ao mesmo tempo, ele prioriza consistência.
- Se o sistema quer continuar funcionando mesmo com problemas de rede, ele pode priorizar disponibilidade e aceitar que, por alguns instantes, duas pessoas possam ver a mesma disponibilidade.

## Conclusão

O teorema CAP mostra que não existe um sistema perfeito para todos os cenários. Em sistemas distribuídos, é necessário decidir qual propriedade é mais importante para o negócio.

Em resumo:

- `ACID` costuma estar mais ligado a consistência.
- `BASE` costuma estar mais ligado a disponibilidade e tolerância a inconsistências temporárias.
