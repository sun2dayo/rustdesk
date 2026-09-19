<#
.SYNOPSIS
    Instala o NovaDX Agente (acesso remoto permanente) num posto Windows.

.DESCRIPTION
    1. Instala o agente como serviço do Windows (--silent-install).
    2. Gera uma senha permanente aleatória e ÚNICA para este posto e aplica-a.
    3. Obtém o ID RustDesk do posto.
    4. Mostra ID + senha e copia-os para a área de transferência, para o técnico
       os guardar no cofre. A senha nunca é escrita em disco neste posto.

    O posto regista-se sozinho na consola https://remoto.novadx.pt/_admin/
    (ID, nome do PC, sistema operativo) através do API server embutido no agente.

    Correr como Administrador:
        powershell -ExecutionPolicy Bypass -File deploy-agente.ps1 -Cliente "Bom Preço"

.PARAMETER Cliente
    Nome do cliente, para identificar o registo no cofre.
.PARAMETER Instalador
    Caminho local do NovaDX-Agente.exe. Se omitido, é descarregado de remoto.novadx.pt.
.PARAMETER Sha256
    SHA-256 esperado do instalador (recomendado quando é descarregado).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Cliente,
    [string]$Instalador,
    [string]$Url = 'https://remoto.novadx.pt/download/NovaDX-Agente.exe',
    [string]$Sha256
)

$ErrorActionPreference = 'Stop'
$AppName = 'NovaDXAgente'
$InstalledExe = Join-Path $env:ProgramFiles "$AppName\$AppName.exe"

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-StrongPassword([int]$Length = 20) {
    # Sem caracteres ambíguos (0/O, 1/l/I) e só símbolos seguros em URL, para o link
    # novadxtecnico://connection/new/<ID>?password=<senha> do KeePassXC.
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789-_.'.ToCharArray()
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] ($Length * 4)
    $rng.GetBytes($bytes)
    $out = New-Object char[] $Length
    for ($i = 0; $i -lt $Length; $i++) {
        $out[$i] = $chars[[BitConverter]::ToUInt32($bytes, $i * 4) % $chars.Length]
    }
    -join $out
}

function Invoke-Agent([string[]]$Arguments) {
    # O agente escreve o resultado para stdout; Start-Process não o captura, por isso usa-se &.
    (& $InstalledExe @Arguments | Out-String).Trim()
}

if (-not (Test-Admin)) { throw 'Execute este script como Administrador.' }
if ([Environment]::Is64BitOperatingSystem -eq $false) { throw 'O NovaDX Agente requer Windows 64 bits.' }

# 1. Instalador
if (-not $Instalador) {
    $Instalador = Join-Path $env:TEMP 'NovaDX-Agente.exe'
    Write-Host "A descarregar $Url ..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $Instalador -UseBasicParsing
}
if ($Sha256) {
    $hash = (Get-FileHash $Instalador -Algorithm SHA256).Hash
    if ($hash -ne $Sha256.ToUpper()) { throw "SHA-256 não confere: $hash" }
}
$sig = Get-AuthenticodeSignature $Instalador
if ($sig.Status -ne 'Valid') { Write-Warning "Instalador sem assinatura digital válida ($($sig.Status))." }

# 2. Instalação silenciosa
if (-not (Test-Path $InstalledExe)) {
    Write-Host 'A instalar o NovaDX Agente...'
    Start-Process -FilePath $Instalador -ArgumentList '--silent-install' -Wait
    $deadline = (Get-Date).AddMinutes(3)
    while (-not (Test-Path $InstalledExe)) {
        if ((Get-Date) -gt $deadline) { throw "Instalação não concluída: $InstalledExe não existe." }
        Start-Sleep -Seconds 2
    }
}
$deadline = (Get-Date).AddMinutes(2)
while ((Get-Service -Name $AppName -ErrorAction SilentlyContinue).Status -ne 'Running') {
    if ((Get-Date) -gt $deadline) { throw "O serviço $AppName não arrancou." }
    Start-Sleep -Seconds 2
}

# 3. Senha permanente única deste posto
$password = New-StrongPassword
$res = Invoke-Agent @('--password', $password)
if ($res -notmatch 'Done') { throw "Falha ao definir a senha: $res" }

# 4. ID do posto (o serviço pode demorar alguns segundos a registar-se)
$id = ''
$deadline = (Get-Date).AddMinutes(1)
while (-not ($id -match '^\d{6,}$')) {
    if ((Get-Date) -gt $deadline) { throw "Não foi possível obter o ID (última resposta: '$id')." }
    Start-Sleep -Seconds 2
    $id = Invoke-Agent @('--get-id')
}

$registo = @"
Cliente : $Cliente
Posto   : $env:COMPUTERNAME
ID      : $id
Senha   : $password
Data    : $(Get-Date -Format 'yyyy-MM-dd HH:mm')
"@
Set-Clipboard -Value $registo

Write-Host ''
Write-Host '=== NovaDX Agente instalado ===' -ForegroundColor Green
Write-Host $registo
Write-Host 'Os dados foram copiados para a área de transferência.' -ForegroundColor Yellow
Write-Host 'Guarde-os AGORA no cofre NovaDX. A senha não fica registada neste posto.' -ForegroundColor Yellow

if ($Instalador -like "$env:TEMP*") { Remove-Item $Instalador -ErrorAction SilentlyContinue }
