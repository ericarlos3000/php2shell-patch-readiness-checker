[CmdletBinding()]
param (
    [string]$PhpVersion,
    [string]$Url,
    [string]$ReportPath = ".\php2shell-report.md"
)

# 1. SAFEGUARD: Ensure at least one version input source is provided
if (-not $PhpVersion -and -not $Url) {
    throw "Error: You must provide either a -PhpVersion (e.g., 8.5.11) or a -Url to run this scan."
}

# 2. DYNAMIC WEB CONNECTION: Extract PHP version from headers if a URL is provided
if ($Url) {
    Write-Host "Connecting to target endpoint: $Url..." -ForegroundColor Cyan
    try {
        # Perform an HTTP GET request to reliably read headers (fully compatible with PowerShell 5.1)
        $webRequest = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
        
        # Read the X-Powered-By header
        $poweredByHeader = $webRequest.Headers["X-Powered-By"]
        
        if ($poweredByHeader -and $poweredByHeader -match "PHP/([\d\.]+)") {
            $PhpVersion = $Matches[1]
            Write-Host "Successfully detected target PHP Version: $PhpVersion" -ForegroundColor Green
        }
        else {
            Write-Error "Could not determine PHP version from X-Powered-By header. Found: $poweredByHeader"
            return
        }
    }
    catch {
        Write-Error "Failed to connect to target URL: $_"
        return
    }
}

# 3. DYNAMIC CONFIGURATION: Load patch baselines from JSON
$configPath = Join-Path $PSScriptRoot "baselines.json"

if (Test-Path $configPath) {
    $baselinesJson = Get-Content -Raw -Path $configPath | ConvertFrom-Json
    $fixedVersions = @{}
    foreach ($property in $baselinesJson.PSObject.Properties) {
        $fixedVersions[$property.Name] = [System.Version]$property.Value
    }
    Write-Host "Successfully loaded current patch baselines from JSON configuration!" -ForegroundColor Green
} else {
    throw "Fatal Error: baselines.json file is missing from $configPath"
}

# 4. SYSTEM VERSION PARSING
try {
    $parsedVersion = [System.Version]::Parse($PhpVersion)
}
catch {
    throw "PhpVersion must use a dotted release format such as 8.5.12."
}

$branch = "{0}.{1}" -f $parsedVersion.Major, $parsedVersion.Minor
$minimumFixed = $fixedVersions[$branch]

# 5. DYNAMIC REMEDIATION & CLASSIFICATION LOGIC
if ($null -eq $minimumFixed) {
    $status = "REVIEW REQUIRED"
    $baselineText = "Not mapped by this checker"
    $remediation = "Consult the current PHP security advisory for this branch or vendor-supplied backport information."
}
elseif ($parsedVersion -lt $minimumFixed) {
    $status = "EXPOSED"
    $baselineText = $minimumFixed.ToString()
    
    # Context-aware multi-line remediation steps
    $remediation = "To secure this server, you must upgrade PHP to at least version $minimumFixed.

Step-by-Step Remediation Plan:
1. Download the safe zip package (Non Thread Safe) for version $minimumFixed from: https://windows.php.net/download/
2. Stop your web server (IIS, Apache, or mock server).
3. Extract the downloaded zip file over your existing PHP directory (typically C:\php\).
4. Restart your web server and rerun this scan to verify.

Automated Command Line Options:
  - Winget: winget upgrade PHP.PHP --version $minimumFixed
  - Chocolatey: choco upgrade php --version $minimumFixed"
}
else {
    $status = "PATCHED BASELINE MET"
    $baselineText = $minimumFixed.ToString()
    $remediation = "The supplied release meets the official patched baseline for this branch. Continue normal patch management and verify vendor-specific packages separately."
}

