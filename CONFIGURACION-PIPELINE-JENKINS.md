# Configuración de Jenkins para Pipeline de Kubernetes (Stage)

## 🎯 Objetivo

Configurar Jenkins para ejecutar el pipeline completo que despliega los 6 microservicios en Kubernetes (ambiente stage).

---

## 📋 Pre-requisitos

Antes de comenzar, asegúrate de tener:

- ✅ Jenkins corriendo en Docker (puerto 8081)
- ✅ Minikube instalado y corriendo
- ✅ Maven instalado en Jenkins
- ✅ kubectl instalado en Jenkins
- ✅ Jenkins conectado a Minikube

Si no has completado estos pasos, sigue la guía `GUIA-CONFIGURACION-JENKINS-K8S.md`.

---

## 🚀 Configuración Paso a Paso

### Paso 1: Instalar Docker CLI en Jenkins

Jenkins necesita poder ejecutar comandos Docker para construir las imágenes:

```powershell
# Instalar Docker CLI en el contenedor de Jenkins
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"

# Agregar usuario jenkins al grupo docker
docker exec -u root jenkins bash -c "usermod -aG docker jenkins"

# Reiniciar Jenkins
docker restart jenkins
```

**Verificar:**
```powershell
docker exec jenkins docker --version
```

### Paso 2: Configurar Docker para usar Minikube Daemon

El pipeline necesita construir imágenes directamente en el daemon de Minikube:

```powershell
# Obtener las variables de entorno de Minikube
minikube docker-env

# Esto mostrará algo como:
# $Env:DOCKER_TLS_VERIFY = "1"
# $Env:DOCKER_HOST = "tcp://192.168.49.2:2376"
# $Env:DOCKER_CERT_PATH = "C:\Users\Isabella\.minikube\certs"
# $Env:MINIKUBE_ACTIVE_DOCKERD = "minikube"
```

**Nota:** Esto se configura automáticamente en el Jenkinsfile con:
```groovy
sh 'eval $(minikube docker-env)'
```

### Paso 3: Dar Acceso a Minikube Socket

Jenkins necesita acceder al socket de Docker de Minikube:

```powershell
# Conectar Jenkins a la red de Minikube
docker network connect minikube jenkins

# Verificar conectividad
docker exec jenkins ping -c 1 $(minikube ip)
```

### Paso 4: Configurar Credenciales de Git (Opcional)

Si tu repositorio es privado:

1. En Jenkins, ir a: **Manage Jenkins** > **Manage Credentials**
2. Click en **(global)**
3. Click en **Add Credentials**
4. Configurar:
   - **Kind:** Username with password
   - **Username:** tu-usuario-github
   - **Password:** tu-token-github
   - **ID:** github-credentials
   - **Description:** GitHub Access Token

### Paso 5: Crear el Pipeline

1. **Abrir Jenkins:** http://localhost:8081

2. **Crear nuevo item:**
   - Click en **"New Item"**
   - Nombre: `deploy-microservices-stage`
   - Tipo: **Pipeline**
   - Click **OK**

3. **Configurar General:**
   - ✅ **Description:** "Pipeline para desplegar microservicios en Kubernetes (stage environment)"
   - ✅ **Discard old builds:** Days to keep: 7, Max # of builds: 10

4. **Configurar Build Triggers (Opcional):**
   - ✅ **GitHub hook trigger for GITScm polling** (si quieres trigger automático)
   - ✅ **Poll SCM:** `H/5 * * * *` (chequear cada 5 minutos)

