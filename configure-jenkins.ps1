# Script para configurar Jenkins Pipeline
# Este script configura automáticamente un pipeline en Jenkins

Write-Host "=== Configurando Jenkins Pipeline ===" -ForegroundColor Green

# Configuración
$JENKINS_URL = "http://localhost:8081"
$JOB_NAME = "ecommerce-pipeline"
$GITHUB_URL = "https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git"

# Crear el XML del job
$jobXml = @"
<?xml version='1.0' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.42">
  <description>Pipeline básico para ecommerce-microservice-backend-app</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>10</daysToKeep>
        <numToKeep>5</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.90">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.8.3">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$GITHUB_URL</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"@

# Función para hacer peticiones HTTP
function Invoke-JenkinsAPI {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null,
        [string]$ContentType = "application/xml"
    )
    
    try {
        $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $Body -ContentType $ContentType
        return $response
    }
    catch {
        Write-Host "Error en petición a Jenkins: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Verificar si Jenkins está disponible
Write-Host "Verificando conexión con Jenkins..." -ForegroundColor Yellow
$jenkinsStatus = Invoke-JenkinsAPI -Url "$JENKINS_URL/api/json"

if ($jenkinsStatus) {
    Write-Host "✅ Jenkins está disponible" -ForegroundColor Green
} else {
    Write-Host "❌ No se puede conectar con Jenkins en $JENKINS_URL" -ForegroundColor Red
    Write-Host "Asegúrate de que Jenkins esté ejecutándose y accesible" -ForegroundColor Yellow
    exit 1
}

# Verificar si el job ya existe
Write-Host "Verificando si el job ya existe..." -ForegroundColor Yellow
$existingJob = Invoke-JenkinsAPI -Url "$JENKINS_URL/job/$JOB_NAME/api/json"

if ($existingJob) {
    Write-Host "⚠️  El job '$JOB_NAME' ya existe. ¿Deseas actualizarlo? (S/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq "S" -or $response -eq "s") {
        Write-Host "Actualizando job existente..." -ForegroundColor Yellow
        $updateResult = Invoke-JenkinsAPI -Url "$JENKINS_URL/job/$JOB_NAME/config.xml" -Method "POST" -Body $jobXml
        if ($updateResult -ne $null) {
            Write-Host "✅ Job actualizado exitosamente" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al actualizar el job" -ForegroundColor Red
        }
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
        exit 0
    }
} else {
    # Crear nuevo job
    Write-Host "Creando nuevo job '$JOB_NAME'..." -ForegroundColor Yellow
    $createResult = Invoke-JenkinsAPI -Url "$JENKINS_URL/createItem?name=$JOB_NAME" -Method "POST" -Body $jobXml
    if ($createResult -ne $null) {
        Write-Host "✅ Job creado exitosamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al crear el job" -ForegroundColor Red
        exit 1
    }
}

# Ejecutar el pipeline
Write-Host "¿Deseas ejecutar el pipeline ahora? (S/N)" -ForegroundColor Yellow
$runPipeline = Read-Host

if ($runPipeline -eq "S" -or $runPipeline -eq "s") {
    Write-Host "Ejecutando pipeline..." -ForegroundColor Yellow
    $buildResult = Invoke-JenkinsAPI -Url "$JENKINS_URL/job/$JOB_NAME/build" -Method "POST"
    if ($buildResult -ne $null) {
        Write-Host "✅ Pipeline ejecutado. Puedes ver el progreso en:" -ForegroundColor Green
        Write-Host "   $JENKINS_URL/job/$JOB_NAME/" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Error al ejecutar el pipeline" -ForegroundColor Red
    }
}

Write-Host "`n=== Configuración Completada ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Job Name: $JOB_NAME" -ForegroundColor Cyan
Write-Host "GitHub URL: $GITHUB_URL" -ForegroundColor Cyan
Write-Host "`nPuedes acceder a Jenkins en: $JENKINS_URL" -ForegroundColor Yellow
Write-Host "El pipeline estará disponible en: $JENKINS_URL/job/$JOB_NAME/" -ForegroundColor Yellow