# 6. GENERATE SECURITY EVIDENCE REPORTS
if ($ReportPath) {
    $checkedAt = Get-Date -Format "yyyy-MM-dd HH:mm K"

    # Compile Markdown Report using a standard multi-line string (immune to here-string bugs!)
    $markdownReport = "
# PHP2Shell Patch Readiness Report

- Checked: $checkedAt
- Supplied PHP release: $PhpVersion
- Parsed branch: $branch
- Branch patched baseline: $baselineText
- Status: $status

## Findings

| CVE | Official finding | Severity | Advisory |
| --- | --- | --- | --- |
| CVE-2026-109618 | RCE via OOM corruption | Critical, CVSS 4.0 score 9.2 | https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w |
| CVE-2026-109619 | RCE via stale global state | Critical, CVSS 4.0 score 9.2 | https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp |

## Remediation

$remediation

PHP states that updating to a release containing the patch is the only complete mitigation for these vulnerabilities.

## Scope

This is a version-based screening result, not an exploit test. It does not inspect a live server, vendor backports, PHP configuration, web-server SAPI, application reachability, or compensating controls.

## Official sources

- PHP security release archive: https://www.php.net/archive/2026.php
- CVE-2026-109618 advisory: https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w
- CVE-2026-109619 advisory: https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp
"

    # Write Markdown to Disk
    Set-Content -Path $ReportPath -Value $markdownReport -Encoding UTF8
    Write-Output "Status: $status"
    Write-Output "Report saved to: $ReportPath"

    # Generate HTML Filename (.md to .html conversion)
    $HtmlReportPath = $ReportPath -replace "\.md$", ".html"
    
    # Configure HTML layout variables
    $themeColor = "#198754"  # Default Green
    $statusIcon = "&#x2705;"
    $complianceStatement = "This server meets your configured security standards. No immediate remediation action is required."
    
    if ($status -eq "EXPOSED") {
        $themeColor = "#dc3545"  # Red
        $statusIcon = "&#x1F6A8;"
        $complianceStatement = "CRITICAL VULNERABILITY DETECTED. This server must be upgraded immediately to prevent remote code execution attacks."
    }

    $htmlRemediation = $remediation -replace "`n", ""
    $utcTimestamp = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
    $displayUrl = if ($Url) { $Url } else { "Manual Input Mode" }

    # Compile the HTML Document using a standard multi-line string
        $htmlContent = "
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <title>PHP Security Scan - Report Dashboard</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 40px; color: #333; }
        .dashboard { max-width: 800px; margin: 0 auto; background: #ffffff; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow: hidden; }
        .header { background: $themeColor; padding: 30px; color: #ffffff; text-align: center; }
        .header h1 { margin: 0; font-size: 28px; letter-spacing: 0.5px; }
        .header p { margin: 5px 0 0 0; opacity: 0.9; font-size: 14px; }
        .content { padding: 40px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .metric-card { background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 6px; padding: 20px; }
        .metric-card h3 { margin: 0 0 8px 0; color: #6c757d; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .metric-card p { margin: 0; font-size: 18px; font-weight: 600; color: #212529; }
        .status-banner { display: flex; align-items: center; background: #f8f9fa; border-left: 5px solid $themeColor; padding: 20px; border-radius: 4px; margin-bottom: 30px; }
        .status-icon { font-size: 32px; margin-right: 20px; }
        .status-text h2 { margin: 0 0 5px 0; font-size: 20px; }
        .status-text p { margin: 0; line-height: 1.5; color: #495057; }
        .section-title { font-size: 16px; font-weight: 600; margin-bottom: 15px; border-bottom: 2px solid #f1f3f5; padding-bottom: 8px; color: #495057; }
        .remediation-box { background: #fffdf5; border: 1px solid #ffeeba; color: #856404; padding: 20px; border-radius: 6px; font-family: monospace; white-space: pre-wrap; line-height: 1.6; font-size: 13px; }
        .footer { text-align: center; padding: 20px; color: #adb5bd; font-size: 12px; border-top: 1px solid #f1f3f5; margin-top: 40px; }
    </style>
</head>
<body>
    <div class='dashboard'>
        <div class='header'>
            <h1>PHP Vulnerability Scan Results</h1>
        </div>
        <div class='content'>
            <div class='status-banner'>
                <div class='status-icon'>$statusIcon</div>
                <div class='status-text'>
                    <h2>Status: $status</h2>
                    <p>$complianceStatement</p>
                </div>
            </div>
            
            <div class='section-title'>Audit Metadata</div>
            <div class='grid'>
                <div class='metric-card'>
                    <h3>Target URL / Host</h3>
                    <p>$displayUrl</p>
                </div>
                <div class='metric-card'>
                    <h3>Detected PHP Version</h3>
                    <p>$PhpVersion</p>
                </div>
                <div class='metric-card'>
                    <h3>Target PHP Branch</h3>
                    <p>$branch</p>
                </div>
                <div class='metric-card'>
                    <h3>Required Safe Baseline</h3>
                    <p>$baselineText</p>
                </div>
            </div>

            <div class='section-title'>Remediation Action Plan</div>
            <div class='remediation-box'>$htmlRemediation</div>
        </div>
        <div class='footer'>
            Report Compiled on $utcTimestamp | Audited with Custom PHP2Shell Patch Checker Engine
        </div>
    </div>
</body>
</html>
"

    # Save the HTML report to disk
    Set-Content -Path $HtmlReportPath -Value $htmlContent -Encoding UTF8
    Write-Output "Beautiful HTML dashboard generated at: $HtmlReportPath"
}