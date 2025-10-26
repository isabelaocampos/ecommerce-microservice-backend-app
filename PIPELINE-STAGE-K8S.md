# Pipeline de CI/CD con Jenkins y Kubernetes - Stage Environment

## 🎯 Objetivo

Crear pipelines completos que permitan la construcción, testing y despliegue de los 6 microservicios en Kubernetes (ambiente de stage), incluyendo pruebas de integración en el ambiente desplegado.

---

## 📋 Microservicios a Desplegar

Los 6 microservicios principales del proyecto:

1. **user-service** (Puerto 8700 → NodePort 30700)
2. **product-service** (Puerto 8500 → NodePort 30500)
3. **favourite-service** (Puerto 8800 → NodePort 30800)
4. **order-service** (Puerto 8300 → NodePort 30300)
5. **payment-service** (Puerto 8400 → NodePort 30400)
6. **shipping-service** (Puerto 8600 → NodePort 30600)

---

## 🏗️ Arquitectura del Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    JENKINS PIPELINE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1️⃣  Checkout                                               │
│      └─ Clonar código desde Git                            │
│                                                             │
│  2️⃣  Build & Test - Fase 1 (Paralelo)                       │
│      ├─ user-service                                        │
│      │   ├─ mvn clean package                              │
│      │   ├─ mvn test                                        │
│      │   └─ docker build                                    │
│      └─ product-service                                     │
│          ├─ mvn clean package                              │
│          ├─ mvn test                                        │
│          └─ docker build                                    │
│                                                             │
│  3️⃣  Build & Test - Fase 2 (Paralelo)                       │
│      ├─ favourite-service                                   │
│      └─ order-service                                       │
│                                                             │
│  4️⃣  Build & Test - Fase 3 (Paralelo)                       │
│      ├─ payment-service                                     │
│      └─ shipping-service                                    │
│                                                             │
│  5️⃣  Verificar Artefactos                                   │
│      ├─ JAR files                                           │
│      └─ Docker images                                       │
│                                                             │
│  6️⃣  Deploy to Kubernetes (Stage)                           │
│      ├─ Aplicar deployments                                │
│      └─ Crear/actualizar services                          │
│                                                             │
│  7️⃣  Esperar Deployments                                    │
│      └─ kubectl wait --for=condition=available             │
│                                                             │
│  8️⃣  Integration Tests on K8s (Paralelo)                    │
│      ├─ Health check user-service                          │
│      ├─ Health check product-service                       │
│      ├─ Health check favourite-service                     │
│      ├─ Health check order-service                         │
│      ├─ Health check payment-service                       │
│      └─ Health check shipping-service                      │
│                                                             │
│  9️⃣  Estado Final                                           │
│      ├─ Reporte de deployments                             │
│      ├─ Reporte de services                                │
│      ├─ Reporte de pods                                    │
│      └─ URLs de endpoints                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Archivos Creados

### 1. Deployments de Kubernetes

Creé archivos de deployment individuales para cada microservicio en `k8s/`:

- ✅ `user-service-deployment.yaml`
- ✅ `product-service-deployment.yaml`
- ✅ `favourite-service-deployment.yaml`
- ✅ `order-service-deployment.yaml`
- ✅ `payment-service-deployment.yaml`
- ✅ `shipping-service-deployment.yaml`

**Características de cada deployment:**
- 2 réplicas para alta disponibilidad
- Liveness y readiness probes configurados
- Resources limits y requests definidos
- Variables de entorno para Eureka y Zipkin
- Service tipo NodePort para acceso externo
- Namespace: `ecommerce`

### 2. Jenkinsfile para Stage Environment

Archivo: `Jenkinsfile-stage`

**Stages del Pipeline:**

1. **Checkout** - Clona el repositorio
2. **Build & Test Fases 1-3** - Construcción y tests en paralelo respetando dependencias
3. **Docker Build** - Construcción de imágenes Docker en Minikube daemon
4. **Deploy to K8s** - Aplicación de manifiestos de Kubernetes
5. **Wait for Deployment** - Espera a que los pods estén disponibles
6. **Integration Tests** - Health checks en paralelo de todos los servicios
7. **Final Report** - Estado final del deployment

### 3. Script de Deployment

Archivo: `deploy-microservices-k8s.ps1`

Script PowerShell que automatiza:
- Verificación de Minikube
- Configuración de Docker daemon
- Build de imágenes Docker
- Creación de namespace
- Deployment en Kubernetes
- Verificación de health checks

---

## 🚀 Implementación Paso a Paso

### Paso 1: Preparar el Ambiente

