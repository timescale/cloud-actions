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
  # The docker registry that images will be pushed to.
  REGISTRY: <registry-name>

  # The image tag to use for this CI pipeline's build. This is used by deployments.
  TAG: auto-${{ github.sha }}
  
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
  # The docker registry that images will be pushed to.
  REGISTRY: <registry-name>

  # The image tag to use for this CI pipeline's build. This is used by deployments.
  TAG: auto-${{ github.sha }}

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

            Vulnerabilities were found in the codebase during the security scan (commit: ${context.sha.substring(0, 7)}).

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

            No critical or high vulnerabilities were found in the codebase scan (commit: ${context.sha.substring(0, 7)}).
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
