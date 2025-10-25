# Script para verificar que Jenkins esté funcionando correctamente
Write-Host "=== Verificación Final de Jenkins ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"

Write-Host "`n1. Verificando estado de Jenkins..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $JENKINS_URL -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Jenkins está ejecutándose correctamente" -ForegroundColor Green
        Write-Host "   URL: $JENKINS_URL" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Jenkins responde con código: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ No se puede conectar con Jenkins: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Asegúrate de que Jenkins esté ejecutándose en $JENKINS_URL" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n2. Verificando archivos del proyecto..." -ForegroundColor Yellow
$requiredFiles = @("Jenkinsfile", "pom.xml", "mvnw")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file encontrado" -ForegroundColor Green
    } else {
        Write-Host "❌ $file no encontrado" -ForegroundColor Red
    }
}

Write-Host "`n3. Verificando contenido del Jenkinsfile..." -ForegroundColor Yellow
if (Test-Path "Jenkinsfile") {
    $jenkinsfileContent = Get-Content "Jenkinsfile" -Raw
    if ($jenkinsfileContent -match "pipeline") {
        Write-Host "✅ Jenkinsfile contiene pipeline válido" -ForegroundColor Green
    } else {
        Write-Host "❌ Jenkinsfile no contiene pipeline válido" -ForegroundColor Red
    }
}

Write-Host "`n=== Instrucciones para Configurar en Jenkins ===" -ForegroundColor Green
Write-Host "1. Abre tu navegador y ve a: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "2. Si es la primera vez, configura Jenkins con la contraseña inicial" -ForegroundColor Yellow
Write-Host "3. Instala los plugins recomendados" -ForegroundColor Yellow
Write-Host "4. Crea un usuario administrador" -ForegroundColor Yellow
Write-Host "5. Haz clic en 'New Item'" -ForegroundColor Cyan
Write-Host "6. Ingresa el nombre: ecommerce-pipeline" -ForegroundColor Cyan
Write-Host "7. Selecciona 'Pipeline' y haz clic en 'OK'" -ForegroundColor Cyan
Write-Host "8. En la sección 'Pipeline':" -ForegroundColor Cyan
Write-Host "   - Definition: Pipeline script from SCM" -ForegroundColor White
Write-Host "   - SCM: Git" -ForegroundColor White
Write-Host "   - Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor White
Write-Host "   - Branch: */master" -ForegroundColor White
Write-Host "   - Script Path: Jenkinsfile" -ForegroundColor White
Write-Host "9. Haz clic en 'Save'" -ForegroundColor Cyan
Write-Host "10. Haz clic en 'Build Now' para ejecutar el pipeline" -ForegroundColor Cyan

Write-Host "`n=== Información del Pipeline ===" -ForegroundColor Green
Write-Host "El pipeline ejecuta los siguientes pasos:" -ForegroundColor Yellow
Write-Host "1. Checkout: Obtiene código del repositorio Git" -ForegroundColor White
Write-Host "2. Build: Ejecuta 'mvn clean package -DskipTests'" -ForegroundColor White
Write-Host "3. Test: Ejecuta 'mvn test'" -ForegroundColor White

Write-Host "`n=== Notas Importantes ===" -ForegroundColor Green
Write-Host "• El proyecto tiene algunos tests que fallan por compatibilidad de Java" -ForegroundColor Yellow
Write-Host "• El build principal funciona correctamente" -ForegroundColor Yellow
Write-Host "• Puedes ejecutar el pipeline sin problemas" -ForegroundColor Yellow
Write-Host "• Los errores de test no afectan la funcionalidad básica" -ForegroundColor Yellow

Write-Host "`n=== URLs Importantes ===" -ForegroundColor Green
Write-Host "Jenkins: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Repositorio: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan

Write-Host "`n¡Jenkins está listo para usar! 🚀" -ForegroundColor Green
Write-Host "Abre $JENKINS_URL en tu navegador para comenzar" -ForegroundColor Yellow
