## 1. O que é
Probes são mecanismos de verificação de saúde usados em orquestração e balanceamento para determinar se uma instância está pronta para receber tráfego e se continua funcional ao longo do tempo.

Sinônimos: probes de saúde, liveness/readiness probes, health probes, startup probes.

Tipos/camadas:
- Liveness Probe
- Readiness Probe
- Startup Probe
- TCP Probe
- HTTP Probe
- Exec Probe

## 2. Por que existe (o problema que resolve)
Probes surgiram para resolver a distinção entre um processo "em execução" e um serviço "pronto". Em ambientes como Kubernetes e sistemas de distribuição de tráfego, era comum rotear requisições para instâncias que haviam iniciado o processo, mas ainda não carregaram dependências ou haviam travado.

A prática consolidou-se em Kubernetes com contêineres e orquestração, inspirada por soluções de load balancers e service discovery de datacenters tradicionais.

## 3. Tipos e características
### Liveness Probe
Como funciona: verifica se o processo ou container ainda está vivo.
Prós: detecta deadlocks e travamentos invisíveis.
Contras: se configurada de forma errada, reinicia componentes saudáveis.
Camada: aplicação/container.
Quando usar: sempre em ambiente orquestrado para reinício automático de pods travados.

### Readiness Probe
Como funciona: determina se a aplicação está pronta para receber tráfego.
Prós: evita enviar requisições para instâncias ainda em boot ou sem dependências.
Contras: pode retardar a adição de instâncias ao pool se for muito profunda.
Camada: aplicação/infrastrutura.
Quando usar: para controlar rollouts e evitar usuários se conectarem prematuramente.

### Startup Probe
Como funciona: valida a inicialização completa antes de ativar liveness/readiness.
Prós: reduz reinícios prematuros durante boot longo.
Contras: adiciona mais uma fase de verificação e complexidade.
Camada: aplicação/container.
Quando usar: aplicações com inicialização demorada ou carregamento de caches grandes.

### TCP Probe
Como funciona: tenta estabelecer conexão TCP no endpoint.
Prós: simples e de baixo overhead.
Contras: não valida se o serviço responde corretamente na camada HTTP ou da aplicação.
Camada: transporte/rede.
Quando usar: serviços TCP brutos ou quando não há HTTP disponível.

### HTTP Probe
Como funciona: faz requisição HTTP/HTTPS a um endpoint de saúde.
Prós: pode validar rotas e respostas de status.
Contras: depende de infraestrutura de aplicação.
Camada: aplicação/transporte.
Quando usar: serviços HTTP, APIs e microserviços REST.

### Exec Probe
Como funciona: executa um comando dentro do container.
Prós: permite validações customizadas de dependências e estado interno.
Contras: não funciona fora de ambientes containerizados e adiciona overhead local.
Camada: aplicação/host.
Quando usar: quando a lógica de saúde não pode ser expressa em HTTP ou TCP.

## 4. Como funciona (mecanismo interno)
Probes são compostos por:
- Endpoint ou comando de verificação
- Agente/daemon do orquestrador
- Configuração de intervalo, timeout e sucessos/falhas

Fluxo típico:
1. O pod ou instância expõe um endpoint ou comando.
2. O orquestrador (Kubernetes kubelet, AWS ELB, Istio) consulta o probe em intervalos.
3. Se o probe falhar por `failureThreshold`, o recurso é removido do pool ou reiniciado.
4. Em readiness, a instância é só adicionada ao serviço após `successThreshold` sucessos.

Algoritmos/estratégias:
- Check periódica com jitter para evitar sincronização.
- Backoff exponencial em retries de probe.
- Verificações de profundidade progressiva: startup → readiness → liveness.

## 5. Onde e como se aplica na prática
### Nível de máquina/processo único
Em uma VM ou processo local, o NGINX ou HAProxy pode usar TCP/HTTP probes para uma aplicação que escuta em uma porta.

### Nível de infraestrutura on-premise/self-managed
Ferramentas reais: HAProxy, NGINX, Consul, Envoy, Keepalived.

### Nível de nuvem/managed service
AWS: ELB/ALB health checks, ECS task health checks.
GCP: Cloud Load Balancing health checks.
Azure: Azure Load Balancer health probes, Azure App Service health checks.

