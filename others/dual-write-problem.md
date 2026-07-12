# Definicoes

É uma das armadilhas arquiteturais mais clássicas e perigosas em sistemas distribuídos. Ele ocorre quando uma aplicação precisa alterar dados em dois sistemas distintos — por exemplo, salvar um registro no banco de dados principal (PostgreSQL) e publicar um evento em um message broker (Kafka/RabbitMQ) ou atualizar um cache (Redis) — e precisa que ambas as operações sejam bem-sucedidas para manter a consistência do ecossistema.

Como esses dois sistemas não compartilham o mesmo contexto transacional (ACID), você não pode simplesmente dar um commit mágico que englobe ambos.

## A Abordagem Ingênua (Onde o problema nasce)

Imagine um fluxo simples de criação de usuário. A aplicação precisa gravar no banco e avisar o resto do sistema.

```java
@Transactional
public void criarUsuario(Usuario user) {
  // 1. Salva no banco de dados relacional
  usuarioRepository.save(user);
  // 2. Publica o evento para outros microsserviços
  kafkaTemplate.send("usuarios-topic", new UsuarioCriadoEvent(user.getId()));
}
```

Isso parece inofensivo, mas esconde cenários de falha catastróficos que geram dor de cabeça e exigem uma observabilidade muito afiada (com ferramentas como Zipkin ou Jaeger) para serem detectados depois do estrago feito:

1. O Banco salva, mas o Broker falha (Network timeout): O usuário é criado no banco, mas o evento nunca é disparado. Sistemas dependentes (como o envio de e-mail de boas-vindas ou o módulo de faturamento) nunca ficam sabendo que o usuário existe.
2. O Broker publica, mas o Banco falha (Rollback): Se você inverter a ordem e publicar no Kafka primeiro, a mensagem vai para a rede. Se o banco der erro (ex: constraint violation) logo em seguida e fizer rollback, os outros microsserviços vão processar um evento de um usuário que, na verdade, nunca foi salvo.

## Como resolver: O Padrão Transactional Outbox

A solução padrão da indústria para resolver o Dual Write sem recorrer a transações distribuídas lentas (como o Two-Phase Commit - 2PC) é o Transactional Outbox Pattern.

Em vez de a aplicação tentar falar com o banco e com o broker ao mesmo tempo, ela fala apenas com o banco de dados, garantindo o ACID.

1. A Transação Única: A aplicação salva os dados de negócio na tabela principal (ex: usuarios) e, na mesma transação de banco de dados, insere uma mensagem em uma tabela separada chamada outbox.
2. O Relay / CDC: Um processo assíncrono em background (como o Debezium fazendo Change Data Capture, ou um worker do Spring Scheduler) lê continuamente essa tabela outbox.
3. Publicação Garantida: Esse worker pega os registros da outbox e os envia para o Kafka. Se o Kafka estiver fora do ar, o worker simplesmente tenta de novo (retries) até conseguir. Uma vez publicado com sucesso, o registro é marcado como processado ou deletado da outbox.

Isso garante o que chamamos de Consistência Eventual (Eventual Consistency) com garantia de entrega (At-Least-Once delivery).
