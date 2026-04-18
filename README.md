# pscs-compiler — POC: including C# from .cs files in PowerShell 5

A single-entrypoint PowerShell 5.1 script that compiles `lib/*.cs` into
one in-memory assembly via `Add-Type`, then runs the `App` class.

## Files

| File | What it shows |
| --- | --- |
| `app.ps1` | Entrypoint. Compiles lib, maps PS params to `App.Run(string[])`. |
| `lib/App.cs` | CLI app class — fetches a URL and prints status/body or headers. |

## Usage

```powershell
# fetch body
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com

# headers only
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com --headers

# custom timeout (ms)
powershell -ExecutionPolicy Bypass -NoProfile -File .\app.ps1 --url https://example.com --timeout 5000
```

## Parameters

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `--url` | string | required | URL to fetch |
| `--timeout` | int (ms) | 10000 | Request timeout |
| `--headers` | switch | false | Print headers only, suppress body |

## Notes / gotchas

- `Add-Type` caches by type name in the current session. Re-running in the
  same session throws "type already exists" — start a fresh PowerShell session.
- `using` directives are hoisted and deduplicated before the source is handed
  to the compiler; `using (var ...)` statements are left in place.
- For anything non-trivial, prefer a real .dll: `dotnet build` + `Add-Type -Path .\App.dll`.
