# 🧪 Guía de Verificación y Testing

## Verificación Rápida - Checklist

### ✅ Paso 1: Verificar Kubernetes

```powershell
# Ver archivos creados
ls k8s\

# Deberías ver:
# - namespace.yaml
# - api-gateway-deployment.yaml
# - eureka-deployment.yaml
# - zipkin-deployment.yaml
# - user-service-deployment.yaml
# - product-service-deployment.yaml
# - order-service-deployment.yaml
# - payment-service-deployment.yaml
# - shipping-service-deployment.yaml
# - favourite-service-deployment.yaml
```

### ✅ Paso 2: Verificar Pruebas Creadas

```powershell
# Ver pruebas unitarias
Get-ChildItem -Recurse -Filter "*UnitTest.java"

# Ver pruebas de integración
Get-ChildItem -Recurse -Filter "*IntegrationTest.java"

# Ver pruebas E2E
Get-ChildItem -Recurse -Filter "*E2ETest.java"

# Ver Locust
cat locustfile.py
```

### ✅ Paso 3: Verificar Jenkinsfiles

```powershell
# Listar Jenkinsfiles
ls Jenkinsfile*

# Deberías ver:
# - Jenkinsfile-dev
# - Jenkinsfile-stage
# - Jenkinsfile-master
```

---

## 🚀 Despliegue en Kubernetes - Paso a Paso

### Opción 1: Usando el Script Automatizado (RECOMENDADO)

```powershell
# Ejecutar script de despliegue
.\deploy-kubernetes.ps1

# Esto hace TODO automáticamente:
# 1. Verifica prerequisitos
# 2. Inicia Minikube si no está corriendo
# 3. Crea namespace
# 4. Despliega todos los servicios
# 5. Espera a que estén listos
# 6. Muestra el estado y URLs
```

### Opción 2: Manual (Para entender cada paso)

```powershell
# 1. Iniciar Minikube
minikube start --driver=docker

# 2. Crear namespace
kubectl apply -f k8s/namespace.yaml

# 3. Desplegar servicios de infraestructura
kubectl apply -f k8s/zipkin-deployment.yaml
kubectl apply -f k8s/eureka-deployment.yaml

# 4. Esperar a que Eureka esté listo
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce --timeout=300s

# 5. Desplegar API Gateway
kubectl apply -f k8s/api-gateway-deployment.yaml

# 6. Desplegar microservicios
kubectl apply -f k8s/user-service-deployment.yaml
kubectl apply -f k8s/product-service-deployment.yaml
kubectl apply -f k8s/order-service-deployment.yaml
kubectl apply -f k8s/payment-service-deployment.yaml
kubectl apply -f k8s/shipping-service-deployment.yaml
kubectl apply -f k8s/favourite-service-deployment.yaml

# 7. Verificar estado
kubectl get pods -n ecommerce
kubectl get services -n ecommerce

# 8. Esperar a que todos estén listos
kubectl wait --for=condition=ready pod --all -n ecommerce --timeout=600s
```

---

## 🧪 Ejecutar Pruebas - Paso a Paso

### Opción 1: Usando el Script Automatizado (RECOMENDADO)

```powershell
# Ejecutar TODAS las pruebas
.\run-all-tests.ps1

# Ejecutar solo algunas pruebas
.\run-all-tests.ps1 -SkipE2E          # Salta E2E
.\run-all-tests.ps1 -SkipPerformance  # Salta Performance
.\run-all-tests.ps1 -SkipIntegration  # Salta Integration
```

### Opción 2: Manual (Pruebas específicas)

#### Pruebas Unitarias

```powershell
# Todas las pruebas unitarias
mvnw.cmd test

# Pruebas unitarias de un servicio específico
cd user-service
..\mvnw.cmd test
cd ..

# Pruebas unitarias de una clase específica
cd user-service
..\mvnw.cmd test -Dtest=UserServiceUnitTest
cd ..

# Ver reportes
start user-service\target\surefire-reports\index.html
```

#### Pruebas de Integración

```powershell
# Todas las pruebas de integración
cd user-service
..\mvnw.cmd test -Dtest=*IntegrationTest
cd ..

# Pruebas de integración de Product Service
cd product-service
..\mvnw.cmd test -Dtest=*IntegrationTest
cd ..

# Ver reportes
start user-service\target\surefire-reports\index.html
```

