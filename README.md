# PHP2Shell Patch Readiness Checker

A defensive PowerShell tool that screens a supplied PHP release against the official patched baselines for CVE-2026-109618 and CVE-2026-109619.

## What it does

- Accepts a dotted PHP release such as `8.5.11`.
- Selects the official patched baseline for PHP 8.2, 8.3, 8.4, or 8.5.
- Returns `EXPOSED`, `PATCHED BASELINE MET`, or `REVIEW REQUIRED`.
- Writes a Markdown assessment with remediation, limitations, and official sources.

## Safe scope

This project performs version-based screening only. It does not scan hosts, send web requests, reproduce memory corruption, or execute exploit code.

## Run an exposed example

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Test-PHP2ShellExposure.ps1 -PhpVersion 8.5.11 -ReportPath .\exposed-8.5.11.md
```

Expected status: `EXPOSED`

## Run a patched-baseline example

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Test-PHP2ShellExposure.ps1 -PhpVersion 8.5.12 -ReportPath .\patched-8.5.12.md
```

Expected status: `PATCHED BASELINE MET`

## Covered baselines

| PHP branch | First patched release |
| --- | --- |
| 8.2 | 8.2.35 |
| 8.3 | 8.3.36 |
| 8.4 | 8.4.27 |
| 8.5 | 8.5.12 |

## Result meanings

- `EXPOSED`: The supplied release is below the official patched baseline for its branch.
- `PATCHED BASELINE MET`: The supplied release is at or above the official patched baseline for its branch.
- `REVIEW REQUIRED`: The branch is outside this checker's four-branch matrix.

## Limitations

This checker does not verify vendor backports, package provenance, configuration mitigations, web-server SAPI, application exposure, or whether a supplied value matches the runtime actually deployed. Validate those separately before closing a remediation ticket.

## Official sources

- https://www.php.net/archive/2026.php
- https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w
- https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp