# Script para instalar Maven en Jenkins
Write-Host "=== Instalando Maven en Jenkins ===" -ForegroundColor Green

# Instalar Maven en el contenedor de Jenkins
Write-Host "`nDescargando e instalando Maven 3.8.1..." -ForegroundColor Yellow
docker exec -u root jenkins bash -c "cd /opt && wget https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz && tar -xzf apache-maven-3.8.1-bin.tar.gz && rm apache-maven-3.8.1-bin.tar.gz && ln -s /opt/apache-maven-3.8.1/bin/mvn /usr/local/bin/mvn"

# Verificar instalación
Write-Host "`nVerificando instalación de Maven..." -ForegroundColor Yellow
docker exec jenkins mvn -version

Write-Host "`n=== Maven instalado exitosamente ===" -ForegroundColor Green
Write-Host "`nAhora debes configurar Maven en Jenkins:" -ForegroundColor Cyan
Write-Host "1. Ve a: Manage Jenkins > Global Tool Configuration" -ForegroundColor White
Write-Host "2. En la seccion 'Maven':" -ForegroundColor White
Write-Host "   - Haz clic en 'Add Maven'" -ForegroundColor White
Write-Host "   - Name: Maven-3.8.1" -ForegroundColor Yellow
Write-Host "   - Desmarca 'Install automatically'" -ForegroundColor White
Write-Host "   - MAVEN_HOME: /opt/apache-maven-3.8.1" -ForegroundColor Yellow
Write-Host "3. Haz clic en 'Save'" -ForegroundColor White

Write-Host "`nListo para crear el pipeline de microservicios!" -ForegroundColor Green
