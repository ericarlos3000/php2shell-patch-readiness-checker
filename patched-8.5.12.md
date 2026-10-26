# PHP2Shell Patch Readiness Report

- Checked: 2026-10-26 11:17 +00:00
- Supplied PHP release: 8.5.12
- Parsed branch: 8.5
- Branch patched baseline: 8.5.12
- Status: PATCHED BASELINE MET

## Findings

| CVE | Official finding | Severity | Advisory |
| --- | --- | --- | --- |
| CVE-2026-109618 | RCE via OOM corruption | Critical, CVSS 4.0 score 9.2 | https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w |
| CVE-2026-109619 | RCE via stale global state | Critical, CVSS 4.0 score 9.2 | https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp |
## Remediation

The supplied release meets the official patched baseline for this branch. Continue normal patch management and verify vendor-specific packages separately.

PHP states that updating to a release containing the patch is the only complete mitigation for these vulnerabilities.

## Scope

This is a version-based screening result, not an exploit test. It does not inspect a live server, vendor backports, PHP configuration, web-server SAPI, application reachability, or compensating controls.

## Official sources

- PHP security release archive: https://www.php.net/archive/2026.php
- CVE-2026-109618 advisory: https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w
- CVE-2026-109619 advisory: https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp
