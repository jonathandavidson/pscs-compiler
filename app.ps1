#requires -Version 5.1

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

Add-Type -TypeDefinition $merged -Language CSharp

[Pscs.Demo.App]::Run(@())
