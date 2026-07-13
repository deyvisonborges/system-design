# Bulkhead Pattern: Entendendo o Isolamento de Recursos na Prática

## O problema

Imagine uma API Java Spring Boot rodando em um Tomcat com um pool de **200 threads**.

Cada requisição precisa consultar quatro serviços:

```text
Cliente
    │
    ▼
API
 ├── Serviço A (20ms)
 ├── Serviço B (15ms)
 ├── Serviço C (5 segundos)
 └── Serviço D (30ms)
```

Se o **Serviço C** ficar lento, todas as threads ficam esperando sua resposta.

```
Thread 1   ───────── esperando Serviço C ─────────
Thread 2   ───────── esperando Serviço C ─────────
...
Thread 200 ───────── esperando Serviço C ─────────
```

Resultado:

```
Thread Pool

200 / 200 threads ocupadas
```

Nenhuma nova requisição consegue ser atendida.

---

# O que é o Bulkhead?

O Bulkhead é um padrão de resiliência cujo objetivo é **isolar recursos**, impedindo que um componente problemático consuma todos os recursos da aplicação.

O nome vem dos compartimentos estanques de um navio.

```
┌──────────────┐
│ Compartimento│
├──────────────┤
│ Compartimento│
├──────────────┤
│ Compartimento│
└──────────────┘
```

Se um compartimento encher de água, os demais continuam protegidos.

Na aplicação acontece exatamente a mesma ideia.

---

# Como funciona?

O Bulkhead **não remove chamadas da thread**.

Ele também **não move uma execução em andamento para outra thread**.

O que ele faz é impedir que chamadas novas entrem quando o limite configurado já foi atingido.

Visualmente:

Sem Bulkhead

```
200 Threads
      │
      ▼
Serviço de Recomendação
```

Todas conseguem chamar o serviço.

Se ele travar, todas ficam bloqueadas.

---

Com Bulkhead

```
200 Threads
      │
      ▼
Bulkhead
      │
      ├── aceita 20 chamadas
      │
      └── rejeita as demais
```

Agora apenas um número controlado de threads pode acessar aquele serviço.

As demais recebem erro ou fallback imediatamente.

---

# O que acontece com as threads rejeitadas?

Elas **não ficam esperando**.

Fluxo simplificado:

```
Thread

↓

Bulkhead

↓

Pool cheio

↓

BulkheadFullException

↓

Fallback ou retorno de erro

↓

Thread é liberada
```

Ou seja, elas voltam rapidamente para o pool do servidor.

---

# Existem dois tipos de Bulkhead

## 1. Semaphore Bulkhead

É o mais simples.

Internamente funciona como um contador de permissões.

```
20 permissões disponíveis

□□□□ □□□□ □□□□ □□□□ □□□□
```

Cada chamada faz:

```
Posso entrar?

SIM → Executa

NÃO → Rejeita
```

Conceitualmente:

```java
if (semaphore.tryAcquire()) {
    try {
        chamarServico();
    } finally {
        semaphore.release();
    }
} else {
    throw new BulkheadFullException();
}
```

Características:

- Não cria novas threads.
- Apenas limita quantas chamadas simultâneas entram.
- Muito leve.

---

## 2. ThreadPool Bulkhead

Neste modelo existe um pool dedicado para aquele recurso.

Exemplo:

```
Tomcat

200 Threads
```

e

```
Recommendation Pool

20 Threads
```

Fluxo:

```
Tomcat Thread

↓

ThreadPool Bulkhead

↓

Pool dedicado

↓

Serviço
```

Se o pool estiver cheio:

```
RejectedExecutionException
```

ou

```
BulkheadFullException
```

---

# O Bulkhead sabe que o serviço caiu?

Não.

Essa é uma confusão muito comum.

O Bulkhead **não monitora a saúde do serviço**.

Ele apenas controla concorrência.

Ele sabe somente:

> "Já tenho X chamadas usando esse recurso."

Não importa o motivo:

- serviço caiu
- timeout
- rede lenta
- banco lento
- GC
- qualquer outro problema

Se o limite for atingido, novas chamadas serão rejeitadas.

---

# Quem detecta que o serviço está indisponível?

Esse papel é do **Circuit Breaker**.

Enquanto o Bulkhead responde:

> "Só permito 20 chamadas simultâneas."

O Circuit Breaker responde:

> "Esse serviço está falhando. Nem vale a pena tentar chamá-lo."

São responsabilidades diferentes.

---

# Como o Resilience4j implementa isso?

Tudo acontece **dentro da JVM**.

Imagine:

```
Pod

┌─────────────────────────┐
│ JVM                     │
│                         │
│ Spring Boot             │
│                         │
│ Resilience4j            │
└─────────────────────────┘
```

Quando usamos:

```java
@Bulkhead(name = "recommendation")
```

o Spring cria um objeto singleton semelhante a:

```java
Bulkhead recommendationBulkhead = new SemaphoreBulkhead(20);
```

ou

```java
ThreadPoolBulkhead recommendationBulkhead = ...
```

Todas as requisições compartilham esse mesmo objeto.

---

# Como várias threads acessam o Bulkhead?

Todas chamam o mesmo objeto compartilhado.

Visualmente:

```
Thread 1
        │
Thread 2
        │
Thread 3
        │
        ▼
RecommendationBulkhead

Permissões: 20
```

Esse objeto utiliza primitivas de concorrência da própria JVM (como `Semaphore`) para controlar acesso simultâneo.

---

# Cada Pod possui seu próprio Bulkhead

Imagine três Pods.

```
Pod A

RecommendationBulkhead
20 permissões
```

```
Pod B

RecommendationBulkhead
20 permissões
```

```
Pod C

RecommendationBulkhead
20 permissões
```

Cada Pod possui sua própria instância.

Eles **não compartilham estado**.

Se o Pod A estiver completamente ocupado, os Pods B e C continuam funcionando normalmente.

---

# Bulkhead + Circuit Breaker

Na prática esses padrões trabalham juntos.

Fluxo comum:

```
Thread

↓

Circuit Breaker

↓

Bulkhead

↓

Timeout

↓

Retry

↓

Serviço Externo
```

Cada um resolve um problema diferente:

| Padrão | Responsabilidade |
|---------|------------------|
| Timeout | Evita esperas infinitas |
| Retry | Tenta novamente em falhas temporárias |
| Circuit Breaker | Interrompe chamadas para serviços indisponíveis |
| Bulkhead | Impede que um serviço consuma todos os recursos da aplicação |

---

# Resumo

O Bulkhead:

- Isola recursos da aplicação.
- Limita chamadas simultâneas para um componente.
- Evita que um serviço lento esgote todas as threads.
- Não detecta falhas do serviço.
- Não move chamadas entre threads.
- Não remove chamadas já iniciadas.
- Funciona localmente dentro de cada JVM/Pod.
- Pode ser implementado por **Semaphore** ou por **Thread Pool dedicado**.

O principal objetivo é simples:

> **Mesmo que um componente falhe ou fique extremamente lento, ele não deve comprometer o funcionamento de toda a aplicação.**
