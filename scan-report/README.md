## Description

Composite action to scan a repository for vulnerabilities and create or update issue or pull request comment if vulnerabilities are found.

- How to use it:

```yaml
    - name: Scan repository for vulnerabilities
      uses: timescale/cloud-actions/scan-report@main
      with:
        report-name: 'trivy-scan' #REQUIRED
        report-filename: 'trivy-scan.report' #REQUIRED
        identifier: 'SECURITY_SCAN_RESULTS_IDENTIFIER' #REQUIRED
        registry: <registry-name>/<image-name> #REQUIRED
        tags: | #OPTIONAL
          <tag1>
          <tag2>
          # ...
        digest: <digest> #OPTIONAL
        report-format: table #OPTIONAL (Default to table)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
        fail-on-vulns: false #OPTIONAL (Default to true)
        ignore-unfixed: true #OPTIONAL (Default to true)
```