5. **Configurar Pipeline:**
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git`
   - **Credentials:** (Si es privado, selecciona las credenciales creadas)
   - **Branch Specifier:** `*/master`
   - **Script Path:** `Jenkinsfile-stage`

6. **Click en "Save"**

### Paso 6: Configurar Variables de Entorno en Jenkins (Opcional)

Si quieres sobreescribir algunas variables:

1. En el pipeline, click en **"Configure"**
2. En **Pipeline**, agregar:

```groovy
environment {
    MINIKUBE_IP = sh(script: 'minikube ip', returnStdout: true).trim()
    DOCKER_BUILDKIT = '1'
}
```

### Paso 7: Instalar Plugins Necesarios

Asegúrate de tener estos plugins instalados en Jenkins:

1. **Manage Jenkins** > **Manage Plugins** > **Available**
2. Buscar e instalar:
   - ✅ **Kubernetes Plugin**
   - ✅ **Docker Pipeline**
   - ✅ **Git Plugin**
   - ✅ **Pipeline: Stage View Plugin**
   - ✅ **JUnit Plugin** (para reportes de tests)

3. Click **Install without restart**

---

## 🧪 Probar el Pipeline

### Primera Ejecución

1. En el pipeline `deploy-microservices-stage`, click en **"Build Now"**

2. Observa el progreso en **"Stage View"**:
   ```
   Checkout → Build Fase 1 → Build Fase 2 → Build Fase 3 
   → Verificar → Deploy → Wait → Tests → Reporte
   ```

3. Si algún stage falla, click en el stage y luego en **"Logs"**

### Ver Console Output

1. Click en el número del build (ej: **#1**)
2. Click en **"Console Output"**
3. Busca líneas con ❌ si hay errores

### Verificar Deployment en Kubernetes

Después de que el pipeline termine:

```powershell
# Ver deployments
kubectl get deployments -n ecommerce

# Ver pods
kubectl get pods -n ecommerce

# Ver services
kubectl get services -n ecommerce
```

---

## 🔧 Configuración Avanzada

### Configurar Post-build Actions

Edita el Jenkinsfile y agrega notificaciones:

```groovy
post {
    success {
        emailext (
            subject: "✅ Pipeline Exitoso: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "El deployment fue exitoso. Ver: ${env.BUILD_URL}",
            to: "tu-email@example.com"
        )
    }
    failure {
        emailext (
            subject: "❌ Pipeline Falló: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "El deployment falló. Ver logs: ${env.BUILD_URL}/console",
            to: "tu-email@example.com"
        )
    }
}
```

### Configurar Parallel Build

El Jenkinsfile ya tiene builds paralelos configurados:

```groovy
stage('Build & Test - Fase 1') {
    parallel {
        stage('user-service') { ... }
        stage('product-service') { ... }
    }
}
```

Esto reduce el tiempo de build de ~15 minutos a ~7 minutos.

### Agregar Stage de Aprobación Manual

Para producción, agrega un stage de aprobación:

```groovy
stage('Aprobar Deploy a Producción') {
    steps {
        input message: '¿Desplegar a producción?',
              ok: 'Deploy',
              submitter: 'admin'
    }
}
```

### Configurar Webhooks de GitHub

Para trigger automático en cada push:

1. En GitHub, ir a: **Settings** > **Webhooks** > **Add webhook**
2. **Payload URL:** `http://TU-IP-PUBLICA:8081/github-webhook/`
3. **Content type:** `application/json`
4. **Events:** Just the push event
5. **Active:** ✅
6. Click **Add webhook**

**Nota:** Jenkins debe ser accesible desde internet.

---

## 📊 Monitoreo del Pipeline

### Blue Ocean UI (Opcional)

Para una mejor visualización:

1. **Manage Jenkins** > **Manage Plugins**
2. Instalar **Blue Ocean**
3. Acceder en: http://localhost:8081/blue

### Configurar Build Metrics

1. **Manage Jenkins** > **Configure System**
2. En **Build Metrics**, configurar:
   - Retention policy
   - Build failure analyzer

### Ver Historial de Builds

```powershell
# Desde la línea de comandos
docker exec jenkins cat /var/jenkins_home/jobs/deploy-microservices-stage/builds/legacyIds
```

---

## 🛠️ Troubleshooting

### Error: "Cannot connect to Minikube"

**Problema:** Jenkins no puede conectarse a Minikube

