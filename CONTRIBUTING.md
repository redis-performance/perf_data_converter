# Contributing

We treat this repo as "Open Source" within Redis: anyone who clears the bar below is welcome to contribute.

## Local setup

```bash
git clone git@github.com:redis-performance/perf_data_converter.git
cd perf_data_converter
git submodule init
git submodule update

# Install system dependencies (Ubuntu/Debian)
sudo apt-get -y install g++ git libelf-dev libssl-dev libcap-dev linux-tools-$(uname -r)

# Install Bazel by following the instructions at:
# https://docs.bazel.build/versions/master/install.html
# (Bazelisk is the recommended approach)

# Generate version information
./scripts/generate-version.sh

# Build the main binary and all targets
bazel build //src:all //src/quipper:all
```

The compiled `perf_to_profile` binary will be available under `bazel-bin/src/perf_to_profile`.

## Branch naming

```
<type>/<short-description>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Example: `feat/add-pipeline-mode`

## Coding standards

- Keep changes focused; one logical change per PR.
- Follow the conventions already present in the codebase (formatting, naming, error handling).
- No dead code, no commented-out blocks.

## Submitting changes

1. Fork or create a branch from `master`.
2. Make your changes with clear, atomic commits.
3. Open a pull request against `master` with a descriptive title and summary.
4. Address review comments promptly; force-push to the same branch to update.

## Testing

- All new behaviour must be covered by tests.
- Existing tests must pass: run the test suite locally before opening a PR.
- Coverage should not decrease.

Run the full test suite with:

```bash
bazel test //src:all //src/quipper:all
```

## Review process

- At least one maintainer approval is required before merge.
- CI must be green.
- Maintainers may request changes or close PRs that don't meet the bar — this is normal and not personal.