# Definicoes

Conjunto de propriedades que garantem a confiabilidade das transacao em sistemas de DBs

## A - Atomicidade

Todas as etapas de uma transação são concluídas com sucesso ou falham simultaneamente, sem estado parcial, tudo ou nada.

É a capacidade de uma transcao que possui N writes, somente realizar o commit quando o ultimo write finalizar com sucesso.

### C - Consistencia

Todos os dados no banco de dados são consistentes ao final da transação.

A transacao deve ser consistente de acordo com seus atributos e tipos seguindo as regras.

### I - Isolamento

Apenas uma transação pode acessar os dados por vez; as outras transações aguardam a conclusão da transação em andamento.

### D - Durabilidade

Os dados são mantidos no banco de dados ao final da transação.

Apos o commit, o dado estara consistente e armazenado permanentemente e disponivel onde deva estar

## Transacoes Distribuidas

Numa transação normal (ACID, banco único), você faz várias operações e o banco garante: ou tudo commita, ou tudo é revertido. Fácil, porque é um único recurso controlando tudo.
Numa arquitetura distribuída (microserviços, cada um com seu próprio banco), uma operação de negócio pode precisar mexer em vários bancos diferentes, em serviços diferentes. Exemplo clássico pro seu domínio:

> Aprovar um crédito PF envolve: debitar limite no serviço de Análise de Crédito, criar registro no > serviço de Contratos, e disparar liberação no serviço de Desembolso. Cada um tem seu próprio banco de dados.

Se o passo 2 falhar depois que o passo 1 já commitou, você tem um estado inconsistente: o limite foi debitado, mas o contrato não existe. Não dá pra usar uma transação SQL normal porque ela não atravessa bancos/serviços diferentes.
Isso é o problema que "transação distribuída" tenta resolver.

### Two Phase Commit

2PC é um protocolo onde um coordenador garante que todos os participantes concordem em commitar, ou todos revertem — como uma votação com direito a veto, seguida de execução obrigatória.

As duas fases

#### Fase 1 — Prepare (votação)

O coordenador pergunta pra cada participante: "você consegue commitar essa operação?"
Cada participante trava os recursos necessários (locks) e responde YES ou NO, mas não commita ainda.

#### Fase 2 — Commit ou Rollback (execução)

Se todos responderam YES → coordenador manda "COMMIT" pra todos.
Se qualquer um respondeu NO (ou não respondeu) → coordenador manda "ROLLBACK" pra todos.

#### Por que 2PC é problemático na prática

1. `Bloqueante`: os recursos ficam travados (locks) durante toda a Fase 1 até a Fase 2 terminar. Se o coordenador cair no meio, os participantes ficam com locks pendurados indefinidamente.
2. `Single point of failure`: se o coordenador morre depois do Prepare mas antes do Commit, os participantes não sabem se devem commitar ou não — ficam em estado "in-doubt".
3. `Não escala bem`: cada participante precisa manter conexão síncrona e locks abertos, o que é péssimo pra alta concorrência (imagine isso em um sistema de crédito com milhares de aprovações simultâneas).
4. `Não funciona bem entre tecnologias heterogêneas` (ex: um serviço com Postgres e outro com um serviço HTTP externo tipo bureau de crédito — Serasa não vai participar de um protocolo 2PC com você).

Por isso, 2PC é raramente usado em microserviços modernos — é mais comum em bancos de dados distribuídos internos (ex: cluster Postgres com XA transactions) do que entre serviços de negócio.

#### Exemplo de Two Phase Commit

