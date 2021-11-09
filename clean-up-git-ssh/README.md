## Description
Clean up git ssh keys

- How to use it:
```yaml
    - name: Clean up gitconfig and ssh
      uses: timescale/cloud-actions/clean-up-git-ssh@main
      if: ${{ always() }}
```
