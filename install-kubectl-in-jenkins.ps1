# Script para instalar kubectl en el contenedor de Jenkins
Write-Host "=== Instalando kubectl en Jenkins ===" -ForegroundColor Green

Write-Host "`nInstalando kubectl en el contenedor de Jenkins..." -ForegroundColor Yellow

# Instalar kubectl en el contenedor de Jenkins
docker exec -u root jenkins bash -c "curl -LO https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/"

Write-Host "`nVerificando instalacion..." -ForegroundColor Yellow
docker exec jenkins kubectl version --client

Write-Host "`n=== CONFIGURANDO ACCESO A KUBERNETES ===" -ForegroundColor Cyan

Write-Host "`nOpcion 1: Copiar archivo kubeconfig desde tu maquina Windows:" -ForegroundColor Yellow
Write-Host "docker cp $env:USERPROFILE\.kube jenkins:/var/jenkins_home/.kube" -ForegroundColor White

Write-Host "`nOpcion 2: Configurar manualmente (si estas usando Docker Desktop):" -ForegroundColor Yellow
Write-Host "El cluster de Kubernetes debe ser accesible desde el contenedor de Jenkins" -ForegroundColor White

Write-Host "`n=== SIGUIENTE PASO ===" -ForegroundColor Green
Write-Host "1. Ejecuta el comando de Opcion 1 para copiar tu configuracion de Kubernetes" -ForegroundColor Cyan
Write-Host "2. Luego ejecuta el pipeline en Jenkins nuevamente" -ForegroundColor Cyan

Write-Host "`nComando completo:" -ForegroundColor Yellow
Write-Host "docker cp $env:USERPROFILE\.kube jenkins:/var/jenkins_home/.kube" -ForegroundColor White