**Solución:**
```powershell
# Verificar que Jenkins esté en la red de Minikube
docker network inspect minikube | findstr jenkins

# Si no está, conectar
docker network connect minikube jenkins

# Verificar conectividad
docker exec jenkins ping -c 1 $(minikube ip)
```

### Error: "kubectl: command not found"

**Problema:** kubectl no está instalado en Jenkins

**Solución:**
```powershell
docker exec -u root jenkins bash -c "curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl' && chmod +x kubectl && mv kubectl /usr/local/bin/"
```

### Error: "mvn: command not found"

**Problema:** Maven no está configurado

**Solución:**
1. **Manage Jenkins** > **Global Tool Configuration**
2. En **Maven**, verificar que `Maven-3.8.1` esté configurado
3. MAVEN_HOME: `/opt/apache-maven-3.8.1`

### Error: "Permission denied" en Docker

**Problema:** Jenkins no tiene permisos para Docker

**Solución:**
```powershell
docker exec -u root jenkins bash -c "usermod -aG docker jenkins"
docker restart jenkins
```

### Pipeline se queda esperando en "Wait for Deployment"

**Problema:** Los pods tardan mucho en estar listos

**Solución:**
1. Verificar recursos de Minikube:
   ```powershell
   minikube config set memory 4096
   minikube config set cpus 2
   minikube delete
   minikube start
   ```

2. Ver logs de los pods:
   ```powershell
   kubectl get pods -n ecommerce
   kubectl logs <pod-name> -n ecommerce
   ```

### Error: "ImagePullBackOff"

**Problema:** Kubernetes no encuentra la imagen Docker

**Solución:**
```powershell
# Asegurarse de que la imagen esté en Minikube
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker images | findstr user-service

# Si no está, construirla manualmente
cd user-service
docker build -t user-service:latest .
```

---

## ✅ Checklist de Configuración

Antes de ejecutar el pipeline, verifica:

- [ ] Jenkins corriendo en puerto 8081
- [ ] Minikube corriendo (`minikube status`)
- [ ] kubectl instalado en Jenkins (`docker exec jenkins kubectl version`)
- [ ] Maven configurado en Jenkins (Global Tool Configuration)
- [ ] Docker CLI instalado en Jenkins (`docker exec jenkins docker --version`)
- [ ] Jenkins conectado a red de Minikube
- [ ] Certificados de Minikube copiados a Jenkins
- [ ] Pipeline creado en Jenkins
- [ ] Script Path apunta a `Jenkinsfile-stage`
- [ ] Git repository configurado correctamente

---

## 📚 Comandos Útiles

### Jenkins

```powershell
# Ver logs de Jenkins
docker logs -f jenkins

# Reiniciar Jenkins
docker restart jenkins

# Entrar al contenedor de Jenkins
docker exec -it jenkins bash

# Ver configuración de Jenkins
docker exec jenkins cat /var/jenkins_home/config.xml
```

### Kubernetes

```powershell
# Ver todos los recursos
kubectl get all -n ecommerce

# Eliminar namespace completo
kubectl delete namespace ecommerce

# Ver configuración de kubectl
docker exec jenkins cat /var/jenkins_home/.kube/config
```

### Minikube

```powershell
# Ver status
minikube status

# Ver IP
minikube ip

# SSH a Minikube
minikube ssh

# Ver Docker daemon
minikube docker-env
```

---

## 🎓 Siguiente Paso

Una vez que el pipeline esté configurado y funcionando:

1. **Ejecuta el pipeline:** Build Now
2. **Verifica el deployment:** `kubectl get pods -n ecommerce`
3. **Ejecuta las pruebas:** `.\test-microservices-k8s.ps1`
4. **Revisa la documentación:** `PIPELINE-STAGE-K8S.md`

---

**¡Tu pipeline de CI/CD está listo para automatizar deployments a Kubernetes!** 🚀

---

**Isabella Ocampo**  
Octubre 26, 2025
