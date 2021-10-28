## Description
Set kubeconfig to the correct environment and login to ECR using AWS
credentials.

- How to use it:
```yaml
    - name: Login to ECR and setup kubeconfig
      uses: timescale/cloud-actions/ecr-k8s-login
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}  #REQUIRED
        aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }}  #REQUIRED
        aws-secret-access-key: <aws key>  #REQUIRED
        region: <aws region>  #REQUIRED
        env:  <k8s env>  #REQUIRED
```
