## Description
Check if sc CLI is installed, if not, checkout the repository and run the `install.sh` script.

- How to use it:
```yaml
    - name: sc install
      uses: timescale/cloud-actions/install-sc-cli@main
      with:
        aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }} #REQUIRED
        gh-token: ${{ secrets.API_TOKEN_GITHUB_CLOUD }} #REQUIRED
```