## Método RED (Foco no Serviço)

Criado como uma adaptação do método de Quatro Sinais de Ouro do Google, ele monitora a integridade de microsserviços e APIs. Ele mede três métricas críticas do ponto de vista do que o usuário vivencia:

- Taxa de Requisições (Rate): O número de solicitações por segundo que o seu serviço está recebendo. Picos ou quedas repentinas indicam anomalias no tráfego.
- Erros (Errors): A quantidade de solicitações que falham (por exemplo, erros HTTP 5xx). É normalmente medida como uma porcentagem do tráfego total.
- Duração (Duration/Latency): O tempo que leva para o serviço processar e responder a uma solicitação. Geralmente medida em percentis (ex: P99 ou P95) para isolar transações lentas.

Ex.: Caso de uso com PROMQL

## Método USE (Foco na Infraestrutura)

Criado por Brendan Gregg, este método é voltado para o nível de hardware, infraestrutura ou recursos sistêmicos (CPU, memória, discos e redes). Ele ajuda a diagnosticar gargalos e falhas de infraestrutura:

- Utilização (Utilization): A porcentagem de tempo em que o recurso está ativamente ocupado trabalhando (ou a capacidade máxima de uso).
- Saturação (Saturation): O grau em que o recurso está sobrecarregado, medindo o tamanho da fila de trabalho que ele não consegue processar imediatamente.
- Erros (Errors): A quantidade de eventos de erro que ocorreram em nível de sistema/hardware
