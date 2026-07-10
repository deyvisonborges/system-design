# Revisão: Persistência e Dados

Este arquivo reúne os principais tópicos dos artigos de `platform/system-design/04-persistencia-e-dados`. Use-o como checklist de estudo, marcando cada item conforme revisar o assunto.

## Instruções

- Marque cada tópico quando estudar o conteúdo teórico.
- Marque os exemplos quando entender como aplicá-los em Java + Spring e TypeScript + NestJS.
- Use as perguntas para fixação como checklist de revisão ativa.

---

## 1. SQL vs NoSQL

Arquivo: `04-persistencia-e-dados/01-sql-vs-nosql.md`

Resumo: comparação entre bancos relacionais e não relacionais, explicando diferenças de modelo, consistência, esquema, e quando cada abordagem é mais adequada.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 2. Persistência poliglota

Arquivo: `04-persistencia-e-dados/02-polyglot-persistence.md`

Resumo: uso de múltiplas tecnologias de banco de dados no mesmo sistema para aproveitar o melhor modelo para cada caso de uso.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 3. Database-per-service vs shared database

Arquivo: `04-persistencia-e-dados/03-database-per-service-vs-shared-database.md`

Resumo: comparação entre banco dedicado por serviço e banco compartilhado entre serviços, abordando isolamento, acoplamento e governança de dados.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 4. Normalização e desnormalização

Arquivo: `04-persistencia-e-dados/04-normalizacao-e-desnormalizacao.md`

Resumo: conceito de normalizar dados para reduzir redundâncias versus desnormalizar para desempenho de leitura.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 5. Replicação leader-follower

Arquivo: `04-persistencia-e-dados/05-replicacao-leader-follower.md`

Resumo: padrão onde um leader processa escritas e replicas followers servem leituras, melhorando disponibilidade e escalabilidade.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 6. Particionamento vs sharding vs replicação

Arquivo: `04-persistencia-e-dados/06-particionamento-vs-sharding-vs-replicacao.md`

Resumo: descreve os conceitos de particionamento, sharding e replicação e como cada técnica resolve diferentes problemas de distribuição de dados.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 7. Database sharding

Arquivo: `04-persistencia-e-dados/07-database-sharding.md`

Resumo: foco no sharding como técnica de particionamento horizontal para dividir dados em shards separados.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 8. Consistent hashing

Arquivo: `04-persistencia-e-dados/08-consistent-hashing.md`

Resumo: técnica de hashing consistente para reduzir redistribuição de chaves quando nós são adicionados ou removidos.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 9. Shuffle sharding

Arquivo: `04-persistencia-e-dados/09-shuffle-sharding.md`

Resumo: isolamento de falhas por atribuir cada cliente a um conjunto de shards, minimizando impactos localizados.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 10. Cache-aside

Arquivo: `04-persistencia-e-dados/10-cache-aside.md`

Resumo: padrão de cache onde a aplicação busca no cache primeiro e, se não encontrar, carrega do banco e atualiza o cache.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 11. Change Data Capture (CDC)

Arquivo: `04-persistencia-e-dados/10-change-data-capture.md`

Resumo: captura de mudanças diretamente do log de transações para publicar eventos e integrar sistemas de forma confiável.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 12. Transactional outbox

Arquivo: `04-persistencia-e-dados/11-transcational-outbox.md`

Resumo: padrão que grava eventos na tabela outbox dentro da mesma transação do negócio para garantir atomicidade entre estado e eventos.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 13. CQRS

Arquivo: `04-persistencia-e-dados/12-cqrs.md`

Resumo: separação de comandos e consultas para permitir modelos diferentes em escrita e leitura.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 14. Event sourcing

Arquivo: `04-persistencia-e-dados/13-event-sourcing.md`

Resumo: persistência de eventos como fonte de verdade, permitindo reconstruir estado histórico e auditar mudanças.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## 15. Materialized view

Arquivo: `04-persistencia-e-dados/14-materialized-view.md`

Resumo: view materializada armazena o resultado de uma consulta como uma tabela física para leitura rápida.

- [ ] 1. O que é
- [ ] 2. Por que existe (o problema que resolve)
- [ ] 3. Como funciona
- [ ] 4. Casos de uso reais
- [ ] 5. Cenários práticos e trade-offs
- [ ] 6. Diagrama e fluxo visual
- [ ] 7. Exemplo aplicado — Java + Spring
- [ ] 8. Exemplo aplicado — TypeScript + NestJS
- [ ] 9. Comparação e armadilhas comuns
- [ ] 10. Perguntas para fixação

---

## Checklist de revisão geral

- [ ] Entender as diferenças entre SQL e NoSQL
- [ ] Identificar quando usar persistência poliglota
- [ ] Comparar database-per-service e shared database
- [ ] Saber quando normalizar ou desnormalizar dados
- [ ] Explicar o funcionamento de leader-follower
- [ ] Distinguir particionamento, sharding e replicação
- [ ] Mapear as aplicações de sharding em banco de dados
- [ ] Explicar consistent hashing e seus benefícios
- [ ] Entender o isolamento de falhas em shuffle sharding
- [ ] Aplicar cache-aside em arquiteturas de leitura pesada
- [ ] Descrever CDC como fonte de eventos
- [ ] Entender transactional outbox como padrão de integração
- [ ] Explicar a separação de comandos e consultas em CQRS
- [ ] Reconstruir estado com event sourcing
- [ ] Compreender materialized views para leituras rápidas
