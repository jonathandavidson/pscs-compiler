#requires -Version 5.1

$ErrorActionPreference = 'Stop'
$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$libDir = Join-Path $here 'lib'

$usings = [System.Collections.Generic.HashSet[string]]::new()
$bodies  = @()

Get-ChildItem -Path $libDir -Filter *.cs -Recurse | ForEach-Object {
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

$refs = [System.AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { -not $_.IsDynamic -and $_.Location } |
    Select-Object -ExpandProperty Location

Add-Type -TypeDefinition $merged -Language CSharp -ReferencedAssemblies $refs

[Pscs.Demo.App]::Run($args)