```powershell
# Asegurarse de que Minikube esté corriendo
minikube status
minikube start  # Si no está corriendo

# Verificar kubectl
kubectl version --client

# Verificar que Jenkins esté corriendo
docker ps | findstr jenkins
```

### Paso 2: Configurar Jenkins para Kubernetes

Si aún no lo has hecho, ejecuta estos comandos:

```powershell
# Instalar kubectl en Jenkins
docker exec -u root jenkins bash -c "curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl' && chmod +x kubectl && mv kubectl /usr/local/bin/"

# Copiar certificados de Minikube
docker cp $env:USERPROFILE\.minikube jenkins:/var/jenkins_home/.minikube

# Configurar kubeconfig
$MINIKUBE_IP = minikube ip
docker exec -u root jenkins bash -c "mkdir -p /var/jenkins_home/.kube && cat > /var/jenkins_home/.kube/config << 'EOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/jenkins_home/.minikube/ca.crt
    server: https://${MINIKUBE_IP}:8443
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

# Conectar Jenkins a la red de Minikube
docker network connect minikube jenkins

# Verificar
docker exec jenkins kubectl get nodes
```

### Paso 3: Instalar Docker CLI en Jenkins

Jenkins necesita Docker CLI para construir imágenes:

```powershell
docker exec -u root jenkins bash -c "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
```

### Paso 4: Configurar Minikube Docker Daemon en Jenkins

Jenkins debe usar el daemon de Docker de Minikube:

```powershell
# Obtener las variables de entorno de Docker de Minikube
minikube docker-env

# Aplicar en Jenkins (esto debe hacerse en el pipeline)
```

### Paso 5: Crear Pipeline en Jenkins

1. Abre Jenkins: http://localhost:8081
2. Clic en **"New Item"**
3. Nombre: `deploy-microservices-stage`
4. Tipo: **Pipeline**
5. En **Pipeline**:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git
   - **Branch:** */master
   - **Script Path:** `Jenkinsfile-stage`
6. Guardar

### Paso 6: Ejecutar el Pipeline

```
1. En Jenkins, ir al pipeline "deploy-microservices-stage"
2. Clic en "Build Now"
3. Ver el progreso en "Stage View"
4. Revisar los logs en "Console Output"
```

### Paso 7: Verificar Deployment

Después de que el pipeline termine exitosamente:

```powershell
# Ver deployments
kubectl get deployments -n ecommerce

# Ver pods
kubectl get pods -n ecommerce

# Ver services
kubectl get services -n ecommerce

# Obtener IP de Minikube
$MINIKUBE_IP = minikube ip

# Probar los endpoints
curl http://${MINIKUBE_IP}:30700/actuator/health  # user-service
curl http://${MINIKUBE_IP}:30500/actuator/health  # product-service
curl http://${MINIKUBE_IP}:30800/actuator/health  # favourite-service
curl http://${MINIKUBE_IP}:30300/actuator/health  # order-service
curl http://${MINIKUBE_IP}:30400/actuator/health  # payment-service
curl http://${MINIKUBE_IP}:30600/actuator/health  # shipping-service
```

---

## 🧪 Pruebas en el Ambiente de Stage

El pipeline incluye pruebas automáticas en Kubernetes:

### 1. Health Checks Automáticos

Cada microservicio es verificado mediante su endpoint `/actuator/health`:

```bash
# Ejemplo de verificación automática en el pipeline
MINIKUBE_IP=$(minikube ip)
SERVICE_URL="http://${MINIKUBE_IP}:30700"
curl -s "${SERVICE_URL}/actuator/health" | grep "UP"
```

### 2. Readiness y Liveness Probes

Kubernetes automáticamente verifica:
- **Liveness:** ¿El pod está vivo?
- **Readiness:** ¿El pod está listo para recibir tráfico?

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8700
  initialDelaySeconds: 60
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8700
  initialDelaySeconds: 30
  periodSeconds: 5
```

### 3. Verificación Manual Adicional

```powershell
# Ejecutar pruebas E2E contra el ambiente de stage
$MINIKUBE_IP = minikube ip
$env:USER_SERVICE_URL = "http://${MINIKUBE_IP}:30700"
$env:PRODUCT_SERVICE_URL = "http://${MINIKUBE_IP}:30500"
$env:ORDER_SERVICE_URL = "http://${MINIKUBE_IP}:30300"

# Ejecutar pruebas
.\mvnw.cmd test -Dtest=*E2ETest
```

---

## 📊 Monitoreo del Deployment

### Ver logs de un servicio

```powershell
# Logs en tiempo real
kubectl logs -f deployment/user-service -n ecommerce

