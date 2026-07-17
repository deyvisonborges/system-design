# Bulkhead Pattern — Guia Completo

> O Bulkhead é um dos padrões de resiliência mais mal compreendidos. Ele **não existe para reduzir latência**, nem para recuperar falhas de uma API externa. Seu objetivo é **isolar recursos**, impedindo que uma dependência problemática afete o restante da aplicação.

---

# O problema que o Bulkhead resolve

Imagine uma API:

```http
GET /products
```

Ela precisa consultar quatro serviços externos:

- Produto
- Estoque
- Preço
- Recomendações

O fluxo é algo parecido com:

```text
Cliente
    │
    ▼
GET /products
    │
    ▼
Promise.all()
    │
 ┌──┼──────────────┬────────────┬─────────────┐
 ▼  ▼              ▼            ▼
Produto Estoque   Preço   Recomendações
```

Suponha que:

| Serviço | Tempo |
|----------|------:|
| Produto | 30ms |
| Estoque | 40ms |
| Preço | 35ms |
| Recomendações | 30 segundos |

A requisição inteira levará aproximadamente:

```
30 segundos
```

Até aqui, **não existe Bulkhead**.

Existe apenas uma dependência lenta.

---

# O verdadeiro problema

Imagine agora:

```
4000 RPS
```

Cada requisição faz quatro chamadas.

Logo:

```
4000 requisições

↓

16000 chamadas externas
```

Se o serviço de Recomendações estiver lento...

Teremos milhares de chamadas esperando resposta.

Essas chamadas ocupam recursos da aplicação.

---

# O que são "recursos"?

A palavra "recurso" é genérica.

Ela depende da tecnologia utilizada.

Pode ser:

| Recurso | Exemplo |
|----------|----------|
| Threads | Java / Spring MVC |
| Conexões HTTP | HttpClient, OkHttp, Axios |
| Pool de conexões | Banco de Dados ou HTTP |
| Memória | Objetos aguardando resposta |
| CPU | Processamentos intensivos |
| Event Loop | Node.js |
| Fila interna | ExecutorService |

O Bulkhead protege qualquer recurso compartilhado.

---

# Exemplo em Java (Spring MVC)

O Spring Boot inicia um servidor embarcado (Tomcat por padrão).

Esse servidor possui um Thread Pool.

Por exemplo:

```
Tomcat

200 Threads
```

Essas threads ficam aguardando requisições.

Quando chega:

```
GET /products
```

O fluxo é:

```
Cliente

↓

Tomcat

↓

Thread 57

↓

Controller

↓

Service

↓

HTTP Client

↓

API Externa
```

Toda a requisição acontece dentro da mesma Thread.

---

# Se a API externa demora

A Thread fica parada esperando.

```
Thread 57

██████████████████████

Esperando resposta
```

Ela não faz outro trabalho.

---

# Agora imagine 200 requisições

```
Thread 1

esperando

Thread 2

esperando

...

Thread 200

esperando
```

Todas ocupadas.

Chega a requisição número 201.

O Tomcat verifica:

```
Existe Thread livre?

Não.
```

Ela ficará aguardando na fila de conexões.

Se a fila encher:

- Timeout
- 503
- Conexões recusadas

---

# Perceba o problema

Produto funciona.

Estoque funciona.

Preço funciona.

Quem derrubou sua API?

```
Recomendações
```

Porque todas as Threads ficaram esperando por ele.

---

# O Bulkhead resolve qual problema?

O Bulkhead responde apenas uma pergunta:

> Como impedir que uma dependência ruim utilize todos os recursos disponíveis da aplicação?

Ele não tenta tornar a API mais rápida.

Ele não tenta recuperar a falha.

Ele apenas limita o quanto essa integração pode consumir.

---

# Analogia do escritório

Imagine um escritório com:

```
20 salas de reunião
```

Todos usam as mesmas salas.

```
Financeiro

RH

Jurídico

Marketing
```

O Marketing resolve reservar:

```
18 salas
```

Agora:

- Financeiro para
- RH para
- Jurídico para

Mesmo sem problema algum.

O recurso compartilhado eram as salas.

---

O Bulkhead cria compartimentos.

```
Financeiro

5 salas

RH

5 salas

Jurídico

5 salas

Marketing

5 salas
```

Agora o Marketing pode travar.

Ele nunca utilizará as salas dos outros departamentos.

---

# O Bulkhead protege recursos

Ele não protege APIs.

Ele protege sua aplicação.

