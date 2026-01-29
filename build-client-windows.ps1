#!/usr/bin/env pwsh
# FreeSO Client Build Script for Windows
# This script automates the build process for the FreeSO client

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipRestore,
    
    [Parameter(Mandatory=$false)]
    [switch]$BuildOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$Run,
    
    [Parameter(Mandatory=$false)]
    [switch]$Publish
)

Write-Host "=== FreeSO Client Build Script for Windows ===" -ForegroundColor Cyan
Write-Host "Configuration: $Configuration" -ForegroundColor Yellow
Write-Host ""

function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Write-Host "Checking prerequisites..." -ForegroundColor Cyan
if (-not (Test-Command "git")) {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

if (-not (Test-Command "dotnet")) {
    Write-Host "ERROR: .NET SDK is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

$dotnetVersion = dotnet --version
Write-Host "Found .NET SDK version: $dotnetVersion" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "TSOClient\FSO.Server.Core\FSO.Server.Core.csproj")) {
    Write-Host "ERROR: This script must be run from the FreeSO project root directory." -ForegroundColor Red
    Write-Host "Please navigate to the directory containing TSOClient\FSO.Server.Core\FSO.Server.Core.csproj" -ForegroundColor Red
    exit 1
}

if ($Clean) {
    Write-Host ""
    Write-Host "Cleaning build artifacts..." -ForegroundColor Cyan
    
    $binFolders = Get-ChildItem -Path . -Include bin -Recurse -Directory -ErrorAction SilentlyContinue
    $objFolders = Get-ChildItem -Path . -Include obj -Recurse -Directory -ErrorAction SilentlyContinue
    
    $totalFolders = $binFolders.Count + $objFolders.Count
    Write-Host "  Found $totalFolders folders to remove" -ForegroundColor Gray
    
    foreach ($folder in $binFolders) {
        Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed $($folder.FullName -replace [regex]::Escape($PWD.Path + '\'), '')" -ForegroundColor DarkGray
    }
    
    foreach ($folder in $objFolders) {
        Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed $($folder.FullName -replace [regex]::Escape($PWD.Path + '\'), '')" -ForegroundColor DarkGray
    }
    
    Write-Host "Clean complete!" -ForegroundColor Green
}

if (-not $SkipRestore) {
    Write-Host ""
    Write-Host "Restoring dependencies..." -ForegroundColor Cyan
    dotnet restore TSOClient\FSO.Server.Core\FSO.Server.Core.sln -p:WarningsNotAsErrors=NU1605
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to restore dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "Dependencies restored!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Building FreeSO Client ($Configuration)..." -ForegroundColor Cyan
dotnet build TSOClient\FSO.Server.Core\FSO.Server.Core.sln -c $Configuration --no-restore -p:WarningsNotAsErrors=NU1605
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    exit 1
}

if ($Publish) {
    Write-Host ""
    Write-Host "Publishing FreeSO Client..." -ForegroundColor Cyan
    dotnet publish TSOClient\FSO.Server.Core\FSO.Server.Core.sln -c $Configuration -r win-x64 --self-contained false --no-build -p:WarningsNotAsErrors=NU1605 -o ..\..\publish
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Publish failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "Publish complete! Files are in publish directory." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Build Complete! ===" -ForegroundColor Green
$exePath = "TSOClient\tso.client\bin\$Configuration\net9.0\TSOClient.exe"
Write-Host "Client executable: $exePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "TIP: Use -Publish to create a distributable package." -ForegroundColor Yellow
Write-Host "TIP: You'll need original TSO game files in a 'game' directory to run the client." -ForegroundColor Yellow

if ($Run) {
    Write-Host ""
    Write-Host "Launching FreeSO Client..." -ForegroundColor Cyan
    if (Test-Path $exePath) {
        & $exePath
    } else {
        Write-Host "Client executable not found at expected location." -ForegroundColor Red
        Write-Host "You may need to run: dotnet run --project TSOClient/tso.client/TSOClient.csproj" -ForegroundColor Yellow
    }
}