# Release Process

This document describes the automated release process for `perf_data_converter` that creates and publishes `.deb` packages to an APT repository.

## Overview

The release process is fully automated using GitHub Actions. When you publish a GitHub Release, the system will:

1. **Build**: Compile the project and create a `.deb` package
2. **Publish**: Add the package to the APT repository hosted on GitHub Pages
3. **Test**: Verify installation across multiple Ubuntu versions and architectures

## Prerequisites

Before creating your first release, ensure:

1. **GitHub Pages is configured**:
   - Repository Settings → Pages
   - Source: "Deploy from a branch"
   - Branch: `gh-pages`
   - Folder: `/ (root)`

2. **gh-pages branch exists** with the required structure:
   ```
   gh-pages/
   ├── conf/
   ├── pool/
   └── dists/
   ```

3. **GitHub Actions are enabled** for the repository.

## Creating a Release

### Step 1: Prepare for Release

1. **Ensure all changes are merged** to the main branch
2. **Run tests locally** to verify everything works:
   ```bash
   bazel test //src:all //src/quipper:all
   ```
3. **Update version-related documentation** if needed

### Step 2: Create the GitHub Release

1. **Go to the Releases page**:
   - Navigate to your repository on GitHub
   - Click on "Releases" in the right sidebar
   - Click "Create a new release"

2. **Create a new tag**:
   - Click "Choose a tag"
   - Enter a new tag name following semantic versioning (e.g., `v1.2.3`)
   - Select "Create new tag: vX.Y.Z on publish"

3. **Fill in release information**:
   - **Release title**: Use the same as the tag (e.g., `v1.2.3`)
   - **Description**: Add release notes describing changes, bug fixes, new features
   - **Attach binaries**: Leave empty (will be auto-generated)

4. **Publish the release**:
   - Click "Publish release"
   - This triggers the automated workflow

### Step 3: Monitor the Workflow

1. **Check GitHub Actions**:
   - Go to the "Actions" tab in your repository
   - Look for the "APT Repository Release" workflow
   - Monitor the progress of the three jobs: build, publish, test

2. **Workflow stages**:
   - **Build** (~5-10 minutes): Compiles code and creates `.deb` package
   - **Publish** (~2-5 minutes): Updates APT repository on gh-pages branch
   - **Test** (~10-15 minutes): Tests installation on 6 different platform combinations

### Step 4: Verify the Release

1. **Check the APT repository**:
   - Visit `https://redis-performance.github.io/perf_data_converter/`
   - Verify the repository structure is updated

2. **Test installation manually** (optional):
   ```bash
   # On an Ubuntu system
   echo "deb [trusted=yes] https://redis-performance.github.io/perf_data_converter focal main" | sudo tee /etc/apt/sources.list.d/perf_data_converter.list
   sudo apt-get update
   sudo apt-get install perf-data-converter
   perf_to_profile --help
   ```

## Manual Workflow Trigger

You can also trigger the workflow manually for testing:

1. **Go to Actions tab** → "APT Repository Release"
2. **Click "Run workflow"**
3. **Enter a release tag** (e.g., `v1.2.3`)
4. **Click "Run workflow"**

This is useful for:
- Testing the workflow without creating a public release
- Re-running a failed workflow
- Building packages for development versions

## Troubleshooting

### Common Issues

1. **Build fails**:
   - Check that all dependencies are properly specified
   - Verify Bazel build works locally
   - Check for compilation errors in the workflow logs

2. **Package creation fails**:
   - Verify FPM installation in the workflow
   - Check file permissions and paths
   - Review the build script for errors

3. **Repository update fails**:
   - Ensure gh-pages branch exists and is properly configured
   - Check GitHub Pages settings
   - Verify reprepro configuration

4. **Test failures**:
   - Check if the package was properly published
   - Verify APT repository accessibility
   - Review Docker container logs for installation issues

### Workflow Logs

To debug issues:
1. Go to Actions tab → failed workflow run
2. Click on the failed job
3. Expand the failed step to see detailed logs
4. Look for error messages and stack traces

### Manual Recovery

If the automated process fails, you can manually:

1. **Build the package locally**:
   ```bash
   ./scripts/build-deb.sh v1.2.3
   ```

2. **Manually update the repository**:
   ```bash
   git checkout gh-pages
   # Copy .deb files to pool/main/p/perf-data-converter/
   # Run reprepro commands
   # Commit and push changes
   ```

## Version Numbering

Follow semantic versioning (semver):
- **Major version** (X.0.0): Breaking changes
- **Minor version** (X.Y.0): New features, backward compatible
- **Patch version** (X.Y.Z): Bug fixes, backward compatible

Examples:
- `v1.0.0`: First stable release
- `v1.1.0`: Added new features
- `v1.1.1`: Bug fixes
- `v2.0.0`: Breaking changes

## Release Checklist

- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Version number follows semver
- [ ] Release notes are prepared
- [ ] GitHub Release is created
- [ ] Workflow completes successfully
- [ ] APT repository is updated
- [ ] Installation tests pass
- [ ] Release is announced (if applicable)
