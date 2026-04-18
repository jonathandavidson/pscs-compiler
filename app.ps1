#requires -Version 5.1
<#
    Single entrypoint: compile every lib/*.cs file together in one Add-Type
    call, then delegate to the App class, forwarding all script arguments.

    Usage:
        powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com
        powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com --headers
        powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com --timeout 5000
#>

param(
    [string]$url,
    [int]$timeout = 0,
    [switch]$headers
)

$ErrorActionPreference = 'Stop'
$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$libDir = Join-Path $here 'lib'

$usings = [System.Collections.Generic.HashSet[string]]::new()
$bodies  = @()

Get-ChildItem -Path $libDir -Filter *.cs | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $body  = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*using\s+[\w][\w.]*\s*;') { $usings.Add($line) | Out-Null }
        else                                            { $body += $line }
    }
    $bodies += ($body -join [Environment]::NewLine)
}

$merged = ($usings -join [Environment]::NewLine) `
        + [Environment]::NewLine `
        + ($bodies -join [Environment]::NewLine)

Add-Type `
    -TypeDefinition $merged `
    -Language CSharp `
    -ReferencedAssemblies 'System.Net','System.Core'

$appArgs = @()
if ($url)           { $appArgs += '--url';     $appArgs += $url }
if ($timeout -gt 0) { $appArgs += '--timeout'; $appArgs += "$timeout" }
if ($headers)       { $appArgs += '--headers' }

[Pscs.Demo.App]::Run($appArgs)
