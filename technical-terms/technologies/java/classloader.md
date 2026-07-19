# ClassLoader

ClassLoader é um componente da JVM responsável por carregar classes dinamicamente em tempo de execução, seguindo uma hierarquia delegativa que permite carregar classes de diferentes fontes como JARs, diretórios e redes.

## Definição

ClassLoader é um componente da JVM que carrega classes dinamicamente em tempo de execução, seguindo uma hierarquia delegativa (Bootstrap, Extension, Application) que permite carregar classes de diferentes fontes como JARs, diretórios e redes, garantindo isolamento e segurança.

```text
ClassLoader = Carregamento dinâmico + Hierarquia delegativa + Isolamento
```

## Como Funciona

### 1. Hierarquia

```text
- Bootstrap ClassLoader: Carrega classes core do Java (rt.jar)
- Extension ClassLoader: Carrega classes de extensão (ext/)
- Application ClassLoader: Carrega classes da aplicação (classpath)
- Custom ClassLoader: ClassLoaders personalizados
```

### 2. Delegation Model

```text
- Parent-first delegation
- ClassLoader delega para parent antes de carregar
- Previne conflitos de versão
- Garante segurança
```

### 3. Processo

```text
- Solicitação de classe
- Delegação para parent
- Parent tenta carregar
- Se parent não encontrar, carrega localmente
- Define classe e retorna
```

## Exemplo Prático

### Custom ClassLoader

```java
public class CustomClassLoader extends ClassLoader {
    private final String classPath;

    public CustomClassLoader(String classPath) {
        this.classPath = classPath;
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] classData = loadClassData(name);
        if (classData == null) {
            throw new ClassNotFoundException(name);
        }
        return defineClass(name, classData, 0, classData.length);
    }

    private byte[] loadClassData(String name) {
        // Carregar bytes do arquivo
        String fileName = classPath + name.replace('.', '/') + ".class";
        try (InputStream in = new FileInputStream(fileName)) {
            return in.readAllBytes();
        } catch (IOException e) {
            return null;
        }
    }
}
```

### Ver ClassLoader de Classe

```java
public class ClassLoaderInfo {
    public static void main(String[] args) {
        ClassLoader loader = ClassLoaderInfo.class.getClassLoader();
        System.out.println("ClassLoader: " + loader);
        
        while (loader != null) {
            System.out.println("Parent: " + loader);
            loader = loader.getParent();
        }
    }
}
```

### Carregar Classe Dinamicamente

```java
public class DynamicLoading {
    public static void main(String[] args) throws Exception {
        CustomClassLoader loader = new CustomClassLoader("/path/to/classes/");
        Class<?> clazz = loader.loadClass("com.example.MyClass");
        Object instance = clazz.getDeclaredConstructor().newInstance();
        
        // Usar reflexão para invocar método
        Method method = clazz.getMethod("doSomething");
        method.invoke(instance);
    }
}
```

### ClassLoader Isolamento

```java
public class IsolatedClassLoader extends URLClassLoader {
    public IsolatedClassLoader(URL[] urls) {
        super(urls, null);  // Sem parent para isolamento total
    }
}
```

## Comandos Úteis

### Ver ClassPath

```bash
# Ver classpath
java -verbose:class MyApp

# Ver classpath detalhado
java -XshowSettings:properties MyApp

# Ver classpath de processo
jinfo -sysprops <pid> | grep classpath
```

### Debug ClassLoader

```bash
# Ver carregamento de classes
java -verbose:class MyApp

# Ver detalhes de classloader
java -XX:+TraceClassLoading MyApp

# Ver classpath
java -XshowSettings:properties MyApp
```

## Vantagens

### 1. Flexibilidade

```text
- Carregamento dinâmico
- Múltiplas fontes
- Customização
```

### 2. Isolamento

```text
- Hierarquia delegativa
- Separação de namespaces
- Prevenção de conflitos
```

### 3. Segurança

```text
- Sandbox
- Controle de permissões
- Isolamento de código
```

## Limitações

### 1. Complexidade

```text
- Hierarquia complexa
- Debugging desafiador
- ClassCastException
```

### 2. Performance

```text
- Overhead de carregamento
- Latência inicial
- Memória extra
```

### 3. Erros

```text
- ClassNotFoundException
- NoClassDefFoundError
- LinkageError
```

## Melhores Práticas

### 1. Seguir Delegation Model

```java
@Override
protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
    // Sempre delegar para parent primeiro
    try {
        return super.loadClass(name, resolve);
    } catch (ClassNotFoundException e) {
        // Carregar localmente se parent não encontrar
        return findClass(name);
    }
}
```

### 2. Usar ClassLoader Adequado

```java
// Usar Thread.currentThread().getContextClassLoader() para recursos
ClassLoader loader = Thread.currentThread().getContextClassLoader();
```

### 3. Evitar Memory Leaks

```java
// Limpar referências a ClassLoader
loader = null;
```

### 4. Monitorar ClassLoader

```bash
# Ver carregamento de classes
java -verbose:class MyApp
```

## Trade-offs

### Bootstrap vs Extension vs Application

- **Bootstrap**: Core Java, não customizável
- **Extension**: Extensões, customizável
- **Application**: Aplicação, customizável
- **Escolha**: Bootstrap para core, Extension para extensões, Application para app

### Parent-first vs Child-first

- **Parent-first**: Seguro, conflitos prevenidos
- **Child-first**: Flexível, risco de conflitos
- **Escolha**: Parent-first para segurança, child-first para isolamento

### URLClassLoader vs Custom

- **URLClassLoader**: Simples, pronto
- **Custom**: Flexível, complexo
- **Escolha**: URLClassLoader para simples, custom para específico

### _Links_

- <https://docs.oracle.com/javase/8/docs/api/java/lang/ClassLoader.html>
- <https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-5.html>
- <https://www.baeldung.com/java-classloaders>
