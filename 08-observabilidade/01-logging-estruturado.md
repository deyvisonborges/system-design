# Logging Estruturado

## 1. O que é

Logging estruturado é a prática de gerar logs com formato consistente e machine-readable, normalmente em JSON ou key-value, para permitir busca, agregação e correlação automática.

Sinônimos / nomes alternativos:

- Structured logging
- JSON logging
- Key-value logging
- Event logging
- Log schema

Variações / camadas reconhecidas:

- Text logs com campos estruturados (ex: "timestamp=... level=... message=...")
- JSON logs / logs em formato de objeto
- Logs de auditoria com schema fixo
- Logs de aplicação versus logs de infraestrutura
- OpenTelemetry Logs / Elastic Common Schema / Cloud Native Logging

## 2. Por que existe (o problema que resolve)

Historicamente, logs eram texto livre e apenas humanos podiam lê-los corretamente. Isso dificultava a busca, correlação entre serviços, análise automática e ingestão em ferramentas de observabilidade.

Antes do logging estruturado, equipes dependiam de grep, análise manual e parsers frágeis. Quando havia falha em produção, recuperar o contexto exato da requisição entre microserviços era lento e sujeito a erro.

O padrão ganhou força com a adoção de stacks como ELK (ElasticSearch + Logstash + Kibana), Splunk e depois com iniciativas de observabilidade cloud-native. Empresas como Netflix, LinkedIn e Google demonstraram o valor de logs estruturados em sistemas distribuídos.

## 3. Tipos e características

### 3.1 Logs em texto estruturado

Como funciona:

- O logger escreve strings formatadas com pares chave=valor.
- Exemplos: `timestamp=2026-07-10T10:00:00Z level=INFO request_id=xyz message="User authenticated"`.

Prós:

- Mais fácil do que analisar texto livre.
- Compatível com parsers tradicionais.

Contras:

- Ainda depende de parsing customizado.
- Campos podem não ser válidos JSON e variam por biblioteca.

Camada:

- Aplicação / biblioteca de logging.

Quando usar:

- Quando você já tem pipeline de logs legados e precisa de estrutura leve.

### 3.2 Logs JSON

Como funciona:

- Cada entrada de log é um objeto JSON completo.
- Ferramentas de ingestão indexam automaticamente campos.

Prós:

- Fácil de parsear e indexar.
- Permite atributos aninhados e tipos nativos (números, booleanos).

Contras:

- Pode gerar payloads maiores.
- Processamento mais custoso em alta taxa de logs.

Camada:

- Aplicação / exportador de logs.

Quando usar:

- Em microsserviços e arquiteturas com ingestão centralizada via ELK, Fluentd ou OpenTelemetry.

### 3.3 Logs de auditoria com schema fixo

Como funciona:

- O log segue um schema obrigatório, descrevendo eventos de segurança ou compliance.
- Campos como `userId`, `action`, `resource`, `result` são obrigatórios.

Prós:

- Facilita compliance, investigação forense e auditoria.

Contras:

- Menos flexível para eventos ad hoc.
- Exige governança de schema.

Camada:

- Aplicação / segurança / conformidade.

Quando usar:

- Em sistemas financeiros, saúde ou qualquer domínio regulado.

### 3.4 Logs de infraestrutura vs logs de aplicação

Como funciona:

- Logs de infra incluem eventos de container, kernel e rede.
- Logs de aplicação incluem exceções, métricas de negócio e contexto transacional.

Prós:

- Separação clara permite pipelines diferentes.

Contras:

- Misturar ambos sem distinção dificulta análise.

Camada:

- Infraestrutura / plataforma.

Quando usar:

- Use logs de aplicação para debug funcional e logs de infraestrutura para operações.

## 4. Como funciona (mecanismo interno)

1. Instrumentação: a aplicação ou framework usa uma biblioteca de logging (Logback, Log4j2, Winston, Pino).
2. Serializer: os dados do log são convertidos para um formato estruturado (JSON, key-value).
3. Enriquecimento: campos como `timestamp`, `level`, `service`, `trace_id`, `request_id`, `user_id` e `environment` são adicionados.
4. Saída: o log é enviado para stdout/stderr, arquivo local ou agente de logs.
5. Agente / coletor: Fluentd, Fluent Bit, Logstash, Promtail ou OpenTelemetry Collector capturam as entradas.
6. Ingestão: o pipeline normaliza os campos e indexa em um sistema de busca ou armazenamento de logs.
7. Visualização: Kibana, Grafana Loki, Splunk, Datadog ou Cloud console exibem os logs pesquisáveis.

