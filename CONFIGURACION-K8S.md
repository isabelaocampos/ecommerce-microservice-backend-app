# 🚀 Guía de Configuración: Jenkins, Docker y Kubernetes

## 📋 Requisitos Previos
- ✅ Docker Desktop instalado
- ✅ Jenkins corriendo en puerto 8081
- ⬜ Minikube instalado
- ⬜ kubectl instalado

---

## 1️⃣ JENKINS - Configuración Inicial

### Acceder a Jenkins
```
URL: http://localhost:8081
```

### Instalar Jenkins limpio (si es necesario)
```powershell
# Detener y limpiar instalación anterior
docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home

# Iniciar nuevo Jenkins
docker run -d --name jenkins -p 8081:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Obtener contraseña inicial
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Plugins necesarios
1. Ir a **Manage Jenkins** > **Manage Plugins**
2. Instalar:
   - Docker Pipeline
   - Docker Plugin
   - Kubernetes Plugin
   - Kubernetes CLI Plugin
   - Git Plugin
   - Maven Integration Plugin

### Configurar Credenciales
1. **Docker Hub:**
   - Ir a **Manage Jenkins** > **Manage Credentials**
   - Add Credentials > Username with password
   - ID: `dockerhub-credentials`
   - Username: tu usuario de Docker Hub
   - Password: tu token de Docker Hub

2. **Kubernetes:**
   - Add Credentials > Secret file
   - ID: `kubeconfig`
   - File: `~/.kube/config` (después de configurar Minikube)

---

## 2️⃣ DOCKER - Verificación y Configuración

### Verificar instalación
```powershell
docker --version
docker ps
docker images
```

### Verificar que Docker Desktop esté corriendo
```powershell
docker info
```

### Probar Docker con tu proyecto
```powershell
# Verificar que los contenedores estén corriendo
docker-compose -f core.yml ps
docker-compose -f compose.yml ps
```

---

## 3️⃣ KUBERNETES - Instalación y Configuración

### Instalar Minikube en Windows

**Opción 1: Con Chocolatey**
```powershell
choco install minikube
```

**Opción 2: Descarga manual**
```powershell
# Descargar desde: https://minikube.sigs.k8s.io/docs/start/
# O ejecutar:
New-Item -Path 'c:\minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
$env:PATH += ";c:\minikube"
```

### Instalar kubectl
```powershell
choco install kubernetes-cli
# O descargar desde: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Iniciar Minikube
```powershell
# Iniciar con Docker como driver
minikube start --driver=docker

# Verificar estado
minikube status

# Verificar nodos
kubectl get nodes

# Habilitar dashboard (opcional)
minikube dashboard
```

---

## 4️⃣ DESPLEGAR EN KUBERNETES

### Crear namespace y desplegar servicios
```powershell
# Ir al directorio del proyecto
cd "C:\Users\Isabella\Documents\ICESI\8. Octavo Semestre\Ingenieria de Software V\ecommerce-microservice-backend-app"

# Aplicar configuraciones
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# Verificar deployments
kubectl get deployments -n ecommerce

# Verificar pods
kubectl get pods -n ecommerce

# Verificar servicios
kubectl get services -n ecommerce
```

### Acceder a los servicios
```powershell
# Obtener URL del servicio API Gateway
minikube service api-gateway-container -n ecommerce --url

# Obtener URL del servicio Eureka
minikube service service-discovery-container -n ecommerce --url

# Obtener URL del User Service
minikube service user-service-container -n ecommerce --url
```

---

## 5️⃣ CONFIGURAR PIPELINE EN JENKINS

### Crear nuevo Job
1. En Jenkins: **New Item** > **Pipeline**
2. Nombre: `ecommerce-microservices-pipeline`
3. En **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git`
   - Branch: `*/master`
   - Script Path: `Jenkinsfile`

### Ejecutar Pipeline
1. Click en **Build Now**
2. Ver logs en **Console Output**

---

## 6️⃣ COMANDOS ÚTILES

### Docker
```powershell
# Ver logs de un servicio
docker logs <container-name> -f

# Reconstruir imágenes
docker-compose build --no-cache

# Limpiar todo
docker system prune -a
```

### Kubernetes
```powershell
# Ver logs de un pod
kubectl logs <pod-name> -n ecommerce

# Describir un pod
kubectl describe pod <pod-name> -n ecommerce

# Reiniciar deployment
kubectl rollout restart deployment/<deployment-name> -n ecommerce

# Escalar deployment
kubectl scale deployment/<deployment-name> --replicas=3 -n ecommerce

# Eliminar todo
kubectl delete namespace ecommerce
```

### Minikube
```powershell
# Detener Minikube
minikube stop

# Eliminar Minikube
minikube delete

# Ver addons
minikube addons list

# Habilitar metrics-server
minikube addons enable metrics-server
```

---

## 7️⃣ VERIFICAR CONFIGURACIÓN

### Checklist
- [ ] Jenkins accesible en http://localhost:8081
- [ ] Plugins de Docker y Kubernetes instalados en Jenkins
- [ ] Docker Desktop corriendo
- [ ] Minikube iniciado (`minikube status`)
- [ ] kubectl funciona (`kubectl get nodes`)
- [ ] Deployments creados (`kubectl get deployments -n ecommerce`)
- [ ] Servicios expuestos (`kubectl get services -n ecommerce`)

### Prueba end-to-end
```powershell
# 1. Obtener URL del API Gateway
$API_URL = minikube service api-gateway-container -n ecommerce --url

# 2. Hacer petición de prueba
Invoke-WebRequest -Uri "$API_URL/app/api/products" -Method GET
```

---

## 🎯 Resultado Final

Deberías tener:
1. ✅ Jenkins corriendo y configurado
2. ✅ Pipeline de CI/CD funcional
3. ✅ Microservicios desplegados en Kubernetes
4. ✅ Servicios accesibles via Minikube

## 📚 Recursos Adicionales
- Jenkins: https://www.jenkins.io/doc/
- Kubernetes: https://kubernetes.io/docs/
- Minikube: https://minikube.sigs.k8s.io/docs/
