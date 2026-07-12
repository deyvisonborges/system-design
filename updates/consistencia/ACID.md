# Definicoes

ACID é um acrônimo para Atomicidade, Consistência, Isolamento e Durabilidade. O modelo ACID garante que as transações sejam executadas de forma confiável, mantendo a integridade dos dados em um ambiente de várias transações simultâneas.

- `Atomicidade`: garante que todas as operações de uma transação sejam executadas com sucesso ou nenhuma delas seja executada. Se uma parte da transação falhar, todas as operações devem ser revertidas.

- `Consistência`: garante que a transação mantenha a consistência dos dados. Os dados devem estar em um estado consistente antes e depois da transação.

- `Isolamento`: garante que as transações sejam executadas de forma isolada, sem interferir umas nas outras.

- `Durabilidade`: garante que as alterações de uma transação sejam permanentes, mesmo em caso de falha do sistema.

## Estudo de Caso de Uso

Imagine que você está fazendo uma transferência bancária para um amigo. Para garantir que a transação seja feita com segurança e sem erros, você segue as seguintes etapas:

- `Início da transação`: você digita o valor da transferência e confirma a transação.
- `Dedução de valores`: o banco verifica se você tem o saldo necessário em sua conta e, se tiver, o valor é deduzido.
- `Adição de valores`: o banco verifica a conta do seu amigo e adiciona o valor transferido.
- `Confirmação da transação`: você e seu amigo recebem a confirmação da transação por e-mail/mensagem de Texto.

Se por algum motivo a transação não puder ser concluída (por exemplo, se você não tiver saldo suficiente em sua conta), a transação será revertida e nenhum valor será transferido. Isso garante que todas as transações bancárias sejam realizadas de maneira consistente e segura, seguindo as propriedades ACID.
