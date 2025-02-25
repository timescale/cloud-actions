## Description
Scan current repository for vulnerabilities

- How to use it:
```yaml
    - name: Scan repository for vulnerabilities
      uses: timescale/cloud-actions/scan-repository@main
      with:
        report-name: 'trivy-repository' #OPTIONAL (Default to trivy-repository)
        report-filename: 'trivy-repository.report' #OPTIONAL (Default to trivy-repository.report)
        report-format: table #OPTIONAL (Default to table)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
        ignore-unfixed: true #OPTIONAL (Default to true)
        fail-on-vulns: false #OPTIONAL (Default to false)
```

This action will fail if vulnerabilities are found. The report that can be used to track and remediate vulnerabilities will be uploaded as an artifact to the workflow run.

### Create Issue example

The following example shows how to create a new issue if vulnerabilities are found.

```yaml
name: Build

on:
  pull_request:
    branches:
      - "main"

env:
  # The name of the report attached to the action run.
  REPORT_NAME: trivy-repository
  # The name of the report file.
  REPORT_FILENAME: trivy-repository.report

# permissions added for lint
permissions:
  contents: read
  issues: write

jobs:
  build:
    runs-on: non-prod
    steps:
      - uses: actions/checkout@v4

      - name: Scan repository for vulnerabilities
        uses: timescale/cloud-actions/scan-repository@main
        id: scan
        with:
          report-name: ${{ env.REPORT_NAME }}
          report-filename: ${{ env.REPORT_FILENAME }}
          report-format: table
          severity: CRITICAL,HIGH
          fail-on-vulns: true
        continue-on-error: true

      - name: Create Issue
        if: steps.scan.outcome != 'success'
        uses: timescale/cloud-actions/scan-create-issue@main
        with:
          report-name: ${{ env.REPORT_NAME }}
          report-filename: ${{ env.REPORT_FILENAME }}
```

### Add comment to pull request example

The following example shows how to add comment to pull request if vulnerabilities are found.

```yaml
name: Build

on:
  pull_request:
    branches:
      - "main"

env:
  # The name of the report attached to the action run.
  REPORT_NAME: trivy-repository
  # The name of the report file.
  REPORT_FILENAME: trivy-repository.report
  # Unique identifier for your comment, used to find it later
  COMMENT_IDENTIFIER: "SECURITY_SCAN_RESULTS_IDENTIFIER"

# permissions added for lint
permissions:
  contents: read
  pull-requests: write

jobs:
  build:
    runs-on: non-prod
    steps:
      - uses: actions/checkout@v4

      - uses: timescale/cloud-actions/scan-repository@main
        id: scan
        with:
          report-name: ${{ env.REPORT_NAME }}
          report-filename: ${{ env.REPORT_FILENAME }}
          report-format: table
          severity: CRITICAL,HIGH
          fail-on-vulns: true
        continue-on-error: true

      - name: Update or create PR comment with vulnerabilities
        uses: timescale/cloud-actions/scan-comment-pr@main
        if: always()
        with:
          report-name: ${{ env.REPORT_NAME }}
          report-filename: ${{ env.REPORT_FILENAME }}
          comment-identifier: ${{ env.COMMENT_IDENTIFIER }}
          scan-outcome: ${{ steps.scan.outcome }}
```