Visualmente:

```
             Minha API

       Recursos Compartilhados

        /      |      |      \
       A       B      C       D
```

Sem Bulkhead:

```
Serviço D

↓

Consome quase tudo
```

Resultado:

```
A não consegue recurso

B não consegue recurso

C não consegue recurso
```

Com Bulkhead:

```
A -> 25 recursos

B -> 25 recursos

C -> 25 recursos

D -> 25 recursos
```

Agora D nunca prejudicará os demais.

---

# Existem dois tipos de Bulkhead

## 1. Semaphore Bulkhead

É o mais utilizado.

Ele **não cria Threads**.

Ele apenas limita concorrência.

Exemplo:

```
Máximo de chamadas simultâneas

20
```

Chegam:

```
Thread 1

↓

Permitida

Thread 2

↓

Permitida

...

Thread 20

↓

Permitida

Thread 21

↓

Rejeitada
```

Ele funciona como uma catraca.

```
Entraram 20.

21º aguarda ou falha.
```

---

## 2. ThreadPool Bulkhead

Esse cria um Executor próprio.

```
Tomcat Thread

↓

ThreadPool Bulkhead

↓

API Externa
```

Exemplo:

```
Executor Recomendações

20 Threads
```

Mesmo que Recomendações fique lenta...

Ela utilizará apenas essas 20 Threads.

Nunca as dos outros serviços.

---

# Exemplo didático

Sem Bulkhead:

```
Tomcat

200 Threads

↓

200 chamadas para Recomendações
```

Se Recomendações travar:

```
200 Threads

↓

Esperando
```

---

Com ThreadPool Bulkhead:

```
Tomcat

200 Threads

↓

Bulkhead

↓

Executor Recomendações

20 Threads

↓

API Recomendações
```

Agora:

```
Somente 20 chamadas simultâneas.
```

---

# Em Node.js

Node normalmente não utiliza Thread por requisição.

O Bulkhead costuma limitar concorrência.

Exemplo:

```typescript
const limiter = pLimit(20);

await limiter(() => consultarRecomendacoes());
```

Agora:

```
20 chamadas executando

980 aguardando
```

Não criou novas Threads.

Apenas limitou a concorrência.

---

# Bulkhead não melhora latência

Isso é muito importante.

Se a API demora:

```
30 segundos
```

Ela continuará demorando.

O Bulkhead apenas impede que:

```
30 segundos

↓

Consumam todos os recursos da aplicação.
```

---

# Comparação entre os padrões

## Timeout

Pergunta:

> Quanto tempo estou disposto a esperar?

```
↓

2 segundos

↓

Cancela
```

---

## Retry

Pergunta:

> Vale a pena tentar novamente?

```
Falhou

↓

Espera

↓

Tenta novamente
```

---

## Circuit Breaker

Pergunta:

> Vale continuar chamando esse serviço?

```
Muitas falhas

↓

Abre circuito

↓

Não chama mais
```

---

## Bulkhead

Pergunta:

> Como impedir que um serviço ruim utilize todos os meus recursos?

---

# Comparação final

| Padrão | Responsabilidade |
|---------|------------------|
| Timeout | Define quanto tempo esperar |
| Retry | Reexecuta uma operação |
| Circuit Breaker | Interrompe chamadas para um serviço falhando |
| Bulkhead | Isola recursos para evitar propagação da falha |

---

# Uma combinação típica

Na prática, normalmente usamos:

```
Requisição

↓

Bulkhead

↓

Timeout

↓

Retry

↓

Circuit Breaker

↓

API Externa
```

Cada um resolve um problema diferente.

---

# O que o Bulkhead NÃO faz

- Não reduz latência.
- Não acelera uma API.
- Não recupera uma falha.
- Não substitui Timeout.
- Não substitui Retry.
- Não substitui Circuit Breaker.

---

# O que o Bulkhead realmente faz

Ele cria isolamento.

Pense em um navio.

Se um compartimento encher de água...

```
Sem Bulkhead

Água

↓

Espalha

↓

Navio afunda
```

Com Bulkhead:

```
Água

↓

Fica presa em um compartimento

↓

Restante do navio continua funcionando.
```

Esse é exatamente o motivo do nome **Bulkhead**.

---

# Resumo em uma frase

> **Bulkhead não protege a API externa. Ele protege a sua aplicação, limitando quanto de seus próprios recursos uma dependência pode consumir, para que uma falha localizada não derrube todo o sistema.**
