# Spring Security

Spring Security é um framework de segurança e autenticação poderoso e altamente customizável para aplicações Java, fornecendo autenticação, autorização, proteção contra ataques comuns e integração com múltiplos mecanismos de segurança.

## Definição

Spring Security é um framework de segurança e autenticação poderoso e altamente customizável para aplicações Java, fornecendo autenticação, autorização, proteção contra ataques comuns como CSRF, XSS e session fixation, integração com múltiplos mecanismos de segurança como OAuth2, JWT, LDAP e SAML.

```text
Spring Security = Autenticação + Autorização + Proteção + Customização + Integração
```

## Como Funciona

### 1. Arquitetura

```text
- Security Filter Chain: Cadeia de filtros de segurança
- Authentication: Processo de autenticação
- Authorization: Processo de autorização
- Security Context: Contexto de segurança
```

### 2. Componentes

```text
- SecurityContextHolder: Armazena contexto de segurança
- Authentication: Representa usuário autenticado
- UserDetailsService: Carrega detalhes do usuário
- PasswordEncoder: Codifica senhas
```

### 3. Filtros

```text
- UsernamePasswordAuthenticationFilter: Autenticação básica
- JwtAuthenticationFilter: Autenticação JWT
- CsrfFilter: Proteção CSRF
- LogoutFilter: Logout
```

## Exemplo Prático

### Configuração Básica

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .requestMatchers("/api/**").authenticated()
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .permitAll()
            )
            .logout(logout -> logout
                .permitAll()
            );
        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        UserDetails user = User.builder()
            .username("user")
            .password(passwordEncoder().encode("password"))
            .roles("USER")
            .build();
        
        UserDetails admin = User.builder()
            .username("admin")
            .password(passwordEncoder().encode("admin"))
            .roles("ADMIN")
            .build();
        
        return new InMemoryUserDetailsManager(user, admin);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### JWT Authentication

```java
@Configuration
@EnableWebSecurity
public class JwtSecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtFilter) 
            throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) 
            throws Exception {
        return config.getAuthenticationManager();
    }
}
```

### JWT Filter

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
            FilterChain filterChain) throws ServletException, IOException {
        String token = tokenProvider.resolveToken(request);
        
        if (token != null && tokenProvider.validateToken(token)) {
            Authentication auth = tokenProvider.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        
        filterChain.doFilter(request, response);
    }
}
```

### Method Security

```java
@Configuration
@EnableMethodSecurity
public class MethodSecurityConfig {
    // Configuração de segurança a nível de método
}

@Service
public class MyService {

    @PreAuthorize("hasRole('ADMIN')")
    public void adminMethod() {
        // Apenas ADMIN
    }

    @PreAuthorize("hasRole('USER')")
    public void userMethod() {
        // Apenas USER
    }

    @PreAuthorize("#userId == authentication.principal.id")
    public void userSpecificMethod(Long userId) {
        // Apenas se userId for do usuário autenticado
    }
}
```

### Custom UserDetailsService

```java
@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        
        return User.builder()
            .username(user.getUsername())
            .password(user.getPassword())
            .roles(user.getRoles())
            .build();
    }
}
```

## Comandos Úteis

### Habilitar Web Security

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    // ...
}
```

### Configurar Security Filter Chain

```java
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    // Configuração
    return http.build();
}
```

### Configurar Password Encoder

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}
```

## Vantagens

### 1. Segurança

```text
- Autenticação robusta
- Autorização flexível
- Proteção contra ataques
```

### 2. Customização

```text
- Altamente customizável
- Múltiplos mecanismos
- Extensível
```

### 3. Integração

```text
- Integrado ao Spring
- Suporte a OAuth2
- Suporte a JWT
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Configuração complexa
- Debugging desafiador
```

### 2. Performance

```text
- Overhead de segurança
- Múltiplos filtros
- Performance reduzida
```

### 3. Verbosidade

```text
- Muito código
- Múltiplas configurações
- Boilerplate
```

## Melhores Práticas

### 1. Usar BCrypt

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}
```

### 2. Usar Method Security

```java
@Configuration
@EnableMethodSecurity
public class MethodSecurityConfig {
    // ...
}
```

### 3. Usar JWT para APIs

```java
.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
```

### 4. Usar Roles

```java
@PreAuthorize("hasRole('ADMIN')")
```

## Trade-offs

### Session vs JWT

- **Session**: Server-side, simples, stateful
- **JWT**: Client-side, escalável, stateless
- **Escolha**: Session para web tradicional, JWT para APIs

### Form Login vs API

- **Form Login**: Web tradicional, session-based
- **API**: REST, token-based
- **Escolha**: Form Login para web, API para REST

### In-Memory vs Database

- **In-Memory**: Simples, temporário
- **Database**: Persistente, complexo
- **Escolha**: In-Memory para testes, Database para produção

### _Links_

- <https://docs.spring.io/spring-security/reference/>
- <https://docs.spring.io/spring-security/reference/servlet/configuration/java.html>
- <https://www.baeldung.com/spring-security>