#### Pruebas E2E

```powershell
# Nota: Para E2E los servicios deben estar corriendo en Kubernetes

# Verificar servicios corriendo
kubectl get pods -n ecommerce

# Ejecutar pruebas E2E
cd user-service
..\mvnw.cmd test -Dtest=*E2ETest
cd ..

cd product-service
..\mvnw.cmd test -Dtest=*E2ETest
cd ..

cd order-service
..\mvnw.cmd test -Dtest=*E2ETest
cd ..
```

#### Pruebas de Rendimiento (Locust)

```powershell
# Instalar Locust si no está instalado
python -m pip install locust

# Verificar instalación
locust --version

# Opción A: Con UI (Recomendado para desarrollo)
locust -f locustfile.py

# Abrir navegador: http://localhost:8089
# Configurar:
#   - Number of users: 100
#   - Spawn rate: 10 users/second
#   - Host: http://localhost:8080
# Click "Start Swarming"

# Opción B: Sin UI (Para CI/CD)
locust -f locustfile.py --headless -u 100 -r 10 -t 5m --html performance-report.html

# Ver reporte
start performance-report.html
```

---

## 🎯 Probar Servicios Manualmente

### Obtener URLs de los Servicios

```powershell
# API Gateway
minikube service api-gateway-container -n ecommerce --url

# User Service
minikube service user-service-container -n ecommerce --url

# Product Service
minikube service product-service-container -n ecommerce --url

# Order Service
minikube service order-service-container -n ecommerce --url

# Eureka Dashboard
minikube service service-discovery-container -n ecommerce --url
```

### Probar con cURL o PowerShell

```powershell
# Obtener URL del servicio
$API_URL = minikube service api-gateway-container -n ecommerce --url

# Listar usuarios
Invoke-WebRequest -Uri "$API_URL/api/users" -Method GET

# Crear usuario
$body = @{
    firstName = "Test"
    lastName = "User"
    email = "test@example.com"
    phone = "1234567890"
} | ConvertTo-Json

Invoke-WebRequest -Uri "$API_URL/api/users" -Method POST -Body $body -ContentType "application/json"

# Listar productos
Invoke-WebRequest -Uri "$API_URL/api/products" -Method GET

# Crear orden
$orderBody = @{
    orderDesc = "Test Order"
} | ConvertTo-Json

Invoke-WebRequest -Uri "$API_URL/api/orders" -Method POST -Body $orderBody -ContentType "application/json"
```

---

## 🔍 Troubleshooting

### Problema: Pods no inician

```powershell
# Ver detalles del pod
kubectl describe pod <pod-name> -n ecommerce

# Ver logs del pod
kubectl logs <pod-name> -n ecommerce

# Ver eventos
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Reiniciar deployment
kubectl rollout restart deployment/<deployment-name> -n ecommerce
```

### Problema: Pruebas fallan

```powershell
# Ver logs detallados de Maven
mvnw.cmd test -X

# Ver reportes de pruebas
start target\surefire-reports\index.html

# Limpiar y reconstruir
mvnw.cmd clean install
```

### Problema: Locust no se conecta

```powershell
# Verificar que los servicios estén corriendo
kubectl get pods -n ecommerce

# Obtener URL correcta del API Gateway
minikube service api-gateway-container -n ecommerce --url

# Usar esa URL en Locust
```

### Problema: Minikube no inicia

```powershell
# Eliminar y reiniciar
minikube delete
minikube start --driver=docker

# Verificar recursos
docker info

# Verificar Hyper-V/VirtualBox está habilitado
```

---

## 📊 Verificar Resultados

### Verificar Kubernetes

```powershell
# Todos los pods deben estar Running
kubectl get pods -n ecommerce

# Todos los servicios deben tener EXTERNAL-IP (o pending)
kubectl get services -n ecommerce

# Deployments deben tener READY 2/2 o 1/1
kubectl get deployments -n ecommerce

# No debe haber errores recientes
kubectl get events -n ecommerce --sort-by='.lastTimestamp' | Select-Object -Last 20
```

