## Description
Installs and generate a deb package with [nfpm](https://nfpm.goreleaser.com/). when the `nfpm-config` input is set.

### How to use it
> [!NOTE]
> When using string interpolation use with the `${{ }}` (eg `${{ env.FOO }}`) so they will be processed before calling the action.

```yaml
    - name: build the deb package
      uses: timescale/cloud-actions/deb-package@main
      with:
        arch: "amd64"               # REQUIRED
        workdir: ...                # OPTIONAL
        upload-artifact-name: ...   # OPTIONAL
        nfpm-version: "2.42.0"      # OPTIONAL
        nfpm-config: |              # OPTIONAL
            depends:
                - postgresql-17
            contents:
                - src: target/release/timescaledb_lake-pg17/usr/lib/postgresql/17/lib/timescaledb_lake*
                dst: /usr/lib/postgresql/17/lib/
                - src: target/release/timescaledb_lake-pg17/usr/share/postgresql/17/extension/timescaledb_lake*
                dst: /usr/share/postgresql/17/extension/
            umask: 2
            name: timescaledb-pg17
            arch: amd64
            platform: linux
            version: 0.0.1-apr24
            maintainer: Timescale Engineering <root@timescale.com>
            description: timescaledb-lake is a PostgreSQL extension
            homepage: https://github.com/timescale/timescaledb-lake.git
```

