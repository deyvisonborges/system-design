# Secret

Secret é um recurso do Kubernetes usado para armazenar dados confidenciais como senhas, tokens e chaves, permitindo injetar informações sensíveis em Pods de forma segura.

## Definição

Secret é um objeto API usado para armazenar dados confidenciais como pares chave-valor, que podem ser consumidos por Pods como variáveis de ambiente, arquivos ou em imagens de container.

```text
Secret = Dados confidenciais + Criptografia base64 + Injeção segura
```

## Como Funciona

### 1. Tipos de Secret

```text
- Opaque: Dados arbitrários (padrão)
- ServiceAccount: Tokens de serviço
- DockerConfigJson: Credenciais de registry
- TLS: Certificados TLS/SSL
- Bootstrap: Tokens de bootstrap
```

### 2. Codificação

```text
- Base64: Dados codificados em base64
- Não criptografado: Base64 não é criptografia
- Etcd: Armazenado em etcd (pode ser criptografado)
- KMS: Integração com KMS para criptografia
```

### 3. Injeção

```text
- Environment variables: Como variáveis de ambiente
- Volume mounts: Como arquivos
- Image pull secrets: Para autenticação de registry
```

## Exemplo Prático

### Secret Opaque

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 de "admin"
  password: cGFzc3dvcmQ=  # base64 de "password"
```

### Secret TLS

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # certificado em base64
  tls.key: LS0tLS1CRUdJTi...  # chave privada em base64
```

### Secret Docker Registry

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==
```

### Pod Consumindo Secret como Environment Variables

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
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: password
```

### Pod Consumindo Secret como Volume

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
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
```

## Comandos Úteis

### Gerenciar Secrets

```bash
# Criar Secret literal
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=password

# Criar Secret de arquivo
kubectl create secret generic tls-secret --from-file=tls.crt=./cert.pem --from-file=tls.key=./key.pem

# Criar Secret Docker registry
kubectl create secret docker-registry docker-registry-secret --docker-server=registry.example.com --docker-username=user --docker-password=password --docker-email=user@example.com

# Listar Secrets
kubectl get secrets

# Ver detalhes
kubectl describe secret my-secret

# Ver Secret em YAML (decodificado)
kubectl get secret my-secret -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'

# Deletar Secret
kubectl delete secret my-secret
```

## Vantagens

### 1. Segurança

```text
- Separação de dados sensíveis
- Não exposto em código
- Controle de acesso RBAC
```

### 2. Flexibilidade

```text
- Atualização sem rebuild
- Diferentes ambientes
- Integração com KMS
```

### 3. Padrão

```text
- Padrão do Kubernetes
- Integração nativa
- Suporte a múltiplos tipos
```

## Limitações

### 1. Base64

```text
- Base64 não é criptografia
- Dados visíveis se acessados
- Requer etcd encryption
```

### 2. Tamanho

```text
- Limite de 1MB por Secret
- Não adequado para grandes arquivos
- Requer particionamento
```

### 3. Complexidade

```text
- Requer gerenciamento
- Rotação de segredos
- Integração com ferramentas externas
```

## Melhores Práticas

### 1. Usar Nomes Significativos

```yaml
metadata:
  name: db-credentials-production
```

### 2. Usar Labels

```yaml
metadata:
  name: my-secret
  labels:
    app: myapp
    environment: production
```

### 3. Habilitar Encryption at Rest

```yaml
# Kubelet configuration
encryptionProviderConfig:
  providers:
  - kms:
      name: my-kms
      keys:
      - name: key1
        endpoint: https://kms.example.com
  - identity: {}
```

### 4. Usar External Secrets Operator

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-external-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: my-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: my-secret/password
```

## Trade-offs

### Secret vs ConfigMap

- **Secret**: Dados sensíveis, base64
- **ConfigMap**: Dados não sensíveis, texto
- **Escolha**: Secret para sensíveis, ConfigMap para não sensíveis

### Volume Mount vs Environment Variables

- **Volume**: Arquivos, mais seguro
- **Env vars**: Variáveis, menos seguro (visível em logs)
- **Escolha**: Volume para produção, env vars para desenvolvimento

### Native Secrets vs External Secrets

- **Native**: Simples, limitado
- **External**: Integrado, mais seguro
- **Escolha**: External para produção, native para desenvolvimento

### _Links_

- <https://kubernetes.io/docs/concepts/configuration/secret/>
- <https://kubernetes.io/docs/concepts/configuration/secret/#understanding-a-secret>
- <https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/>
