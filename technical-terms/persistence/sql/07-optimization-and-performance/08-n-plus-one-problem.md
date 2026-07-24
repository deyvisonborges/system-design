# N+1 Problem

O problema N+1 é um problema de performance comum em aplicações que usam ORMs (Object-Relational Mappers), onde uma consulta inicial é seguida por N consultas adicionais para recuperar dados relacionados, em vez de uma única consulta otimizada. Isso pode resultar em dezenas ou centenas de consultas de banco de dados para uma única operação.

## Definição

O problema N+1 ocorre quando, para recuperar uma lista de N objetos e seus relacionamentos, o código executa 1 consulta inicial para buscar os objetos principais e depois N consultas adicionais (uma para cada objeto) para buscar os dados relacionados. Isso resulta em N+1 consultas totais em vez de 1 ou 2 consultas otimizadas.

## Como Funciona - Passo a Passo

### Passo 1: Consulta Inicial

Uma consulta é executada para buscar os objetos principais (ex: todos os clientes).

### Passo 2: Iteração Sobre Resultados

O código itera sobre cada objeto retornado.

### Passo 3: Consulta Adicional por Objeto

Para cada objeto, uma consulta adicional é executada para buscar dados relacionados (ex: pedidos do cliente).

### Passo 4: Repetição

Isso se repete para cada um dos N objetos, resultando em N consultas adicionais.

### Passo 5: Total de Consultas

Total: 1 (inicial) + N (adicionais) = N+1 consultas.

## Exemplos Práticos

### Exemplo 1: N+1 em ORM (Pseudo-código)

```python
# Problema N+1
clientes = Cliente.all()  # 1 consulta
for cliente in clientes:
    pedidos = cliente.pedidos.all()  # N consultas (uma por cliente)
    print(f"{cliente.nome}: {len(pedidos)} pedidos")

# Total: 1 + N consultas
```

**Explicação detalhada:**

1. Primeira consulta busca todos os clientes
2. Para cada cliente, uma consulta adicional busca seus pedidos
3. Se houver 100 clientes, são 101 consultas
4. Extremamente ineficiente

### Exemplo 2: Solução com Eager Loading

```python
# Solução com eager loading
clientes = Cliente.all().prefetch_related('pedidos')  # 2 consultas
for cliente in clientes:
    pedidos = cliente.pedidos.all()  # Usa dados em cache
    print(f"{cliente.nome}: {len(pedidos)} pedidos")

# Total: 2 consultas
```

**Explicação detalhada:**

1. prefetch_related carrega relacionamentos antecipadamente
2. Segunda consulta busca todos os pedidos dos clientes
3. Dados são cacheados no ORM
4. Muito mais eficiente

### Exemplo 3: N+1 em SQL Puro

```sql
-- Problema N+1 (simulado em aplicação)
-- Consulta 1: buscar clientes
SELECT id, nome FROM clientes;

-- Para cada cliente, consulta adicional:
SELECT id, data, valor FROM pedidos WHERE cliente_id = 1;
SELECT id, data, valor FROM pedidos WHERE cliente_id = 2;
-- ... (N consultas)
```

**Explicação detalhada:**

1. Primeira consulta busca clientes
2. Aplicação faz loop e executa consulta para cada cliente
3. Mesmo problema que ORM, mas mais explícito
4. Pode ser resolvido com JOIN ou IN

### Exemplo 4: Solução com JOIN

```sql
-- Solução com JOIN (1 consulta)
SELECT c.id, c.nome, p.id as pedido_id, p.data, p.valor
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- Ou com agregação
SELECT c.id, c.nome, COUNT(p.id) as num_pedidos, SUM(p.valor) as total
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;
```

**Explicação detalhada:**

1. JOIN retorna clientes e pedidos em uma consulta
2. Aplicação processa resultado
3. Muito mais eficiente
4. 1 consulta em vez de N+1

### Exemplo 5: Solução com IN

```sql
-- Solução com IN (2 consultas)
-- Consulta 1: buscar clientes
SELECT id, nome FROM clientes;

-- Consulta 2: buscar pedidos de todos os clientes
SELECT cliente_id, data, valor FROM pedidos WHERE cliente_id IN (1, 2, 3, ...);
```

