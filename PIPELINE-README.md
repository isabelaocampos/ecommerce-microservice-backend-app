# 🚀 Pipeline CI/CD para Microservicios en Kubernetes

## 📌 Resumen Ejecutivo

Este proyecto implementa un **pipeline completo de CI/CD** para los 6 microservicios principales del sistema de e-commerce, incluyendo:

- ✅ **Build automatizado** con Maven
- ✅ **Pruebas unitarias** de cada microservicio
- ✅ **Construcción de imágenes Docker**
- ✅ **Despliegue en Kubernetes** (ambiente stage)
- ✅ **Pruebas de integración** en el ambiente desplegado
- ✅ **Health checks automáticos**
- ✅ **Reportes de estado** del deployment

---

## 🎯 Microservicios Incluidos

| Microservicio | Puerto Interno | NodePort | Función |
|---------------|----------------|----------|---------|
| **user-service** | 8700 | 30700 | Gestión de usuarios y autenticación |
| **product-service** | 8500 | 30500 | Catálogo y gestión de productos |
| **favourite-service** | 8800 | 30800 | Lista de favoritos/wishlist |
| **order-service** | 8300 | 30300 | Procesamiento de órdenes |
| **payment-service** | 8400 | 30400 | Procesamiento de pagos |
| **shipping-service** | 8600 | 30600 | Gestión de envíos |

---

## 📁 Archivos Creados

### 1. Manifiestos de Kubernetes (`k8s/`)

Cada microservicio tiene su propio archivo de deployment:

```
k8s/
├── user-service-deployment.yaml      ✅
├── product-service-deployment.yaml   ✅
├── favourite-service-deployment.yaml ✅
├── order-service-deployment.yaml     ✅
├── payment-service-deployment.yaml   ✅
└── shipping-service-deployment.yaml  ✅
```

**Características:**
- 2 réplicas por servicio (alta disponibilidad)
- Liveness y readiness probes
- Resource limits configurados
- Service tipo NodePort
- Variables de entorno para Eureka y Zipkin

### 2. Pipeline de Jenkins

**`Jenkinsfile-stage`** - Pipeline completo con 9 stages:

1. **Checkout** - Clonar repositorio
2. **Build & Test Fase 1** - user-service, product-service (paralelo)
3. **Build & Test Fase 2** - favourite-service, order-service (paralelo)
4. **Build & Test Fase 3** - payment-service, shipping-service (paralelo)
5. **Verificar Artefactos** - JAR files y Docker images
6. **Deploy to K8s** - Aplicar manifiestos
7. **Esperar Deployments** - Wait for pods ready
8. **Integration Tests** - Health checks en paralelo
9. **Estado Final** - Reporte completo

### 3. Scripts de Automatización

```
deploy-microservices-k8s.ps1   ✅ Deployment automatizado
test-microservices-k8s.ps1     ✅ Pruebas de integración
```

### 4. Documentación

```
PIPELINE-STAGE-K8S.md          ✅ Guía completa de implementación
```

---

## 🏗️ Arquitectura del Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                       GIT REPOSITORY                        │
│          (GitHub: ecommerce-microservice-backend)           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ git clone
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    JENKINS PIPELINE                         │
├─────────────────────────────────────────────────────────────┤
│  Stage 1: Checkout                                          │
│  Stage 2-4: Build & Test (Paralelo por fases)              │
│  Stage 5: Verificar Artefactos                              │
│  Stage 6: Build Docker Images                               │
│  Stage 7: Deploy to Kubernetes                              │
│  Stage 8: Wait for Ready                                    │
│  Stage 9: Integration Tests                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ kubectl apply
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              KUBERNETES CLUSTER (Minikube)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Namespace: ecommerce                                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: user-service (2 replicas)             │   │
│  │  Service: NodePort 30700                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: product-service (2 replicas)          │   │
│  │  Service: NodePort 30500                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: favourite-service (2 replicas)        │   │
│  │  Service: NodePort 30800                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: order-service (2 replicas)            │   │
│  │  Service: NodePort 30300                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: payment-service (2 replicas)          │   │
│  │  Service: NodePort 30400                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Deployment: shipping-service (2 replicas)         │   │
│  │  Service: NodePort 30600                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Guía de Uso Rápido

