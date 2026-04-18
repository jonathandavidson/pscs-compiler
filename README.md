# pscs-compiler — POC: including C# from .cs files in PowerShell 5

A single-entrypoint PowerShell 5.1 script that compiles `lib/*.cs` into
one in-memory assembly via `Add-Type`, then runs the `App` class.

## Files

| File | What it shows |
| --- | --- |
| `app.ps1` | Entrypoint. Compiles lib and forwards all args to `App.Run()`. |
| `lib/App.cs` | Parses CLI arguments and delegates to the appropriate class. |
| `lib/Hello.cs` | Prints a hello message, optionally addressed to a name. |
| `lib/Help.cs` | Prints usage information. |

## Usage

```powershell
# Hello, World!
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1

# Hello, <name>!
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --name Alice

# Print usage
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --help
```

## Notes / gotchas

- `Add-Type` caches by type name in the current session. Re-running in the
  same session throws "type already exists" — start a fresh PowerShell session.
- `using` directives are hoisted and deduplicated before the source is handed
  to the compiler; `using (var ...)` statements are left in place.
- `app.ps1` forwards `$args` directly to `App.Run()` — adding new parameters
  to the C# classes requires no changes to the entrypoint script.
- For anything non-trivial, prefer a real .dll: `dotnet build` + `Add-Type -Path .\App.dll`.
