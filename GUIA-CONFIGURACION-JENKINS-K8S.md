# Configuración de Jenkins, Docker y Kubernetes

## Objetivo
Configurar e integrar Jenkins, Docker y Kubernetes para automatizar el despliegue del proyecto de microservicios.

## Pasos Realizados

### 1. Iniciar Minikube
Primero inicié el cluster de Kubernetes local con Minikube:
```powershell
minikube delete  # Limpié configuraciones anteriores
minikube start   # Inicié nuevo cluster
minikube ip      # Obtuve la IP: 192.168.49.2
```

### 2. Levantar Jenkins en Docker
Ejecuté Jenkins en un contenedor de Docker mapeando el puerto 8081:
```powershell
docker run -d --name jenkins -p 8081:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

Para la configuración inicial, obtuve la contraseña con:
```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Luego accedí a http://localhost:8081, instalé los plugins sugeridos y creé mi usuario administrador.

### 3. Instalar kubectl en Jenkins
Como Jenkins corre en un contenedor Linux, necesité instalar kubectl dentro del contenedor:
```powershell
docker exec -u root jenkins bash -c "curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl' && chmod +x kubectl && mv kubectl /usr/local/bin/"
```

Verifiqué la instalación:
```powershell
docker exec jenkins kubectl version --client
```

### 4. Conectar Jenkins con Kubernetes
Este fue el paso más importante. Primero copié los certificados de Minikube al contenedor:
```powershell
docker cp $env:USERPROFILE\.minikube jenkins:/var/jenkins_home/.minikube
```

Luego creé la configuración de kubectl dentro de Jenkins usando la IP de Minikube (192.168.49.2):
```powershell
docker exec -u root jenkins bash -c "cat > /var/jenkins_home/.kube/config << 'EOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/jenkins_home/.minikube/ca.crt
    server: https://192.168.49.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
users:
- name: minikube
  user:
    client-certificate: /var/jenkins_home/.minikube/profiles/minikube/client.crt
    client-key: /var/jenkins_home/.minikube/profiles/minikube/client.key
EOF
"
```

El paso final fue conectar Jenkins a la red de Docker de Minikube para que pudieran comunicarse:
```powershell
docker network connect minikube jenkins
```

Probé que funcionara:
```powershell
docker exec jenkins kubectl get nodes
```

### 5. Crear Pipeline de Verificación
En Jenkins creé un nuevo pipeline llamado `k8s-verification` con este script:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Verificar Kubernetes') {
            steps {
                echo 'Verificando conectividad con Kubernetes...'
                sh 'kubectl version --client'
                sh 'kubectl cluster-info'
            }
        }
        
        stage('Verificar Namespaces') {
            steps {
                echo 'Listando namespaces de Kubernetes...'
                sh 'kubectl get namespaces'
            }
        }
        
        stage('Verificar Pods') {
            steps {
                echo 'Verificando pods en todos los namespaces...'
                sh 'kubectl get pods --all-namespaces'
            }
        }
        
        stage('Estado del Cluster') {
            steps {
                echo 'Verificando estado general del cluster...'
                sh 'kubectl get nodes'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completado exitosamente!'
        }
    }
}
```

**Nota importante:** Tuve que usar comandos `sh` en lugar de `bat` porque Jenkins corre dentro de un contenedor Linux, aunque mi máquina sea Windows.

### 6. Ejecutar y Verificar
Ejecuté el pipeline con "Build Now" y todos los stages se completaron exitosamente, mostrando:
- Versión de kubectl
- Información del cluster
- Lista de namespaces (default, kube-system, kube-public, kube-node-lease)
- Pods corriendo en el cluster
- Estado del nodo de Minikube

## Resultado Final

Logré integrar completamente:
- **Jenkins** (http://localhost:8081) - Para CI/CD
- **Docker** - Como plataforma de contenedores
- **Kubernetes (Minikube)** - Para orquestación de contenedores

Jenkins ahora puede ejecutar comandos kubectl y está listo para automatizar despliegues en Kubernetes.

## Comandos Útiles para el Proyecto

Reiniciar Jenkins:
```powershell
docker restart jenkins
```

Verificar conectividad:
```powershell
docker exec jenkins kubectl get nodes
```

Ver logs de Jenkins:
```powershell
docker logs -f jenkins
```

---

**Isabella Ocampo - 25 de Octubre de 2025**
