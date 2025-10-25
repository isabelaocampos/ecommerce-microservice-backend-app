# Script para abrir Jenkins en el navegador
Write-Host "=== Abriendo Jenkins ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"

Write-Host "Jenkins está ejecutándose en: $JENKINS_URL" -ForegroundColor Green
Write-Host "Abriendo Jenkins en el navegador..." -ForegroundColor Yellow

# Abrir Jenkins en el navegador
Start-Process $JENKINS_URL

Write-Host "`n=== Instrucciones para Configurar el Pipeline ===" -ForegroundColor Yellow
Write-Host "1. Si es la primera vez, configura Jenkins con la contraseña inicial" -ForegroundColor Cyan
Write-Host "2. Instala los plugins recomendados" -ForegroundColor Cyan
Write-Host "3. Crea un usuario administrador" -ForegroundColor Cyan
Write-Host "4. Haz clic en 'New Item'" -ForegroundColor Cyan
Write-Host "5. Ingresa el nombre: ecommerce-pipeline" -ForegroundColor Cyan
Write-Host "6. Selecciona 'Pipeline' y haz clic en 'OK'" -ForegroundColor Cyan
Write-Host "7. En la sección 'Pipeline':" -ForegroundColor Cyan
Write-Host "   - Definition: Pipeline script from SCM" -ForegroundColor White
Write-Host "   - SCM: Git" -ForegroundColor White
Write-Host "   - Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor White
Write-Host "   - Branch: */master" -ForegroundColor White
Write-Host "   - Script Path: Jenkinsfile" -ForegroundColor White
Write-Host "8. Haz clic en 'Save'" -ForegroundColor Cyan
Write-Host "9. Haz clic en 'Build Now' para ejecutar el pipeline" -ForegroundColor Cyan

Write-Host "`n=== Información del Proyecto ===" -ForegroundColor Green
Write-Host "Repository: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan
Write-Host "Branch: master" -ForegroundColor Cyan
Write-Host "Jenkinsfile: Jenkinsfile (en la raíz del proyecto)" -ForegroundColor Cyan

Write-Host "`n=== Pipeline Básico ===" -ForegroundColor Green
Write-Host "El Jenkinsfile contiene:" -ForegroundColor Yellow
Write-Host "- Checkout: Obtiene el código del repositorio" -ForegroundColor White
Write-Host "- Build: Ejecuta 'mvn clean package -DskipTests'" -ForegroundColor White
Write-Host "- Test: Ejecuta 'mvn test'" -ForegroundColor White

Write-Host "`n¡Jenkins abierto! 🚀" -ForegroundColor Green
