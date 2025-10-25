# Script para configurar Pipeline de Kubernetes en Jenkins
Write-Host "=== Configurando Pipeline de Kubernetes en Jenkins ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"

Write-Host "`n📋 PASOS PARA CREAR EL PIPELINE EN JENKINS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n1️⃣ ACCEDER A JENKINS" -ForegroundColor Yellow
Write-Host "   URL: $JENKINS_URL" -ForegroundColor White
Write-Host "   Abriendo en navegador..." -ForegroundColor Gray
Start-Process $JENKINS_URL
Start-Sleep -Seconds 2

Write-Host "`n2️⃣ CREAR NUEVO PIPELINE" -ForegroundColor Yellow
Write-Host "   → Haz clic en 'New Item' (esquina superior izquierda)" -ForegroundColor White
Write-Host "   → Nombre del item: kubernetes-verification-pipeline" -ForegroundColor Cyan
Write-Host "   → Tipo: Pipeline" -ForegroundColor White
Write-Host "   → Clic en 'OK'" -ForegroundColor White

Write-Host "`n3️⃣ CONFIGURAR EL PIPELINE - OPCIÓN 1 (Recomendada)" -ForegroundColor Yellow
Write-Host "   En la sección 'Pipeline':" -ForegroundColor White
Write-Host "   → Definition: Pipeline script from SCM" -ForegroundColor Cyan
Write-Host "   → SCM: Git" -ForegroundColor Cyan
Write-Host "   → Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan
Write-Host "   → Branch: */master" -ForegroundColor Cyan
Write-Host "   → Script Path: Jenkinsfile" -ForegroundColor Cyan
Write-Host "   → Desmarcar: 'Lightweight checkout' (si da problemas)" -ForegroundColor Yellow

Write-Host "`n3️⃣ CONFIGURAR EL PIPELINE - OPCIÓN 2 (Si Opción 1 falla)" -ForegroundColor Yellow
Write-Host "   En la sección 'Pipeline':" -ForegroundColor White
Write-Host "   → Definition: Pipeline script" -ForegroundColor Cyan
Write-Host "   → Copia y pega el script del Jenkinsfile directamente" -ForegroundColor Cyan

Write-Host "`n4️⃣ GUARDAR Y EJECUTAR" -ForegroundColor Yellow
Write-Host "   → Haz clic en 'Save'" -ForegroundColor White
Write-Host "   → Haz clic en 'Build Now'" -ForegroundColor White

Write-Host "`n" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n🔧 SOLUCIÓN AL ERROR 'Failed to schedule build'" -ForegroundColor Magenta
Write-Host "Si ves ese error, prueba estas soluciones:" -ForegroundColor White
Write-Host "`n   Solución 1: Recargar la página" -ForegroundColor Yellow
Write-Host "   → Presiona F5 o recarga con Ctrl+R" -ForegroundColor White
Write-Host "   → Espera unos segundos" -ForegroundColor White
Write-Host "   → Intenta 'Build Now' de nuevo" -ForegroundColor White

Write-Host "`n   Solución 2: Usar Pipeline Script directo" -ForegroundColor Yellow
Write-Host "   → En lugar de 'Pipeline script from SCM'" -ForegroundColor White
Write-Host "   → Usa 'Pipeline script'" -ForegroundColor White
Write-Host "   → Y pega el contenido del Jenkinsfile" -ForegroundColor White

Write-Host "`n   Solución 3: Reiniciar Jenkins" -ForegroundColor Yellow
Write-Host "   → Ejecuta: docker restart jenkins" -ForegroundColor White
Write-Host "   → Espera 30 segundos" -ForegroundColor White
Write-Host "   → Vuelve a intentar" -ForegroundColor White

Write-Host "`n" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n📄 CONTENIDO DEL JENKINSFILE ACTUALIZADO:" -ForegroundColor Green
Write-Host "El Jenkinsfile ahora verifica:" -ForegroundColor White
Write-Host "   ✅ Conectividad con Kubernetes" -ForegroundColor Cyan
Write-Host "   ✅ Versión de kubectl" -ForegroundColor Cyan
Write-Host "   ✅ Información del cluster" -ForegroundColor Cyan
Write-Host "   ✅ Namespaces disponibles" -ForegroundColor Cyan
Write-Host "   ✅ Pods en el namespace ecommerce" -ForegroundColor Cyan
Write-Host "   ✅ Estado general del cluster" -ForegroundColor Cyan

Write-Host "`n" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n⚠️  REQUISITOS PREVIOS:" -ForegroundColor Red
Write-Host "   → Jenkins debe estar corriendo: docker ps | findstr jenkins" -ForegroundColor White
Write-Host "   → Kubernetes debe estar activo (Docker Desktop o Minikube)" -ForegroundColor White
Write-Host "   → kubectl debe estar instalado en el sistema" -ForegroundColor White

Write-Host "`n🔍 VERIFICAR REQUISITOS:" -ForegroundColor Yellow

# Verificar Docker
Write-Host "`n   Verificando Docker..." -ForegroundColor Gray
try {
    docker ps | Out-Null
    Write-Host "   ✅ Docker está corriendo" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker no está disponible" -ForegroundColor Red
}

# Verificar Jenkins
Write-Host "`n   Verificando Jenkins..." -ForegroundColor Gray
$jenkinsContainer = docker ps --filter "name=jenkins" --format "{{.Names}}"
if ($jenkinsContainer) {
    Write-Host "   ✅ Jenkins está corriendo (contenedor: $jenkinsContainer)" -ForegroundColor Green
} else {
    Write-Host "   ❌ Jenkins no está corriendo" -ForegroundColor Red
    Write-Host "   → Ejecuta: docker run -d --name jenkins -p 8081:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts" -ForegroundColor Yellow
}

# Verificar kubectl
Write-Host "`n   Verificando kubectl..." -ForegroundColor Gray
try {
    kubectl version --client 2>&1 | Out-Null
    Write-Host "   ✅ kubectl está instalado" -ForegroundColor Green
} catch {
    Write-Host "   ❌ kubectl no está instalado" -ForegroundColor Red
    Write-Host "   → Instala kubectl desde: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
}

# Verificar Kubernetes
Write-Host "`n   Verificando Kubernetes..." -ForegroundColor Gray
try {
    kubectl cluster-info 2>&1 | Out-Null
    Write-Host "   ✅ Kubernetes está activo" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Kubernetes no está accesible" -ForegroundColor Red
    Write-Host "   → Activa Kubernetes en Docker Desktop" -ForegroundColor Yellow
    Write-Host "   → O inicia Minikube: minikube start" -ForegroundColor Yellow
}

Write-Host "`n" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n🚀 COMANDO RÁPIDO - Reiniciar Jenkins si es necesario:" -ForegroundColor Cyan
Write-Host "   docker restart jenkins" -ForegroundColor White

Write-Host "`n[SIGUIENTE PASO]" -ForegroundColor Green
Write-Host "   -> Ve a $JENKINS_URL" -ForegroundColor Cyan
Write-Host "   -> Crea el pipeline siguiendo los pasos de arriba" -ForegroundColor Cyan
Write-Host "   -> Disfruta viendo tu pipeline de Kubernetes!" -ForegroundColor Cyan

Write-Host "`nListo para configurar!" -ForegroundColor Green
Write-Host ""
