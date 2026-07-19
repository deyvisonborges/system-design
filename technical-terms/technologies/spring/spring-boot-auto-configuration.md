# Spring Boot Auto Configuration

Spring Boot Auto Configuration é um mecanismo que configura automaticamente beans baseado em dependências no classpath, eliminando a necessidade de configuração manual XML ou Java, seguindo o princípio de convenção sobre configuração.

## Definição

Spring Boot Auto Configuration é um mecanismo que configura automaticamente beans e componentes baseado em dependências presentes no classpath, eliminando a necessidade de configuração manual XML ou Java, seguindo o princípio de convenção sobre configuração e permitindo sobrescrita quando necessário.

```text
Auto Configuration = Configuração automática + Convenção sobre configuração + Sobrescrita
```

## Como Funciona

### 1. Processo

```text
- @EnableAutoConfiguration: Habilita auto configuração
- Classpath scanning: Detecta dependências
- Conditional beans: Cria beans baseado em condições
- Properties: Configura via application.properties/yml
- Sobrescrita: Permite customização
```

### 2. Anotações

```text
- @AutoConfiguration: Marca classe como auto configuração
- @ConditionalOnClass: Condiciona à presença de classe
- @ConditionalOnMissingBean: Condiciona à ausência de bean
- @ConditionalOnProperty: Condiciona à propriedade
- @ConditionalOnResource: Condiciona à presença de recurso
```

### 3. Ordem

```text
- AutoConfigurationImportSelector: Importa configurações
- @AutoConfigurationOrder: Define ordem
- @AutoConfigureBefore: Configura antes de outra
- @AutoConfigureAfter: Configura após outra
```

## Exemplo Prático

### Criar Auto Configuration

```java
@AutoConfiguration
@ConditionalOnClass(DataSource.class)
@EnableConfigurationProperties(DataSourceProperties.class)
public class DataSourceAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public DataSource dataSource(DataSourceProperties properties) {
        return DataSourceBuilder.create()
            .url(properties.getUrl())
            .username(properties.getUsername())
            .password(properties.getPassword())
            .build();
    }
}
```

### Properties

```java
@ConfigurationProperties(prefix = "app.datasource")
public class DataSourceProperties {
    private String url;
    private String username;
    private String password;

    // Getters e setters
}
```

### application.properties

```properties
app.datasource.url=jdbc:mysql://localhost:3306/mydb
app.datasource.username=root
app.datasource.password=password
```

### Sobrescrever Auto Configuration

```java
@Configuration
public class CustomDataSourceConfiguration {

    @Bean
    @Primary
    public DataSource customDataSource() {
        return DataSourceBuilder.create()
            .url("jdbc:h2:mem:testdb")
            .build();
    }
}
```

### Desabilitar Auto Configuration

```java
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}
```

### Via properties

```properties
spring.autoconfigure.exclude=com.example.DataSourceAutoConfiguration
```

## Comandos Úteis

### Ver Auto Configurações

```bash
# Ver auto configurações ativas
java -jar MyApp.jar --debug

# Ver report de auto configuração
java -jar MyApp.jar --spring.boot.debug=true
```

### Ativar/Desativar

```properties
# Desabilitar auto configuração específica
spring.autoconfigure.exclude=com.example.AutoConfiguration

# Desabilitar via property
spring.autoconfigure.enabled=false
```

## Vantagens

### 1. Simplicidade

```text
- Sem configuração manual
- Convenção sobre configuração
- Setup rápido
```

### 2. Produtividade

```text
- Menos boilerplate
- Foco na lógica de negócio
- Desenvolvimento mais rápido
```

### 3. Flexibilidade

```text
- Sobrescrita fácil
- Configuração via properties
- Conditional beans
```

## Limitações

### 1. Complexidade

```text
- Difícil de debugar
- Muitas configurações automáticas
- Comportamento não óbvio
```

### 2. Conflitos

```text
- Conflitos de beans
- Sobrescrita não trivial
- Requer entendimento profundo
```

### 3. Performance

```text
- Scanning de classpath
- Criação de beans não usados
- Startup mais lento
```

## Melhores Práticas

### 1. Usar Conditional Annotations

```java
@Bean
@ConditionalOnClass(DataSource.class)
@ConditionalOnMissingBean(DataSource.class)
public DataSource dataSource() {
    // ...
}
```

### 2. Usar @ConfigurationProperties

```java
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    // ...
}
```

### 3. Desabilitar Não Usados

```properties
spring.autoconfigure.exclude=com.example.UnusedAutoConfiguration
```

### 4. Debug Auto Configuration

```bash
java -jar MyApp.jar --debug
```

## Trade-offs

### Auto vs Manual Configuration

- **Auto**: Simples, rápido, mágico
- **Manual**: Explícito, controlado, verboso
- **Escolha**: Auto para protótipo, manual para produção

### @ConditionalOnClass vs @ConditionalOnBean

- **OnClass**: Baseado em classe no classpath
- **OnBean**: Baseado em bean no contexto
- **Escolha**: OnClass para dependências, OnBean para beans

### Enable vs Exclude

- **Enable**: Habilita configuração específica
- **Exclude**: Desabilita configuração específica
- **Escolha**: Enable para seletivo, Exclude para remover

### _Links_

- <https://docs.spring.io/spring-boot/docs/current/reference/html/auto-configuration.html>
- <https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/autoconfigure/EnableAutoConfiguration.html>
- <https://www.baeldung.com/spring-boot-auto-configuration>
