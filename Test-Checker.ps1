$cases = @(
    @{ Version = "8.2.34"; Expected = "EXPOSED" }
    @{ Version = "8.2.35"; Expected = "PATCHED BASELINE MET" }
    @{ Version = "8.3.35"; Expected = "EXPOSED" }
    @{ Version = "8.3.36"; Expected = "PATCHED BASELINE MET" }
    @{ Version = "8.4.26"; Expected = "EXPOSED" }
    @{ Version = "8.4.27"; Expected = "PATCHED BASELINE MET" }
    @{ Version = "8.5.11"; Expected = "EXPOSED" }
    @{ Version = "8.5.12"; Expected = "PATCHED BASELINE MET" }
)

$failures = 0
foreach ($case in $cases) {
    $reportPath = ".\test-$($case.Version).md"
    $output = & .\Test-PHP2ShellExposure.ps1 -PhpVersion $case.Version -ReportPath $reportPath
    $expectedLine = "Status: $($case.Expected)"

    if ($output -contains $expectedLine) {
        Write-Output "PASS $($case.Version) -> $($case.Expected)"
    }
    else {
        Write-Output "FAIL $($case.Version) -> expected $($case.Expected)"
        $failures++
    }

    Remove-Item -Path $reportPath -ErrorAction SilentlyContinue
} if ($failures -gt 0) {
    throw "$failures test case(s) failed."
}

Write-Output "All $($cases.Count) test cases passed."