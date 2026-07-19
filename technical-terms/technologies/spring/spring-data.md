# Spring Data

Spring Data é um framework que simplifica o acesso a dados, fornecendo uma abstração consistente sobre múltiplos data stores como JPA, MongoDB, Redis e Cassandra, com suporte a repositories, query methods e paginação.

## Definição

Spring Data é um framework que simplifica o acesso a dados, fornecendo uma abstração consistente sobre múltiplos data stores como JPA, MongoDB, Redis e Cassandra, com suporte a repositories, query methods derivados do nome do método, query methods customizados, paginação e sorting, reduzindo o código boilerplate.

```text
Spring Data = Repositories + Query Methods + Abstração + Múltiplos Data Stores
```

## Como Funciona

### 1. Repositories

```text
- Repository: Interface base
- CrudRepository: Operações CRUD
- PagingAndSortingRepository: Paginação e sorting
- JpaRepository: JPA específico
```

### 2. Query Methods

```text
- Derivados do nome: findByNome, findByEmail
- @Query: Query customizada JPQL ou SQL
- @Query com @Param: Parâmetros nomeados
- @Modifying: Queries de modificação
```

### 3. Módulos

```text
- Spring Data JPA: JPA/Hibernate
- Spring Data MongoDB: MongoDB
- Spring Data Redis: Redis
- Spring Data Cassandra: Cassandra
```

## Exemplo Prático

### Repository Básico

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // Herda métodos: save, findAll, findById, delete, etc.
}
```

### Query Methods Derivados

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    User findByEmail(String email);
    
    List<User> findByNomeContaining(String nome);
    
    List<User> findByAtivoTrueOrderByNomeAsc();
    
    Optional<User> findByEmailAndAtivoTrue(String email);
    
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailCustom(@Param("email") String email);
}
```

### Repository Customizado

```java
public interface UserRepositoryCustom {
    List<User> findUsersWithCustomLogic();
}

@Repository
public class UserRepositoryImpl implements UserRepositoryCustom {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Override
    public List<User> findUsersWithCustomLogic() {
        // Lógica customizada
        return entityManager.createQuery("SELECT u FROM User u", User.class).getResultList();
    }
}

public interface UserRepository extends JpaRepository<User, Long>, UserRepositoryCustom {
    // Combina métodos padrão e customizados
}
```

### Paginação

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    Page<User> findByAtivoTrue(Pageable pageable);
}

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public Page<User> findUsers(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("nome").ascending());
        return userRepository.findByAtivoTrue(pageable);
    }
}
```

### Query com @Query

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.nome LIKE %:nome%")
    List<User> findByNomeLike(@Param("nome") String nome);
    
    @Query(value = "SELECT * FROM users WHERE email = :email", nativeQuery = true)
    User findByEmailNative(@Param("email") String email);
    
    @Modifying
    @Query("UPDATE User u SET u.ativo = false WHERE u.ultimoLogin < :data")
    int desativarUsuariosInativos(@Param("data") LocalDateTime data);
}
```

### Auditing

```java
@Configuration
@EnableJpaAuditing
public class JpaAuditingConfig {
}

@Entity
@EntityListeners(AuditingEntityListener.class)
public class User {
    
    @CreatedDate
    private LocalDateTime dataCriacao;
    
    @LastModifiedDate
    private LocalDateTime dataAtualizacao;
    
    @CreatedBy
    private String criadoPor;
    
    @LastModifiedBy
    private String atualizadoPor;
}
```

## Comandos Úteis

### Habilitar Repositories

```java
@Configuration
@EnableJpaRepositories(basePackages = "com.example.repository")
public class JpaConfig {
    // ...
}
```

### Configurar Paginação

```java
Pageable pageable = PageRequest.of(page, size, Sort.by("nome").ascending());
```

### Usar @Query

```java
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);
```

## Vantagens

### 1. Produtividade

```text
- Menos código boilerplate
- Query methods automáticos
- Repositórios genéricos
```

### 2. Consistência

```text
- API consistente
- Múltiplos data stores
- Padrão uniforme
```

### 3. Flexibilidade

```text
- Query methods customizados
- Repositories customizados
- Extensível
```

## Limitações

### 1. Complexidade

```text
- Query methods complexos
- Nomenclatura específica
- Curva de aprendizado
```

### 2. Performance

```text
- Overhead de abstração
- N+1 queries
- Performance reduzida
```

### 3. Limitações

```text
- Queries complexas limitadas
- N+1 problem
- Debugging desafiador
```

## Melhores Práticas

### 1. Usar Query Methods Simples

```java
User findByEmail(String email);
```

### 2. Usar @Query para Queries Complexas

```java
@Query("SELECT u FROM User u WHERE u.nome LIKE %:nome%")
List<User> findByNomeLike(@Param("nome") String nome);
```

### 3. Usar @EntityGraph para Fetch

```java
@EntityGraph(attributePaths = {"roles"})
User findByEmail(String email);
```

### 4. Usar @Transactional para Modificação

```java
@Transactional
@Modifying
@Query("UPDATE User u SET u.ativo = false WHERE u.id = :id")
int desativarUsuario(@Param("id") Long id);
```

## Trade-offs

### Query Methods vs @Query

- **Query Methods**: Simples, automático, limitado
- **@Query**: Flexível, customizado, complexo
- **Escolha**: Query methods para simples, @Query para complexo

### JpaRepository vs CrudRepository

- **JpaRepository**: JPA específico, mais recursos
- **CrudRepository**: Genérico, simples
- **Escolha**: JpaRepository para JPA, CrudRepository para genérico

### Pagination vs List

- **Pagination**: Eficiente, lazy, complexo
- **List**: Simples, eager, ineficiente
- **Escolha**: Pagination para grandes datasets, List para pequenos

### _Links_

- <https://docs.spring.io/spring-data/jpa/docs/current/reference/html/>
- <https://docs.spring.io/spring-data/commons/docs/current/reference/html/>
- <https://www.baeldung.com/spring-data-jpa>
