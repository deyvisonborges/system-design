# Java + Spring Boot (Kafka consumer com backpressure real)

```java
@Component
@RequiredArgsConstructor
public class AnaliseCreditoConsumer {

    // Limita chamadas concorrentes ao bureau externo
    private final Semaphore bureauCapacity = new Semaphore(20);
    private final BureauScoreClient bureauClient;
    private final MeterRegistry meterRegistry;

    @KafkaListener(
        topics = "analise-credito-solicitada",
        groupId = "credito-gateway-pf",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consume(ConsumerRecord<String, AnaliseCreditoEvent> record, Acknowledgment ack) {
        AnaliseCreditoEvent evento = record.value();

        // Backpressure real: se não conseguir permit, NÃO faz commit do offset.
        // Isso faz o Kafka reentregar depois, sem estourar memória do consumer.
        boolean acquired = false;
        try {
            acquired = bureauCapacity.tryAcquire(200, TimeUnit.MILLISECONDS);
            if (!acquired) {
                meterRegistry.counter("credito.bureau.backpressure.rejected").increment();
                // Não faz ack -> mensagem não é commitada -> será reprocessada
                return;
            }

            var score = bureauClient.consultarScore(evento.getCpf());
            processarResultado(evento, score);
            ack.acknowledge();

        } catch (Exception e) {
            log.error("Erro ao processar análise de crédito CPF={}", evento.getCpf(), e);
            // não dá ack -> reprocessa
        } finally {
            if (acquired) bureauCapacity.release();
        }
    }
}
```

```yaml
spring:
  kafka:
    consumer:
      max-poll-records: 50        # limita lote por poll
      fetch-max-wait: 500ms
    listener:
      concurrency: 3              # 3 threads consumidoras
      ack-mode: manual            # ack manual = controle fino de quando avançar offset
```

# NestJS (mesma ideia, com fila interna + p-limit)

```ts
import PQueue from 'p-queue';
@Injectable()
export class AnaliseCreditoConsumer {
  // fila com concorrência controlada — equivalente ao Semaphore do Java
  private readonly queue = new PQueue({ concurrency: 20 });

  constructor(
    private readonly bureauClient: BureauScoreClient,
    private readonly metrics: MetricsService,
  ) {}

  @EventPattern('analise-credito-solicitada')
  async handleAnaliseCredito(
    @Payload() evento: AnaliseCreditoEvent,
    @Ctx() context: KafkaContext,
  ) {
    const heartbeat = context.getHeartbeat();

    // Se a fila já está saturada, aplica load shedding
    if (this.queue.size > 500) {
      this.metrics.increment('credito.bureau.backpressure.rejected');
      throw new Error('Fila saturada — mensagem será reprocessada pelo Kafka');
      // não commitamos o offset -> Kafka reentrega
    }

    await this.queue.add(async () => {
      const score = await this.bureauClient.consultarScore(evento.cpf);
      await this.processarResultado(evento, score);
    });

    const consumer = context.getConsumer();
    await consumer.commitOffsets([{
      topic: context.getTopic(),
      partition: context.getPartition(),
      offset: (Number(context.getMessage().offset) + 1).toString(),
    }]);
  }
}
```

1. Offset commit manual é o mecanismo de backpressure de verdade em Kafka — não fazer ack()/commit é o que sinaliza "não avancei, me manda de novo depois". O Semaphore/token sozinho só protege memória local, mas não avisa o Kafka.
2. max-poll-records + concurrency controlam quanto entra por vez — isso é o "queue-length-based throttling" do seu arquivo, só que configurado na origem (broker → consumer), não depois que já virou objeto em memória.
3. Métricas de rejeição (meterRegistry.counter(...)) são essenciais no seu contexto de Dynatrace/observability — sem isso você não sabe se está rejeitando 2% ou 40% do tráfego.
