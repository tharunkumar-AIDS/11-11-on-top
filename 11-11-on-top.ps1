# 11:11 ON TOP loader v4
# User run command (admin prompt varum):
#   powershell -ExecutionPolicy Bypass -c "iwr -useb 'bit.ly/11-11-on-top' | iex"

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Write-Host "[*] 11:11 loader v4"

$zipUrl = "https://raw.githubusercontent.com/tharunkumar-AIDS/11-11-on-top/main/11-11-on-top.zip"

# FIX: 8.3 short path (MT15~1 mari) ah full long path ah maathu — Expand-Archive ku short path work aagathu
function Get-LongPath($p) {
    try { return (Get-Item -LiteralPath $p -Force).FullName }
    catch { return $p }
}
$tempRoot = $env:TEMP
if ([string]::IsNullOrWhiteSpace($tempRoot) -or !(Test-Path $tempRoot)) { $tempRoot = $env:TMP }
if ([string]::IsNullOrWhiteSpace($tempRoot) -or !(Test-Path $tempRoot)) { $tempRoot = "C:\Windows\Temp" }
$tempRoot = Get-LongPath $tempRoot
Write-Host ("[*] Temp: " + $tempRoot)

$appDir = Join-Path $tempRoot "11-11-on-top"
$zipPath = Join-Path $tempRoot "11-11-on-top.zip"
Write-Host ("[*] Target: " + $appDir)

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
    New-Item $appDir -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    if (!(Test-Path $zipPath)) { throw "Download file not found! Antivirus blocked? TEMP folder ah exclusion la podu." }
    $size = (Get-Item $zipPath).Length
    Write-Host ("[*] Downloaded: " + $size + " bytes")
    if ($size -lt 500KB) { throw "Download incomplete (small file)! Net check pannu." }

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
    Write-Host ("[!] Temp was: " + $tempRoot)
    pause
    exit 1
}
