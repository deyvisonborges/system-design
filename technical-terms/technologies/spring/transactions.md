# Transactions

Spring Transactions é um framework que fornece abstração para gerenciamento de transações, suportando transações programáticas e declarativas, com suporte a múltiplos recursos, propagação, isolamento e rollback rules.

## Definição

Spring Transactions é um framework que fornece abstração para gerenciamento de transações, suportando transações programáticas e declarativas, com suporte a múltiplos recursos, propagação, isolamento, timeout e rollback rules, simplificando o gerenciamento de transações em aplicações Spring.

```text
Transactions = Abstração + Declarativo + Propagação + Isolamento + Rollback
```

## Como Funciona

### 1. Tipos

```text
- Declarativo: @Transactional
- Programático: TransactionTemplate
- XML: Configuração via XML (legado)
```

### 2. Propagação

```text
- REQUIRED: Usa transação existente ou cria nova
- REQUIRES_NEW: Cria nova transação
- SUPPORTS: Usa transação existente ou não transacional
- NOT_SUPPORTED: Executa não transacional
- MANDATORY: Requer transação existente
- NEVER: Executa não transacional
- NESTED: Transação aninhada
```

### 3. Isolamento

```text
- DEFAULT: Isolamento padrão do banco
- READ_UNCOMMITTED: Leitura não commitada
- READ_COMMITTED: Leitura commitada
- REPEATABLE_READ: Leitura repetível
- SERIALIZABLE: Serializável
```

## Exemplo Prático

### @Transactional Básico

```java
@Service
public class TransactionalService {

    @Transactional
    public void transferMoney(Long fromId, Long toId, BigDecimal amount) {
        Account from = accountRepository.findById(fromId);
        Account to = accountRepository.findById(toId);
        
        from.setBalance(from.getBalance().subtract(amount));
        to.setBalance(to.getBalance().add(amount));
        
        accountRepository.save(from);
        accountRepository.save(to);
    }
}
```

### Propagação

```java
@Service
public class PropagationService {

    @Transactional(propagation = Propagation.REQUIRED)
    public void requiredMethod() {
        // Usa transação existente ou cria nova
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void requiresNewMethod() {
        // Cria nova transação
    }

    @Transactional(propagation = Propagation.SUPPORTS)
    public void supportsMethod() {
        // Usa transação existente ou não transacional
    }
}
```

### Isolamento

```java
@Service
public class IsolationService {

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public void readCommittedMethod() {
        // Leitura commitada
    }

    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public void repeatableReadMethod() {
        // Leitura repetível
    }

    @Transactional(isolation = Isolation.SERIALIZABLE)
    public void serializableMethod() {
        // Serializável
    }
}
```

### Rollback Rules

```java
@Service
public class RollbackService {

    @Transactional(rollbackFor = Exception.class)
    public void rollbackForException() throws Exception {
        // Rollback para Exception
    }

    @Transactional(noRollbackFor = BusinessException.class)
    public void noRollbackForBusiness() throws BusinessException {
        // Não rollback para BusinessException
    }

    @Transactional(rollbackForClassName = {"java.lang.Exception"})
    public void rollbackForClassName() throws Exception {
        // Rollback por nome de classe
    }
}
```

### TransactionTemplate

```java
@Service
public class ProgrammaticService {

    private final TransactionTemplate transactionTemplate;

    public ProgrammaticService(TransactionTemplate transactionTemplate) {
        this.transactionTemplate = transactionTemplate;
    }

    public void executeInTransaction() {
        transactionTemplate.execute(status -> {
            // Código transacional
            accountRepository.save(account);
            return null;
        });
    }

    public <T> T executeWithResult() {
        return transactionTemplate.execute(status -> {
            // Código transacional com retorno
            return accountRepository.findAll();
        });
    }
}
```

### Timeout

```java
@Service
public class TimeoutService {

    @Transactional(timeout = 5)  // 5 segundos
    public void timeoutMethod() {
        // Timeout após 5 segundos
    }
}
```

### ReadOnly

```java
@Service
public class ReadOnlyService {

    @Transactional(readOnly = true)
    public List<Account> findAll() {
        // Transação read-only
        return accountRepository.findAll();
    }
}
```

## Comandos Úteis

### Habilitar Transações

```java
@Configuration
@EnableTransactionManagement
public class TransactionConfig {
    // Configuração
}
```

### Configurar PlatformTransactionManager

```java
@Configuration
@EnableTransactionManagement
public class TransactionConfig {

    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}
```

### Configurar JPA TransactionManager

```java
@Configuration
@EnableTransactionManagement
public class JpaTransactionConfig {

    @Bean
    public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }
}
```

## Vantagens

### 1. Abstração

```text
- Abstração de transações
- Independente de implementação
- API consistente
```

### 2. Declarativo

```text
- @Transactional simples
- Menos código
- Foco na lógica
```

### 3. Flexibilidade

```text
- Múltiplas opções
- Configuração granular
- Rollback rules
```

## Limitações

### 1. Complexidade

```text
- Múltiplas opções
- Configuração complexa
- Erros sutis
```

### 2. Performance

```text
- Overhead de transação
- Locks no banco
- Performance reduzida
```

### 3. Limitações

```text
- Apenas métodos públicos
- Não funciona em chamadas internas
- Requer proxy
```

## Melhores Práticas

### 1. Usar @Transactional

```java
@Transactional
public void method() {
    // ...
}
```

### 2. Definir Propagação Adequada

```java
@Transactional(propagation = Propagation.REQUIRED)
public void method() {
    // ...
}
```

### 3. Especificar Rollback Rules

```java
@Transactional(rollbackFor = Exception.class)
public void method() throws Exception {
    // ...
}
```

### 4. Usar ReadOnly para Consultas

```java
@Transactional(readOnly = true)
public List<Account> findAll() {
    return accountRepository.findAll();
}
```

## Trade-offs

### Declarativo vs Programático

- **Declarativo**: Simples, @Transactional, menos controle
- **Programático**: Mais controle, TransactionTemplate, mais código
- **Escolha**: Declarativo para padrão, programático para avançado

### REQUIRED vs REQUIRES_NEW

- **REQUIRED**: Usa transação existente ou cria nova
- **REQUIRES_NEW**: Sempre cria nova transação
- **Escolha**: REQUIRED para padrão, REQUIRES_NEW para independente

### READ_COMMITTED vs SERIALIZABLE

- **READ_COMMITTED**: Leitura commitada, menos locks
- **SERIALIZABLE**: Serializável, mais locks
- **Escolha**: READ_COMMITTED para performance, SERIALIZABLE para consistência

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#transaction>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/transaction/annotation/Transactional.html>
- <https://www.baeldung.com/spring-transactional>