### Verificar Pruebas

```powershell
# Buscar reportes de JUnit
Get-ChildItem -Recurse -Path . -Include "TEST-*.xml" | Select-Object FullName

# Contar pruebas ejecutadas
$reports = Get-ChildItem -Recurse -Path . -Include "TEST-*.xml"
$reports.Count

# Ver último reporte de Locust
if (Test-Path performance-report.html) {
    Write-Host "✅ Reporte de Locust encontrado"
    start performance-report.html
}
```

---

## 📸 Screenshots para el Reporte

### 1. Configuración Jenkins

```
- Panel de Jenkins con los 3 pipelines
- Configuración de credenciales Docker Hub
- Configuración de credenciales Kubeconfig
- Configuración de un pipeline (script from SCM)
```

### 2. Kubernetes Desplegado

```powershell
# Capturar este output
kubectl get all -n ecommerce

# Capturar dashboard
minikube dashboard
```

### 3. Ejecución de Pipelines

```
- Pipeline DEV en ejecución y completado
- Pipeline STAGE en ejecución y completado
- Pipeline MASTER en ejecución y completado
- Console Output mostrando pasos exitosos
```

### 4. Reportes de Pruebas

```powershell
# Abrir reportes para capturar
start user-service\target\surefire-reports\index.html
start performance-report.html
```

### 5. Release Notes

```powershell
# Ver Release Notes generadas
Get-ChildItem -Filter "RELEASE-NOTES-*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

---

## ✅ Checklist Final de Verificación

```powershell
Write-Host "🔍 Verificación del Proyecto" -ForegroundColor Cyan
Write-Host ""

# Kubernetes
Write-Host "Kubernetes:" -ForegroundColor Yellow
if (minikube status | Select-String "Running") {
    Write-Host "  ✅ Minikube corriendo" -ForegroundColor Green
}
$pods = kubectl get pods -n ecommerce 2>$null
if ($pods) {
    Write-Host "  ✅ Pods desplegados" -ForegroundColor Green
}

# Jenkinsfiles
Write-Host "Jenkinsfiles:" -ForegroundColor Yellow
if (Test-Path "Jenkinsfile-dev") { Write-Host "  ✅ Jenkinsfile-dev" -ForegroundColor Green }
if (Test-Path "Jenkinsfile-stage") { Write-Host "  ✅ Jenkinsfile-stage" -ForegroundColor Green }
if (Test-Path "Jenkinsfile-master") { Write-Host "  ✅ Jenkinsfile-master" -ForegroundColor Green }

# Pruebas
Write-Host "Pruebas:" -ForegroundColor Yellow
$unitTests = Get-ChildItem -Recurse -Filter "*UnitTest.java"
Write-Host "  ✅ $($unitTests.Count) archivos de pruebas unitarias" -ForegroundColor Green
$integrationTests = Get-ChildItem -Recurse -Filter "*IntegrationTest.java"
Write-Host "  ✅ $($integrationTests.Count) archivos de pruebas de integración" -ForegroundColor Green
$e2eTests = Get-ChildItem -Recurse -Filter "*E2ETest.java"
Write-Host "  ✅ $($e2eTests.Count) archivos de pruebas E2E" -ForegroundColor Green

# Locust
Write-Host "Rendimiento:" -ForegroundColor Yellow
if (Test-Path "locustfile.py") {
    $lines = (Get-Content "locustfile.py").Count
    Write-Host "  ✅ locustfile.py ($lines líneas)" -ForegroundColor Green
}

# Documentación
Write-Host "Documentación:" -ForegroundColor Yellow
if (Test-Path "TALLER2-GUIA.md") { Write-Host "  ✅ TALLER2-GUIA.md" -ForegroundColor Green }
if (Test-Path "RESUMEN-EJECUTIVO.md") { Write-Host "  ✅ RESUMEN-EJECUTIVO.md" -ForegroundColor Green }
if (Test-Path "CONFIGURACION-K8S.md") { Write-Host "  ✅ CONFIGURACION-K8S.md" -ForegroundColor Green }

Write-Host ""
Write-Host "✨ Verificación completada" -ForegroundColor Cyan
```

---

**¡Listo para ejecutar y documentar! 🎓**
