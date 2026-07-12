#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script de reorganização - system-design
# ------------------------------------------------------------------------------
# NÃO move nem apaga nenhum arquivo existente.
# Apenas cria as novas pastas + stubs de artigos que ainda não existem.
# Rode a partir da raiz do repo (onde está o README.md atual).
#
# Uso:
#   chmod +x reorganizar.sh
#   ./reorganizar.sh
# ==============================================================================

ROOT="$(pwd)"
echo ">> Criando estrutura em: $ROOT"

# ------------------------------------------------------------------------------
# Função utilitária: cria arquivo .md com stub, só se ainda não existir
# ------------------------------------------------------------------------------
make_stub() {
  local filepath="$1"
  local title="$2"

  if [ -f "$filepath" ]; then
    echo "   [skip] já existe: $filepath"
    return
  fi

  mkdir -p "$(dirname "$filepath")"
  cat > "$filepath" <<EOF
# ${title}

> Status: rascunho

## O que é

## Quando usar

## Trade-offs

## Exemplo prático

## Referências
EOF
  echo "   [novo]  $filepath"
}

# ------------------------------------------------------------------------------
# Pastas de assets (imagens ficam separadas dos .md a partir de agora)
# ------------------------------------------------------------------------------
echo ""
echo "== Criando pasta de assets =="
mkdir -p "$ROOT/_assets"
echo "   [novo]  _assets/ (mova os .png existentes das pastas 01-11 para cá manualmente, ou peça outro script pra isso)"

# ------------------------------------------------------------------------------
# 05-container-patterns está com número duplicado com 05-resiliencia.
# Renomeamos a pasta de container-patterns para 06 e empurramos as seguintes.
# Como você optou por NÃO mover arquivos, deixamos isso documentado aqui:
# ------------------------------------------------------------------------------
echo ""
echo "== ATENÇÃO: conflito de numeração existente =="
echo "   05-container-patterns e 05-resiliencia dividem o mesmo número."
echo "   Sugestão (não aplicada automaticamente): renomear pastas para"
echo "   evitar ambiguidade, seguindo a nova numeração abaixo:"
echo ""
echo "     01-fundamentos-e-escalabilidade"
echo "     02-comunicacao-e-integracao"
echo "     03-consistencia-e-transacoes"
echo "     04-persistencia-e-dados"
echo "     05-resiliencia"
echo "     06-container-patterns"
echo "     07-deployment"
echo "     08-caching              <- NOVA (ver abaixo)"
echo "     09-observabilidade"
echo "     10-seguranca"
echo "     11-confiabilidade"
echo "     12-trade-offs"
echo "     others/"
echo ""
echo "   Para renomear você mesmo (preservando git history), rode:"
echo "     git mv 05-container-patterns 06-container-patterns"
echo "     git mv 06-deployment 07-deployment"
echo "     git mv 07-trade-offs 12-trade-offs"
echo "     git mv 08-observabilidade 09-observabilidade"
echo "     git mv 09-seguranca 10-seguranca"
echo "     git mv 10-caching 08-caching   # depois de consolidar (ver abaixo)"
echo "     git mv 11-confiabilidade 11-confiabilidade  # já ok"

# ------------------------------------------------------------------------------
# 08-caching (nova pasta consolidada — hoje caching está espalhado em
# 10-caching/03-cdn.md e 03-consistencia-e-transacoes/14-caching.md)
# ------------------------------------------------------------------------------
echo ""
echo "== Criando pasta consolidada de Caching =="
CACHING_DIR="$ROOT/08-caching"

make_stub "$CACHING_DIR/01-fundamentos-de-cache.md" "Fundamentos de Cache (o que é, hit/miss, TTL)"
make_stub "$CACHING_DIR/02-cache-aside.md" "Cache-Aside Pattern"
make_stub "$CACHING_DIR/03-write-through-vs-write-behind.md" "Write-Through vs Write-Behind vs Write-Around"
make_stub "$CACHING_DIR/04-cache-invalidation.md" "Cache Invalidation Strategies"
make_stub "$CACHING_DIR/05-cache-stampede-e-thundering-herd.md" "Cache Stampede e Thundering Herd"
make_stub "$CACHING_DIR/06-cdn.md" "CDN (Content Delivery Network)"
make_stub "$CACHING_DIR/07-distributed-cache-vs-local-cache.md" "Distributed Cache vs Local Cache"
make_stub "$CACHING_DIR/08-cache-eviction-policies.md" "Cache Eviction Policies (LRU, LFU, FIFO)"

echo ""
echo "   OBS: 14-caching.md (em 03-consistencia-e-transacoes) e"
echo "        10-caching/03-cdn.md (atual) têm conteúdo que se sobrepõe"
echo "        com os stubs acima. Sugestão: revisar o conteúdo antigo e"
echo "        colar dentro dos novos arquivos, depois apagar os antigos."

