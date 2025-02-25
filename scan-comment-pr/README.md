## Description

Create a comment on the pull request if vulnerabilities are found with the report attached.

- How to use it:
```yaml
    - name: Comment on pull request with vulnerabilities report
      uses: timescale/cloud-actions/scan-comment-pr@main
      with:
        report-name: 'trivy-image' #REQUIRED
        report-filename: 'trivy-image.report' #REQUIRED
        comment-identifier: 'SECURITY_SCAN_RESULTS_IDENTIFIER' #OPTIONAL (Default to SECURITY_SCAN_RESULTS_IDENTIFIER)
        scan-outcome: ${{ steps.<scan-step-id>.outcome }}
```

Reference [scan-image README](../scan-image/README.md#add-comment-to-pull-request-example) for extended example.