# pscs-compiler — POC: including C# from .cs files in PowerShell 5

A single-entrypoint PowerShell 5.1 script that compiles `lib/*.cs` into
one in-memory assembly via `Add-Type`, then runs the `App` class.

## Files

| File | What it shows |
| --- | --- |
| `app.ps1` | Entrypoint. Compiles lib and forwards all args to `App.Run()`. |
| `lib/App.cs` | Parses CLI arguments and delegates to the appropriate class. |
| `lib/handlers/Hello.cs` | Prints a hello message, optionally addressed to a name. |
| `lib/handlers/Help.cs` | Prints usage information. |
| `lib/handlers/Config.cs` | Loads and parses a JSON config file. |

## Usage

```powershell
# Hello, World!
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1

# Hello, <name>!
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --name Alice

# Load a config file, then greet
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --config .\config.json

# Print usage
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --help
```

## Parameters

| Parameter | Description |
| --- | --- |
| `--name <name>` | Name to greet. Takes precedence over a name in the config file. |
| `--config <path>` | Path to a JSON config file. Must be valid JSON. If a `name` property is present it is used as the greeting name. |
| `--help` | Print usage information. |

## Config file

A config file is a plain JSON object. The `name` property is the only
recognised key at this time:

```json
{
  "name": "Alice"
}
```

If `--name` and `--config` are both provided, `--name` takes precedence.

## Assembly references

`app.ps1` does not maintain a hardcoded `-ReferencedAssemblies` list. Instead
it queries the assemblies already loaded into the current `AppDomain` at
runtime:

```powershell
$refs = [System.AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { -not $_.IsDynamic -and $_.Location } |
    Select-Object -ExpandProperty Location
```

PowerShell 5.1 loads a broad set of .NET Framework assemblies on startup, so
any standard library namespace a `.cs` file references will already be present.
Dynamic assemblies (those with no on-disk path) are excluded because
`Add-Type` cannot reference them by path. Adding a new `using` directive to a
`.cs` file requires no changes to `app.ps1` as long as the assembly is part of
the standard .NET Framework — which covers all typical use cases.

## Notes / gotchas

- `Add-Type` caches by type name in the current session. Re-running in the
  same session throws "type already exists" — start a fresh PowerShell session.
- `using` directives are hoisted and deduplicated before the source is handed
  to the compiler; `using (var ...)` statements are left in place.
- `app.ps1` forwards `$args` directly to `App.Run()` — adding new parameters
  to the C# classes requires no changes to the entrypoint script.
- For anything non-trivial, prefer a real .dll: `dotnet build` + `Add-Type -Path .\App.dll`.
