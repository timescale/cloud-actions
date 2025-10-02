# AWS Auth GitHub Action

This GitHub Action creates the necessary files to authenticate with multiple profiles.

## Usage

Below is an example of how to use this action in your workflow:

```yaml
---
name: Example Workflow

on:
  push:
    branches:
      - main

jobs:
  aws-auth-example:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials
        uses: timescale/cloud-actions/aws-auth@main
        with:
          aws-profiles: |-
            [
                {
                    "profile": "default",
                    "region": "us-east-1",
                    "aws_access_key_id": "${{ secrets.AWS_ACCESS_KEY_ID }}",
                    "aws_secret_access_key": "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
                },
                {
                    "profile": "secondary",
                    "region": "us-west-2",
                    "aws_access_key_id": "${{ secrets.SECONDARY_AWS_ACCESS_KEY_ID }}",
                    "aws_secret_access_key": "${{ secrets.SECONDARY_AWS_SECRET_ACCESS_KEY }}"
                }
            ]
     # do your tasks then...
    - name: cleaning up
      run: |
        rm -f ~/.aws/config ~/.aws/credentials
      shell: bash
      if: always()
```
