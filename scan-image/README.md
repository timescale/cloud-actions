## Description
Scan image for vulnerabilities

- How to use it:
```yaml
    - name: Scan image for vulnerabilities
      uses: timescale/cloud-actions/scan-image@main
      with:
        region: us-east-1 #OPTIONAL (Default to us-east-1)
        registry: "142548018081.dkr.ecr.us-east-1.amazonaws.com" #REQUIRED
        image: <image-name>:<tag> #REQUIRED
        report-format: table #OPTIONAL (Default to json)
        severity: CRITICAL #OPTIONAL (Default to CRITICAL,HIGH)
      secrets:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets._AWS_SECRET_ACCESS_KEY }} #REQUIRED
```

This action will always succeed, even if vulnerabilities are found. The report that can be used to track and remediate vulnerabilities will be uploaded as an artifact to the workflow run.