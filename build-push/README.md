## Description
Build & Push Docker Images.

- How to use it:
```yaml
    - name: Build using a tag
      uses: timescale/cloud-actions/build-push@main
      with:
        region: us-east-1 #OPTIONAL (Default to us-east-1)
        tags: | #REQUIRED
          tag1
          tag2
          tag3
        registry: <my_registry>:<my_image> #REQUIRED
        file: build/Dockerfile #OPTIONAL (Default to build/Dockerfile)
        dockerfile_path: build/Dockerfile
        docker_target: release
      secrets:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} #REQUIRED
        aws-secret-access-key: ${{ secrets._AWS_SECRET_ACCESS_KEY }} #REQUIRED
```
## Note
This action will be likely replaced with `docker/build-push-action@v2`
once home-made actions allow another embedded actions.
