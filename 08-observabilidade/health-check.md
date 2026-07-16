## 1. O que é

Health Check é um mecanismo de verificação que determina se um serviço, componente ou instância está apto a receber tráfego e operar corretamente.

Sinônimos: checagem de saúde, health probe, readiness check, liveness probe.

Tipos/camadas:

- Liveness check
- Readiness check
- Startup check
- Active health check
- Passive health check

## 2. Por que existe (o problema que resolve)

Health checks existem porque era comum enviar tráfego para processos que não estavam prontos ou que haviam sofrido falha silenciosa. Antes, balanceadores e orquestradores não distinguiam entre um processo iniciado e um processo realmente pronto.

A origem prática vem de sistemas como HAProxy, Kubernetes e práticas de service discovery, onde é preciso remover instâncias ruins do pool para evitar falhas de usuário.

## 3. Tipos e características

### Liveness check

Como funciona: valida se o processo está vivo e respondendo. Se falhar, o container/pod é reiniciado.
Prós: detecta deadlocks e travamentos.
Contras: não verifica se o serviço está pronto para receber tráfego.
Camada: aplicação.
Quando usar: sempre em plataformas de orquestração como Kubernetes.

### Readiness check

Como funciona: verifica se o serviço está pronto para atender requisições corretamente.
Prós: evita roteamento para instâncias que ainda estão inicializando.
Contras: pode demorar mais para retornar pronto em serviços complexos.
Camada: aplicação/infrastrutura.
Quando usar: para controles de rollout e auto-scaling.

### Startup check

Como funciona: valida a inicialização completa da aplicação antes de ativar liveness/readiness.
Prós: previne reinício prematuro durante boot.
Contras: adiciona etapas extras à inicialização.
Camada: aplicação.
Quando usar: serviços com inicialização demorada.

### Active health check

Como funciona: sondas externas iniciam verificações periódicas.
Prós: detecta falhas de ponta a ponta.
Contras: gera overhead de rede.
Camada: rede/infrastrutura.
Quando usar: em balanceadores e proxies.

### Passive health check

Como funciona: streams de tráfego são observados e falhas na comunicação acionam remoção.
Prós: menos overhead adicional.
Contras: falha só é detectada após tentativa de tráfego.
Camada: aplicação/rede.
Quando usar: em proxies que já têm métricas de erro.

## 4. Como funciona (mecanismo interno)

Health checks trabalham em três componentes principais:

- Endpoint de saúde na aplicação (/health, /live, /ready)
- Agente ou balanceador que faz requests periódicos
- Lógica de resposta e status

Algoritmos/estratégias:

- HTTP GET 200/503
- TCP connect / socket probe
- Exec probe no container
- TTL baseado em heartbeat

O fluxo típico:

1. Serviço expõe endpoint de saúde.
2. Orquestrador ou load balancer faz requisições a intervalos regulares.
3. Se o endpoint devolver status de erro, a instância é retirada do pool ou reiniciada.

## 5. Onde e como se aplica na prática

### Nível de máquina/processo único

No nível local, um serviço pode expor `/health` e o NGINX ou HAProxy faz health check via HTTP.

### Nível de infraestrutura on-premise/self-managed

Ferramentas reais: HAProxy, NGINX, Envoy, Consul, Keepalived, Apache HTTPD.

### Nível de nuvem/managed service

AWS: ELB/ALB health checks, Route 53 health checks.
GCP: Cloud Load Balancing health checks.
Azure: Azure Load Balancer health probes.

### Nível de orquestração/Kubernetes

Kubernetes: livenessProbe, readinessProbe e startupProbe em `PodSpec`. Istio e Linkerd também usam health checks para service mesh.

## 6. Casos de uso reais e quando NÃO usar

### Casos de uso reais

1. Kubernetes: readiness check evita tráfego para pods que não aceitaram conexões.
2. AWS ALB: health checks de HTTP para determinar targets saudáveis.
3. Consul: service health checks com scripts personalizados.
4. Envoy: active health checks para proxies upstream.

