# cloud-actions

Timescale cloud playground for GH Actions and shared workflows. With
regards to shared workflows, see some usage examples below.

### workflows usage example
#### Example of deploy.yaml caller (upon manual trigger)
```yaml
name: Deploy Caller
on:
  workflow_dispatch:
    inputs:
      env:
        description: 'Your Env: prod|dev'
        required: true
        default: 'dev'
      tag:
        description: 'Tag'
        required: true
        default: ''
      region:
        description: 'AWS Region: all|us-east-1|eu-central-1'
        required: true
        default: 'us-east-1'

jobs:
  deploy:
    name: Deploy
    uses: timescale/cloud-actions/.github/workflows/deploy.yaml@main
    with:
      env: ${{ github.event.inputs.env }}
      region: ${{ github.event.inputs.region }}
      tag: ${{ github.event.inputs.tag }}
      registry: myregsitry.dockerhub.com/myapp
      chart_name: myapp-chart
      chart_namespace: myapp-namespace
    secrets:
      API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
      ORG_AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      ORG_AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      ORG_KUBECONFIG_DEV: ${{ secrets.KUBECONFIG_DEV }}
      ORG_KUBECONFIG_DEV_EU_WEST_1: ${{ secrets.KUBECONFIG_DEV_EU_WEST_1 }}
      ORG_KUBECONFIG_DEV_US_WEST_2: ${{ secrets.KUBECONFIG_DEV_US_WEST_2 }}
      ORG_KUBECONFIG_PROD: ${{ secrets.KUBECONFIG_PROD }}
      ORG_KUBECONFIG_PROD_EU_WEST_1: ${{ secrets.KUBECONFIG_PROD_EU_WEST_1 }}
      ORG_KUBECONFIG_PROD_US_WEST_2: ${{ secrets.KUBECONFIG_PROD_US_WEST_2 }}
      ORG_KUBECONFIG_STAGE: ${{ secrets.KUBECONFIG_STAGE }}
```

#### Example of build.yaml caller (upon tag push event)
```yaml
name: Build Caller
on:
  push:
    tags:
      - "v*"

jobs:
  tag:
    runs-on: runner-label
    name: Retrieve Tag
    outputs: 
      tagjob: ${{ steps.git_tag.outputs.TAG }}
    steps:
    - name: Setup | Git Tag
      id: git_tag
      run: echo ::set-output name=TAG::${GITHUB_REF/refs\/tags\//}
      shell: bash

  release:
    name: Build Docker
    needs: tag
    uses: timescale/cloud-actions/.github/workflows/build.yaml@main
    with:
      region: us-east-1
      tags: |
          ${{ needs.tag.outputs.tagjob }}
      registry: myregsitry.dockerhub.com/myapp
      dockerfile_path: ./Dockerfile
      docker_target: release
    secrets:
      API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
