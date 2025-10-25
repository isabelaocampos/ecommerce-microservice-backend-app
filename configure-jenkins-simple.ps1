# Script simple para configurar Jenkins Pipeline
Write-Host "=== Configurando Jenkins Pipeline ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"
$JOB_NAME = "ecommerce-pipeline"

Write-Host "Jenkins está disponible en: $JENKINS_URL" -ForegroundColor Green
Write-Host "Job Name: $JOB_NAME" -ForegroundColor Green

Write-Host "`n=== Instrucciones Manuales ===" -ForegroundColor Yellow
Write-Host "1. Abre tu navegador y ve a: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "2. Haz clic en 'New Item'" -ForegroundColor Cyan
Write-Host "3. Ingresa el nombre: $JOB_NAME" -ForegroundColor Cyan
Write-Host "4. Selecciona 'Pipeline' y haz clic en 'OK'" -ForegroundColor Cyan
Write-Host "5. En la sección 'Pipeline':" -ForegroundColor Cyan
Write-Host "   - Definition: Pipeline script from SCM" -ForegroundColor White
Write-Host "   - SCM: Git" -ForegroundColor White
Write-Host "   - Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor White
Write-Host "   - Branch: */master" -ForegroundColor White
Write-Host "   - Script Path: Jenkinsfile" -ForegroundColor White
Write-Host "6. Haz clic en 'Save'" -ForegroundColor Cyan
Write-Host "7. Haz clic en 'Build Now' para ejecutar el pipeline" -ForegroundColor Cyan

Write-Host "`n=== Información del Proyecto ===" -ForegroundColor Green
Write-Host "Repository: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan
Write-Host "Branch: master" -ForegroundColor Cyan
Write-Host "Jenkinsfile: Jenkinsfile (en la raíz del proyecto)" -ForegroundColor Cyan

Write-Host "`n=== Pipeline Básico ===" -ForegroundColor Green
Write-Host "El Jenkinsfile contiene:" -ForegroundColor Yellow
Write-Host "- Checkout: Obtiene el código del repositorio" -ForegroundColor White
Write-Host "- Build: Ejecuta 'mvn clean package -DskipTests'" -ForegroundColor White
Write-Host "- Test: Ejecuta 'mvn test'" -ForegroundColor White

Write-Host "`n¡Configuración lista! 🚀" -ForegroundColor Green