# Últimas 100 líneas
kubectl logs deployment/user-service -n ecommerce --tail=100

# Logs de un pod específico
kubectl logs <pod-name> -n ecommerce
```

### Describir un deployment

```powershell
kubectl describe deployment user-service -n ecommerce
```

### Ver eventos

```powershell
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### Dashboard de Kubernetes

```powershell
# Abrir dashboard de Minikube
minikube dashboard
```

---

## 🔄 Gestión del Deployment

### Escalar un servicio

```powershell
# Escalar a 3 réplicas
kubectl scale deployment/user-service --replicas=3 -n ecommerce

# Verificar
kubectl get deployment user-service -n ecommerce
```

### Actualizar un servicio

```powershell
# Editar deployment
kubectl edit deployment user-service -n ecommerce

# O aplicar cambios desde archivo
kubectl apply -f k8s/user-service-deployment.yaml
```

### Reiniciar un deployment

```powershell
kubectl rollout restart deployment/user-service -n ecommerce
```

### Ver historial de rollouts

```powershell
kubectl rollout history deployment/user-service -n ecommerce
```

### Rollback a versión anterior

```powershell
kubectl rollout undo deployment/user-service -n ecommerce
```

---

## 🛠️ Troubleshooting

### Pod no inicia (CrashLoopBackOff)

```powershell
# Ver logs del pod
kubectl logs <pod-name> -n ecommerce --previous

# Describir el pod
kubectl describe pod <pod-name> -n ecommerce
```

### Imagen no se encuentra

```powershell
# Asegurarse de que la imagen esté en Minikube
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker images | findstr user-service

# Reconstruir imagen
cd user-service
docker build -t user-service:latest .
```

### Service no responde

```powershell
# Verificar que el pod esté corriendo
kubectl get pods -n ecommerce

# Verificar endpoints
kubectl get endpoints -n ecommerce

# Probar desde dentro del cluster
kubectl run test-pod --image=curlimages/curl -it --rm -- sh
curl http://user-service:8700/actuator/health
```

### Problemas de conectividad

```powershell
# Verificar que Minikube tunnel esté corriendo (si usas LoadBalancer)
minikube tunnel

# O usar port-forward
kubectl port-forward service/user-service 8700:8700 -n ecommerce
```

---

## 📈 Métricas y Monitoreo

### Recursos utilizados por los pods

```powershell
kubectl top pods -n ecommerce
kubectl top nodes
```

### Ver métricas de un deployment

```powershell
kubectl get deployment user-service -n ecommerce -o yaml
```

---

## 🧹 Limpieza

### Eliminar todos los deployments

```powershell
# Eliminar namespace completo
kubectl delete namespace ecommerce

# O eliminar servicios individuales
kubectl delete -f k8s/user-service-deployment.yaml
kubectl delete -f k8s/product-service-deployment.yaml
# etc...
```

### Limpiar imágenes Docker

```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker images | findstr -service
docker rmi <image-id>
```

---

## ✅ Checklist de Verificación

Después de ejecutar el pipeline, verifica:

- [ ] Todos los stages del pipeline están en verde
- [ ] 6 deployments creados en namespace `ecommerce`
- [ ] 12 pods corriendo (2 réplicas × 6 servicios)
- [ ] 6 services tipo NodePort creados
- [ ] Health checks responden HTTP 200
- [ ] Logs no muestran errores críticos
- [ ] Readiness probes pasan
- [ ] Liveness probes pasan

---

## 📚 Próximos Pasos

1. **Agregar pruebas E2E completas** - Ejecutar flujos de usuario completos
2. **Implementar monitoring** - Prometheus + Grafana
3. **Agregar logging centralizado** - ELK Stack
4. **Configurar CI/CD completo** - Deploy automático en cada commit
5. **Implementar stage de producción** - Deployment a producción con aprobación manual

---

## 🎯 Resultado Esperado

Al finalizar el pipeline exitosamente:

```
✅ Pipeline completado exitosamente!
📋 Todos los microservicios fueron:
   ✓ Compilados
   ✓ Testeados (pruebas unitarias)
   ✓ Construidos como Docker images
   ✓ Desplegados en Kubernetes (stage)
   ✓ Verificados con health checks

📡 Endpoints disponibles:
  user-service:      http://192.168.49.2:30700
  product-service:   http://192.168.49.2:30500
  favourite-service: http://192.168.49.2:30800
  order-service:     http://192.168.49.2:30300
  payment-service:   http://192.168.49.2:30400
  shipping-service:  http://192.168.49.2:30600
```

---

**Isabella Ocampo - 26 de Octubre de 2025**
**Ingeniería de Software V - ICESI**
