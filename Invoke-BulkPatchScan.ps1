# =====================================================================
# MULTI-SITE PHP COMPLIANCE AUDITOR (CSV-DRIVEN)
# =====================================================================
$csvPath = Join-Path $PSScriptRoot "targets.csv"
$checkerScript = Join-Path $PSScriptRoot "Test-PHP2ShellExposure.ps1"

if (-not (Test-Path $csvPath)) {
    Write-Error "Error: targets.csv file not found! Please create it in the script directory."
    return
}

# Import target URLs from the CSV file
$targets = Import-Csv -Path $csvPath

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      STARTING ENTERPRISE INFRASTRUCTURE SCAN" -ForegroundColor Cyan
Write-Host "      Detected Targets: $($targets.Count)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

foreach ($target in $targets) {
    $friendlyName = $target.SiteName
    $url = $target.URL
    
    # Generate custom report filenames dynamically based on the SiteName
    $reportFile = ".\report-$friendlyName.md"
    
    Write-Host "`n>>> Auditing Site: $friendlyName ($url)..." -ForegroundColor Yellow
    
    try {
        # Execute your core scanner script on the target URL
        powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File $checkerScript -Url $url -ReportPath $reportFile
    }
    catch {
        Write-Host "Failed to scan target $($friendlyName): $_" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "      ENTERPRISE INFRASTRUCTURE SCAN COMPLETE!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan