# Cache causando problemas

## Problem

O cache expirou e milhares de requests foram ao banco.

## Questions

- Todas as chaves expiraram?
- É a mesma chave?
- Há invalidação?

## Possible solutions

- Cache Aside
- Refresh Ahead
- Cache Warming
- Cache Stampede Protection
- Single Flight
- Jitter
- Distributed Lock
