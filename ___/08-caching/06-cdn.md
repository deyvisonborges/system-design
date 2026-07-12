# CDN (Content Delivery Network)

> Status: rascunho

## 1. O que é

Uma CDN (Content Delivery Network) é uma rede distribuída de servidores de borda projetada para entregar conteúdo de forma rápida e confiável aos usuários finais. Ela replica ou cacheia ativos (como imagens, vídeos, CSS, JavaScript, APIs e até páginas HTML) em pontos de presença geograficamente próximos ao cliente.

Sinônimos: rede de distribuição de conteúdo, edge network, entrega de conteúdo na borda.

Variações comuns:

- CDN de conteúdo estático (assets, imagens, arquivos multimídia)
- CDN para conteúdo dinâmico/acelerador de aplicação
- CDN com WAF/segurança integrada
- CDN para streaming de vídeo (live e VOD)
- CDN de APIs / edge computing

## 2. Por que existe (o problema que resolve)

CDNs existem para reduzir latência de acesso e aliviar carga no servidor de origem. Antes das CDNs, clientes em diferentes regiões precisavam fazer requisições diretamente ao mesmo data center, resultando em:

- latência alta para usuários distantes,
- maior tempo de carregamento,
- mais tráfego de backbone e custos de egress,
- maior risco de sobrecarga do servidor de origem.

A primeira geração de CDNs surgiu no começo dos anos 2000 com empresas como Akamai, quando a internet global cresceu e a velocidade do usuário final passou a ser a principal métrica de qualidade. O objetivo era aproximar o conteúdo do usuário e evitar que um único ponto de origem se tornasse gargalo.

## 3. Tipos e características

### CDN de conteúdo estático

Como funciona: armazena cópias de arquivos estáticos na borda e serve diretamente do cache quando o cliente solicita.
Prós: redução significativa de latência e custo de origem.
Contras: precisa de políticas de invalidação e de controle de cache.
Camada: camada de aplicação / CDN edge.
Quando usar: imagens, vídeos, CSS, JS, downloads, arquivos estáticos.

### CDN para conteúdo dinâmico / aplicação acelerada

Como funciona: acelera respostas dinâmicas com técnicas de proxy reverso, TCP/TLS optimization e cache parcial.
Prós: melhora desempenho de APIs e páginas dinâmicas.
Contras: complexidade maior e menos ganho quando o conteúdo é altamente personalizado.
Camada: aplicação / camada de transporte.
Quando usar: APIs públicas, sites dinâmicos com alto tráfego global.

### CDN com WAF / segurança integrada

Como funciona: adiciona firewall de aplicação web, bloqueio de bots e proteção DDoS na borda.
Prós: protege a origem, reduz ataques volumétricos.
Contras: custo adicional e risco de bloqueios falsos.
Camada: segurança / borda.
Quando usar: e-commerce, APIs públicas, aplicações expostas.

### CDN de streaming de vídeo

Como funciona: entrega vídeo em fragmentos HLS/DASH de servidores edge perto do usuário.
Prós: menor buffering e melhor experiência de vídeo.
Contras: exige suporte a multi-bitrate e cache control de mídia.
Camada: aplicação / mídia.
Quando usar: streaming de vídeo ao vivo ou sob demanda.

### CDN de APIs / edge computing

Como funciona: executa lógica leve na borda, como transformação de headers, autenticação e roteamento.
Prós: reduz latência e permite processamento próximo ao usuário.
Contras: limitações de execução e complexidade de debugging.
Camada: edge / aplicação.
Quando usar: APIs críticas globalmente, personalização de conteúdo e funções de borda.

## 4. Como funciona (mecanismo interno)

O funcionamento básico de uma CDN envolve:

- PoPs (Points of Presence): servidores distribuídos em várias regiões.
- DNS geográfico: resolve o nome do site para o PoP mais próximo do usuário.
- Cache: cópias de conteúdo guardadas no PoP com TTL.
- Origin pull / push: o PoP obtém conteúdo do servidor de origem quando necessário.
- Invalidação / purga: força remoção de conteúdo desatualizado nas bordas.
- Health checks: verificam se o origin e os PoPs estão disponíveis.

Passo a passo:

1. O usuário faz uma requisição DNS para `www.example.com`.
2. O DNS responde com o endereço IP do PoP mais próximo.
3. O cliente conecta ao PoP e solicita o recurso.
4. Se o recurso estiver em cache e válido, o PoP atende diretamente (cache hit).
5. Se não estiver em cache, o PoP busca no origin, cacheia a resposta e a entrega.
6. Políticas de cache control, cookies e headers definem o tempo de vida e a personalização.

Algoritmos/estratégias comuns:

- Cache-control / max-age / stale-while-revalidate
- Origin shield / mid-tier cache
- Gzip/Brotli compression na borda
- Revalidation condicional (ETag / If-Modified-Since)
- TLS session resumption e OCSP stapling

## 5. Onde e como se aplica na prática

### Nível de máquina/processo único

Uma aplicação local pode usar um proxy de cache como Varnish para simular uma CDN em um único nó.

### Nível de infraestrutura on-premise/self-managed

Ferramentas reais: Varnish, Squid, Apache Traffic Server, NGINX com cache, Fastly.

