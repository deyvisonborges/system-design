# Connection Pool

## Categoria no System Design

Connection Pool pertence à categoria de **Resource Management / Gerenciamento de recursos compartilhados**, dentro do guarda-chuva maior de **Performance & Scalability Patterns**. Mais especificamente, ele é um caso do padrão genérico **Object Pool** (do catálogo de design patterns clássicos, GoF), aplicado ao recurso "conexão de rede com um banco de dados".

Ele se relaciona diretamente com outros tópicos que você já estudou:

- **Resiliência** (Circuit Breaker, Bulkhead) — pool esgotado é uma das causas mais comuns de cascading failure
- **Concorrência** (thread pools, Virtual Threads) — pool de conexão e pool de threads são primos: ambos resolvem "recurso caro, reutilizável, com contenção"
- **Capacity Planning** — dimensionar pool é, no fim, uma conta de fila (teoria das filas, Little's Law)
- **Observabilidade** — métricas de pool (ativo/ocioso/esperando) são um dos sinais mais importantes de saúde de um sistema

## Definição formal

> Um **connection pool** é uma estrutura de gerenciamento de recursos que mantém um conjunto de conexões físicas reutilizáveis com um recurso externo (tipicamente um banco de dados), evitando o custo de criar e destruir uma conexão a cada operação. Consumidores (threads) tomam uma conexão emprestada do pool, a utilizam, e a devolvem ao final da operação, ao invés de possuírem a conexão de forma exclusiva e permanente.

Formalmente, um pool é definido por um conjunto de parâmetros de controle:

| Parâmetro | O que representa |
|---|---|
| `minimumIdle` | número mínimo de conexões ociosas mantidas sempre abertas |
| `maximumPoolSize` | teto de conexões físicas simultâneas (ativas + ociosas) |
| `connectionTimeout` | tempo máximo que uma thread espera por uma conexão livre antes de falhar |
| `idleTimeout` | tempo que uma conexão pode ficar ociosa antes de ser fechada (acima do mínimo) |
| `maxLifetime` | tempo máximo de vida de uma conexão, mesmo em uso, antes de ser reciclada |
| `validationQuery` / `keepaliveTime` | mecanismo para checar se a conexão ainda está viva antes de entregá-la |

## Por que existe: o problema de fundo

Toda conexão com um banco relacional envolve trabalho caro e não relacionado à query em si:

1. 3-way handshake TCP (SYN, SYN-ACK, ACK) — ida e volta de rede
2. Handshake de autenticação do protocolo do Postgres (troca de credenciais, SSL/TLS se estiver habilitado)
3. O Postgres forka um processo novo (sim, processo, não thread — isso é importante) para atender essa conexão
4. Esse processo aloca memória (work_mem, buffers locais), inicializa contexto de transação

Repetir esse processo a cada request é como contratar e demitir um funcionário novo para cada tarefa de 5 segundos — o overhead de "abrir a empresa e fechar" supera o tempo do trabalho em si.

Isso tudo pode levar de 5ms a 50ms+ dependendo da rede e carga. Se sua API recebe 500 req/s e cada uma abre e fecha uma conexão, você está pagando esse custo 500 vezes por segundo — e o Postgres, que não foi feito pra ter milhares de processos simultâneos, começa a sofrer com overhead de context switch e uso de memória.

**Resultado sem pool**: latência alta, banco de dados fazendo mais trabalho de "gerenciar conexões" do que de fato executar queries, e em picos de carga o banco literalmente recusa novas conexões `(FATAL: too many connections)`.

## Exemplo didático 1 — o restaurante e os garçons

Imagina um restaurante com 10 mesas.

- **Sem pool**: a cada cliente que senta, o restaurante *contrata um garçom novo*, treina ele por 10 minutos, ele atende a mesa por 2 minutos, e depois é demitido. Óbvio que isso é um desperdício absurdo — o custo de contratar/demitir é muito maior que o de atender.
- **Com pool**: o restaurante já tem 4 garçons contratados, de plantão. Quando um cliente senta, um garçom livre atende. Quando termina, o garçom fica disponível de novo para o próximo cliente. Se os 4 estiverem ocupados e chegar um 5º cliente, ele espera na fila até algum garçom liberar (ou o restaurante recusa se a fila for longa demais — igual ao `connectionTimeout`).

Os "garçons" são as conexões. Os "clientes" são as threads da sua aplicação pedindo dados ao banco.

## Exemplo didático 2 — a fila do banco (agência bancária)

- O banco tem **6 guichês abertos** (= `maximumPoolSize`), mas só **2 atendentes fixos** (= `minimumIdle`) ficam sempre lá quando o movimento é baixo, pra não pagar gente parada à toa.
- Se o movimento aumenta, o gerente abre mais guichês, até o limite de 6.
- Se todos os 6 estão ocupados, você pega uma senha e espera (= fila do pool). Se demorar mais que um certo tempo, você desiste e vai embora bravo (= `SQLTransientConnectionException` por `connectionTimeout` estourado).
- Um atendente que fica muito tempo parado sem cliente é dispensado até sobrar só os 2 fixos de novo (= `idleTimeout`).

## Cenário real 1 — o pool pequeno demais numa Black Friday

Uma API de checkout de e-commerce roda com `maximumPoolSize: 10` em cada uma de 5 instâncias (total: 50 conexões possíveis no banco). Em condições normais, cada request usa a conexão por ~15ms e libera. Tudo tranquilo.

Na Black Friday, o tráfego multiplica por 20x. As queries de estoque começam a demorar mais porque o banco está sob mais carga (mais I/O, mais lock contention nas tabelas de estoque). Agora cada conexão fica presa por 300ms em vez de 15ms.

Resultado: as 10 conexões de cada instância saturam rapidinho. Novas requests começam a esperar na fila do pool. Depois de 30 segundos de espera (`connectionTimeout`), começam a estourar `SQLTransientConnectionException` em cascata — e isso é percebido pelo cliente como "o site travou", mesmo que o banco em si não tenha caído. O gargalo real não foi o banco, foi o **tamanho do pool** não suportar o aumento de latência por operação.

**A lição**: pool não escala sozinho o throughput — ele só existe pra reaproveitar conexões. Se a latência por query sobe, o mesmo pool sustenta *menos* throughput, não mais.

## Cenário real 2 — connection leak (o vazamento silencioso)

Um desenvolvedor escreve um código assim, sem `try-with-resources`:

```java
Connection conn = dataSource.getConnection();
ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM propostas_credito");
// processa o resultado...
// esqueceu de fechar a conexão em caso de exceção no meio do processamento
```

Se uma exceção acontece antes do `conn.close()`, aquela conexão nunca volta pro pool. Ela fica marcada como "em uso" para sempre — um **connection leak**.

Isso não trava a aplicação imediatamente. É um vazamento silencioso: a cada exceção não tratada, uma conexão "some" do pool disponível. Depois de horas ou dias, o pool inteiro está "vazado" (todas as conexões marcadas como ocupadas, mas nenhuma thread realmente as usando), e a aplicação passa a travar em produção com timeouts, sem nenhuma mudança de código ter sido feita naquele dia — o que torna esse bug particularmente difícil de debugar.

O HikariCP tem uma proteção pra isso: `leakDetectionThreshold`, que loga um warning se uma conexão fica emprestada além de X segundos sem devolução, ajudando a identificar o código culpado.

## Cenário real 3 — pool por serviço em arquitetura de microsserviços

No seu contexto de Crédito PF: imagina que o `Crédito Gateway PF` e outros 8 microsserviços do domínio de crédito compartilham a mesma instância de Postgres (um padrão comum, mesmo com bounded contexts separados por schema).

Se cada um desses 9 serviços sobe com `maximumPoolSize: 30` "porque sim", e cada serviço roda com 5 réplicas no Kubernetes, você chega em:

```
9 serviços × 5 réplicas × 30 conexões = 1.350 conexões potenciais
```

O Postgres, por padrão, aceita `max_connections = 100`. Você estouraria o limite do banco só de manter os pools "de prontidão", mesmo sem tráfego nenhum. Esse é um dos motivos pelos quais times de plataforma costumam colocar um **PgBouncer** (connection pooler externo, em modo *transaction pooling*) na frente do Postgres: ele multiplexa centenas de conexões lógicas da aplicação em um número muito menor de conexões físicas reais com o banco, adicionando uma camada de pooling *entre* o pool de cada aplicação e o banco.

## Pool de conexão vs. pool de threads — a confusão mais comum

| | Pool de threads (Tomcat) | Pool de conexões (HikariCP) |
|---|---|---|
| O que reutiliza | threads do SO para processar requests HTTP | conexões TCP/processo já autenticadas com o banco |
| Tamanho típico | 200 (padrão Tomcat) | 10-20 (regra prática: `(núcleos do banco × 2) + discos`) |
| Gargalo que resolve | custo de criar thread do SO por request | custo de handshake TCP + autenticação + processo no Postgres |
| O que acontece se esgota | request enfileira na fila de aceitação do Tomcat | thread trava em `getConnection()` até timeout |

O erro clássico é achar que o pool de conexões deveria ser do mesmo tamanho que o pool de threads. Na prática, a maior parte do tempo de vida de uma request é gasta em coisas que não são banco (serialização, chamadas a outros serviços, validação) — só uma fração do tempo total realmente segura uma conexão. Por isso o pool de conexões é, de propósito, muito menor.

## Resumo mental para levar

- Connection pool existe porque **abrir conexão é caro**, não porque "é boa prática" de forma abstrata.
- O tamanho ideal **não** é "o máximo possível" — é limitado pela capacidade real do banco (CPU, disco, `max_connections`).
- Mais threads na aplicação **não** implica precisar de mais conexões — a maioria das threads não está com banco no momento.
- Vazamento de conexão é um dos bugs mais traiçoeiros em produção: sintoma aparece horas depois da causa.
- Em arquiteturas com múltiplos serviços batendo no mesmo banco, o pooling de cada aplicação isolado pode não ser suficiente — daí ferramentas como PgBouncer entram como uma segunda camada de pooling.

## A ideia central do Connection Pool

Connection pool resolve isso com uma sacada simples: reutilizar conexões já abertas, em vez de abrir e fechar a cada request.

Ao subir a aplicação, o pool (ex: HikariCP, que é o padrão hoje em Spring Boot) já cria um número de conexões físicas com o banco e as mantém vivas e ociosas, esperando serem usadas.

![alt text](image.png)

Repare: as conexões físicas com o Postgres já existem antes da request chegar. O pool é literalmente uma coleção de Connection objects vivos, guardados numa estrutura interna (no HikariCP, uma ConcurrentBag).

### O que acontence quando a requeet chega

#### Passo 1 — Tomcat aceita a conexão HTTP e escala uma thread

O Tomcat tem seu próprio pool de threads (maxThreads, padrão 200). Uma thread do pool HTTP pega essa request e começa a executar o código do seu controller/service.

#### Passo 2 — o código chama o repository/JPA

Em algum ponto, o Spring Data JPA (ou seu código manual) precisa executar uma query. Ele não abre uma conexão nova — ele pede uma emprestada ao DataSource, que é o HikariCP:

```java
Connection conn = dataSource.getConnection(); // pool.getConnection()
```

#### Passo 3 — o pool decide o que fazer

Aqui tem 3 cenários possíveis:

1. Tem conexão ociosa disponível → o pool entrega na hora (latência de microssegundos, é só pegar um objeto de uma lista)
2. Todas as conexões estão ocupadas, mas ainda não bateu o maximumPoolSize → o pool abre uma conexão física nova (aqui sim acontece o handshake TCP + fork no Postgres)
3. Bateu o maximumPoolSize → a thread fica bloqueada esperando até alguém devolver uma conexão, ou até estourar o connectionTimeout (padrão 30s no HikariCP) — e aí lança SQLTransientConnectionException

#### Passo 4 — a query executa

A thread usa a conexão pra rodar o SQL. A conexão fica marcada como "ativa" (`in-use`) durante todo esse tempo — nenhuma outra thread pode usá-la.

#### Passo 5 — devolução ao pool

Quando o método termina (geralmente via `try-with-resources` ou o Spring fechando a transação), chama-se `conn.close()`. Mas atenção: isso não fecha o socket TCP. O HikariCP sobrescreve o comportamento — `close()` só devolve a conexão pro pool, marcando como ociosa de novo, pronta pro próximo que pedir.

![alt text](image-1.png)

### O que realmente importa dimensionar

Por que não dá pra simplesmente colocar maximumPoolSize: 500
O Postgres não escala conexões de graça. Cada conexão é um processo do sistema operacional, com sua própria memória alocada (work_mem, buffers de contexto). Se você tem 10 instâncias do Crédito Gateway PF rodando em Kubernetes, cada uma com pool de 500, você está pedindo ao Postgres pra sustentar 5000 processos simultâneos — isso destrói a máquina antes mesmo de rodar uma query pesada, só de context switching.

A fórmula clássica (do próprio autor do HikariCP, Brett Wooldridge) pra número ideal de conexões é:

```md
connections = ((core_count * 2) + effective_spindle_count)
```

Ou seja: para um banco com 8 cores, algo em torno de 16-20 conexões já é suficiente pra saturar o throughput — o gargalo real é CPU/disco do banco, não quantidade de conexões esperando. Ter mais conexões do que isso só faz as threads brigarem por CPU e criar mais contenção via context switching, sem ganho real de vazão.

#### A relação real entre threads da aplicação e conexões do pool

Isso é o coração da pergunta que você fez. Pensa assim:

1. O Tomcat pode ter 200 threads processando requests simultaneamente
2. Mas o pool de conexões pode ter só 20 conexões
3. Isso é intencional: a maioria das threads passa a maior parte do tempo fazendo coisa que não é banco (serialização JSON, chamadas HTTP pra outros serviços, validação, lógica de negócio) — só uma fração do tempo de vida da request realmente segura uma conexão de banco

Se você dimensiona o pool igual ao número de threads HTTP, está desperdiçando recursos do banco pra um cenário que quase nunca acontece (todas as 200 threads precisando de banco ao mesmo tempo).

#### Onde Virtual Threads muda o jogo (e onde não muda)

Com virtual threads você pode ter milhões de threads virtuais concorrentes fazendo I/O, mas todas elas ainda vão competir pelas mesmas ~20 conexões físicas — e isso é bom, porque o Postgres não aguentaria mais que isso de qualquer forma.

O que muda é que, no modelo antigo (thread por request, platform threads), uma thread bloqueada esperando conexão prende um thread do SO caro. Com virtual threads, essa espera é praticamente grátis — a virtual thread "desmonta" do carrier thread enquanto espera, liberando recursos do SO. Ou seja: Loom ajuda na eficiência de esperar pela conexão, não aumenta quantas conexões o banco consegue dar.

## Como ele funciona: os três modos de pooling

O comportamento do PgBouncer muda bastante dependendo do modo configurado — essa é a parte mais importante de entender antes de usar.

### Session Polling

A conexão física fica atrelada a um cliente durante toda a sessão (do connect até o disconnect). É o modo mais parecido com "sem pooling nenhum" em termos de comportamento, mas ainda economiza o custo de handshake se o cliente reconectar. Menos eficiente em número de conexões economizadas, mas 100% compatível com qualquer feature do Postgres (prepared statements, SET de sessão, etc).

### Transaction Pooling

A conexão física é devolvida ao pool assim que a transação termina (commit ou rollback), não quando a sessão termina. É o modo mais usado na prática, porque permite multiplexar muito mais clientes lógicos por conexão física — já que a maior parte do tempo uma conexão de aplicação está ociosa entre transações.

Cuidado: nesse modo, features que dependem de estado de sessão persistente (SET variáveis de sessão, prepared statements nomeados fora da transação, LISTEN/NOTIFY) podem quebrar, porque a próxima transação do mesmo cliente lógico pode cair numa conexão física diferente, sem aquele estado.

### Statement Pooling

A conexão é devolvida a cada statement individual. É o mais agressivo em compartilhamento, mas também o mais restritivo — transações multi-statement não funcionam bem aqui. Raramente usado.

Na prática, transaction pooling é o padrão adotado na maioria dos times, porque equilibra bem eficiência com compatibilidade — mas exige atenção do time de aplicação para não depender de estado de sessão.

## PgBouncer não faz replicação nem decide read/write

Isso é importante separar: pooling e replicação são camadas ortogonais, que resolvem problemas diferentes.

- Replicação (Postgres primário → réplicas via streaming de WAL) resolve "ter cópias dos dados para leitura, escaláveis horizontalmente"
- Pooling (PgBouncer) resolve "gerenciar conexões eficientemente contra cada instância"

O PgBouncer, no modo padrão, só faz pooling contra um alvo Postgres — ele não escolhe sozinho se uma query vai pro primário ou pra uma réplica. Em uma arquitetura com réplicas de leitura, normalmente você tem:

```md
App → PgBouncer (write pool) → Postgres primário
App → PgBouncer (read pool)  → Réplicas (com load balancing configurado)
```

## Cenário aplicado: Crédito PF com múltiplos serviços

### Sem PgBouncer

```md
9 serviços de crédito × 5 réplicas × 30 conexões = 1.350 conexões diretas no Postgres
```

Isso sozinho já estoura qualquer max_connections razoável, mesmo com tráfego baixo.

### Com PgBouncer (transaction pooling), configurando por exemplo default_pool_size: 20 por banco lógico

```md
1.350 conexões lógicas das aplicações → PgBouncer → ~20-40 conexões físicas reais no Postgres
```

O Postgres real só enxerga uma fração pequena e estável de conexões físicas, mesmo que centenas de instâncias de serviços diferentes estejam, do ponto de vista delas, "conectadas" o tempo todo.