### Quando NÃO usar ou evitar

- Serviços sem endpoint HTTP ou TCP: use exec probe ou health check de socket.
- Componentes que não suportam reinício rápido: liveness pode causar reinícios desnecessários.
- Serviços de leitura apenas se o health check checa somente connectivity de escrita.
- Se a detecção for muito sensível: pode causar flapping e remoção de instâncias saudáveis.

## 7. Cenários práticos e trade-offs

### Cenário 1: boot lento

Um microserviço leva 90s para carregar caches. O startupProbe em Kubernetes mantém o pod fora do pool até estar pronto.

### Cenário 2: deadlock em produção

O processo trava mas a porta fica aberta. A livenessProbe detecta e reinicia o pod.

### Cenário 3: endpoint degradado

Uma instância responde 200 no health, mas 503 em uma dependência crítica. Um readiness check profundo remove a instância do pool.

| Tipo | Latência | Consistência | Custo operacional | Complexidade de implementação | Resiliência |
|---|---|---|---|---|---|
| Liveness | Baixa | Médio | Baixo | Baixo | Alto |
| Readiness | Baixa | Alto | Médio | Médio | Alto |
| Startup | Médio | Alto | Médio | Médio | Alto |
| Active | Baixo | Alto | Médio | Médio | Alto |
| Passive | Baixo | Médio | Baixo | Baixo | Médio |

## 8. Diagrama e fluxo visual

a) Mermaid:

```mermaid
flowchart LR
  A[Aplicação] --> B[/live endpoint]
  A --> C[/ready endpoint]
  D[Orquestrador] --> E[livenessProbe]
  D --> F[readinessProbe]
  E -- falha --> G[reinicia pod]
  F -- falha --> H[remove do serviço]
```

b) Prompt de imagem:
"Illustration of health checks in a distributed system with readiness and liveness probes, a load balancer checking endpoints, and Kubernetes pod lifecycle management."

## 9. Exemplo aplicado — Java + Spring

```java
@RestController
public class HealthController {

  @GetMapping("/health/live")
  public ResponseEntity<String> live() {
    return ResponseEntity.ok("alive");
  }

  @GetMapping("/health/ready")
  public ResponseEntity<String> ready() {
    if (cacheService.isInitialized() && dbClient.isConnected()) {
      return ResponseEntity.ok("ready");
    }
    return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("not ready");
  }
}
```

Comentários: `liveness` é simples, `readiness` verifica dependências críticas e pode impedir roteamento prematuro.

## 10. Exemplo aplicado — TypeScript + NestJS

```ts
@Controller('health')
export class HealthController {
  constructor(private readonly cacheService: CacheService, private readonly dbService: DbService) {}

  @Get('live')
  live() {
    return { status: 'alive' };
  }

  @Get('ready')
  async ready() {
    const ready = await this.cacheService.isInitialized() && this.dbService.isConnected();
    if (!ready) {
      throw new ServiceUnavailableException('not ready');
    }
    return { status: 'ready' };
  }
}
```

Comentários: NestJS permite lançar `ServiceUnavailableException` para readiness fail, o que o orquestrador traduz em não saudável.

## 11. Comparação e armadilhas comuns

Comparação com monitoramento de aplicação: health checks são decisões binárias de saúde, enquanto métricas e logs são sinais contínuos.

Erros comuns:

- implementar liveness e readiness no mesmo endpoint: mistura objetivos.
- retornar 200 mesmo se dependências falharem: false positive.
- checar apenas a própria aplicação e não dependências críticas.
- usar timeouts rígidos sem jitter: pode gerar flapping na detecção.

## 12. Perguntas para fixação

1. Qual a diferença entre liveness e readiness checks?
2. Por que um startup check pode ser necessário em Kubernetes?
3. Quando um health check ativo é melhor que um passivo?
4. Como evitar flapping com health checks?
5. Qual é o risco de expor um health check muito profundo em um load balancer?
