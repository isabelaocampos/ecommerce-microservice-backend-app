# ============================================================================
# Script de Despliegue Automatizado para E-Commerce Microservices
# ============================================================================
# Este script automatiza el despliegue completo en Kubernetes
# Uso: .\deploy-kubernetes.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 E-Commerce Microservices Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar prerequisitos
Write-Host "📋 Verificando prerequisitos..." -ForegroundColor Yellow

# Verificar kubectl
try {
    kubectl version --client | Out-Null
    Write-Host "✅ kubectl instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl no encontrado. Por favor instala kubectl." -ForegroundColor Red
    exit 1
}

# Verificar Minikube
try {
    minikube status | Out-Null
    Write-Host "✅ Minikube corriendo" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Minikube no está corriendo. Intentando iniciar..." -ForegroundColor Yellow
    minikube start --driver=docker
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar Minikube" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📦 Desplegando Servicios en Kubernetes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Crear namespace
Write-Host "📝 Creando namespace 'ecommerce'..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Desplegar Zipkin (Tracing)
Write-Host "📊 Desplegando Zipkin (Distributed Tracing)..." -ForegroundColor Yellow
kubectl apply -f k8s/zipkin-deployment.yaml

# Desplegar Eureka (Service Discovery)
Write-Host "🔍 Desplegando Eureka (Service Discovery)..." -ForegroundColor Yellow
kubectl apply -f k8s/eureka-deployment.yaml

# Esperar a que Eureka esté listo
Write-Host "⏳ Esperando a que Eureka esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce --timeout=300s

# Desplegar API Gateway
Write-Host "🌐 Desplegando API Gateway..." -ForegroundColor Yellow
kubectl apply -f k8s/api-gateway-deployment.yaml

# Desplegar Microservicios (6 servicios principales)
Write-Host "🔧 Desplegando 6 Microservicios..." -ForegroundColor Yellow
$services = @(
    "user-service-deployment.yaml",
    "product-service-deployment.yaml",
    "favourite-service-deployment.yaml",
    "order-service-deployment.yaml",
    "payment-service-deployment.yaml",
    "shipping-service-deployment.yaml"
)

foreach ($service in $services) {
    $serviceName = $service -replace "-deployment.yaml", ""
    Write-Host "  → Desplegando $serviceName..." -ForegroundColor Cyan
    kubectl apply -f "k8s/$service"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "⏳ Esperando a que los pods estén listos" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Esperar a que todos los deployments estén listos
$deployments = @(
    "service-discovery",
    "zipkin",
    "user-service",
    "product-service",
    "favourite-service",
    "order-service",
    "payment-service",
    "shipping-service"
)

foreach ($deployment in $deployments) {
    Write-Host "⏳ Esperando $deployment..." -ForegroundColor Yellow
    kubectl rollout status deployment/$deployment -n ecommerce --timeout=300s
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $deployment está listo" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $deployment tardó mucho en estar listo" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 Estado del Cluster" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Mostrar estado de pods
Write-Host "🔍 Pods en ecommerce namespace:" -ForegroundColor Yellow
kubectl get pods -n ecommerce

Write-Host ""
Write-Host "🔍 Servicios en ecommerce namespace:" -ForegroundColor Yellow
kubectl get services -n ecommerce

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔗 URLs de Acceso" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para acceder a los 6 microservicios, ejecuta:" -ForegroundColor Yellow
Write-Host ""
Write-Host "User Service:" -ForegroundColor Cyan
Write-Host "  minikube service user-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Product Service:" -ForegroundColor Cyan
Write-Host "  minikube service product-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Favourite Service:" -ForegroundColor Cyan
Write-Host "  minikube service favourite-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Order Service:" -ForegroundColor Cyan
Write-Host "  minikube service order-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Payment Service:" -ForegroundColor Cyan
Write-Host "  minikube service payment-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Shipping Service:" -ForegroundColor Cyan
Write-Host "  minikube service shipping-service-container -n ecommerce --url" -ForegroundColor White
Write-Host ""
Write-Host "Eureka Dashboard:" -ForegroundColor Cyan
Write-Host "  minikube service service-discovery-container -n ecommerce --url" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Despliegue Completado" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Comandos utiles:" -ForegroundColor Yellow
Write-Host "  Ver logs:           kubectl logs -f deployment/api-gateway -n ecommerce" -ForegroundColor White
Write-Host "  Ver todos los pods: kubectl get pods -n ecommerce" -ForegroundColor White
Write-Host "  Dashboard K8s:      minikube dashboard" -ForegroundColor White
Write-Host "  Eliminar todo:      kubectl delete namespace ecommerce" -ForegroundColor White
Write-Host ""