### Nível de nuvem/managed service

- AWS: Amazon CloudFront, AWS Global Accelerator (para performance de rede), AWS WAF.
- GCP: Cloud CDN, Cloud Armor.
- Azure: Azure CDN, Azure Front Door.
- Outros: Akamai, Fastly, Cloudflare, StackPath, BunnyCDN.

### Nível de orquestração/Kubernetes

No Kubernetes, CDNs funcionam como front door: ingress controllers podem direcionar para serviços, e integrações com Cloudflare Workers ou Fastly permitem edge logic via Kubernetes.

## 6. Quando usar e quando não usar

### Quando usar

- Sites globais com usuários distribuídos.
- Aplicações com muitos ativos estáticos.
- Streaming de vídeo ou downloads grandes.
- APIs expostas globalmente.
- Quando se deseja reduzir custo de egress e carga de origem.

### Quando NÃO usar

- Aplicações intranet locais sem usuários globais.
- Dados altamente sensíveis que não devem ser replicados fora da origem sem criptografia sólida.
- Conteúdo 100% personalizado por usuário onde cache não ajuda.
- Quando o custo de CDN supera os ganhos de performance para um público restrito.

## 7. Exemplos didáticos

### Exemplo 1: site estático internacional

Uma loja online serve imagens e CSS de `www.example.com`. Usuários no Brasil e na Europa são roteados a PoPs próximos. O PoP no Brasil atende localmente imagens e reduz o tempo de carregamento.

### Exemplo 2: API globais com cache parcial

Uma API de consulta de produtos usa cache de 60 segundos na CDN para endpoints de catálogo, enquanto endpoints de carrinho permanecem sem cache. Isso reduz o tráfego para o origin e acelera respostas de inventário.

### Exemplo 3: streaming de vídeo

Uma plataforma de curso online usa CDN para entregar vídeos HLS. A CDN armazena fragmentos próximos ao usuário, reduzindo buffering durante picos de visualização.

## 8. Ferramentas e serviços importantes

### CDNs gerenciadas

- Cloudflare: CDN + WAF + Workers.
- Fastly: CDN de alta performance e edge compute.
- Akamai: CDN corporativa com vasta presença global.
- Amazon CloudFront: integração AWS.
- Google Cloud CDN: integração GCP.
- Azure CDN / Front Door: integração Azure.

### Software self-hosted / proxy

- Varnish Cache: proxy reverso de cache.
- NGINX: cache de proxy reverso e TLS termination.
- Apache Traffic Server: CDN e cache.
- Squid: proxy de cache HTTP.

### Ferramentas auxiliares

- `curl`, `wget`: testar cabeçalhos de cache.
- WebPageTest e Lighthouse: medir impact de CDN.
- Grafana/Prometheus: monitorar latência de borda e cache hit ratio.

## 9. Boas práticas

- Use `Cache-Control`, `ETag` e `Last-Modified` corretamente.
- Defina TTLs apropriados por tipo de conteúdo.
- Configure `stale-while-revalidate` para melhorar disponibilidade em falhas de origin.
- Proteja o origin com `origin access identity` ou `private origin`.
- Monitore cache hit ratio, egress e tempos de resposta.
- Use origem shield ou mid-tier caches para diminuir o número de buscas ao origin.
- Valide headers `Vary` para evitar cache errado em conteúdo com locale / auth.

## 10. Exemplos de implementação

### Exemplo com NGINX (static caching)

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=mycache:10m max_size=10g inactive=60m;
server {
  listen 80;
  location /static/ {
    proxy_cache mycache;
    proxy_cache_valid 200 302 10m;
    proxy_cache_valid 404 1m;
    proxy_cache_min_uses 1;
    proxy_pass http://origin;
    add_header X-Cache-Status $upstream_cache_status;
  }
}
```

### Exemplo com CloudFront

- Crie uma distribuição CloudFront com origin apontando para S3 ou ALB.
- Configure `Cache Policy` para `Cache-Control` e query strings.
- Ative `Origin Shield` para reduzir tráfego de origem.

### Exemplo com Cloudflare Worker

```js
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const cache = caches.default;
  const cacheKey = new Request(request.url, request);
  let response = await cache.match(cacheKey);
  if (!response) {
    response = await fetch(request);
    response = new Response(response.body, response);
    response.headers.set('Cache-Control', 'public, max-age=120');
    event.waitUntil(cache.put(cacheKey, response.clone()));
  }
  return response;
}
```

## 11. Principais desafios e armadilhas

- Cache inválido: conteúdo velho pode ser servido se invalidação não for configurada.
- Cookies e autenticação: cache de respostas autenticadas pode vazar dados.
- TLS termination: cuidado com criptografia interna e segurança de origin.
- Invalidação global lenta: purgar muitos PoPs pode demorar.
- TTLs muito curtos: reduzem cache hit ratio e ganhos de CDN.

## 12. Perguntas de fixação

- O que faz uma CDN e por que a geografia é importante?
- Quando você deve usar uma CDN para APIs e quando não faz sentido?
- Quais cabeçalhos HTTP são essenciais para uma CDN funcionar corretamente?
- Como `Origin Shield` melhora o comportamento de cache?
- Quais são os riscos de depender apenas de cache sem monitorar TTL e hits?
