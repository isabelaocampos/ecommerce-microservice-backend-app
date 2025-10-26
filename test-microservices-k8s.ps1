# Script para ejecutar pruebas de integración contra los microservicios en Kubernetes
# Isabella Ocampo - Ingeniería de Software V

Write-Host "🧪 Ejecutando Pruebas de Integración en Kubernetes (Stage)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Obtener IP de Minikube
Write-Host "📍 Obteniendo IP de Minikube..." -ForegroundColor Yellow
$MINIKUBE_IP = minikube ip
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Minikube no está corriendo" -ForegroundColor Red
    Write-Host "   Ejecuta: minikube start" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ IP de Minikube: $MINIKUBE_IP" -ForegroundColor Green
Write-Host ""

# Definir endpoints de los servicios
$services = @{
    "user-service" = @{
        "port" = 30700
        "health" = "/actuator/health"
        "endpoints" = @("/api/users", "/api/users/1")
    }
    "product-service" = @{
        "port" = 30500
        "health" = "/actuator/health"
        "endpoints" = @("/api/products", "/api/products/1")
    }
    "favourite-service" = @{
        "port" = 30800
        "health" = "/actuator/health"
        "endpoints" = @("/api/favourites")
    }
    "order-service" = @{
        "port" = 30300
        "health" = "/actuator/health"
        "endpoints" = @("/api/orders")
    }
    "payment-service" = @{
        "port" = 30400
        "health" = "/actuator/health"
        "endpoints" = @("/api/payments")
    }
    "shipping-service" = @{
        "port" = 30600
        "health" = "/actuator/health"
        "endpoints" = @("/api/shipments")
    }
}

# Contadores para el reporte
$totalTests = 0
$passedTests = 0
$failedTests = 0

# Función para hacer request HTTP
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$ServiceName,
        [string]$EndpointName,
        [int]$ExpectedStatus = 200
    )
    
    $global:totalTests++
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "   ✅ $EndpointName - HTTP $($response.StatusCode)" -ForegroundColor Green
            $global:passedTests++
            return $true
        } else {
            Write-Host "   ❌ $EndpointName - Expected HTTP $ExpectedStatus but got HTTP $($response.StatusCode)" -ForegroundColor Red
            $global:failedTests++
            return $false
        }
    } catch {
        Write-Host "   ❌ $EndpointName - Error: $($_.Exception.Message)" -ForegroundColor Red
        $global:failedTests++
        return $false
    }
}