### Opción 1: Usando Jenkins (Recomendado)

1. **Abrir Jenkins:**
   ```powershell
   # Jenkins está en http://localhost:8081
   ```

2. **Crear Pipeline:**
   - New Item → "deploy-microservices-stage"
   - Pipeline script from SCM
   - Git: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git
   - Script Path: `Jenkinsfile-stage`

3. **Ejecutar:**
   - Build Now
   - Ver progreso en Stage View

### Opción 2: Usando Script PowerShell

```powershell
# Desplegar todos los microservicios
.\deploy-microservices-k8s.ps1

# Ejecutar pruebas
.\test-microservices-k8s.ps1
```

### Opción 3: Manual con kubectl

```powershell
# 1. Construir imágenes
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
cd user-service
.\mvnw.cmd clean package -DskipTests
docker build -t user-service:latest .
cd ..

# Repetir para cada servicio...

# 2. Crear namespace
kubectl create namespace ecommerce

# 3. Aplicar deployments
kubectl apply -f k8s/user-service-deployment.yaml
kubectl apply -f k8s/product-service-deployment.yaml
kubectl apply -f k8s/favourite-service-deployment.yaml
kubectl apply -f k8s/order-service-deployment.yaml
kubectl apply -f k8s/payment-service-deployment.yaml
kubectl apply -f k8s/shipping-service-deployment.yaml

# 4. Verificar
kubectl get pods -n ecommerce
```

---

## 🧪 Pruebas Incluidas

### 1. Pruebas Unitarias (en Pipeline)

```bash
mvn test
```

Ejecutadas durante el build de cada microservicio.

### 2. Health Checks (en Pipeline)

```bash
curl http://${MINIKUBE_IP}:30700/actuator/health
```

Verifican que cada servicio responda correctamente.

### 3. Liveness & Readiness Probes (Automático en K8s)

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

### 4. Pruebas de Integración (Script)

```powershell
.\test-microservices-k8s.ps1
```

Ejecuta:
- Health checks de todos los servicios
- Verificación de endpoints funcionales
- Pruebas de conectividad entre servicios
- Verificación de DNS interno

---

## 📊 Verificación del Deployment

### Ver estado de los deployments

```powershell
kubectl get deployments -n ecommerce
```

**Salida esperada:**
```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
user-service        2/2     2            2           5m
product-service     2/2     2            2           5m
favourite-service   2/2     2            2           5m
order-service       2/2     2            2           5m
payment-service     2/2     2            2           5m
shipping-service    2/2     2            2           5m
```

### Ver pods

```powershell
kubectl get pods -n ecommerce
```

**Salida esperada:**
```
NAME                                 READY   STATUS    RESTARTS   AGE
user-service-xxxxxxxxxx-xxxxx        1/1     Running   0          5m
user-service-xxxxxxxxxx-xxxxx        1/1     Running   0          5m
product-service-xxxxxxxxxx-xxxxx     1/1     Running   0          5m
product-service-xxxxxxxxxx-xxxxx     1/1     Running   0          5m
...
```

### Acceder a los servicios

```powershell
# Obtener IP de Minikube
$MINIKUBE_IP = minikube ip

# Probar servicios
curl http://${MINIKUBE_IP}:30700/actuator/health  # user-service
curl http://${MINIKUBE_IP}:30500/actuator/health  # product-service
curl http://${MINIKUBE_IP}:30800/actuator/health  # favourite-service
curl http://${MINIKUBE_IP}:30300/actuator/health  # order-service
curl http://${MINIKUBE_IP}:30400/actuator/health  # payment-service
curl http://${MINIKUBE_IP}:30600/actuator/health  # shipping-service
```

---

## 🔍 Monitoreo y Logs

### Ver logs de un servicio

```powershell
# Logs en tiempo real
kubectl logs -f deployment/user-service -n ecommerce

# Últimas 100 líneas
kubectl logs deployment/user-service -n ecommerce --tail=100
```

### Ver eventos

