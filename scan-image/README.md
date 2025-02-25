## Description
Scan image for vulnerabilities

- How to use it:
```yaml
    - name: Scan image for vulnerabilities
      uses: timescale/cloud-actions/scan-image@main
      with:
        report-name: 'trivy-image' #OPTIONAL (Default to trivy-image)
        report-filename: 'trivy-image.report' #OPTIONAL (Default to trivy-image.report)
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets._AWS_SECRET_ACCESS_KEY }} #REQUIRED
        region: us-east-1 #OPTIONAL (Default to us-east-1)
        registry: <registry-name> #REQUIRED
        image: <image-name>:<tag> #REQUIRED
        report-format: table #OPTIONAL (Default to table)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
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
          aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }}
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
          aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }}
          registry: ${{ env.REGISTRY }}
          image: <your-repo-name>:${{ env.TAG }}
          report-format: table
          severity: CRITICAL,HIGH
          fail-on-vulns: true
        continue-on-error: true

      - name: Download vulnerability report
        if: steps.scan.outcome != 'success'
        uses: actions/download-artifact@v4
        with:
          name: ${{ env.REPORT_NAME }}
          path: ./vulnerability-reports

      - name: Update or create PR comment with vulnerabilities
        if: steps.scan.outcome != 'success'
        uses: actions/github-script@v6
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const reportContent = require('fs').readFileSync('./vulnerability-reports/${{ env.REPORT_FILENAME }}', 'utf8');

            const commentBody = `<!-- ${{ env.COMMENT_IDENTIFIER }} -->
            ## ⚠️ Security Vulnerabilities Detected

            Vulnerabilities were found in the image during the security scan (commit: ${context.sha.substring(0, 7)}).

            <details>
            <summary>Click to expand vulnerability report</summary>

            \`\`\`
            ${reportContent}
            \`\`\`

            </details>

            Please review and address these security issues before merging.
            `;

            // Get all comments on the PR
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });

            // Look for our specific comment using the identifier
            const botComment = comments.find(comment => {
              return comment.body.includes('${{ env.COMMENT_IDENTIFIER }}');
            });

            if (botComment) {
              // If comment exists, update it
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body: commentBody
              });
              console.log(`Updated existing comment ID ${botComment.id}`);
            } else {
              // If comment doesn't exist, create a new one
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: commentBody
              });
              console.log('Created new comment');
            }

      - name: Comment on PR when no vulnerabilities found
        if: steps.scan.outcome == 'success'
        uses: actions/github-script@v6
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const commentBody = `<!-- ${{ env.COMMENT_IDENTIFIER }} -->
            ## ✅ Security Scan Passed

            No critical or high vulnerabilities were found in the image scan (commit: ${context.sha.substring(0, 7)}).
            `;

            // Get all comments on the PR
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });

            // Look for our specific comment
            const botComment = comments.find(comment => {
              return comment.body.includes('${{ env.COMMENT_IDENTIFIER }}');
            });

            if (botComment) {
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body: commentBody
              });
            } else {
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: commentBody
              });
            }

      - name: Fail on vulnerabilities
        if: steps.scan.outcome != 'success'
        shell: bash
        run: exit 1
```