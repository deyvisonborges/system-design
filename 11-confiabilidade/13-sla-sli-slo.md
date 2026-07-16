## SLI

SLI (Service Level Indicator) são indicadores de nível de serviço. São métricas específicas, mensuráveis e orientadas ao usuário ou ao sistema.

Exemplos comuns:

- Latência de requisição: porcentagem de respostas em menos de 200 ms.
- Disponibilidade: porcentagem de tempo em que o serviço está operacional.
- Taxa de erro: porcentagem de requisições que retornam falha.

Um SLI deve ser definido de forma clara, objetiva e confiável para ser usado como base de decisão.

## SLO

SLO (Service Level Objective) é o objetivo ou meta para um SLI específico. Ele define o nível aceitável de serviço que a equipe se compromete a entregar.

Exemplos de SLO:

- Disponibilidade de 99,9% por mês.
- 95% das requisições completadas em menos de 200 ms.
- Taxa de erro menor que 0,1%.

SLOs ajudam a balancear confiabilidade e velocidade de entrega, fornecendo limites claros para manutenção e melhorias.

## SLA

SLA (Service Level Agreement) é um contrato formal entre provedor e cliente que descreve as expectativas de serviço e as consequências do não cumprimento.

Um SLA geralmente inclui:

- Os SLOs acordados.
- Penalidades ou créditos em caso de violação.
- Exclusões e exceções (por exemplo, manutenção programada).
- Responsabilidades de cada parte.

## Relação entre SLI, SLO e SLA

- SLI mede o serviço.
- SLO estabelece metas para esses indicadores.
- SLA formaliza os objetivos em um acordo entre cliente e fornecedor.

## Exemplo prático

Imagine um serviço de streaming de vídeo.

- SLI: percentual de requisições que retornam em menos de 500 ms.
- SLO: 95% das requisições devem responder em menos de 500 ms durante um mês.
- SLA: o fornecedor promete que, se a disponibilidade cair abaixo de 99,5% no mês, o cliente receberá um desconto no plano.

Nesse caso:

- o SLI mede o desempenho real do serviço;
- o SLO define a meta interna da equipe;
- o SLA formaliza o compromisso com o cliente.

## Boas práticas

- Use SLIs acionáveis e relevantes para o usuário.
- Defina SLOs realistas e alinhados ao negócio.
- Não transforme todos os SLOs em SLA; nem todas as métricas precisam de compromisso contratual.
- Monitore continuamente e revise metas quando necessário.