```powershell
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### Dashboard de Kubernetes

```powershell
minikube dashboard
```

### Métricas de recursos

```powershell
kubectl top pods -n ecommerce
kubectl top nodes
```

---

## 🛠️ Gestión del Deployment

### Escalar un servicio

```powershell
kubectl scale deployment/user-service --replicas=3 -n ecommerce
```

### Actualizar un servicio

```powershell
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

### Rollback

```powershell
kubectl rollout undo deployment/user-service -n ecommerce
```

---

## 🧹 Limpieza

### Eliminar todo

```powershell
kubectl delete namespace ecommerce
```

### Eliminar un servicio específico

```powershell
kubectl delete -f k8s/user-service-deployment.yaml
```

---

## ✅ Checklist de Verificación

Después de ejecutar el pipeline:

- [ ] Pipeline de Jenkins completado sin errores
- [ ] 6 deployments creados en namespace `ecommerce`
- [ ] 12 pods corriendo (2 réplicas × 6 servicios)
- [ ] 6 services tipo NodePort creados
- [ ] Todos los health checks responden HTTP 200
- [ ] Readiness probes pasan (kubectl get pods muestra READY)
- [ ] Liveness probes pasan (no hay restarts frecuentes)
- [ ] Logs no muestran errores críticos
- [ ] Todos los endpoints son accesibles desde fuera del cluster

---

## 📈 Métricas del Pipeline

| Métrica | Valor |
|---------|-------|
| **Tiempo total de ejecución** | ~5-7 minutos |
| **Stages** | 9 |
| **Servicios desplegados** | 6 |
| **Pods totales** | 12 (2 réplicas × 6) |
| **Tests ejecutados** | Unitarios + Health Checks |
| **Deployment strategy** | Rolling Update |
| **Tiempo de startup** | ~60 segundos por servicio |

---

## 🎓 Entregables del Taller

### 1. Pipelines (15%)

✅ **Jenkinsfile-stage**: Pipeline completo con:
- Build de 6 microservicios
- Tests unitarios
- Build de Docker images
- Deploy en Kubernetes
- Tests de integración en K8s

### 2. Manifiestos de Kubernetes

✅ **6 archivos YAML** en `k8s/`:
- Deployments con 2 réplicas
- Services tipo NodePort
- Health checks configurados
- Resource limits

### 3. Scripts de Automatización

✅ **deploy-microservices-k8s.ps1**: Deployment automatizado
✅ **test-microservices-k8s.ps1**: Pruebas de integración

### 4. Documentación

✅ **PIPELINE-STAGE-K8S.md**: Guía completa de implementación
✅ **Este README**: Resumen ejecutivo

---

## 🚧 Troubleshooting

### Pipeline falla en "Docker Build"

**Problema:** No puede construir la imagen Docker

**Solución:**
```powershell
# Asegurarse de usar el daemon de Minikube
eval $(minikube docker-env)
```

### Pods en estado CrashLoopBackOff

**Problema:** El pod se reinicia continuamente

**Solución:**
```powershell
# Ver logs
kubectl logs <pod-name> -n ecommerce --previous

# Verificar recursos
kubectl describe pod <pod-name> -n ecommerce
```

### Service no responde

**Problema:** No se puede acceder al servicio

**Solución:**
```powershell
# Verificar que el pod esté Running
kubectl get pods -n ecommerce

# Verificar endpoints
kubectl get endpoints -n ecommerce

# Probar desde dentro del cluster
kubectl run test --image=curlimages/curl -it --rm -- curl http://user-service:8700/actuator/health
```

---

## 📚 Referencias

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)

---

## 👥 Autor

**Isabella Ocampo**  
Ingeniería de Software V  
Universidad ICESI  
Octubre 26, 2025

---

## 📝 Notas Finales

Este pipeline implementa las mejores prácticas de CI/CD:

- ✅ **Construcción paralela** para optimizar tiempos
- ✅ **Tests automáticos** en cada stage
- ✅ **Health checks** antes de marcar como exitoso
- ✅ **Rollback automático** si falla el deployment
- ✅ **Monitoreo integrado** con liveness/readiness probes
- ✅ **Alta disponibilidad** con 2 réplicas por servicio
- ✅ **Documentación completa** para mantenimiento

**¡El ambiente de stage está listo para recibir deployments automáticos!** 🚀
