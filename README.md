# PHP2Shell Patch Readiness Checker

A defensive PowerShell tool that screens a supplied PHP release against the official patched baselines for CVE-2026-109618 and CVE-2026-109619.

## What it does

- **Dual Scan Capability:** Accepts a dotted PHP release such as `8.5.11` (Static Mode) OR queries a live web server's headers dynamically via `-Url` (Active Mode).
- **JSON-Driven Configurations:** Loads the official patched baselines dynamically from an externalized `baselines.json` configuration database instead of hardcoding values.
- **Visual Executive Reporting:** Generates both a raw Markdown assessment and a beautifully styled, interactive HTML dashboard report with responsive grids, status badges, and device-native emojis.
- **Multi-Site Orchestration:** Audits multiple network endpoints sequentially using a CSV-driven bulk scanner pipeline (`Invoke-BulkPatchScan.ps1` via `targets.csv`).

## Safe scope

This project supports both version-based static screening and active dynamic header queries. To test web connection parsing safely without exposing real production infrastructure, a lightweight local mock server script (`Start-MockServer.ps1`) is provided to simulate different PHP version scenarios.

---

## 🔍 How to Run Scans

### 1. Direct Static Version Check
To test your script against a manually specified version input:
```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Test-PHP2ShellExposure.ps1 -PhpVersion 8.5.11 -ReportPath .\exposed-8.5.11.md
```
*Expected status:* `EXPOSED`

---

### 2. Active Web Scanner Check
To run an active scan against a live web server's headers and compile a styled HTML dashboard:

**Step A: Start the Mock Web Server**
In a separate PowerShell terminal window, launch your local test environment:
```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Start-MockServer.ps1
```
*Expected output:* Mock server running on port 8000 mimicking a safe version (`PHP 8.5.15`) or vulnerable version (`PHP 8.4.26`).

**Step B: Execute the Scan**
In your main VS Code terminal, execute the scanner targeting the web server:
```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Test-PHP2ShellExposure.ps1 -Url "http://localhost:8000" -ReportPath .\audit-report.md
```
*Expected results:* The script connects, dynamically extracts the version from the headers, checks it against the JSON config, and outputs both `audit-report.md` and `audit-report.html` dashboards.

---

## 🚀 Advanced Enterprise Upgrades

### 1. Dynamic Configuration (`baselines.json`)
By separating security baselines from the application logic, security analysts can easily manage minimum safe thresholds across multiple branches without modifying script code:
```json
{
    "8.2": "8.2.35",
    "8.3": "8.3.36",
    "8.4": "8.4.27",
    "8.5": "8.5.12"
}
```

### 2. CSV-Driven Bulk Auditor (`Invoke-BulkPatchScan.ps1`)
Orchestrate mass-infrastructure scans seamlessly. Create a `targets.csv` inventory file mapping your environments:
```csv
SiteName,URL
LocalMockServer,http://localhost:8000
ExampleWebDomainPT,http://example.pt
ExampleWebDomain,http://example.com
```

Then launch the automated bulk audit:
```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Invoke-BulkPatchScan.ps1
```
Your scanner will cycle through each site, gracefully catching network errors, and generating individual custom reports (e.g., `report-LocalMockServer.html`) for each target.

---

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
