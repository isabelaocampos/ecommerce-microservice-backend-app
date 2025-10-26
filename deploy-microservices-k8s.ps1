# Script para desplegar los 6 microservicios en Kubernetes
# Isabella Ocampo - Ingeniería de Software V

Write-Host "🚀 Desplegando Microservicios en Kubernetes (Stage Environment)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Minikube esté corriendo
Write-Host "📍 Paso 1: Verificando Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Minikube no está corriendo. Iniciando Minikube..." -ForegroundColor Red
    minikube start
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar Minikube" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Minikube está corriendo" -ForegroundColor Green
}

# Obtener IP de Minikube
$MINIKUBE_IP = minikube ip
Write-Host "📡 IP de Minikube: $MINIKUBE_IP" -ForegroundColor Cyan
Write-Host ""

# Configurar Docker para usar el daemon de Minikube
Write-Host "📍 Paso 2: Configurando Docker para Minikube..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
Write-Host "✅ Docker configurado para usar Minikube daemon" -ForegroundColor Green
Write-Host ""

# Construir imágenes Docker para cada microservicio
Write-Host "📍 Paso 3: Construyendo imágenes Docker..." -ForegroundColor Yellow

$services = @(
    "user-service",
    "product-service", 
    "favourite-service",
    "order-service",
    "payment-service",
    "shipping-service"
)

foreach ($service in $services) {
    Write-Host "🐳 Construyendo $service..." -ForegroundColor Cyan
    Push-Location $service
    
    # Construir JAR si no existe
    if (-not (Test-Path "target\*.jar")) {
        Write-Host "   📦 Compilando $service..." -ForegroundColor Gray
        .\mvnw.cmd clean package -DskipTests
    }
    
    # Construir imagen Docker
    docker build -t "${service}:latest" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Imagen ${service}:latest creada" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Error al construir imagen de $service" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
}

Write-Host ""

# Crear namespace si no existe
Write-Host "📍 Paso 4: Creando namespace 'ecommerce'..." -ForegroundColor Yellow
kubectl get namespace ecommerce 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    kubectl create namespace ecommerce
    Write-Host "✅ Namespace 'ecommerce' creado" -ForegroundColor Green
} else {
    Write-Host "✅ Namespace 'ecommerce' ya existe" -ForegroundColor Green
}
Write-Host ""

# Desplegar microservicios
Write-Host "📍 Paso 5: Desplegando microservicios en Kubernetes..." -ForegroundColor Yellow

foreach ($service in $services) {
    Write-Host "☸️  Desplegando $service..." -ForegroundColor Cyan
    kubectl apply -f "k8s\${service}-deployment.yaml"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ $service desplegado" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Error al desplegar $service" -ForegroundColor Red
    }
}

Write-Host ""

# Esperar a que los deployments estén listos
Write-Host "📍 Paso 6: Esperando que los pods estén listos..." -ForegroundColor Yellow
Write-Host "⏳ Esto puede tomar hasta 2 minutos..." -ForegroundColor Gray
Write-Host ""

foreach ($service in $services) {
    Write-Host "⏰ Esperando $service..." -ForegroundColor Cyan
    kubectl wait --for=condition=available --timeout=120s "deployment/$service" -n ecommerce
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ $service está listo" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $service tardó más de lo esperado" -ForegroundColor Yellow
    }
}

Write-Host ""

# Mostrar estado de los deployments
Write-Host "📍 Paso 7: Verificando estado de los deployments..." -ForegroundColor Yellow
Write-Host ""
Write-Host "📦 Deployments:" -ForegroundColor Cyan
kubectl get deployments -n ecommerce
Write-Host ""

Write-Host "🐳 Pods:" -ForegroundColor Cyan
kubectl get pods -n ecommerce
Write-Host ""

Write-Host "🎯 Services:" -ForegroundColor Cyan
kubectl get services -n ecommerce
Write-Host ""

# Mostrar URLs de acceso
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "✅ DEPLOYMENT COMPLETADO" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📡 Endpoints de los microservicios:" -ForegroundColor Yellow
Write-Host ""

$ports = @{
    "user-service" = 30700
    "product-service" = 30500
    "favourite-service" = 30800
    "order-service" = 30300
    "payment-service" = 30400
    "shipping-service" = 30600
}

foreach ($service in $services) {
    $port = $ports[$service]
    $url = "http://${MINIKUBE_IP}:${port}"
    Write-Host "  $service`.PadRight(20) : $url" -ForegroundColor Cyan
    Write-Host "    Health check: ${url}/actuator/health" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar health checks
Write-Host "📍 Paso 8: Verificando health checks..." -ForegroundColor Yellow
Write-Host ""

foreach ($service in $services) {
    $port = $ports[$service]
    $url = "http://${MINIKUBE_IP}:${port}/actuator/health"
    
    Write-Host "🔍 Verificando $service..." -ForegroundColor Cyan
    
    $maxRetries = 10
    $retryCount = 0
    $success = $false
    
    while ($retryCount -lt $maxRetries -and -not $success) {
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "   ✅ $service está respondiendo (HTTP 200)" -ForegroundColor Green
                $success = $true
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "   ⏳ Intento $retryCount/$maxRetries - Esperando..." -ForegroundColor Gray
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if (-not $success) {
        Write-Host "   ⚠️  $service no responde aún (puede estar iniciando)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "🎉 Proceso de deployment finalizado" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Comandos útiles:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Ver logs de un servicio:" -ForegroundColor Gray
Write-Host "    kubectl logs -f deployment/user-service -n ecommerce" -ForegroundColor White
Write-Host ""
Write-Host "  Ver estado de pods:" -ForegroundColor Gray
Write-Host "    kubectl get pods -n ecommerce" -ForegroundColor White
Write-Host ""
Write-Host "  Escalar un servicio:" -ForegroundColor Gray
Write-Host "    kubectl scale deployment/user-service --replicas=3 -n ecommerce" -ForegroundColor White
Write-Host ""
Write-Host "  Eliminar todos los deployments:" -ForegroundColor Gray
Write-Host "    kubectl delete namespace ecommerce" -ForegroundColor White
Write-Host ""
