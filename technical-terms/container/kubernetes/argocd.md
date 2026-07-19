# ArgoCD

ArgoCD é uma ferramenta de GitOps contínua para Kubernetes que usa repositórios Git como fonte de verdade para definir e gerenciar aplicações e infraestrutura, automatizando deployments e garantindo consistência.

## Definição

ArgoCD é uma ferramenta declarativa de GitOps contínua para Kubernetes que automatiza deployments, sincronizando o estado do cluster com repositórios Git e garantindo que o estado desejado seja mantido automaticamente.

```text
ArgoCD = GitOps + Sincronização automática + Declarativo
```

## Como Funciona

### 1. Componentes

```text
- API Server: API e UI web
- Repository Server: Gerencia repositórios Git
- Application Controller: Sincroniza aplicações
- ApplicationSet: Gerencia múltiplas aplicações
```

### 2. Fluxo

```text
- Git como fonte de verdade
- ArgoCD monitora repositório
- Detecta mudanças
- Sincroniza automaticamente
- Garante estado desejado
```

### 3. Sincronização

```text
- Manual: Sincronização sob demanda
- Automática: Sincronização automática
- Prune: Remove recursos não declarados
- Self-Heal: Corrige desvios
```

## Exemplo Prático

### Application YAML

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myapp.git
    targetRevision: main
    path: kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### ApplicationSet para Múltiplos Clusters

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp-multi-cluster
spec:
  generators:
  - list:
      elements:
      - cluster: cluster1
        url: https://cluster1.example.com
      - cluster: cluster2
        url: https://cluster2.example.com
  template:
    metadata:
      name: '{{cluster}}-myapp'
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/myapp.git
        targetRevision: main
        path: kubernetes
      destination:
        server: '{{url}}'
        namespace: production
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

### Directory Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: apps-from-directory
spec:
  generators:
  - git:
      repoURL: https://github.com/myorg/apps.git
      revision: main
      directories:
      - path: apps/*
  template:
    metadata:
      name: '{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/apps.git
        targetRevision: main
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: production
      syncPolicy:
        automated:
          prune: true
```

## Comandos Úteis

### Gerenciar Aplicações

```bash
# Criar aplicação
argocd app create myapp --repo https://github.com/myorg/myapp.git --path kubernetes --dest-server https://kubernetes.default.svc --dest-namespace production

# Listar aplicações
argocd app list

# Ver status da aplicação
argocd app get myapp

# Sincronizar aplicação
argocd app sync myapp

# Sincronizar com opções
argocd app sync myapp --prune --force

# Ver logs de sincronização
argocd app logs myapp

# Deletar aplicação
argocd app delete myapp
```

### Gerenciar Repositórios

```bash
# Adicionar repositório
argocd repo add https://github.com/myorg/myapp.git

# Listar repositórios
argocd repo list

# Remover repositório
argocd repo rm https://github.com/myorg/myapp.git
```

## Vantagens

### 1. GitOps

```text
- Git como fonte de verdade
- Versionamento de infraestrutura
- Histórico de mudanças
```

### 2. Automação

```text
- Sincronização automática
- Self-healing
- Reduz erros manuais
```

### 3. Visibilidade

```text
- Dashboard web
- Histórico de sincronização
- Visualização de estado
```

## Limitações

### 1. Complexidade

```text
- Curva de aprendizado
- Configuração inicial complexa
- Requer infraestrutura Git
```

### 2. Latência

```text
- Tempo de sincronização
- Pode não ser instantâneo
- Requer monitoramento
```

### 3. Dependência

```text
- Dependência de Git
- Requer acesso ao cluster
- Ponto único de falha
```

## Melhores Práticas

### 1. Usar Branches por Ambiente

```text
- main: Produção
- staging: Staging
- develop: Desenvolvimento
```

### 2. Configurar SyncPolicy Adequado

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

### 3. Usar ApplicationSets para Escala

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
```

### 4. Monitorar Aplicações

```bash
# Ver dashboard
argocd app get myapp --web

# Ver logs
argocd app logs myapp --follow
```

## Trade-offs

### ArgoCD vs Flux

- **ArgoCD**: UI web rica, mais recursos
- **Flux**: Mais leve, focado em GitOps
- **Escolha**: ArgoCD para recursos completos, Flux para leveza

### ArgoCD vs Helm

- **ArgoCD**: GitOps, automático
- **Helm**: Manual, mais controle
- **Escolha**: ArgoCD para GitOps, Helm para manual

### Automated vs Manual Sync

- **Automated**: Sincronização automática, menos controle
- **Manual**: Controle total, mais trabalho
- **Escolha**: Automated para produção, Manual para desenvolvimento

### _Links_

- <https://argoproj.github.io/argo-cd/>
- <https://argoproj.github.io/argo-cd/getting_started/>
- <https://argoproj.github.io/argo-cd/operator-manual/>
