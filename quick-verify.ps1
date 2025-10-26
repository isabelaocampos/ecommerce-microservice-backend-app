# Quick Verification Script
# Verifica que todo este listo para ejecutar el pipeline

Write-Host "Verificacion Pre-Pipeline" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

$checks = 0
$passed = 0

# 1. Verificar Minikube
Write-Host "1. Verificando Minikube..." -ForegroundColor Yellow
try {
    $minikubeStatus = minikube status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK - Minikube esta corriendo" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "   ERROR - Minikube no esta corriendo" -ForegroundColor Red
        Write-Host "   Ejecuta: minikube start" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR - Minikube no esta instalado" -ForegroundColor Red
}
$checks++

# 2. Verificar kubectl
Write-Host "2. Verificando kubectl..." -ForegroundColor Yellow
try {
    $null = Get-Command kubectl -ErrorAction Stop
    Write-Host "   OK - kubectl esta instalado" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   ERROR - kubectl no esta instalado" -ForegroundColor Red
}
$checks++

# 3. Verificar Docker
Write-Host "3. Verificando Docker..." -ForegroundColor Yellow
try {
    $null = Get-Command docker -ErrorAction Stop
    Write-Host "   OK - Docker esta instalado" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   ERROR - Docker no esta instalado" -ForegroundColor Red
}
$checks++

# 4. Verificar Jenkins
Write-Host "4. Verificando Jenkins..." -ForegroundColor Yellow
try {
    $container = docker ps --filter "name=jenkins" --format "{{.Names}}" 2>&1
    if ($container -eq "jenkins") {
        Write-Host "   OK - Jenkins esta corriendo" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "   ERROR - Jenkins no esta corriendo" -ForegroundColor Red
        Write-Host "   Ejecuta: docker start jenkins" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR - No se puede verificar Jenkins" -ForegroundColor Red
}
$checks++

# 5. Verificar Jenkinsfile-stage
Write-Host "5. Verificando Jenkinsfile-stage..." -ForegroundColor Yellow
if (Test-Path "Jenkinsfile-stage") {
    Write-Host "   OK - Jenkinsfile-stage existe" -ForegroundColor Green
    $passed++
} else {
    Write-Host "   ERROR - Jenkinsfile-stage no existe" -ForegroundColor Red
}
$checks++

# 6. Verificar deployments K8s
Write-Host "6. Verificando deployments K8s..." -ForegroundColor Yellow
$deploymentFiles = @(
    "k8s\user-service-deployment.yaml",
    "k8s\product-service-deployment.yaml",
    "k8s\favourite-service-deployment.yaml",
    "k8s\order-service-deployment.yaml",
    "k8s\payment-service-deployment.yaml",
    "k8s\shipping-service-deployment.yaml"
)

$allExist = $true
foreach ($file in $deploymentFiles) {
    if (-not (Test-Path $file)) {
        $allExist = $false
        Write-Host "   ERROR - Falta: $file" -ForegroundColor Red
    }
}

if ($allExist) {
    Write-Host "   OK - Todos los deployments existen (6/6)" -ForegroundColor Green
    $passed++
}
$checks++

# 7. Verificar namespace ecommerce
Write-Host "7. Verificando namespace ecommerce..." -ForegroundColor Yellow
$namespaceOutput = kubectl get namespace ecommerce 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Namespace ecommerce existe" -ForegroundColor Green
    $passed++
} else {
    Write-Host "   INFO - Namespace sera creado por el pipeline" -ForegroundColor Cyan
    $passed++
}
$checks++

Write-Host ""
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "RESULTADO" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificaciones: $passed/$checks" -ForegroundColor White

$percentage = [math]::Round(($passed / $checks) * 100, 2)
Write-Host "Porcentaje: ${percentage}%" -ForegroundColor $(if ($percentage -eq 100) { "Green" } else { "Yellow" })
Write-Host ""

if ($passed -eq $checks) {
    Write-Host "LISTO PARA EJECUTAR EL PIPELINE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  1. Script:  .\deploy-microservices-k8s.ps1" -ForegroundColor White
    Write-Host "  2. Jenkins: http://localhost:8081" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "FALTAN ALGUNAS CONFIGURACIONES" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Revisa los errores arriba y corrigelos" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
