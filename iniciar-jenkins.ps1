# Inicia Jenkins como servicio opcional del mismo Docker Compose.
# Espera su página y muestra la clave inicial solo en esta terminal.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'secrets\elastic_password.txt'))) {
    Write-Error 'Primero inicia el laboratorio con INICIAR-AQUI.cmd.'
    exit 1
}

docker compose --profile jenkins up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Jenkins no pudo iniciar. Revisa Docker Desktop y los mensajes anteriores.'
    exit 1
}

$ready = $false
for ($i = 0; $i -lt 36; $i++) {
    try {
        $response = Invoke-WebRequest 'http://localhost:8080/login' -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) { $ready = $true; break }
    } catch { }
    Start-Sleep -Seconds 5
}
if (-not $ready) {
    Write-Error 'Jenkins todavía no responde. Usa: docker compose --profile jenkins logs --tail=80 jenkins'
    exit 1
}

Write-Host 'Jenkins listo en http://localhost:8080' -ForegroundColor Green
Write-Host 'Si es el primer inicio, usa esta clave para desbloquear Jenkins:'
docker compose --profile jenkins exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword
Write-Host 'No compartas esta clave ni una captura de esta terminal.'