Componentes:

- Logger de aplicação: gera eventos de log.
- Processador local: enriquece e formata os eventos.
- Agente/coletor: transporta para a plataforma central.
- Armazenamento: índice ou datastore de logs.
- Interface de consulta: dashboard e alertas.

Algoritmos/estratégias usados:

- Rotas de logs baseadas em labels/campos.
- Parsing e normalização de JSON.
- Enriquecimento automático com MDC/Context.
- Compressão e retenção configurável.

## 5. Onde e como se aplica na prática

### Nível de máquina/processo único

- Em um serviço local, o logger escreve JSON no stdout e o processo de container captura.
- Exemplo: `logback-spring.xml` escreve para `console` com encoder JSON.
- Vantagem: fácil depuração e compatibilidade com containers.

### Nível on-premise/self-managed

- ELK stack: Logstash parseia, Elasticsearch indexa, Kibana consulta.
- Graylog: captura, normaliza e agrupa logs estruturados.
- Fluentd/Fluent Bit: agentes que enviam JSON para Kafka, Elasticsearch ou Splunk.
- Splunk Enterprise e rsyslog com parser de JSON.

### Nível de nuvem/managed service

- AWS CloudWatch Logs: ingestão de logs JSON com CloudWatch Logs Insights.
- GCP Cloud Logging: suporta jsonPayload e schemas de logs.
- Azure Monitor Logs: Log Analytics com campos estruturados.
- Datadog Logs, New Relic Logs, Elastic Cloud.

### Nível de orquestração/Kubernetes

- K8s trata logs de pods via stdout/stderr.
- DaemonSet de Fluentd/Fluent Bit coleta e encaminha JSON.
- Istio/Envoy adicionam `istio_policy_status`, `request_id` e `source_workload` aos logs.
- OpenTelemetry Collector em k8s pode coletar logs estruturados e enviar a backend.

## 6. Casos de uso reais e quando NÃO usar

### Casos de uso reais

- Plataforma de e-commerce: logs estruturados de pedidos, checkout e pagamento. Tipo: JSON logs com `request_id`, `order_id`, `user_id`.
- Fintech / bancos: auditoria e conformidade em eventos de transação. Tipo: logs de auditoria com schema fixo.
- Microserviços distribuídos: correlação de requisições usando `trace_id` e `span_id`. Tipo: logs JSON com enriquecimento de contexto.
- Aplicações SaaS multi-tenant: isolamento de tenant via campo `tenant_id`. Tipo: logs com labels multi-tenant.
- Operações de plataforma: logs de container e pod para troubleshooting. Tipo: infraestrutura + application logs separados.

### Quando NÃO usar ou evitar

- Sistemas embarcados/IoT com recursos limitados: o overhead de JSON pode ser proibitivo.
- Logs transitórios de debug extremo em alto volume: não estruture em JSON campos excessivos que aumentem custo de armazenamento.
- Aplicações sem pipeline de logs centralizado: gerar logs estruturados sem um coletor é desperdício; preferir estrutura mínima até ter ingestão.
- Campos PII ou sensíveis sem anonimização: logs estruturados tornam dados mais fáceis de indexar, aumentando risco de exposição.

## 7. Cenários práticos e trade-offs

### Cenário 1: Investigação de produção em microserviços

Um pedido falha em um serviço de checkout. Os logs estruturados com `order_id`, `trace_id` e `service` permitem filtrar rapidamente todos os eventos relacionados ao pedido e reconstruir o fluxo entre `gateway`, `payments` e `inventory`.

### Cenário 2: Picos de tráfego e custo de armazenamento

Durante uma campanha de marketing, os logs aumentam 10x. Se os logs forem JSON verbosos com campos desnecessários, a ingestão e retenção se tornam caras. A solução é reduzir campos e usar amostragem ou retenção mais curta para logs de debug.

### Cenário 3: Falha em ingestão e schema

Uma equipe altera o schema e deixa de enviar o campo `request_id`. O pipeline de ingestão rejeita ou indexa logs incompletos, quebrando dashboards. O aprendizado é validar schema e manter compatibilidade.

### Tabela de trade-offs

| Variação | Latência | Consistência | Custo operacional | Complexidade | Resiliência |
|---|---|---|---|---|---|
| Texto estruturado | Baixa | Média | Baixo | Baixa | Média |
| JSON logs | Média | Alta | Médio | Médio | Alta |
| Logs de auditoria | Média | Alta | Alto | Alto | Alta |
| Infra logs vs app logs | Baixa | Média | Médio | Médio | Alta |

