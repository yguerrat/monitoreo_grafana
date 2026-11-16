# Crea contraseñas únicas para este computador. No las incluye en el ZIP.
$ErrorActionPreference = 'Stop'
$folder = Join-Path $PSScriptRoot 'secrets'
if (-not (Test-Path -LiteralPath $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
}

function New-Secret([string]$name, [int]$bytesCount = 24) {
    $path = Join-Path $folder ($name + '.txt')
    if (Test-Path -LiteralPath $path) { return }
    $bytes = New-Object byte[] $bytesCount
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $value = ([System.BitConverter]::ToString($bytes)).Replace('-', '').ToLowerInvariant()
    Set-Content -LiteralPath $path -Value $value -Encoding Ascii -NoNewline
}

New-Secret 'elastic_password'
New-Secret 'kibana_password'
New-Secret 'logstash_password'
New-Secret 'logstash_keystore_password'
New-Secret 'alumno_password'
New-Secret 'grafana_password'
New-Secret 'kibana_session_key' 32
New-Secret 'kibana_saved_objects_key' 32
Write-Host 'Credenciales locales preparadas.'
