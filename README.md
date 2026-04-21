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
it resolves references in two passes:

1. **AppDomain sweep.** Every non-dynamic assembly already loaded into the
   current `AppDomain` is added to the reference set, and its exported
   namespaces are recorded as "covered."
2. **GAC fallback.** The `using` directives hoisted from the merged source are
   parsed into a set of required namespaces. Any namespace not already covered
   triggers a scan of `GAC_MSIL`, `GAC_64`, and `GAC_32` under
   `%windir%\Microsoft.NET\assembly\`. Each DLL is opened with
   `Assembly.ReflectionOnlyLoadFrom`, its exported namespaces inspected, and
   the first assembly that provides a missing namespace is added to the
   reference set. A `ReflectionOnlyAssemblyResolve` handler is attached during
   the scan so transitive metadata references resolve against the GAC as well.
   The scan stops early once every needed namespace has been satisfied.

Adding a new `using` directive to a `.cs` file requires no changes to
`app.ps1` as long as the target namespace is provided by some assembly
already loaded in the AppDomain or present in the GAC — which covers the
entire standard .NET Framework surface, including assemblies that PowerShell
does not pre-load (e.g. `System.Web.Extensions` for
`System.Web.Script.Serialization`).

The GAC scan adds a one-time startup cost (typically a few hundred
milliseconds) and only runs when the AppDomain sweep left something
unresolved.

## Notes / gotchas

- `Add-Type` caches by type name in the current session. Re-running in the
  same session throws "type already exists" — start a fresh PowerShell session.
- `using` directives are hoisted and deduplicated before the source is handed
  to the compiler; `using (var ...)` statements are left in place.
- `app.ps1` forwards `$args` directly to `App.Run()` — adding new parameters
  to the C# classes requires no changes to the entrypoint script.
- For anything non-trivial, prefer a real .dll: `dotnet build` + `Add-Type -Path .\App.dll`.
