# JSON-RPC

JSON-RPC é um protocolo leve de chamada de procedimento remoto que usa JSON para enviar dados estruturados. Ele permite a comunicação bidirecional sem estado entre cliente e servidor, onde o cliente pode executar funções remotas passando parâmetros e o servidor responde com resultados ou erros

## Exemplo de Requisição

Uma requisição típica possui quatro chaves principais:

- jsonrpc: A versão do protocolo (geralmente "2.0").
- method: Uma string contendo o nome do método que você deseja invocar.
- params: Um array ou objeto com os parâmetros passados para o método.
- id: Um identificador único que vincula a resposta à requisição enviada. (Se for omitido, o servidor tratará a requisição como uma "notificação", sem gerar resposta)

```json
{
  "jsonrpc": "2.0",
  "method": "subtract",
  "params": [42, 23],
  "id": 1
}

```

## Exemplode Resposta

Após processar a requisição, o servidor retorna um objeto JSON que pode conter o resultado da execução ou um erro:

- jsonrpc: A mesma versão do protocolo.
- result: O dado retornado pelo método (presente em caso de sucesso).
- error: Um objeto contendo código e mensagem (presente em caso de falha).
- id: O mesmo ID único da requisição correspondente.

```json
{
  "jsonrpc": "2.0",
  "result": 19,
  "id": 1
}
```
