# Hot Spot Queries

Em sistemas distribuídos e bancos de dados, um hot spot é um ponto de concentração de carga em que a maior parte das operações, requisições ou transações acaba indo para um único nó, partição, servidor ou tabela, enquanto os demais recursos ficam subutilizados.

Aqui o problema não é a query, mas sim um recurso que recebe tráfego muito acima dos demais, tornando-se um gargalo.

Um Hot Spot pode existir em:

- tabela
- linha
- índice
- partição
- cache
- serviço
- fila
- nó do cluster
- shard

Ou seja, qualquer recurso que concentre acesso excessivo.

Ex.:

- produtos famosos muito consultados;
- chave de cache
- banco particionado (cenario em que os clientes caem somente em um shard especifico)

> Hot Spot não significa query ruim

- `O problema`: isso gera sobrecarga no ponto concentrado, aumentando latência, reduzindo throughput e, em alguns casos, causando queda de desempenho ou indisponibilidade parcial.
- `Causa comum`: o uso de chaves com padrão sequencial ou muito previsível, como IDs auto incrementais, pode concentrar acessos em uma mesma partição. Também é comum ocorrer em tabelas muito acessadas ou em consultas que sempre passam por um mesmo ponto de processamento.
- `Como resolver`: a solução geralmente envolve distribuir a carga de forma mais uniforme, por exemplo usando chaves aleatórias ou hash-based, criando particionamento adequado e otimizando consultas que estejam impactando um ponto central.

## Exemplo prático

Imagine um sistema de e-commerce com milhões de pedidos. Se todos os pedidos forem armazenados em uma única partição baseada em um ID sequencial, essa partição pode virar um gargalo. Enquanto uma parte do sistema trabalha muito, outras ficam quase sem uso. Ao trocar para uma estratégia de particionamento mais equilibrada, a carga é distribuída melhor e o sistema passa a responder com mais rapidez.
