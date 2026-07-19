# ConfigMap

ConfigMap é um recurso do Kubernetes usado para armazenar dados não confidenciais em pares chave-valor, permitindo injetar configurações em Pods sem modificar a imagem do container.

## Definição

ConfigMap é um objeto API usado para armazenar dados não confidenciais como pares chave-valor, que podem ser consumidos por Pods como variáveis de ambiente, argumentos de linha de comando ou arquivos de configuração.

```text
ConfigMap = Dados não confidenciais + Injeção de configuração + Pares chave-valor
```

## Como Funciona

### 1. Tipos de Dados

```text
- Literais: Valores simples
- Arquivos: Conteúdo de arquivos
- Configurações: Dados de aplicação
- Environment variables: Variáveis de ambiente
```

### 2. Injeção

```text
- Environment variables: Como variáveis de ambiente
- Volume mounts: Como arquivos
- Command arguments: Como argumentos
```

### 3. Escopo

```text
- Namespace-scoped: Limitado ao namespace
- Pod consumption: Pods consomem ConfigMaps
- Imutável: Pode ser marcado como imutável
```

## Exemplo Prático

### ConfigMap Literal

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  database_url: "postgres://localhost:5432/mydb"
  cache_ttl: "300"
  debug_mode: "true"
```

### ConfigMap com Arquivos

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    server.port=8080
    spring.datasource.url=jdbc:postgresql://localhost:5432/mydb
    spring.datasource.username=admin
  logback.xml: |
    <configuration>
      <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
          <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
      </appender>
      <root level="INFO">
        <appender-ref ref="STDOUT" />
      </root>
    </configuration>
```

### ConfigMap Imutável

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
immutable: true
data:
  database_url: "postgres://localhost:5432/mydb"
```

### Pod Consumindo ConfigMap como Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: myapp:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: database_url
    - name: CACHE_TTL
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: cache_ttl
```

### Pod Consumindo ConfigMap como Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: myapp:1.0
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

## Comandos Úteis

### Gerenciar ConfigMaps

```bash
# Criar ConfigMap literal
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2

# Criar ConfigMap de arquivo
kubectl create configmap app-config --from-file=app.properties

# Criar ConfigMap de diretório
kubectl create configmap my-config --from-file=./config/

# Listar ConfigMaps
kubectl get configmaps

# Ver detalhes
kubectl describe configmap my-config

# Ver ConfigMap em YAML
kubectl get configmap my-config -o yaml

# Deletar ConfigMap
kubectl delete configmap my-config
```

## Vantagens

### 1. Separação

```text
- Separa configuração do código
- Imagens reutilizáveis
- Configuração externalizada
```

### 2. Flexibilidade

```text
- Atualização sem rebuild
- Diferentes ambientes
- Configuração dinâmica
```

### 3. Versionamento

```text
- Versionado como código
- GitOps friendly
- Rollback fácil
```

## Limitações

### 1. Tamanho

```text
- Limite de 1MB por ConfigMap
- Não adequado para grandes arquivos
- Requer particionamento
```

### 2. Segurança

```text
- Não criptografado
- Dados visíveis
- Não para dados sensíveis
```

### 3. Complexidade

```text
- Requer planejamento
- Múltiplos ConfigMaps
- Gerenciamento necessário
```

## Melhores Práticas

### 1. Usar Nomes Significativos

```yaml
metadata:
  name: app-config-production
```

### 2. Usar Labels

```yaml
metadata:
  name: my-config
  labels:
    app: myapp
    environment: production
```

### 3. Usar Imutável quando Possível

```yaml
immutable: true
```

### 4. Usar ConfigMaps por Ambiente

```yaml
# configmap-dev.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    environment: dev
data:
  database_url: "postgres://dev-db:5432/mydb"

# configmap-prod.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    environment: prod
data:
  database_url: "postgres://prod-db:5432/mydb"
```

## Trade-offs

### ConfigMap vs Environment Variables

- **ConfigMap**: Gerenciável, versionado
- **Env vars**: Simples, não versionado
- **Escolha**: ConfigMap para produção, env vars para desenvolvimento

### Volume Mount vs Environment Variables

- **Volume**: Arquivos, mais dados
- **Env vars**: Variáveis, menos dados
- **Escolha**: Volume para arquivos, env vars para variáveis

### Múltiplos ConfigMaps vs Um Grande

- **Múltiplos**: Modular, mais organizado
- **Um grande**: Simples, menos organizado
- **Escolha**: Múltiplos para produção, um para desenvolvimento

### _Links_

- <https://kubernetes.io/docs/concepts/configuration/configmap/>
- <https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/>
- <https://kubernetes.io/docs/concepts/configuration/configmap/#configmap-and-pods>