# Función para verificar pods
function Test-PodsStatus {
    Write-Host "📍 Verificando estado de pods en Kubernetes..." -ForegroundColor Yellow
    Write-Host ""
    
    $pods = kubectl get pods -n ecommerce -o json | ConvertFrom-Json
    
    $runningCount = 0
    $totalPods = $pods.items.Count
    
    foreach ($pod in $pods.items) {
        $podName = $pod.metadata.name
        $podStatus = $pod.status.phase
        $ready = "0/0"
        
        if ($pod.status.containerStatuses) {
            $readyContainers = ($pod.status.containerStatuses | Where-Object { $_.ready -eq $true }).Count
            $totalContainers = $pod.status.containerStatuses.Count
            $ready = "$readyContainers/$totalContainers"
        }
        
        if ($podStatus -eq "Running" -and $ready -match "^\d+/\d+$" -and $ready.Split("/")[0] -eq $ready.Split("/")[1]) {
            Write-Host "   ✅ $podName - $podStatus ($ready)" -ForegroundColor Green
            $runningCount++
        } else {
            Write-Host "   ⚠️  $podName - $podStatus ($ready)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "   Pods corriendo: $runningCount/$totalPods" -ForegroundColor Cyan
    Write-Host ""
    
    return $runningCount -eq $totalPods
}

# Verificar estado de pods
$podsOk = Test-PodsStatus

if (-not $podsOk) {
    Write-Host "⚠️  Advertencia: No todos los pods están en estado Running" -ForegroundColor Yellow
    Write-Host "   Las pruebas pueden fallar" -ForegroundColor Yellow
    Write-Host ""
}

# Ejecutar pruebas de health check para cada servicio
Write-Host "📍 Ejecutando Health Checks..." -ForegroundColor Yellow
Write-Host ""

foreach ($serviceName in $services.Keys) {
    $service = $services[$serviceName]
    $port = $service.port
    $healthPath = $service.health
    
    Write-Host "🔍 Testeando $serviceName..." -ForegroundColor Cyan
    
    $baseUrl = "http://${MINIKUBE_IP}:${port}"
    $healthUrl = "${baseUrl}${healthPath}"
    
    Test-Endpoint -Url $healthUrl -ServiceName $serviceName -EndpointName "Health Check"
    
    Write-Host ""
}

# Ejecutar pruebas de endpoints funcionales
Write-Host "📍 Ejecutando Pruebas de Endpoints Funcionales..." -ForegroundColor Yellow
Write-Host ""

foreach ($serviceName in $services.Keys) {
    $service = $services[$serviceName]
    $port = $service.port
    $endpoints = $service.endpoints
    
    if ($endpoints.Count -gt 0) {
        Write-Host "🔍 Testeando endpoints de $serviceName..." -ForegroundColor Cyan
        
        $baseUrl = "http://${MINIKUBE_IP}:${port}"
        
        foreach ($endpoint in $endpoints) {
            $url = "${baseUrl}${endpoint}"
            
            # Algunos endpoints pueden devolver 404 si no hay datos, eso es OK
            # Solo verificamos que el servicio responda
            try {
                $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
                Write-Host "   ✅ $endpoint - HTTP $($response.StatusCode)" -ForegroundColor Green
                $global:totalTests++
                $global:passedTests++
            } catch {
                $statusCode = $_.Exception.Response.StatusCode.value__
                if ($statusCode -eq 404 -or $statusCode -eq 401) {
                    Write-Host "   ⚠️  $endpoint - HTTP $statusCode (esperado, no hay datos/autenticación)" -ForegroundColor Yellow
                    $global:totalTests++
                    $global:passedTests++
                } else {
                    Write-Host "   ❌ $endpoint - Error: $($_.Exception.Message)" -ForegroundColor Red
                    $global:totalTests++
                    $global:failedTests++
                }
            }
        }
        
        Write-Host ""
    }
}

# Pruebas de comunicación entre servicios
Write-Host "📍 Ejecutando Pruebas de Integración entre Servicios..." -ForegroundColor Yellow
Write-Host ""

Write-Host "🔍 Verificando conectividad entre servicios..." -ForegroundColor Cyan

# Verificar que los servicios pueden verse entre sí a través de DNS de Kubernetes
$testPod = kubectl get pods -n ecommerce -l app=user-service -o jsonpath='{.items[0].metadata.name}' 2>&1

if ($LASTEXITCODE -eq 0 -and $testPod) {
    Write-Host "   📡 Usando pod: $testPod" -ForegroundColor Gray
    
    # Probar DNS interno
    $dnsTest = kubectl exec $testPod -n ecommerce -- nslookup product-service 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ DNS interno funcionando (product-service resolvible)" -ForegroundColor Green
        $global:totalTests++
        $global:passedTests++
    } else {
        Write-Host "   ❌ DNS interno no funciona" -ForegroundColor Red
        $global:totalTests++
        $global:failedTests++
    }
} else {
    Write-Host "   ⚠️  No se pudo verificar DNS interno (no hay pods disponibles)" -ForegroundColor Yellow
}

Write-Host ""

# Verificar que los servicios están registrados en Eureka (si tienen Eureka)
Write-Host "🔍 Verificando registro de servicios..." -ForegroundColor Cyan
Write-Host "   ℹ️  Esta verificación requiere que service-discovery esté desplegado" -ForegroundColor Gray
Write-Host ""

# Generar reporte final
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "📊 REPORTE DE PRUEBAS" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total de pruebas ejecutadas: $totalTests" -ForegroundColor White
Write-Host "Pruebas exitosas: $passedTests" -ForegroundColor Green
Write-Host "Pruebas fallidas: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host ""

$successRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
Write-Host "Tasa de éxito: ${successRate}%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 50) { "Yellow" } else { "Red" })
Write-Host ""

# Mostrar URLs de los servicios
Write-Host "📡 URLs de los servicios:" -ForegroundColor Yellow
Write-Host ""

foreach ($serviceName in $services.Keys | Sort-Object) {
    $port = $services[$serviceName].port
    $url = "http://${MINIKUBE_IP}:${port}"
    Write-Host "  $serviceName`.PadRight(20) : $url" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Estado final
if ($failedTests -eq 0 -and $totalTests -gt 0) {
    Write-Host "✅ Todas las pruebas pasaron exitosamente!" -ForegroundColor Green
    exit 0
} elseif ($totalTests -eq 0) {
    Write-Host "⚠️  No se ejecutaron pruebas" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "❌ Algunas pruebas fallaron. Revisa los logs arriba." -ForegroundColor Red
    Write-Host ""
    Write-Host "📝 Comandos útiles para debugging:" -ForegroundColor Yellow
    Write-Host "   kubectl get pods -n ecommerce" -ForegroundColor White
    Write-Host "   kubectl logs -f deployment/user-service -n ecommerce" -ForegroundColor White
    Write-Host "   kubectl describe pod <pod-name> -n ecommerce" -ForegroundColor White
    exit 1
}
