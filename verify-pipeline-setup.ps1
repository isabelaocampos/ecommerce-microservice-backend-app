# Script de Verificación Pre-Pipeline
# Verifica que todo esté configurado correctamente antes de ejecutar el pipeline
# Isabella Ocampo - Ingeniería de Software V

Write-Host "🔍 Verificación Pre-Pipeline para Kubernetes" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$allChecksPass = $true
$checksCompleted = 0
$totalChecks = 0

function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$TestScript,
        [string]$SuccessMessage,
        [string]$FailureMessage,
        [string]$FixCommand = ""
    )
    
    $global:totalChecks++
    Write-Host "🔍 Verificando $Name..." -ForegroundColor Yellow
    
    try {
        $result = & $TestScript
        if ($result) {
            Write-Host "   ✅ $SuccessMessage" -ForegroundColor Green
            $global:checksCompleted++
            return $true
        } else {
            Write-Host "   ❌ $FailureMessage" -ForegroundColor Red
            if ($FixCommand) {
                Write-Host "   💡 Solución: $FixCommand" -ForegroundColor Yellow
            }
            $global:allChecksPass = $false
            return $false
        }
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($FixCommand) {
            Write-Host "   💡 Solución: $FixCommand" -ForegroundColor Yellow
        }
        $global:allChecksPass = $false
        return $false
    }
}

Write-Host "📍 PARTE 1: Verificación de Herramientas Locales" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Minikube
Test-Component -Name "Minikube instalado" -TestScript {
    $null = Get-Command minikube -ErrorAction SilentlyContinue
    return $?
} -SuccessMessage "Minikube está instalado" `
  -FailureMessage "Minikube no está instalado" `
  -FixCommand "Instalar desde: https://minikube.sigs.k8s.io/docs/start/"

# Verificar Minikube corriendo
Test-Component -Name "Minikube corriendo" -TestScript {
    $status = minikube status 2>&1
    return $LASTEXITCODE -eq 0
} -SuccessMessage "Minikube está corriendo" `
  -FailureMessage "Minikube no está corriendo" `
  -FixCommand "Ejecutar: minikube start"

# Verificar kubectl
Test-Component -Name "kubectl instalado" -TestScript {
    $null = Get-Command kubectl -ErrorAction SilentlyContinue
    return $?
} -SuccessMessage "kubectl está instalado" `
  -FailureMessage "kubectl no está instalado" `
  -FixCommand "Instalar desde: https://kubernetes.io/docs/tasks/tools/"

# Verificar Docker
Test-Component -Name "Docker Desktop" -TestScript {
    $null = Get-Command docker -ErrorAction SilentlyContinue
    return $?
} -SuccessMessage "Docker está instalado" `
  -FailureMessage "Docker no está instalado" `
  -FixCommand "Instalar Docker Desktop desde: https://www.docker.com/products/docker-desktop/"

Write-Host ""
Write-Host "📍 PARTE 2: Verificación de Jenkins" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar contenedor Jenkins
Test-Component -Name "Jenkins Container" -TestScript {
    $container = docker ps --filter "name=jenkins" --format "{{.Names}}" 2>&1
    return $container -eq "jenkins"
} -SuccessMessage "Jenkins está corriendo en Docker" `
  -FailureMessage "Jenkins no está corriendo" `
  -FixCommand "Ejecutar: docker start jenkins (o revisar GUIA-CONFIGURACION-JENKINS-K8S.md)"

