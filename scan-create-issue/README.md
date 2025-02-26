## Description

Create a new issue if vulnerabilities are found with the report attached.

- How to use it:
```yaml
    - name: Create issue with vulnerabilities report
      uses: timescale/cloud-actions/scan-create-issue@main
      with:
        report-name: 'trivy-image' #OPTIONAL (Default to trivy-image)
        report-filename: 'trivy-image.report' #OPTIONAL (Default to trivy-image.report)
        issue-identifier: 'SECURITY_SCAN_RESULTS_IDENTIFIER' #REQUIRED
```

Reference [scan-image README](../scan-image/README.md#create-issue-example) for extended example.