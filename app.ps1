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

function Get-AsmNamespaces($asm) {
    $set = [System.Collections.Generic.HashSet[string]]::new()
    try {
        foreach ($t in $asm.GetExportedTypes()) {
            if ($t.Namespace) { [void]$set.Add($t.Namespace) }
        }
    } catch {}
    $set
}

# Namespaces imported by the merged source
$needed = [System.Collections.Generic.HashSet[string]]::new()
foreach ($u in $usings) {
    if ($u -match '^\s*using\s+([\w][\w.]*)\s*;') { [void]$needed.Add($matches[1]) }
}

# Start from assemblies already loaded in the current AppDomain
$refs    = [System.Collections.Generic.HashSet[string]]::new()
$covered = [System.Collections.Generic.HashSet[string]]::new()
foreach ($asm in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
    if ($asm.IsDynamic -or -not $asm.Location) { continue }
    [void]$refs.Add($asm.Location)
    foreach ($ns in (Get-AsmNamespaces $asm)) { [void]$covered.Add($ns) }
}

$missing = [System.Collections.Generic.HashSet[string]]::new()
foreach ($ns in $needed) { if (-not $covered.Contains($ns)) { [void]$missing.Add($ns) } }

# Fill in any missing namespaces by scanning the GAC for a matching assembly
if ($missing.Count -gt 0) {
    $resolver = [System.ResolveEventHandler]{
        param($sender, $eventArgs)
        try { [System.Reflection.Assembly]::ReflectionOnlyLoad($eventArgs.Name) } catch { $null }
    }
    [System.AppDomain]::CurrentDomain.add_ReflectionOnlyAssemblyResolve($resolver)
    try {
        $gacRoots = 'GAC_MSIL','GAC_64','GAC_32' |
            ForEach-Object { Join-Path $env:windir "Microsoft.NET\assembly\$_" } |
            Where-Object { Test-Path $_ }

        foreach ($dll in (Get-ChildItem -Path $gacRoots -Filter *.dll -Recurse -ErrorAction SilentlyContinue)) {
            if ($missing.Count -eq 0) { break }
            try {
                $gacAsm = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($dll.FullName)
                $asmNs  = Get-AsmNamespaces $gacAsm
                $hit    = $false
                foreach ($ns in @($missing)) {
                    if ($asmNs.Contains($ns)) { $hit = $true; [void]$missing.Remove($ns) }
                }
                if ($hit) { [void]$refs.Add($dll.FullName) }
            } catch {}
        }
    } finally {
        [System.AppDomain]::CurrentDomain.remove_ReflectionOnlyAssemblyResolve($resolver)
    }
}

Add-Type -TypeDefinition $merged -Language CSharp -ReferencedAssemblies @($refs)

[Pscs.Demo.App]::Run($args)
