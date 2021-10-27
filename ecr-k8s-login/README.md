## Description
Set kubeconfig to the correct environment and login to ECR using AWS
credentials.

- How to use it:
```yaml
    - name: Login to ECR and setup kubeconfig
      uses: ./actions/ecr-k8s-login
      env:
        ORG_KUBECONFIG_DEV: ${{ secrets.ORG_KUBECONFIG_DEV }} #REQUIRED
        ORG_KUBECONFIG_STAGE: ${{ secrets.ORG_KUBECONFIG_STAGE }} #REQUIRED
        ORG_KUBECONFIG_PROD: ${{ secrets.ORG_KUBECONFIG_PROD }} #REQUIRED
      with:
        aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }} #REQUIRED
        env: ${{ github.event.inputs.env }} #REQUIRED
        region: ${{ github.event.inputs.region }} #REQUIRED (default to us-east-1)
```
