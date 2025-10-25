# Script para probar el pipeline localmente
Write-Host "=== Probando Pipeline Localmente ===" -ForegroundColor Green

# Verificar que estamos en el directorio correcto
Write-Host "Directorio actual: $(Get-Location)" -ForegroundColor Cyan

# Verificar archivos necesarios
Write-Host "`n1. Verificando archivos necesarios..." -ForegroundColor Yellow
$requiredFiles = @("Jenkinsfile", "pom.xml", "mvnw")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file encontrado" -ForegroundColor Green
    } else {
        Write-Host "❌ $file no encontrado" -ForegroundColor Red
    }
}

# Probar Maven Wrapper
Write-Host "`n2. Probando Maven Wrapper..." -ForegroundColor Yellow
try {
    Write-Host "Ejecutando: .\mvnw --version" -ForegroundColor Cyan
    & .\mvnw --version
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven Wrapper funciona correctamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Error con Maven Wrapper" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error ejecutando Maven Wrapper: $($_.Exception.Message)" -ForegroundColor Red
}

# Probar compilación
Write-Host "`n3. Probando compilación..." -ForegroundColor Yellow
try {
    Write-Host "Ejecutando: .\mvnw clean package -DskipTests" -ForegroundColor Cyan
    & .\mvnw clean package -DskipTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilación exitosa" -ForegroundColor Green
    } else {
        Write-Host "❌ Error en compilación" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error ejecutando compilación: $($_.Exception.Message)" -ForegroundColor Red
}

# Probar tests
Write-Host "`n4. Probando tests..." -ForegroundColor Yellow
try {
    Write-Host "Ejecutando: .\mvnw test" -ForegroundColor Cyan
    & .\mvnw test
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Tests ejecutados correctamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Error en tests" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error ejecutando tests: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Resumen del Pipeline ===" -ForegroundColor Green
Write-Host "El pipeline ejecuta los siguientes pasos:" -ForegroundColor Yellow
Write-Host "1. Checkout: Obtiene código del repositorio Git" -ForegroundColor White
Write-Host "2. Build: Ejecuta 'mvn clean package -DskipTests'" -ForegroundColor White
Write-Host "3. Test: Ejecuta 'mvn test'" -ForegroundColor White

Write-Host "`n=== Para usar en Jenkins ===" -ForegroundColor Green
Write-Host "1. Ve a http://localhost:8081" -ForegroundColor Cyan
Write-Host "2. Crea un nuevo Pipeline job" -ForegroundColor Cyan
Write-Host "3. Configura el SCM como Git" -ForegroundColor Cyan
Write-Host "4. Repository URL: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor Cyan
Write-Host "5. Script Path: Jenkinsfile" -ForegroundColor Cyan
Write-Host "6. Ejecuta 'Build Now'" -ForegroundColor Cyan

Write-Host "`n¡Pipeline listo para usar! 🚀" -ForegroundColor Green
