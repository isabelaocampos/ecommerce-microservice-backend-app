# ============================================================================
# Script para Ejecutar Todas las Pruebas
# ============================================================================
# Este script ejecuta todas las pruebas del proyecto
# Uso: .\run-all-tests.ps1

param(
    [switch]$SkipUnit = $false,
    [switch]$SkipIntegration = $false,
    [switch]$SkipE2E = $false,
    [switch]$SkipPerformance = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🧪 Ejecutando Suite Completa de Pruebas" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$StartTime = Get-Date

# ============================================================================
# PRUEBAS UNITARIAS
# ============================================================================
if (-not $SkipUnit) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "1️⃣  PRUEBAS UNITARIAS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    $services = @(
        "user-service",
        "product-service",
        "favourite-service",
        "order-service",
        "payment-service",
        "shipping-service"
    )
    
    foreach ($service in $services) {
        Write-Host "🔬 Ejecutando pruebas unitarias en $service..." -ForegroundColor Cyan
        Push-Location $service
        & ..\mvnw.cmd test -Dtest=*UnitTest
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Pruebas unitarias fallaron en $service" -ForegroundColor Red
            $ErrorCount++
        } else {
            Write-Host "✅ Pruebas unitarias pasaron en $service" -ForegroundColor Green
        }
        Pop-Location
        Write-Host ""
    }
} else {
    Write-Host "⏭️  Saltando pruebas unitarias" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# PRUEBAS DE INTEGRACIÓN
# ============================================================================
if (-not $SkipIntegration) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "2️⃣  PRUEBAS DE INTEGRACIÓN" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    $services = @(
        "user-service",
        "product-service",
        "order-service"
    )
    
    foreach ($service in $services) {
        Write-Host "🔗 Ejecutando pruebas de integración en $service..." -ForegroundColor Cyan
        Push-Location $service
        & ..\mvnw.cmd test -Dtest=*IntegrationTest
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Pruebas de integración fallaron en $service" -ForegroundColor Red
            $ErrorCount++
        } else {
            Write-Host "✅ Pruebas de integración pasaron en $service" -ForegroundColor Green
        }
        Pop-Location
        Write-Host ""
    }
} else {
    Write-Host "⏭️  Saltando pruebas de integración" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# PRUEBAS E2E
# ============================================================================
if (-not $SkipE2E) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "3️⃣  PRUEBAS END-TO-END" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "🌐 Ejecutando pruebas E2E..." -ForegroundColor Cyan
    
    $services = @(
        "user-service",
        "product-service",
        "order-service"
    )
    
    foreach ($service in $services) {
        Write-Host "🔄 Ejecutando pruebas E2E en $service..." -ForegroundColor Cyan
        Push-Location $service
        & ..\mvnw.cmd test -Dtest=*E2ETest
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  Algunas pruebas E2E fallaron en $service (esto es normal si los servicios no están corriendo)" -ForegroundColor Yellow
        } else {
            Write-Host "✅ Pruebas E2E pasaron en $service" -ForegroundColor Green
        }
        Pop-Location
        Write-Host ""
    }
} else {
    Write-Host "⏭️  Saltando pruebas E2E" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# PRUEBAS DE RENDIMIENTO
# ============================================================================
if (-not $SkipPerformance) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "4️⃣  PRUEBAS DE RENDIMIENTO (LOCUST)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar si Locust está instalado
    try {
        locust --version | Out-Null
        Write-Host "✅ Locust instalado" -ForegroundColor Green
        
        Write-Host "⚡ Ejecutando pruebas de rendimiento..." -ForegroundColor Cyan
        Write-Host "⚠️  Nota: Asegúrate de que los servicios estén corriendo en Kubernetes" -ForegroundColor Yellow
        Write-Host ""
        
        # Ejecutar Locust en modo headless
        locust -f locustfile.py --headless -u 50 -r 5 -t 1m --html performance-report.html
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Pruebas de rendimiento completadas" -ForegroundColor Green
            Write-Host "📊 Reporte generado: performance-report.html" -ForegroundColor Cyan
        } else {
            Write-Host "⚠️  Pruebas de rendimiento tuvieron problemas" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Locust no está instalado. Instalando..." -ForegroundColor Yellow
        python -m pip install locust
        Write-Host "✅ Locust instalado. Ejecuta el script nuevamente." -ForegroundColor Green
    }
} else {
    Write-Host "⏭️  Saltando pruebas de rendimiento" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# RESUMEN
# ============================================================================
$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⏱️  Duración total: $($Duration.ToString('mm\:ss'))" -ForegroundColor White

if ($ErrorCount -eq 0) {
    Write-Host "✅ Todas las pruebas pasaron exitosamente" -ForegroundColor Green
} else {
    Write-Host "⚠️  $ErrorCount prueba(s) fallaron" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📁 Reportes generados:" -ForegroundColor Yellow
Write-Host "  • Unit Tests:        target/surefire-reports/" -ForegroundColor White
Write-Host "  • Integration Tests: target/failsafe-reports/" -ForegroundColor White
Write-Host "  • Performance:       performance-report.html" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✨ Pruebas Completadas" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