# ------------------------------------------------------------------------------
# Gaps notados no restante da estrutura (System Design puro, sem negócio)
# ------------------------------------------------------------------------------

echo ""
echo "== Preenchendo gaps em 01-fundamentos-e-escalabilidade =="
FUND_DIR="$ROOT/01-fundamentos-e-escalabilidade"
make_stub "$FUND_DIR/14-monolito-vs-microsservicos.md" "Monolito vs Microsserviços"
make_stub "$FUND_DIR/15-modular-monolith.md" "Modular Monolith"
make_stub "$FUND_DIR/16-strangler-fig-pattern.md" "Strangler Fig Pattern"
make_stub "$FUND_DIR/17-backend-for-frontend-bff.md" "Backend For Frontend (BFF)"

echo ""
echo "== Preenchendo gaps em 02-comunicacao-e-integracao =="
COMM_DIR="$ROOT/02-comunicacao-e-integracao"
make_stub "$COMM_DIR/06-long-polling-vs-websocket-vs-sse.md" "Long Polling vs WebSocket vs Server-Sent Events"
make_stub "$COMM_DIR/07-service-to-service-communication.md" "Service-to-Service Communication Patterns"

echo ""
echo "== Preenchendo gaps em 04-persistencia-e-dados =="
PERSIST_DIR="$ROOT/04-persistencia-e-dados"
make_stub "$PERSIST_DIR/15-write-ahead-log.md" "Write-Ahead Log (WAL)"
make_stub "$PERSIST_DIR/16-read-replicas-e-read-your-writes.md" "Read Replicas e Read-Your-Writes Consistency"
make_stub "$PERSIST_DIR/17-vector-clock-e-conflict-resolution.md" "Vector Clocks e Conflict Resolution"

echo ""
echo "== Preenchendo gaps em 05-resiliencia =="
RES_DIR="$ROOT/05-resiliencia"
make_stub "$RES_DIR/13-backpressure-pattern.md" "Backpressure Pattern (aplicado)"
make_stub "$RES_DIR/14-disaster-recovery.md" "Disaster Recovery (RTO/RPO)"

echo ""
echo "== Preenchendo gaps em 09-observabilidade (após renumeração) =="
OBS_DIR="$ROOT/08-observabilidade"
make_stub "$OBS_DIR/05-apm-e-instrumentacao.md" "APM e Instrumentação (spans, traces, contexto)"
make_stub "$OBS_DIR/06-slo-error-budget-na-pratica.md" "SLO e Error Budget na Prática"

echo ""
echo "== Preenchendo gaps em 09-seguranca =="
SEC_DIR="$ROOT/09-seguranca"
make_stub "$SEC_DIR/05-rate-limiting-e-seguranca-de-api.md" "Rate Limiting e Segurança de API"
make_stub "$SEC_DIR/06-secrets-management.md" "Secrets Management"

echo ""
echo "== Preenchendo gaps em 12-trade-offs =="
TRADE_DIR="$ROOT/07-trade-offs"
make_stub "$TRADE_DIR/01-latencia-vs-consistencia.md" "Latência vs Consistência"
make_stub "$TRADE_DIR/02-throughput-vs-latencia.md" "Throughput vs Latência"
make_stub "$TRADE_DIR/03-custo-vs-disponibilidade.md" "Custo vs Disponibilidade"
make_stub "$TRADE_DIR/04-simplicidade-vs-flexibilidade.md" "Simplicidade vs Flexibilidade"

echo ""
echo "== Nova pasta: 13-estudos-de-caso (design de sistemas completos) =="
CASES_DIR="$ROOT/13-estudos-de-caso"
make_stub "$CASES_DIR/01-design-url-shortener.md" "Design: URL Shortener"
make_stub "$CASES_DIR/02-design-rate-limiter.md" "Design: Rate Limiter Distribuído"
make_stub "$CASES_DIR/03-design-feed-de-noticias.md" "Design: Feed de Notícias (Fan-out)"
make_stub "$CASES_DIR/04-design-sistema-de-notificacoes.md" "Design: Sistema de Notificações"
make_stub "$CASES_DIR/05-design-chat-em-tempo-real.md" "Design: Chat em Tempo Real"
make_stub "$CASES_DIR/06-design-sistema-de-pagamentos.md" "Design: Sistema de Pagamentos (idempotência, reconciliação)"

echo ""
echo ">> Concluído. Nenhum arquivo existente foi movido ou apagado."
echo ">> Revise as sugestões de 'git mv' impressas acima e execute manualmente se concordar."