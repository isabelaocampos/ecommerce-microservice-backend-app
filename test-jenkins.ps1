# Script para probar la configuración de Jenkins
Write-Host "=== Probando Configuración de Jenkins ===" -ForegroundColor Green

$JENKINS_URL = "http://localhost:8081"

# Verificar que Jenkins esté ejecutándose
Write-Host "1. Verificando que Jenkins esté ejecutándose..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $JENKINS_URL -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Jenkins está ejecutándose correctamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Jenkins responde con código: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ No se puede conectar con Jenkins: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Asegúrate de que Jenkins esté ejecutándose en $JENKINS_URL" -ForegroundColor Yellow
    exit 1
}

# Verificar que el proyecto tenga el Jenkinsfile
Write-Host "`n2. Verificando Jenkinsfile..." -ForegroundColor Yellow
if (Test-Path "Jenkinsfile") {
    Write-Host "✅ Jenkinsfile encontrado" -ForegroundColor Green
    Write-Host "Contenido del Jenkinsfile:" -ForegroundColor Cyan
    Get-Content "Jenkinsfile" | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
} else {
    Write-Host "❌ Jenkinsfile no encontrado" -ForegroundColor Red
    Write-Host "Creando Jenkinsfile básico..." -ForegroundColor Yellow
    
    $jenkinsfileContent = @"
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Obteniendo código fuente...'
                git branch: 'master', url: 'https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Construyendo proyecto...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                sh 'mvn test'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completado'
        }
    }
}
"@
    
    $jenkinsfileContent | Out-File -FilePath "Jenkinsfile" -Encoding UTF8
    Write-Host "✅ Jenkinsfile creado" -ForegroundColor Green
}

# Verificar que Maven esté disponible
Write-Host "`n3. Verificando Maven..." -ForegroundColor Yellow
try {
    $mavenVersion = & mvn --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven está disponible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Maven no está disponible, pero el proyecto tiene mvnw" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Maven no está disponible, pero el proyecto tiene mvnw" -ForegroundColor Yellow
}

# Verificar que el proyecto tenga mvnw
Write-Host "`n4. Verificando Maven Wrapper..." -ForegroundColor Yellow
if (Test-Path "mvnw") {
    Write-Host "✅ Maven Wrapper (mvnw) encontrado" -ForegroundColor Green
} else {
    Write-Host "❌ Maven Wrapper no encontrado" -ForegroundColor Red
}

# Verificar estructura del proyecto
Write-Host "`n5. Verificando estructura del proyecto..." -ForegroundColor Yellow
$requiredFiles = @("pom.xml", "Jenkinsfile")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file encontrado" -ForegroundColor Green
    } else {
        Write-Host "❌ $file no encontrado" -ForegroundColor Red
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Para configurar el pipeline manualmente:" -ForegroundColor Yellow
Write-Host "1. Ve a $JENKINS_URL" -ForegroundColor White
Write-Host "2. Crea un nuevo Pipeline job" -ForegroundColor White
Write-Host "3. Configura el SCM como Git" -ForegroundColor White
Write-Host "4. Usa el repositorio: https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git" -ForegroundColor White
Write-Host "5. Script Path: Jenkinsfile" -ForegroundColor White

Write-Host "`n¡Configuración lista para usar! 🚀" -ForegroundColor Green
