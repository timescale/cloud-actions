## Description
Scan image for vulnerabilities

- How to use it:
```yaml
    - name: Scan image for vulnerabilities
      uses: timescale/cloud-actions/scan-image@main
      with:
        report-name: 'trivy-image' #OPTIONAL (Default to trivy-image)
        report-filename: 'trivy-image.report' #OPTIONAL (Default to trivy-image.report)
        registry: <registry-name> #REQUIRED
        image: <image-name>:<tag> #REQUIRED
        report-format: table #OPTIONAL (Default to table)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
        ignore-unfixed: true #OPTIONAL (Default to true)
        fail-on-vulns: false #OPTIONAL (Default to false)
```

This action will always succeed, even if vulnerabilities are found. The report that can be used to track and remediate vulnerabilities will be uploaded as an artifact to the workflow run.
The report could also be used to create a new issue or to add comment to pull request.

### Create Issue example

The following example shows how to create a new issue if vulnerabilities are found.

```yaml
name: Build

on:
  pull_request:
    branches:
      - "main"

env:
  # The docker registry that images will be pushed to.
  REGISTRY: <registry-name>
  # The image tag to use for this CI pipeline's build. This is used by deployments.
  TAG: auto-${{ github.sha }}
  # The name of the report attached to the action run.
  REPORT_NAME: trivy-image
  # The name of the report file.
  REPORT_FILENAME: trivy-image.report

# permissions added for lint
permissions:
  contents: read
  issues: write

jobs:
  build:
    runs-on: non-prod
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: AWS ECR login
        run: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ env.REGISTRY }}
      - run: make configure-proxy
      - run: make build-operator
      - name: Show created Docker Image
        run: docker images | grep "${TAG}"
      - if: github.ref == 'refs/heads/main'
        run: make push-latest

      - name: Scan image for vulnerabilities
        uses: timescale/cloud-actions/scan-image@main
        id: scan
        with:
          report-name: ${{ env.REPORT_NAME }}
          report-filename: ${{ env.REPORT_FILENAME }}
          registry: ${{ env.REGISTRY }}
          image: <your-repo-name>:${{ env.TAG }}
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
  # The docker registry that images will be pushed to.
  REGISTRY: <registry-name>
  # The image tag to use for this CI pipeline's build. This is used by deployments.
  TAG: auto-${{ github.sha }}
  # The name of the report attached to the action run.
  REPORT_NAME: trivy-image
  # The name of the report file.
  REPORT_FILENAME: trivy-image.report
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
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: AWS ECR login
        run: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ env.REGISTRY }}
      - run: make configure-proxy
      - run: make build-operator
      - name: Show created Docker Image
        run: docker images | grep "${TAG}"
      - if: github.ref == 'refs/heads/main'
        run: make push-latest

      - uses: timescale/cloud-actions/scan-image@main
        id: scan
        with:
          report-name: ${{ env.REPORT_NAME }}
          registry: ${{ env.REGISTRY }}
          image: <your-repo-name>:${{ env.TAG }}
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