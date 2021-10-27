## Description
Build & Push Docker Images.

- How to use it:
```yaml
    - name: Build using a tag
      uses: ./actions/build-push
      with:
        aws-access-key-id: ${{ secrets.ORG_AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets.ORG_AWS_SECRET_ACCESS_KEY }} #REQUIRED
        region: us-east-1 #OPTIONAL (Default to us-east-1)
        tags: | #REQUIRED
          tag1
          tag2
          tag3
        registry: ${{ env.REGISTRY }} #REQUIRED
        file: build/Dockerfile #OPTIONAL (Default to ./Dockerfile)
        target: release #OPTIONAL (Default to '')
```
## Note
This action will be likely replaced with `docker/build-push-action@v2`
once home-made actions allow another embedded actions.
