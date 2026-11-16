# Inicia el laboratorio y comprueba que sus páginas respondan.
# Si algo falla, muestra una pista y devuelve un código de error.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

# Primero comprueba que Docker esté instalado y funcionando.
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error 'Docker no está instalado o no está disponible en la terminal.'
    exit 1
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Docker Desktop no está iniciado. Ábrelo y vuelve a ejecutar este archivo.'
    exit 1
}

# Construye la app e inicia los seis servicios del archivo compose.yaml.
& (Join-Path $PSScriptRoot 'preparar-secretos.ps1')
Write-Host 'Iniciando el laboratorio. La primera descarga puede tardar varios minutos...'
docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Error 'No se pudo iniciar el laboratorio. Revisa el mensaje de Docker mostrado arriba.'
    exit 1
}

# Estas direcciones sirven para saber si las herramientas ya están listas.
$elasticPassword = (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'secrets\elastic_password.txt') -Raw).Trim()
$basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('elastic:' + $elasticPassword))
$checks = @(
    @{ Name = 'Aplicación de ejemplo'; Url = 'http://localhost:8000/health' },
    @{ Name = 'Prometheus'; Url = 'http://localhost:9090/-/ready' },
    @{ Name = 'Grafana'; Url = 'http://localhost:3000/api/health' },
    @{ Name = 'Elasticsearch'; Url = 'http://localhost:9200/_cluster/health'; Headers = @{ Authorization = 'Basic ' + $basicAuth } },
    @{ Name = 'Kibana'; Url = 'http://localhost:5601/api/status' }
)

# Espera hasta cinco minutos y vuelve a probar cada diez segundos.
$deadline = (Get-Date).AddMinutes(5)
do {
    $pending = @()
    foreach ($check in $checks) {
        try {
            $params = @{ Uri = $check.Url; TimeoutSec = 5; UseBasicParsing = $true }
            if ($check.Headers) { $params.Headers = $check.Headers }
            $response = Invoke-WebRequest @params
            if ($response.StatusCode -ne 200) { $pending += $check.Name }
        } catch {
            $code = [int]$_.Exception.Response.StatusCode
            if ($check.Name -ne 'Kibana' -or $code -ne 401) { $pending += $check.Name }
        }
    }
    if ($pending.Count -eq 0) { break }
    Write-Host ('Esperando: ' + ($pending -join ', '))
    Start-Sleep -Seconds 10
} while ((Get-Date) -lt $deadline)

# Muestra el estado final y las direcciones que usarán los alumnos.
Write-Host ''
docker compose ps -a
Write-Host ''
if ($pending.Count -eq 0) {
    # Grafana conserva el panel anterior; este comando actualiza su contraseña.
    docker compose exec -T grafana sh -c 'grafana cli admin reset-admin-password "$(cat /run/secrets/grafana_password)" >/dev/null'
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Revisa la contraseña de Grafana en el contenedor.' }
    Write-Host 'Laboratorio listo. Abre guia-monitoreo-interactiva.html.' -ForegroundColor Green
} else {
    Write-Warning ('Algunos servicios aún no responden: ' + ($pending -join ', '))
    Write-Host 'Consulta los errores con: docker compose logs --tail=80'
}
Write-Host 'Prueba la app: http://localhost:8000'
Write-Host 'Prometheus: http://localhost:9090 | Grafana: http://localhost:3000 | Kibana: http://localhost:5601'
Write-Host ('Grafana: usuario admin | clave: ' + (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'secrets\grafana_password.txt') -Raw).Trim())
Write-Host ('Kibana: usuario alumno | clave: ' + (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'secrets\alumno_password.txt') -Raw).Trim())
Write-Host 'No compartas la carpeta secrets ni publiques estas claves.'
if ($pending.Count -ne 0) { exit 1 }
