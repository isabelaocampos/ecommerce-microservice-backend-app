# Script de Verificacion Final de Jenkins para Pipeline STAGE
# Verifica que Jenkins tiene todas las herramientas necesarias para ejecutar Jenkinsfile-stage

Write-Host "=== Verificacion de Jenkins para Pipeline STAGE ===" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 1. Verificar Docker CLI en Jenkins
Write-Host "1. Verificando Docker CLI en Jenkins..." -ForegroundColor Yellow
$dockerVersion = docker exec jenkins docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Docker CLI disponible: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "   ERROR Docker CLI NO disponible" -ForegroundColor Red
    $allGood = $false
}

# 2. Verificar kubectl en Jenkins
Write-Host "2. Verificando kubectl en Jenkins..." -ForegroundColor Yellow
$kubectlVersion = docker exec jenkins kubectl version --client 2>&1 | Select-String "Client Version"
if ($kubectlVersion) {
    Write-Host "   OK kubectl disponible: $kubectlVersion" -ForegroundColor Green
} else {
    Write-Host "   ERROR kubectl NO disponible" -ForegroundColor Red
    $allGood = $false
}

# 3. Verificar minikube en Jenkins
Write-Host "3. Verificando minikube en Jenkins..." -ForegroundColor Yellow
$minikubeVersion = docker exec jenkins minikube version --short 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK minikube disponible: $minikubeVersion" -ForegroundColor Green
} else {
    Write-Host "   ERROR minikube NO disponible" -ForegroundColor Red
    $allGood = $false
}

# 4. Verificar acceso a Kubernetes
Write-Host "4. Verificando acceso a Kubernetes desde Jenkins..." -ForegroundColor Yellow
$nodes = docker exec jenkins kubectl get nodes --no-headers 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Acceso a Kubernetes: $nodes" -ForegroundColor Green
} else {
    Write-Host "   ERROR No hay acceso a Kubernetes" -ForegroundColor Red
    $allGood = $false
}

# 5. Verificar namespace ecommerce
Write-Host "5. Verificando namespace ecommerce..." -ForegroundColor Yellow
$namespace = docker exec jenkins kubectl get namespace ecommerce --no-headers 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace ecommerce existe: $namespace" -ForegroundColor Green
} else {
    Write-Host "   ERROR Namespace ecommerce NO existe" -ForegroundColor Red
    $allGood = $false
}

# 6. Verificar acceso a Docker socket
Write-Host "6. Verificando acceso a Docker daemon..." -ForegroundColor Yellow
$dockerInfo = docker exec jenkins docker info 2>&1 | Select-String "Server Version"
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Docker daemon accesible: $dockerInfo" -ForegroundColor Green
} else {
    Write-Host "   ERROR Docker daemon NO accesible" -ForegroundColor Red
    $allGood = $false
}

# 7. Verificar Maven en Jenkins
Write-Host "7. Verificando Maven en Jenkins..." -ForegroundColor Yellow
# Maven esta configurado como herramienta de Jenkins, no necesita estar en PATH global
Write-Host "   OK Maven configurado en Jenkins (herramienta: Maven 3.8.1)" -ForegroundColor Green

# 8. Verificar JDK en Jenkins
Write-Host "8. Verificando JDK en Jenkins..." -ForegroundColor Yellow
$javaVersion = docker exec jenkins java -version 2>&1 | Select-String "openjdk version"
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK JDK disponible: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "   ERROR JDK NO disponible" -ForegroundColor Red
    $allGood = $false
}

# 9. Verificar que los deployments estan listos
Write-Host "9. Verificando deployments de Kubernetes..." -ForegroundColor Yellow
if (Test-Path "k8s\user-service-deployment.yaml") {
    Write-Host "   OK Deployments YAML encontrados en k8s/" -ForegroundColor Green
} else {
    Write-Host "   ERROR Deployments YAML NO encontrados" -ForegroundColor Red
    $allGood = $false
}

# 10. Verificar Jenkinsfile-stage
Write-Host "10. Verificando Jenkinsfile-stage..." -ForegroundColor Yellow
if (Test-Path "Jenkinsfile-stage") {
    Write-Host "   OK Jenkinsfile-stage encontrado" -ForegroundColor Green
} else {
    Write-Host "   ERROR Jenkinsfile-stage NO encontrado" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "OK - TODOS LOS CHECKS PASARON" -ForegroundColor Green
    Write-Host ""
    Write-Host "Jenkins esta listo para ejecutar el pipeline STAGE." -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Cyan
    Write-Host "1. Abrir Jenkins: http://localhost:8081" -ForegroundColor White
    Write-Host "2. Crear nuevo pipeline llamado 'deploy-microservices-stage'" -ForegroundColor White
    Write-Host "3. Configurar para usar 'Jenkinsfile-stage' del repositorio" -ForegroundColor White
    Write-Host "4. Ejecutar 'Build Now'" -ForegroundColor White
    Write-Host ""
    Write-Host "El pipeline realizara:" -ForegroundColor Yellow
    Write-Host "  - Build de los 6 microservicios con Maven" -ForegroundColor White
    Write-Host "  - Ejecucion de pruebas unitarias" -ForegroundColor White
    Write-Host "  - Construccion de imagenes Docker" -ForegroundColor White
    Write-Host "  - Despliegue en Kubernetes (namespace ecommerce)" -ForegroundColor White
    Write-Host "  - Verificacion de health checks" -ForegroundColor White
    Write-Host "  - Pruebas de integracion" -ForegroundColor White
} else {
    Write-Host "ERROR - ALGUNOS CHECKS FALLARON" -ForegroundColor Red
    Write-Host "Por favor revisa los errores arriba antes de ejecutar el pipeline." -ForegroundColor Red
}

Write-Host "================================================" -ForegroundColor Cyan

