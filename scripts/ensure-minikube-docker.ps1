<#
PowerShell helper: ensure-minikube-docker.ps1
Runs on Windows host. Purpose:
 - Ensure Docker (Docker Desktop) is running
 - Ensure Minikube is installed and running with docker driver
 - Print guidance about Docker socket ownership for Jenkins agent containers

Usage (run as normal user):
  .\scripts\ensure-minikube-docker.ps1

If you want it to run at user login, create a scheduled task or add to your startup scripts.
#>

Set-StrictMode -Version Latest

Function Wait-ForDocker {
    param(
        [int]$Retries = 20,
        [int]$DelaySeconds = 3
    )

    Write-Host "Checking for Docker CLI availability..."
    for ($i=1; $i -le $Retries; $i++) {
        try {
            docker version --format '{{.Server.Version}}' > $null 2>&1
            Write-Host "✅ Docker is available"
            return $true
        } catch {
            Write-Host "Docker not available yet (attempt $i/$Retries). If you use Docker Desktop, ensure it's started."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    Write-Host "❌ Docker CLI not available after $Retries attempts. Start Docker Desktop and re-run this script." -ForegroundColor Red
    return $false
}

Function Ensure-Minikube-Running {
    param(
        [int]$Retries = 10,
        [int]$DelaySeconds = 4
    )

    Write-Host "Checking minikube..."
    try {
        & minikube version > $null 2>&1
    } catch {
        Write-Host "❌ 'minikube' not found in PATH. Please install minikube: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Red
        return $false
    }

    $status = & minikube status --format '{{.Host}}' 2>$null
    if ($?) {
        # If minikube exists, check if host running
        $hostStatus = (& minikube status) -join "`n"
        if ($hostStatus -match "host: Running") {
            Write-Host "✅ Minikube host is Running"
            return $true
        } else {
            Write-Host "⚠️ Minikube not running. Attempting to start minikube with docker driver..."
            try {
                & minikube start --driver=docker --memory=4096 --cpus=2
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Minikube started"
                    return $true
                } else {
                    Write-Host "❌ minikube start failed (exit $LASTEXITCODE). Check logs with 'minikube logs'." -ForegroundColor Red
                    return $false
                }
            } catch {
                Write-Host "❌ Exception while starting minikube: $_" -ForegroundColor Red
                return $false
            }
        }
    } else {
        Write-Host "⚠️ Unable to query minikube status. Ensure minikube is installed and accessible." -ForegroundColor Yellow
        return $false
    }
}

# --- Script body ---
$dockerOk = Wait-ForDocker
if (-not $dockerOk) { exit 1 }

$minikubeOk = Ensure-Minikube-Running
if (-not $minikubeOk) { exit 1 }

Write-Host "\n=== Recommendations for Jenkins agent containers that use the host Docker socket ===\n"
Write-Host "If you run Jenkins inside a container and mount the host Docker socket, ensure the socket is accessible to the Jenkins user. On Windows+Docker Desktop the socket is provided inside the Moby VM and permission issues are often seen when the agent runs as a different UID. Options:" -ForegroundColor Cyan
Write-Host "  1) Run the Jenkins agent container as root (not ideal for security) so it can access /var/run/docker.sock." -ForegroundColor Yellow
Write-Host "  2) If your Jenkins agent is a Windows service, use the Docker-in-Docker approach (dind) or use 'docker buildx create --use' remote builders." -ForegroundColor Yellow
Write-Host "  3) Prefer to run the Jenkins agent in the same context as Docker (e.g., on the host or inside WSL2 with access to Docker) and mount the socket: -v /var/run/docker.sock:/var/run/docker.sock" -ForegroundColor Yellow
Write-Host "  4) If you need to relax socket perms temporarily on the host (Linux), run: sudo chmod 666 /var/run/docker.sock" -ForegroundColor Yellow

Write-Host "\nHelper finished successfully. You can add this script to Windows Task Scheduler at login to ensure minikube is started automatically." -ForegroundColor Green

exit 0
