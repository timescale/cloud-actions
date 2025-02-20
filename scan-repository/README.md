## Description
Scan current repository for vulnerabilities

- How to use it:
```yaml
    - name: Scan repository for vulnerabilities
      uses: timescale/cloud-actions/scan-repository@main
      with:
        report-format: table #OPTIONAL (Default to json)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
```

This action will fail if vulnerabilities are found. The report that can be used to track and remediate vulnerabilities will be uploaded as an artifact to the workflow run.