### Nível de orquestração/Kubernetes
Kubernetes: `livenessProbe`, `readinessProbe`, `startupProbe` em `PodSpec`; Istio e Linkerd também usam probes para determinar endpoint readiness.

## 6. Casos de uso reais e quando NÃO usar
### Casos de uso reais
1. Kubernetes: aplicações Spring Boot expõem `/actuator/health` como readiness.
2. AWS ALB: verifica `/healthz` para targets em EC2 ou ECS.
3. Envoy: health check ativo upstream para balanceamento.
4. Consul: serviços registrados com HTTP/TCP checks.

### Quando NÃO usar ou evitar
- Serviços que não aceitam conexões externas: use exec probe.
- Componentes somente backend sem dependência de rede: health check HTTP pode ser irrelevante.
- Sistemas com boot rápido e cargas previsíveis: startup probe pode ser excessivo.
- Probes que são muito pesados: podem consumir recursos e gerar falsos negativos.

## 7. Cenários práticos e trade-offs
### Cenário 1: inicialização lenta
Uma API Java demora a carregar caches e conexões. O startup probe mantém o pod fora de tráfego até completar.

### Cenário 2: deadlock silencioso
O processo está vivo, mas não responde à API. A liveness probe detecta o travamento e reinicia o pod.

### Cenário 3: dependência externa indisponível
A aplicação não está pronta porque não consegue conectar ao banco. A readiness probe falha e o serviço não recebe tráfego.

| Tipo | Latência | Consistência | Custo operacional | Complexidade de implementação | Resiliência |
|---|---|---|---|---|---|
| Liveness | Baixa | Médio | Baixo | Baixo | Alto |
| Readiness | Baixa | Alto | Médio | Médio | Alto |
| Startup | Médio | Alto | Médio | Médio | Alto |
| TCP | Baixa | Médio | Baixo | Baixo | Médio |
| HTTP | Baixa | Alto | Médio | Médio | Alto |
| Exec | Médio | Alto | Médio | Alto | Alto |

## 8. Diagrama e fluxo visual
a) Mermaid:
```mermaid
flowchart TD
  A[Pod] --> B[/health/live]
  A --> C[/health/ready]
  D[Kubelet] --> B
  D --> C
  B -- ok --> E[Pod permanece]
  C -- ok --> F[Pod recebe tráfego]
  B -- fail --> G[reinicia container]
  C -- fail --> H[remove do service]
```

b) Prompt de imagem:
"Illustration of Kubernetes health probes with liveness and readiness checks, a kubelet checking endpoints, and traffic flow only after readiness is confirmed." 

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
    if (!database.isConnected() || !cache.isReady()) {
      return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("not ready");
    }
    return ResponseEntity.ok("ready");
  }
}
```

Comentários: o endpoint de readiness verifica dependências externas, enquanto o endpoint de liveness é apenas um pulse.

## 10. Exemplo aplicado — TypeScript + NestJS
```ts
@Controller('health')
export class HealthController {
  constructor(private readonly dbService: DbService) {}

  @Get('live')
  live() {
    return { status: 'alive' };
  }

  @Get('ready')
  async ready() {
    const connected = await this.dbService.isConnected();
    if (!connected) {
      throw new ServiceUnavailableException('not ready');
    }
    return { status: 'ready' };
  }
}
```

Comentários: NestJS lança exceção apropriada para indicar não disponibilidade ao orquestrador.

## 11. Comparação e armadilhas comuns
Comparação com monitoramento contínuo: probes são ações ativas de verificação, enquanto métricas são sinais positivos ou negativos contínuos.

Erros comuns:
- usar readiness probe no mesmo endpoint que liveness: mistura objetivos.
- definir timeout menor que o tempo normal de inicialização: causa falsos positivos.
- criar probe HTTP que consulta demais dependências: pode tornar o probe frágil e instável.
- não usar sucesso/failure thresholds: faz com que uma única falha derrube o serviço.

## 12. Perguntas para fixação
1. Qual a diferença prática entre readiness e liveness probe?
2. Por que um startup probe é útil para aplicações que carregam caches?
3. Quando um TCP probe é mais adequado que um HTTP probe?
4. Como a threshold de falhas influencia a estabilidade de probes?
5. Quais são as armadilhas de usar um probe muito profundo?