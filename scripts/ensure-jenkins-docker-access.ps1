<#
PowerShell helper: instructions to give Jenkins container access to Docker socket.
This script only prints guidance and safe commands. It does NOT modify the host automatically.

Run as Administrator on Windows host (or use an elevated Linux shell if your Docker host is a Linux VM).
#>

Write-Host "\n=== Jenkins Docker Socket Access Helper ===\n"

Write-Host "Observed issue: Jenkins agent cannot access /var/run/docker.sock (permission denied)." -ForegroundColor Yellow
Write-Host "Common causes: the socket is owned by root and the container user is not in the 'docker' group, or the Jenkins container isn't started with the right group/user settings.\n"

Write-Host "Options to fix it (choose one):\n" -ForegroundColor Cyan

Write-Host "1) Quick (less secure) - Run the Jenkins container as root (allows direct access to the socket):" -ForegroundColor Green
Write-Host "  Example (PowerShell) - stop and remove existing jenkins container, then run as root:" -ForegroundColor Gray
Write-Host "  docker stop jenkins; docker rm jenkins;" -ForegroundColor DarkGray
Write-Host "  docker run -d --name jenkins --restart=always -u 0 `"# run as root inside container`" `"# (adjust volumes/ports as needed)`" -ForegroundColor DarkGray
Write-Host "    -v /var/run/docker.sock:/var/run/docker.sock `"# mount host docker socket`" `"# mount jenkins_home and other volumes`" -ForegroundColor DarkGray
Write-Host "    -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts" -ForegroundColor DarkGray
Write-Host "\nNote: running the container as root is fine for local workshop environments but is not recommended for production.\n"

Write-Host "2) Preferred (secure-ish) - Add the container to the host 'docker' group / match gid:" -ForegroundColor Green
Write-Host "  Steps on the Docker host (requires root privileges on the host):" -ForegroundColor Gray
Write-Host "  # find docker group id on the host" -ForegroundColor DarkGray
Write-Host "  getent group docker | cut -d: -f3  # (on Linux hosts)" -ForegroundColor DarkGray
Write-Host "  # change socket group to 'docker' (example) and allow group rw:" -ForegroundColor DarkGray
Write-Host "  sudo chown root:docker /var/run/docker.sock" -ForegroundColor DarkGray
Write-Host "  sudo chmod 660 /var/run/docker.sock" -ForegroundColor DarkGray
Write-Host "  # run the jenkins container with the docker group added (use the gid or group name):" -ForegroundColor DarkGray
Write-Host "  docker run -d --name jenkins --restart=always --group-add docker -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts" -ForegroundColor DarkGray
Write-Host "\nThis keeps the container running as the default jenkins user while allowing access to the socket via the docker group.\n"

Write-Host "3) Alternative - Keep current container but chown the socket to allow the specific user id used by the container" -ForegroundColor Green
Write-Host "  # find the jenkins user id inside the container (on host):" -ForegroundColor DarkGray
Write-Host "  docker exec jenkins id -u" -ForegroundColor DarkGray
Write-Host "  # suppose the UID is 1000, then on host do:" -ForegroundColor DarkGray
Write-Host "  sudo chown 1000:1000 /var/run/docker.sock" -ForegroundColor DarkGray
Write-Host "  # risky: changes who can access the socket on the host.\n" -ForegroundColor Yellow

Write-Host "4) Docker-in-Docker (DinD) or sidecar (more complex):" -ForegroundColor Green
Write-Host "  Use DinD sidecar or a Docker daemon inside the container, or build images on the host via a privileged sidecar. This is more complex and not covered by this script.\n"

Write-Host "Suggested docker-compose snippet (preferred over run-as-root):\n" -ForegroundColor Cyan
Write-Host @"
version: '3.7'
services:
  jenkins:
    image: jenkins/jenkins:lts
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    group_add:
      - docker
    # optional: user: "0"    # use only for quick debugging
volumes:
  jenkins_home:
"@ -ForegroundColor DarkGray

Write-Host "What I recommend you do now (local workshop):" -ForegroundColor Cyan
Write-Host "  1) If you can, run the docker commands above on the machine that runs your Jenkins container (as admin/root)." -ForegroundColor Gray
Write-Host "  2) If you are using docker-compose, add the 'group_add: - docker' line and ensure socket ownership is root:docker with mode 660." -ForegroundColor Gray
Write-Host "  3) If you prefer a fast workaround, restart the Jenkins container as root (option #1) then run the pipeline once to confirm it works." -ForegroundColor Gray

Write-Host "Debug commands to run on the Jenkins container (to inspect user/group):" -ForegroundColor Cyan
Write-Host "  docker exec -it jenkins id" -ForegroundColor DarkGray
Write-Host "  docker exec -it jenkins ls -l /var/run/docker.sock" -ForegroundColor DarkGray

Write-Host "\nIf you'd like, I can:"
Write-Host "  - Generate a docker-compose file tailored to your environment (tell me your existing compose flags/volumes)."
Write-Host "  - Add a small helper to the repo to detect the Jenkins container id and show the recommended docker run or compose snippet with values filled in.\n"

Write-Host "Done. Copy the recommended commands above and run them on the host that runs Docker and the Jenkins container. If you want, paste the output of 'docker ps' and 'docker exec jenkins id' and I'll craft an exact command you can run.\n" -ForegroundColor Green