## 8. Diagrama e fluxo visual

```mermaid
flowchart TD
    A[Aplicação] -->|Gera evento| B[Logger estruturado]
    B --> C[JSON / key-value]
    C --> D[Agente de logs (Fluentd/Collector)]
    D --> E[Pipeline de ingestão]
    E --> F[Armazenamento indexado]
    F --> G[Dashboard / Busca]
    F --> H[Alertas / Monitoramento]
```

**Prompt de imagem em inglês**

"Create a conceptual illustration of structured logging in a distributed system: an application emitting JSON log events, a collector ingesting and parsing them, and a searchable dashboard. Show metadata fields like timestamp, request_id, service, and level, with a modern cloud operations style."

## 9. Exemplo aplicado — Java + Spring

`pom.xml` dependencies:

```xml
<dependency>
  <groupId>net.logstash.logback</groupId>
  <artifactId>logstash-logback-encoder</artifactId>
  <version>7.4</version>
</dependency>
```

`src/main/resources/logback-spring.xml`:

```xml
<configuration>
  <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder" />
  </appender>

  <logger name="org.springframework" level="INFO" />
  <root level="INFO">
    <appender-ref ref="CONSOLE" />
  </root>
</configuration>
```

`OrderService.java`:

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;

@Service
public class OrderService {
  private static final Logger log = LoggerFactory.getLogger(OrderService.class);

  public void processOrder(String orderId, String userId) {
    MDC.put("order_id", orderId);
    MDC.put("user_id", userId);
    log.info("Processing order", Map.of("event", "order_processing", "order_id", orderId, "user_id", userId));
    try {
      // lógica de negócio
    } catch (Exception ex) {
      log.error("Order processing failed", ex);
    } finally {
      MDC.clear();
    }
  }
}
```

Pontos-chave:

- `LogstashEncoder` converte cada evento em JSON.
- `MDC` adiciona contexto transacional a todas as linhas de log.
- Assim é possível buscar por `order_id` ou `user_id` em dashboards.

## 10. Exemplo aplicado — TypeScript + NestJS

`package.json`:

```json
"dependencies": {
  "@nestjs/common": "^10.0.0",
  "@nestjs/core": "^10.0.0",
  "winston": "^3.9.0",
  "nest-winston": "^1.8.0"
}
```

`logger.options.ts`:

```ts
import { utilities as nestWinstonModuleUtilities, WinstonModuleOptions } from 'nest-winston';
import * as winston from 'winston';

export const winstonConfig: WinstonModuleOptions = {
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ]
};
```

`app.module.ts`:

```ts
import { Module } from '@nestjs/common';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from './logger.options';
import { OrdersModule } from './orders/orders.module';

@Module({
  imports: [WinstonModule.forRoot(winstonConfig), OrdersModule],
})
export class AppModule {}
```

`orders.service.ts`:

```ts
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  processOrder(orderId: string, userId: string) {
    this.logger.log({
      message: 'Processing order',
      orderId,
      userId,
      event: 'order_processing',
    });
  }
}
```

Pontos-chave:

- `winston.format.json()` produz saída estruturada JSON.
- Logs podem ser coletados por Fluent Bit e enviados para Elasticsearch ou CloudWatch.
- O `message` e campos adicionais facilitam a análise.

## 11. Comparação e armadilhas comuns

### Comparação com logs tradicionais

- Logs tradicionais são texto livre e difíceis de parsear.
- Logging estruturado oferece campos nomeados e permite buscas por atributos específicos.

### Comparação com métricas

- Métricas são numéricas e agregadas.
- Logs estruturados capturam eventos detalhados e contexto rico.

### Erros comuns

- Ausência de um schema consistente: causa inconsistência entre serviços e dificulta consulta.
- Incluir PII sem anonimização: expõe dados sensíveis em um formato fácil de indexar.
- Não adicionar campos de correlação (`trace_id`, `request_id`): torna difícil juntar eventos de uma mesma transação.
- Usar JSON excessivamente verboso em alta taxa de logs: aumenta custo e latência de ingestão.

## 12. Perguntas para fixação

- Qual a diferença técnica entre logging estruturado e logs de texto livre?
- Quando é melhor usar logs JSON em vez de logs em formato key-value?
- Por que `request_id` e `trace_id` são importantes em logs estruturados?
- Quais são os riscos de não padronizar o schema de logs em uma plataforma de microserviços?
- Como o logging estruturado se integra com um pipeline de ingestão como Fluentd ou OpenTelemetry Collector?