```java
// Interface que cada participante deve implementar
interface TwoPhaseParticipant {
  boolean prepare(String transactionId);  // Fase 1: vota
  void commit(String transactionId);        // Fase 2a: confirma
  void rollback(String transactionId);      // Fase 2b: desfaz
}

// Participante: Serviço de Análise de Crédito
class AnaliseCreditoParticipant implements TwoPhaseParticipant {

  private final Map<String, BigDecimal> reservasPendentes = new ConcurrentHashMap<>();

  @Override
  public boolean prepare(String transactionId) {
    try {
      // Trava o registro no banco (lock pessimista) e valida se dá pra debitar
      BigDecimal limiteDisponivel = buscarLimiteComLock(clienteId);
      if (limiteDisponivel.compareTo(valorSolicitado) < 0) {
          return false; // vota NO
      }
      // Guarda a intenção, mas NÃO commita ainda
      reservasPendentes.put(transactionId, valorSolicitado);
      return true; // vota YES
    } catch (Exception e) {
      return false;
    }
  }

  @Override
  public void commit(String transactionId) {
    BigDecimal valor = reservasPendentes.remove(transactionId);
    // AGORA sim persiste de verdade
    limiteRepository.debitar(clienteId, valor);
  }

  @Override
  public void rollback(String transactionId) {
    reservasPendentes.remove(transactionId);
    // Libera o lock, nada foi persistido
  }

  // Recovery ao reiniciar o coordenador
  void recoverPendingTransactions() {
    List<Transaction> pending = log.findByState(TransactionState.PREPARING, TransactionState.COMMITTING);
    for (Transaction tx : pending) {
      if (tx.getState() == TransactionState.COMMITTING) {
        // já tinha decidido commitar, só terminar o trabalho
        resumeCommit(tx.getId());
      } else {
        // travou na votação, mais seguro abortar
        resumeRollback(tx.getId());
      }
    }
  }
}

// O Coordenador
class TwoPhaseCommitCoordinator {

  private final List<TwoPhaseParticipant> participants;
  private final TransactionLogRepository log; // persiste o estado da transação!

  public boolean executeTransaction(String transactionId) {
    log.save(transactionId, TransactionState.PREPARING);
    // FASE 1: PREPARE
    boolean allVotedYes = true;
    for (TwoPhaseParticipant participant : participants) {
      boolean vote = participant.prepare(transactionId);
      if (!vote) {
        allVotedYes = false;
        break;
      }
    }
    // FASE 2: COMMIT ou ROLLBACK
    if (allVotedYes) {
      log.save(transactionId, TransactionState.COMMITTING);
      for (TwoPhaseParticipant participant : participants) {
        participant.commit(transactionId);
      }
      log.save(transactionId, TransactionState.COMMITTED);
      return true;
    } else {
      log.save(transactionId, TransactionState.ROLLING_BACK);
      for (TwoPhaseParticipant participant : participants) {
        participant.rollback(transactionId);
      }
      log.save(transactionId, TransactionState.ROLLED_BACK);
      return false;
    }
  }
}
```

Em Spring Boot com múltiplos bancos, usaria JTA (Java Transaction API) com um transaction manager como Atomikos ou Narayana, que já implementam esse protocolo pronto — você não escreve o coordenador na mão, só configura os XADataSource.

Na prática, o coordinator é só um código — uma classe, um serviço, um componente que roda em algum lugar (dentro de um dos seus microserviços, ou como um serviço à parte). Não tem nada mágico ou "de infraestrutura" nele, tipo um software especial que você instala.

> As alternativas modernas

### Saga Pattern

Definição didática: em vez de uma transação atômica, você quebra a operação em uma sequência de transações locais menores, cada uma com uma ação de compensação (o "desfazer") caso algo dê errado mais adiante.

Não existe lock global — cada passo commita de verdade, e se um passo posterior falhar, você compensa os passos anteriores (não faz rollback técnico, faz uma ação de negócio reversa).

a) **Saga Coreografada (Choreography)**
Cada serviço reage a eventos publicados pelos outros, sem um orquestrador central.

```md
Análise de Crédito debita limite 
  → publica evento "LimiteDebitado"
    → Contratos escuta, cria contrato 
      → publica "ContratoCriado"
        → Desembolso escuta, tenta agendar TED
          → FALHA (conta inválida)
          → publica "DesembolsoFalhou"
            → Contratos escuta, cancela contrato (compensação)
            → Análise de Crédito escuta, devolve o limite (compensação)
```

- `Vantagem`: desacoplado, sem ponto central.
- `Desvantagem`: difícil de rastrear o fluxo todo ("quem está ouvindo o quê" fica espalhado), debugging mais difícil.

b) **Saga Orquestrada (Orchestration)**
Um orquestrador central comanda passo a passo e decide quando compensar.

Diferente do 2PC, ele não é bloqueante. Assume que o 2PC não escala na nuvem e adota a consistência eventual (BASE).

- Sem Bloqueios Permanentes: O orquestrador vai chamando cada microserviço de forma sequencial (ou paralela, dependendo do fluxo). Cada serviço executa sua transação local, commita imediatamente no seu próprio banco e libera os recursos. O dado fica visível para o resto do sistema logo em seguida.

- Transações Compensatórias: Se o Passo 1 e o Passo 2 derem certo, mas o Passo 3 falhar, o orquestrador não consegue dar um "rollback" mágico no banco de dados dos passos anteriores (porque eles já salvaram e liberaram o dado). Em vez disso, ele é responsável por acionar de forma explícita as ações de compensação (ex: se o Passo 2 cobrou o cartão e o Passo 3 falhou ao emitir a nota, o orquestrador chama uma rota do Passo 2 para estornar o cartão).

```md
Orquestrador (Saga de Aprovação de Crédito):
  1. Chama Análise de Crédito → debita limite → OK
  2. Chama Contratos → cria contrato → OK
  3. Chama Desembolso → agenda TED → FALHA
  4. Orquestrador decide compensar:
     4a. Chama Contratos → cancela contrato
     4b. Chama Análise de Crédito → devolve limite
```

- Vantagem: fluxo centralizado e visível, mais fácil de testar e monitorar.
- Desvantagem: o orquestrador vira um componente crítico (mas não é SPOF de dados como no 2PC — ele só orquestra chamadas, não segura locks).
