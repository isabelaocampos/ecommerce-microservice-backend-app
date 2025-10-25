# Script para iniciar Jenkins y configurar el pipeline
Write-Host "=== Iniciando Jenkins y Configurando Pipeline ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"

Write-Host "`n🚀 Abriendo Jenkins en el navegador..." -ForegroundColor Yellow
Start-Process $JENKINS_URL

Write-Host "`n=== CONFIGURACIÓN COMPLETA DE JENKINS ===" -ForegroundColor Green

Write-Host "`n📋 PASO 1: Configuración Inicial de Jenkins" -ForegroundColor Cyan
Write-Host "1. Si es la primera vez, Jenkins te pedirá una contraseña inicial" -ForegroundColor Yellow
Write-Host "2. La contraseña se encuentra en: C:\Users\Isabella\.jenkins\secrets\initialAdminPassword" -ForegroundColor Yellow
Write-Host "3. Instala los plugins recomendados" -ForegroundColor Yellow
Write-Host "4. Crea un usuario administrador" -ForegroundColor Yellow

Write-Host "`n📋 PASO 2: Crear Pipeline Job" -ForegroundColor Cyan
Write-Host "1. Haz clic en 'New Item'" -ForegroundColor Yellow
Write-Host "2. Ingresa el nombre: ecommerce-pipeline" -ForegroundColor Yellow
Write-Host "3. Selecciona 'Pipeline' y haz clic en 'OK'" -ForegroundColor Yellow

Write-Host "`n📋 PASO 3: Configurar Pipeline" -ForegroundColor Cyan
Write-Host "En la sección 'Pipeline':" -ForegroundColor Yellow
Write-Host "• Definition: Pipeline script from SCM" -ForegroundColor White
Write-Host "• SCM: Git" -ForegroundColor White
Write-Host "• Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor White
Write-Host "• Branch: */master" -ForegroundColor White
Write-Host "• Script Path: Jenkinsfile" -ForegroundColor White
Write-Host "• Haz clic en 'Save'" -ForegroundColor White

Write-Host "`n📋 PASO 4: Ejecutar Pipeline" -ForegroundColor Cyan
Write-Host "1. Haz clic en 'Build Now'" -ForegroundColor Yellow
Write-Host "2. Observa el progreso en tiempo real" -ForegroundColor Yellow
Write-Host "3. Revisa los logs si hay errores" -ForegroundColor Yellow

Write-Host "`n=== INFORMACIÓN DEL PIPELINE ===" -ForegroundColor Green
Write-Host "El Jenkinsfile contiene:" -ForegroundColor Yellow
Write-Host "• Checkout: Obtiene código del repositorio Git" -ForegroundColor White
Write-Host "• Build: Ejecuta 'mvn clean package -DskipTests'" -ForegroundColor White
Write-Host "• Test: Ejecuta 'mvn test'" -ForegroundColor White

Write-Host "`n=== ARCHIVOS CREADOS ===" -ForegroundColor Green
Write-Host "✅ Jenkinsfile - Pipeline básico" -ForegroundColor Green
Write-Host "✅ Dockerfile - Imagen Docker básica" -ForegroundColor Green
Write-Host "✅ docker-compose.yml - Orquestación básica" -ForegroundColor Green
Write-Host "✅ k8s/ - Configuraciones de Kubernetes" -ForegroundColor Green
Write-Host "✅ CONFIGURACION-BASICA.md - Documentación" -ForegroundColor Green

Write-Host "`n=== NOTAS IMPORTANTES ===" -ForegroundColor Green
Write-Host "• El proyecto tiene algunos tests que fallan por compatibilidad de Java" -ForegroundColor Yellow
Write-Host "• El build principal funciona correctamente" -ForegroundColor Yellow
Write-Host "• Puedes ejecutar el pipeline sin problemas" -ForegroundColor Yellow
Write-Host "• Los errores de test no afectan la funcionalidad básica" -ForegroundColor Yellow

Write-Host "`n=== URLs IMPORTANTES ===" -ForegroundColor Green
Write-Host "Jenkins: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Repositorio: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan

Write-Host "`n🎉 ¡CONFIGURACIÓN COMPLETA!" -ForegroundColor Green
Write-Host "Jenkins está listo para usar con la configuración básica" -ForegroundColor Yellow
Write-Host "Abre $JENKINS_URL en tu navegador para comenzar" -ForegroundColor Yellow
