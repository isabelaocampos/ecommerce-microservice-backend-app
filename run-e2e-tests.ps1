# Script para ejecutar pruebas E2E
# Este script inicia los servicios necesarios y ejecuta las pruebas E2E

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " E2E TESTING - Ecommerce Microservices" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si los servicios están corriendo
function Test-ServiceRunning {
    param($Port, $ServiceName)
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port/actuator/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $ServiceName (puerto $Port) está corriendo" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "✗ $ServiceName (puerto $Port) NO está corriendo" -ForegroundColor Yellow
        return $false
    }
    return $false
}

Write-Host "Verificando servicios necesarios..." -ForegroundColor Cyan
Write-Host ""

$userServiceRunning = Test-ServiceRunning -Port 8700 -ServiceName "user-service"
$productServiceRunning = Test-ServiceRunning -Port 8500 -ServiceName "product-service"
$orderServiceRunning = Test-ServiceRunning -Port 8300 -ServiceName "order-service"

Write-Host ""

# Advertir si algún servicio no está corriendo
if (-not $userServiceRunning -or -not $productServiceRunning -or -not $orderServiceRunning) {
    Write-Host "⚠ ADVERTENCIA: Algunos servicios no están corriendo" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para iniciar los servicios, ejecuta en terminales separadas:" -ForegroundColor Yellow
    Write-Host "  Terminal 1: cd user-service;    .\mvnw.cmd spring-boot:run" -ForegroundColor White
    Write-Host "  Terminal 2: cd product-service; .\mvnw.cmd spring-boot:run" -ForegroundColor White
    Write-Host "  Terminal 3: cd order-service;   .\mvnw.cmd spring-boot:run" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "¿Deseas continuar con las pruebas de todos modos? (s/n)"
    if ($response -ne "s") {
        Write-Host "Abortando pruebas E2E" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Ejecutando Pruebas E2E" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ejecutar pruebas E2E
Write-Host "Ejecutando: UserServiceE2ETest..." -ForegroundColor Cyan
.\mvnw.cmd clean test -Dtest=UserServiceE2ETest -DfailIfNoTests=false

Write-Host ""
Write-Host "Ejecutando: ProductServiceE2ETest..." -ForegroundColor Cyan
.\mvnw.cmd test -Dtest=ProductServiceE2ETest -DfailIfNoTests=false

Write-Host ""
Write-Host "Ejecutando: CrossServiceOrderFlowE2ETest..." -ForegroundColor Cyan
.\mvnw.cmd test -Dtest=CrossServiceOrderFlowE2ETest -DfailIfNoTests=false

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Pruebas E2E Completadas" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Revisa los resultados arriba" -ForegroundColor Yellow
Write-Host ""