**Explicação detalhada:**

1. Primeira consulta busca clientes
2. Segunda consulta busca pedidos de todos os clientes de uma vez
3. Aplicação combina resultados em memória
4. 2 consultas em vez de N+1

## Padrões que Causam N+1

### Padrão 1: Lazy Loading em Loop

```python
# Problema
for cliente in clientes:
    print(cliente.pedidos.count())  # Consulta por cliente
```

### Padrão 2: Acesso a Relacionamento em View

```python
# Problema em template/view
{% for cliente in clientes %}
    {{ cliente.pedidos.count }}  <!-- Consulta por cliente -->
{% endfor %}
```

### Padrão 3: Nested Loops

```python
# Problema
for cliente in clientes:
    for pedido in cliente.pedidos:
        print(pedido.itens.count())  <!-- Consulta por pedido -->
```

### Padrão 4: Condição em Relacionamento

```python
# Problema
for cliente in clientes:
    pedidos_recentes = cliente.pedidos.filter(data__gt='2024-01-01')  # Consulta por cliente
```

### Padrão 5: Agregação em Loop

```python
# Problema
for cliente in clientes:
    total = cliente.pedidos.aggregate(Sum('valor'))  # Consulta por cliente
```

## Soluções

### Solução 1: Eager Loading (ORM)

Carregue relacionamentos antecipadamente.

```python
# Django
clientes = Cliente.objects.prefetch_related('pedidos')

# Rails (ActiveRecord)
clientes = Cliente.includes(:pedidos).all

# Hibernate (Java)
clientes = session.createQuery("FROM Cliente c LEFT JOIN FETCH c.pedidos", Cliente.class).list();
```

### Solução 2: JOIN em SQL

Use JOIN para buscar dados relacionados.

```sql
SELECT c.*, p.*
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

### Solução 3: IN com Batch

Busque dados relacionados em lote.

```sql
-- Busca clientes
SELECT id, nome FROM clientes;

-- Busca pedidos em lote
SELECT * FROM pedidos WHERE cliente_id IN (1, 2, 3, 4, 5);
```

### Solução 4: Subquery com Agregação

Use subquery para agregações.

```sql
SELECT c.id, c.nome,
       (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id) as num_pedidos,
       (SELECT SUM(valor) FROM pedidos p WHERE p.cliente_id = c.id) as total
FROM clientes c;
```

### Solução 5: Materialização

Materialize dados se usado frequentemente.

```sql
-- Tabela materializada
CREATE TABLE cliente_stats (
    cliente_id INT,
    num_pedidos INT,
    total_valor DECIMAL(10,2),
    atualizado_em TIMESTAMP
);

-- Atualize periodicamente
INSERT INTO cliente_stats
SELECT c.id, COUNT(p.id), SUM(p.valor), NOW()
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id;
```

## Estratégias de Prevenção

### Estratégia 1: Use Eager Loading por Padrão

Configure eager loading como padrão para relacionamentos comuns.

```python
# Django
class Cliente(models.Model):
    pedidos = models.ManyToManyField(Pedido, related_name='clientes')

# Query com eager loading
Cliente.objects.prefetch_related('pedidos')
```

### Estratégia 2: Monitore Consultas

Use ferramentas para monitorar número de consultas.

```python
# Django Debug Toolbar
# Mostra todas as consultas executadas

# Rails Bullet Gem
# Alerta sobre N+1 queries
```

### Estratégia 3: Escreva Testes de Performance

Testes que verificam número de consultas.

```python
# Django
from django.test import TestCase
from django.db import connection
from django.test.utils import override_settings

class ClienteTest(TestCase):
    def test_n_plus_one(self):
        with self.assertNumQueries(2):  # Apenas 2 consultas permitidas
            clientes = Cliente.objects.prefetch_related('pedidos')
            for cliente in clientes:
                list(cliente.pedidos.all())
```

### Estratégia 4: Use SELECT Específico

Selecione apenas colunas necessárias.

```python
# Bom
Cliente.objects.only('id', 'nome').prefetch_related('pedidos')

