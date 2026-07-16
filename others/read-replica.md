# Definicoes

É uma cópia somente leitura do seu banco de dados principal (primário). Ela serve para desafogar o banco de dados principal, permitindo que consultas de leitura pesadas, relatórios ou análises sejam processados em servidores separados

Como funciona e principais detalhes:

- Replicação Assíncrona: Os dados são copiados do servidor primário para a réplica de forma assíncrona. Isso significa que há uma pequena janela de atraso (conhecida como replication lag) entre uma alteração no primário e ela aparecer na réplica.

- Separação de Tráfego: A aplicação deve ser configurada para direcionar operações de escrita (INSERT, UPDATE, DELETE) para o banco principal e operações de leitura (SELECT) para as réplicas.- Escalabilidade: Você pode criar múltiplas réplicas (o limite varia conforme o serviço, como até 15 no Amazon RDS) para aumentar massivamente a capacidade de leitura do seu sistema.

- Redução de Latência: Réplicas podem ser distribuídas geograficamente (em diferentes regiões do mundo) para entregar dados mais perto dos usuários.
