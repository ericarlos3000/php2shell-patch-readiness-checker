[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PhpVersion,

    [ValidateNotNullOrEmpty()]
    [string]$ReportPath = ".\php2shell-report.md"
)

$fixedVersions = @{
    "8.2" = [System.Version]"8.2.35"
    "8.3" = [System.Version]"8.3.36"
    "8.4" = [System.Version]"8.4.27"
    "8.5" = [System.Version]"8.5.12"
}

try {
    $parsedVersion = [System.Version]::Parse($PhpVersion)
}
catch {
    throw "PhpVersion must use a dotted release format such as 8.5.12."
}

$branch = "{0}.{1}" -f $parsedVersion.Major, $parsedVersion.Minor
$minimumFixed = $fixedVersions[$branch]

if ($null -eq $minimumFixed) {
    $status = "REVIEW REQUIRED"
    $baselineText = "Not mapped by this checker"
    $remediation = "Consult the current PHP security advisory for this branch or vendor-supplied backport information."
}
elseif ($parsedVersion -lt $minimumFixed) {
    $status = "EXPOSED"
    $baselineText = $minimumFixed.ToString()
    $remediation = "Upgrade to the patched release for this branch or to a current supported PHP release."
}
else {
    $status = "PATCHED BASELINE MET"
    $baselineText = $minimumFixed.ToString()
    $remediation = "The supplied release meets the official patched baseline for this branch. Continue normal patch management and verify vendor-specific packages separately."
}

$checkedAt = Get-Date -Format "yyyy-MM-dd HH:mm K"

$report = @"
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
"@

Set-Content -Path $ReportPath -Value $report -Encoding UTF8

Write-Output "Status: $status"
Write-Output "Report: $ReportPath"