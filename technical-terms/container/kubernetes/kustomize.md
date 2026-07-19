# Kustomize

Kustomize é uma ferramenta de customização de Kubernetes que permite gerenciar configurações através de overlays e patches, sem usar templates, facilitando a gestão de múltiplos ambientes e configurações.

## Definição

Kustomize é uma ferramenta de customização de Kubernetes que usa um sistema de overlays e patches para gerenciar configurações sem templates, permitindo gerenciar múltiplos ambientes e variações de forma declarativa.

```text
Kustomize = Customização sem templates + Overlays + Patches
```

## Como Funciona

### 1. Componentes

```text
- Base: Configuração base da aplicação
- Overlay: Variações por ambiente
- Patch: Modificações específicas
- Kustomization.yaml: Arquivo de configuração
```

### 2. Estratégias

```text
- Patches: Modificações em recursos existentes
- Generators: Criação de novos recursos
- Transformers: Modificação de recursos
- ConfigMapGenerator: Geração de ConfigMaps
```

### 3. Processo

```text
- Define base
- Cria overlays
- Aplica patches
- Gera manifesto final
- Aplica ao cluster
```

## Exemplo Prático

### Estrutura de Diretórios

```text
myapp/
  base/
    deployment.yaml
    service.yaml
    kustomization.yaml
  overlays/
    production/
      kustomization.yaml
      patch-replica.yaml
    staging/
      kustomization.yaml
      patch-replica.yaml
```

### Base kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

commonLabels:
  app: myapp
  environment: base
```

### Base deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        ports:
        - containerPort: 8080
```

### Overlay Production kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: production

bases:
- ../../base

patchesStrategicMerge:
- patch-replica.yaml

commonLabels:
  environment: production

images:
- name: myapp
  newTag: 2.0
```

### Patch para Produção

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
```

### Overlay Staging kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: staging

bases:
- ../../base

patchesStrategicMerge:
- patch-replica.yaml

commonLabels:
  environment: staging

images:
- name: myapp
  newTag: 1.5
```

## Comandos Úteis

### Gerenciar Kustomize

```bash
# Ver manifesto gerado
kustomize build base

# Ver manifesto de overlay
kustomize build overlays/production

# Aplicar ao cluster
kubectl apply -k overlays/production

# Ver diferença
kustomize build overlays/production | kubectl diff -f -

# Criar ConfigMap de arquivos
kustomize edit add configmap my-config --from-file=config.yaml
```

### Gerenciar Recursos

```bash
# Adicionar recurso
kustomize edit add resource deployment.yaml

# Adicionar patch
kustomize edit add patch patch.yaml

# Adicionar secret
kustomize edit add secret my-secret --from-literal=password=secret

# Adicionar ConfigMap
kustomize edit add configmap my-config --from-literal=key=value
```

## Vantagens

### 1. Sem Templates

```text
- YAML puro
- Sem lógica de template
- Mais simples
```

### 2. Declarativo

```text
- Declara estado desejado
- GitOps friendly
- Versionamento fácil
```

### 3. Flexibilidade

```text
- Overlays por ambiente
- Patches granulares
- Reutilização de base
```

## Limitações

### 1. Complexidade

```text
- Estrutura de diretórios
- Múltiplos arquivos
- Curva de aprendizado
```

### 2. Manutenção

```text
- Requer organização
- Múltiplos arquivos para manter
- Versionamento cuidadoso
```

### 3. Limitações

```text
- Sem lógica condicional
- Sem loops
- Menos flexível que Helm
```

## Melhores Práticas

### 1. Usar Estrutura Base + Overlay

```text
base/
overlays/
  production/
  staging/
  development/
```

### 2. Usar CommonLabels

```yaml
commonLabels:
  app: myapp
  environment: production
```

### 3. Usar ConfigMapGenerator

```yaml
configMapGenerator:
- name: my-config
  files:
  - config.yaml
```

### 4. Versionar com Git

```bash
# Usar Git para versionar
git add .
git commit -m "Add production overlay"
```

## Trade-offs

### Kustomize vs Helm

- **Kustomize**: Sem templates, YAML puro
- **Helm**: Templates poderosos, mais complexo
- **Escolha**: Kustomize para simples, Helm para complexo

### Kustomize vs ArgoCD

- **Kustomize**: Customização
- **ArgoCD**: GitOps
- **Escolha**: Usar juntos, ArgoCD com Kustomize

### StrategicMerge vs JSON6902

- **StrategicMerge**: Simples, limitado
- **JSON6902**: Poderoso, mais complexo
- **Escolha**: StrategicMerge para simples, JSON6902 para complexo

### _Links_

- <https://kustomize.io/>
- <https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomize/>
- <https://kustomize.io/docs/>
