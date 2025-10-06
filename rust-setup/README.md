## Description

Installs a specific Rust toolchain and configures the environment for the job.

How to use it:

```yaml
    - name: Setup Rust Environment
      uses: timescale/cloud-actions/setup-rust@main
      with:
        # The Rust toolchain version to install (e.g., 1.82.0, stable).
        rust-version: '1.82.0' # REQUIRED

        # (Optional) Override the default path for CARGO_HOME.
        # Defaults to a temporary directory provided by the runner.
        cargo-home: '${{ runner.temp }}/.cargo' # OPTIONAL

        # (Optional) Override the default path for RUSTUP_HOME.
        # Defaults to a temporary directory provided by the runner.
        rustup-home: '${{ runner.temp }}/.rustup' # OPTIONAL

        # (Optional) Change permission for the $CARGO_HOME and 
        # $RUSTUP_HOME directories
        # Only run for non-empty values.
        chown-user: '' # OPTIONAL
```