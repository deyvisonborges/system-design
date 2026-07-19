# HttpMessageConverter

HttpMessageConverter é um componente do Spring MVC que converte requisições HTTP em objetos Java e objetos Java em respostas HTTP, suportando múltiplos formatos como JSON, XML, form data e texto, facilitando a serialização e deserialização de dados.

## Definição

HttpMessageConverter é um componente do Spring MVC que converte requisições HTTP em objetos Java e objetos Java em respostas HTTP através da interface HttpMessageConverter, suportando múltiplos formatos como JSON, XML, form data e texto, facilitando a serialização e deserialização de dados em aplicações web.

```text
HttpMessageConverter = Serialização/Deserialização + Múltiplos formatos + JSON/XML/Text + Spring MVC
```

## Como Funciona

### 1. Interface

```text
- canRead: Verifica se pode ler o tipo
- canWrite: Verifica se pode escrever o tipo
- read: Converte requisição em objeto
- write: Converte objeto em resposta
- getSupportedMediaTypes: Tipos suportados
```

### 2. Tipos

```text
- MappingJackson2HttpMessageConverter: JSON
- Jaxb2RootElementHttpMessageConverter: XML
- StringHttpMessageConverter: Texto
- FormHttpMessageConverter: Form data
- ByteArrayHttpMessageConverter: Bytes
```

### 3. Registro

```text
- WebMvcConfigurer: Interface para configurar converters
- extendMessageConverters: Adiciona converters customizados
- configureMessageConverters: Configura todos os converters
```

## Exemplo Prático

### Converter Customizado

```java
public class CustomMessageConverter extends AbstractHttpMessageConverter<MyObject> {

    public CustomMessageConverter() {
        super(new MediaType("application", "custom"));
    }

    @Override
    protected boolean supports(Class<?> clazz) {
        return MyObject.class.isAssignableFrom(clazz);
    }

    @Override
    protected MyObject readInternal(Class<? extends MyObject> clazz, HttpInputMessage inputMessage) 
            throws IOException {
        String body = StreamUtils.copyToString(inputMessage.getBody(), StandardCharsets.UTF_8);
        // Parse custom format
        return new MyObject();
    }

    @Override
    protected void writeInternal(MyObject myObject, HttpOutputMessage outputMessage) 
            throws IOException {
        outputMessage.getBody().write(myObject.toString().getBytes(StandardCharsets.UTF_8));
    }
}
```

### Configurar Converter

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        converters.add(new CustomMessageConverter());
    }
}
```

### JSON Converter

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        converter.setObjectMapper(mapper);
        converters.add(0, converter);
    }
}
```

### XML Converter

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        Jaxb2RootElementHttpMessageConverter converter = new Jaxb2RootElementHttpMessageConverter();
        converters.add(converter);
    }
}
```

### String Converter

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        StringHttpMessageConverter converter = new StringHttpMessageConverter(StandardCharsets.UTF_8);
        converter.setWriteAcceptCharset(false);
        converters.add(converter);
    }
}
```

### Form Data Converter

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        FormHttpMessageConverter converter = new FormHttpMessageConverter();
        converter.setCharset(StandardCharsets.UTF_8);
        converters.add(converter);
    }
}
```

## Comandos Úteis

### Adicionar Converter

```java
@Override
public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
    converters.add(new MyMessageConverter());
}
```

### Configurar Ordem

```java
@Override
public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
    converters.add(0, new MyMessageConverter());  // Primeiro
}
```

### Configurar Todos os Converters

```java
@Override
public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
    converters.clear();
    converters.add(new MyMessageConverter());
}
```

## Vantagens

### 1. Flexibilidade

```text
- Múltiplos formatos
- Customização
- Extensível
```

### 2. Padrão

```text
- Interface padrão
- Bem documentado
- Fácil de usar
```

### 3. Integração

```text
- Integrado ao Spring MVC
- Suporte a @RequestBody
- Suporte a @ResponseBody
```

## Limitações

### 1. Complexidade

```text
- Implementação complexa
- Curva de aprendizado
- Debugging desafiador
```

### 2. Performance

```text
- Overhead de conversão
- Serialização/deserialização
- Performance reduzida
```

### 3. Limitações

```text
- Apenas Spring MVC
- Não funciona com WebFlux
- Específico do Spring
```

## Melhores Práticas

### 1. Usar extendMessageConverters

```java
@Override
public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
    converters.add(new MyMessageConverter());
}
```

### 2. Configurar ObjectMapper

```java
MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
ObjectMapper mapper = new ObjectMapper();
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
converter.setObjectMapper(mapper);
```

### 3. Configurar Charset

```java
StringHttpMessageConverter converter = new StringHttpMessageConverter(StandardCharsets.UTF_8);
```

### 4. Usar WebMvcConfigurer

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    // ...
}
```

## Trade-offs

### extendMessageConverters vs configureMessageConverters

- **extendMessageConverters**: Adiciona aos existentes
- **configureMessageConverters**: Substitui todos
- **Escolha**: extendMessageConverters para adicionar, configureMessageConverters para substituir

### JSON vs XML

- **JSON**: Leve, popular, simples
- **XML**: Verboso, estruturado, complexo
- **Escolha**: JSON para APIs modernas, XML para legado

### Custom vs Built-in

- **Custom**: Flexível, específico
- **Built-in**: Padrão, simples
- **Escolha**: Built-in para padrão, custom para específico

### _Links_

- <https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-config-message-converters>
- <https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/converter/HttpMessageConverter.html>
- <https://www.baeldung.com/spring-httpmessageconverter-rest>
