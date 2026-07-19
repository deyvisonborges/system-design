# Helm

Helm é um gerenciador de pacotes para Kubernetes que simplifica a instalação e gerenciamento de aplicações através de charts, permitindo versionamento, reutilização e compartilhamento de configurações.

## Definição

Helm é um gerenciador de pacotes para Kubernetes que usa charts para definir, instalar e atualizar aplicações complexas, simplificando o gerenciamento de recursos do Kubernetes através de templates e valores configuráveis.

```text
Helm = Gerenciador de pacotes + Charts + Templates
```

## Como Funciona

### 1. Componentes

```text
- Charts: Pacotes de recursos Kubernetes pré-configurados
- Templates: Arquivos YAML com variáveis
- Values: Valores para customizar templates
- Release: Instância de um chart em um cluster
```

### 2. Estrutura

```text
- Chart.yaml: Metadados do chart
- values.yaml: Valores padrão
- templates/: Templates YAML
- charts/: Dependências de charts
- README.md: Documentação
```

### 3. Comandos

```text
- helm install: Instala um chart
- helm upgrade: Atualiza uma release
- helm uninstall: Remove uma release
- helm list: Lista releases
```

## Exemplo Prático

### Criar um Chart

```bash
# Criar um novo chart
helm create myapp

# Estrutura criada
myapp/
  Chart.yaml
  values.yaml
  charts/
  templates/
    deployment.yaml
    service.yaml
    ingress.yaml
    NOTES.txt
  .helmignore
  README.md
```

### Chart.yaml

```yaml
apiVersion: v2
name: myapp
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0"
```

### values.yaml

```yaml
replicaCount: 1

image:
  repository: myapp
  pullPolicy: IfNotPresent
  tag: "1.0"

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Template deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.port }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

### Instalar Chart

```bash
# Instalar chart local
helm install myapp ./myapp

# Instalar chart do repositório
helm install myapp stable/nginx

# Instalar com valores customizados
helm install myapp ./myapp --set replicaCount=3

# Instalar com arquivo de valores
helm install myapp ./myapp -f custom-values.yaml
```

## Comandos Úteis

### Gerenciar Charts

```bash
# Criar chart
helm create myapp

# Instalar chart
helm install myapp ./myapp

# Listar releases
helm list

# Ver status de release
helm status myapp

# Atualizar release
helm upgrade myapp ./myapp

# Rollback de release
helm rollback myapp

# Uninstall release
helm uninstall myapp

# Ver histórico
helm history myapp
```

### Gerenciar Repositórios

```bash
# Adicionar repositório
helm repo add stable https://charts.helm.sh/stable

# Listar repositórios
helm repo list

# Atualizar repositórios
helm repo update

# Buscar chart
helm search repo nginx

# Remover repositório
helm repo remove stable
```

## Vantagens

### 1. Simplificação

```text
- Simplifica instalação complexa
- Reutilização de configurações
- Reduz erros manuais
```

### 2. Versionamento

```text
- Versionamento de charts
- Rollback fácil
- Histórico de mudanças
```

### 3. Flexibilidade

```text
- Templates configuráveis
- Valores customizáveis
- Adaptação a diferentes ambientes
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Templates podem ser complexos
- Troubleshooting desafiador
```

### 2. Manutenção

```text
- Requer manutenção de charts
- Atualizações de dependências
- Versionamento cuidadoso
```

### 3. Segurança

```text
- Charts de fontes não confiáveis
- Valores sensíveis
- Requer validação
```

## Melhores Práticas

### 1. Usar Namespaces

```bash
# Instalar em namespace específico
helm install myapp ./myapp --namespace production
```

### 2. Versionar Charts

```yaml
# Chart.yaml
apiVersion: v2
version: 0.1.0  # Semver
```

### 3. Usar Secrets para Valores Sensíveis

```bash
# Criar secret
kubectl create secret generic myapp-values --from-file=values.yaml

# Usar secret
helm install myapp ./myapp --set-file values.yaml=myapp-values
```

### 4. Validar Templates

```bash
# Validar templates
helm template myapp ./myapp

# Lint chart
helm lint ./myapp
```

## Trade-offs

### Helm vs kubectl apply

- **Helm**: Gerenciamento de pacotes, mais complexo
- **kubectl apply**: Simples, mais manual
- **Escolha**: Helm para complexo, kubectl para simples

### Helm vs Kustomize

- **Helm**: Gerenciador de pacotes, templates
- **Kustomize**: Customização sem templates
- **Escolha**: Helm para reutilização, Kustomize para customização

### Helm vs ArgoCD

- **Helm**: Gerenciamento manual
- **ArgoCD**: GitOps, automático
- **Escolha**: Helm para manual, ArgoCD para GitOps

### _Links_

- <https://helm.sh/docs/>
- <https://helm.sh/docs/chart_template_guide/>
- <https://helm.sh/docs/topics/charts/>
