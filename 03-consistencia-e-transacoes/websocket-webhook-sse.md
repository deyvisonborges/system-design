# Visao geral do problema

O HTTP tradicional foi projetado para comunicação request-response, onde o cliente faz uma requisição e o servidor responde. Este modelo não é adequado para comunicação em tempo real, onde o servidor precisa enviar dados para o cliente sem que o cliente faça uma requisição.

## Websocket

### Fundamentos

É um protocolo que permite comunicação bidirecional entre cliente e servidor, mantendo uma conexão aberta. A conversa comeca com uma requisicao HTTP normal, mas em vez de retornar um corpo de resposta e fechar a conexao, o servidor responde com status 101 (Switching Protocols) e a conexao permanece aberta. A conexao deixa de falar HTTP e passa a usar um protocolo binario especializado.

## Webhook

## Server Sent Events

## Links

- <https://arnab-k.medium.com/websockets-in-nestjs-real-time-applications-992d1a91a494>