# Ruim
Cliente.objects.all().prefetch_related('pedidos')
```

### Estratégia 5: Cache de Consultas

Cache resultados de consultas frequentes.

```python
# Redis cache
from django.core.cache import cache

def get_clientes_com_pedidos():
    cache_key = 'clientes_com_pedidos'
    clientes = cache.get(cache_key)
    if not clientes:
        clientes = Cliente.objects.prefetch_related('pedidos')
        cache.set(cache_key, clientes, timeout=300)
    return clientes
```

## N+1 em Diferentes ORMs

### Django (Python)

```python
# Problema
for cliente in Cliente.objects.all():
    print(cliente.pedidos.count())

# Solução
for cliente in Cliente.objects.prefetch_related('pedidos'):
    print(cliente.pedidos.count())
```

### Rails (Ruby)

```ruby
# Problema
Cliente.all.each do |cliente|
  puts cliente.pedidos.count
end

# Solução
Cliente.includes(:pedidos).each do |cliente|
  puts cliente.pedidos.count
end
```

### Hibernate (Java)

```java
// Problema
List<Cliente> clientes = session.createQuery("FROM Cliente", Cliente.class).list();
for (Cliente cliente : clientes) {
    cliente.getPedidos().size(); // N+1
}

// Solução
List<Cliente> clientes = session.createQuery(
    "FROM Cliente c LEFT JOIN FETCH c.pedidos", Cliente.class
).list();
```

### Entity Framework (C#)

```csharp
// Problema
var clientes = context.Clientes.ToList();
foreach (var cliente in clientes) {
    var pedidos = cliente.Pedidos.ToList(); // N+1
}

// Solução
var clientes = context.Clientes
    .Include(c => c.Pedidos)
    .ToList();
```

### Sequelize (Node.js)

```javascript
// Problema
const clientes = await Cliente.findAll();
for (const cliente of clientes) {
    const pedidos = await cliente.getPedidos(); // N+1
}

// Solução
const clientes = await Cliente.findAll({
    include: [{ model: Pedido }]
});
```

## Dicas de Performance

1. **Sempre use eager loading para relacionamentos**

```python
Cliente.objects.prefetch_related('pedidos')
```

1. **Monitore número de consultas em desenvolvimento**

```python
# Django Debug Toolbar
# Rails Bullet Gem
```

1. **Escreva testes que verificam número de consultas**

```python
with self.assertNumQueries(2):
    # código
```

1. **Use SELECT específico quando possível**

```python
Cliente.objects.only('id', 'nome')
```

1. **Considere cache para consultas frequentes**

```python
cache.get('clientes_com_pedidos')
```

## Detecção de N+1

### Django Debug Toolbar

Mostra todas as consultas executadas e alerta sobre duplicatas.

### Rails Bullet Gem

Detecta N+1 queries e sugere correções.

### SQL Logging

Ative logging de SQL para ver todas as consultas.

```python
# Django
LOGGING = {
    'version': 1,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'level': 'DEBUG',
            'handlers': ['console'],
        },
    },
}
```

### EXPLAIN

Use EXPLAIN para analisar consultas.

```sql
EXPLAIN SELECT * FROM clientes;
```

## Resumo

- **N+1 Problem**: 1 consulta inicial + N consultas adicionais para relacionamentos
- **Causa**: Lazy loading em loops, acesso a relacionamentos em views
- **Impacto**: Extremamente ineficiente, dezenas/centenas de consultas
- **Solução ORM**: Eager loading (prefetch_related, includes, LEFT JOIN FETCH)
- **Solução SQL**: JOIN, IN com batch, subquery com agregação
- **Prevenção**: Eager loading por padrão, monitore consultas, testes de performance
- **Detecção**: Debug toolbar, Bullet gem, SQL logging
- **Cache**: Use cache para consultas frequentes
- **Materialização**: Materialize dados se usado muito frequentemente
- **Compatibilidade**: Todos os ORMs têm soluções para N+1
- **Regra de ouro**: Sempre use eager loading, monitore consultas, escreva testes de performance