# Verificar kubectl en Jenkins
$jenkinsRunning = docker ps --filter "name=jenkins" --format "{{.Names}}" 2>&1
if ($jenkinsRunning -eq "jenkins") {
    Test-Component -Name "kubectl en Jenkins" -TestScript {
        $output = docker exec jenkins kubectl version --client 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "kubectl está instalado en Jenkins" `
      -FailureMessage "kubectl no está en Jenkins" `
      -FixCommand "Ejecutar: docker exec -u root jenkins bash -c ""curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl' && chmod +x kubectl && mv kubectl /usr/local/bin/"""
    
    # Verificar Maven en Jenkins
    Test-Component -Name "Maven en Jenkins" -TestScript {
        $output = docker exec jenkins mvn -version 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "Maven está instalado en Jenkins" `
      -FailureMessage "Maven no está en Jenkins" `
      -FixCommand "Ver GUIA-CONFIGURACION-JENKINS-K8S.md para instalar Maven"
    
    # Verificar Docker CLI en Jenkins
    Test-Component -Name "Docker CLI en Jenkins" -TestScript {
        $output = docker exec jenkins docker --version 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "Docker CLI está instalado en Jenkins" `
      -FailureMessage "Docker CLI no está en Jenkins" `
      -FixCommand "Ejecutar: docker exec -u root jenkins bash -c ""apt-get update && apt-get install -y docker.io"""
} else {
    Write-Host "⚠️  Jenkins no está corriendo, omitiendo verificaciones de Jenkins" -ForegroundColor Yellow
    $global:totalChecks += 3
}

Write-Host ""
Write-Host "📍 PARTE 3: Verificación de Conectividad" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar conexión Jenkins-Minikube
if ($jenkinsRunning -eq "jenkins") {
    Test-Component -Name "Conectividad Jenkins-Minikube" -TestScript {
        $minikubeIp = minikube ip
        $output = docker exec jenkins ping -c 1 $minikubeIp 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "Jenkins puede conectarse a Minikube" `
      -FailureMessage "Jenkins no puede conectarse a Minikube" `
      -FixCommand "Ejecutar: docker network connect minikube jenkins"
    
    # Verificar kubeconfig en Jenkins
    Test-Component -Name "kubeconfig en Jenkins" -TestScript {
        $output = docker exec jenkins test -f /var/jenkins_home/.kube/config 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "kubeconfig está configurado en Jenkins" `
      -FailureMessage "kubeconfig no está en Jenkins" `
      -FixCommand "Ver GUIA-CONFIGURACION-JENKINS-K8S.md, sección 'Configurar kubeconfig'"
    
    # Verificar que Jenkins pueda usar kubectl
    Test-Component -Name "kubectl funcional en Jenkins" -TestScript {
        $output = docker exec jenkins kubectl get nodes 2>&1
        return $LASTEXITCODE -eq 0
    } -SuccessMessage "kubectl puede comunicarse con Kubernetes desde Jenkins" `
      -FailureMessage "kubectl no puede comunicarse con Kubernetes" `
      -FixCommand "Verificar certificados de Minikube y kubeconfig en Jenkins"
} else {
    $global:totalChecks += 3
}

Write-Host ""
Write-Host "📍 PARTE 4: Verificación de Archivos del Proyecto" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Jenkinsfile-stage
Test-Component -Name "Jenkinsfile-stage" -TestScript {
    return Test-Path "Jenkinsfile-stage"
} -SuccessMessage "Jenkinsfile-stage existe" `
  -FailureMessage "Jenkinsfile-stage no existe" `
  -FixCommand "Crear el archivo Jenkinsfile-stage en la raíz del proyecto"

# Verificar deployments de Kubernetes
$services = @(
    "user-service",
    "product-service",
    "favourite-service",
    "order-service",
    "payment-service",
    "shipping-service"
)

$missingDeployments = @()
foreach ($service in $services) {
    $deploymentFile = "k8s\${service}-deployment.yaml"
    if (-not (Test-Path $deploymentFile)) {
        $missingDeployments += $service
    }
}

Test-Component -Name "Deployments de K8s" -TestScript {
    return $missingDeployments.Count -eq 0
} -SuccessMessage "Todos los deployments existen (6/6)" `
  -FailureMessage "Faltan deployments: $($missingDeployments -join ', ')" `
  -FixCommand "Crear los archivos de deployment faltantes en k8s/"

# Verificar Dockerfiles
$missingDockerfiles = @()
foreach ($service in $services) {
    $dockerFile = "${service}\Dockerfile"
    if (-not (Test-Path $dockerFile)) {
        $missingDockerfiles += $service
    }
}

Test-Component -Name "Dockerfiles" -TestScript {
    return $missingDockerfiles.Count -eq 0
} -SuccessMessage "Todos los Dockerfiles existen (6/6)" `
  -FailureMessage "Faltan Dockerfiles: $($missingDockerfiles -join ', ')" `
  -FixCommand "Crear los Dockerfiles faltantes"

Write-Host ""
Write-Host "📍 PARTE 5: Verificación de Namespace de Kubernetes" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar namespace ecommerce
$namespaceExists = $false
$namespaceOutput = kubectl get namespace ecommerce 2>&1
if ($LASTEXITCODE -eq 0) {
    $namespaceExists = $true
}

if ($namespaceExists) {
    Write-Host "🔍 Namespace 'ecommerce'..." -ForegroundColor Yellow
    Write-Host "   ℹ️  Namespace ya existe" -ForegroundColor Cyan
    
    # Ver deployments existentes
    $deployments = kubectl get deployments -n ecommerce -o json 2>&1 | ConvertFrom-Json
    if ($deployments.items.Count -gt 0) {
        Write-Host "   📦 Deployments existentes:" -ForegroundColor Cyan
        foreach ($deployment in $deployments.items) {
            $name = $deployment.metadata.name
            $replicas = $deployment.status.replicas
            $ready = $deployment.status.readyReplicas
            Write-Host "      - $name ($ready/$replicas ready)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   📦 No hay deployments en el namespace" -ForegroundColor Gray
    }
} else {
    Write-Host "🔍 Namespace 'ecommerce'..." -ForegroundColor Yellow
    Write-Host "   ℹ️  Namespace no existe (será creado por el pipeline)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📊 REPORTE DE VERIFICACIÓN" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Verificaciones completadas: $checksCompleted/$totalChecks" -ForegroundColor White

$percentage = if ($totalChecks -gt 0) { [math]::Round(($checksCompleted / $totalChecks) * 100, 2) } else { 0 }
Write-Host "Porcentaje de éxito: ${percentage}%" -ForegroundColor $(if ($percentage -eq 100) { "Green" } elseif ($percentage -ge 80) { "Yellow" } else { "Red" })
Write-Host ""

if ($allChecksPass) {
    Write-Host "✅ TODAS LAS VERIFICACIONES PASARON" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 El sistema está listo para ejecutar el pipeline" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
    Write-Host "   1. Abrir Jenkins: http://localhost:8081" -ForegroundColor White
    Write-Host "   2. Crear pipeline 'deploy-microservices-stage'" -ForegroundColor White
    Write-Host "   3. Configurar Git repository" -ForegroundColor White
    Write-Host "   4. Script Path: Jenkinsfile-stage" -ForegroundColor White
    Write-Host "   5. Build Now" -ForegroundColor White
    Write-Host ""
    Write-Host "O ejecutar directamente:" -ForegroundColor Yellow
    Write-Host "   .\deploy-microservices-k8s.ps1" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "❌ ALGUNAS VERIFICACIONES FALLARON" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  Por favor, corrige los errores antes de ejecutar el pipeline" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Documentacion de ayuda:" -ForegroundColor Yellow
    Write-Host "   - GUIA-CONFIGURACION-JENKINS-K8S.md" -ForegroundColor White
    Write-Host "   - CONFIGURACION-PIPELINE-JENKINS.md" -ForegroundColor White
    Write-Host "   - PIPELINE-STAGE-K8S.md" -ForegroundColor White
    Write-Host ""
    exit 1
}
