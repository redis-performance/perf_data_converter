# APT Repository Setup and Usage

This document describes how to set up and use the APT repository for `perf_data_converter`.

## Overview

The `perf_data_converter` project provides an automated APT repository that allows users to install the `perf-data-converter` package on Ubuntu systems using standard package management tools.

## Repository Setup (For Maintainers)

### Prerequisites

1. **GitHub Pages**: Ensure GitHub Pages is enabled for the repository and configured to serve from the `gh-pages` branch.
2. **gh-pages Branch**: Create an orphan `gh-pages` branch with the following structure:
   ```
   gh-pages/
   ├── conf/
   ├── pool/
   └── dists/
   ```

### Initial Setup Steps

1. **Create the gh-pages branch**:
   ```bash
   git checkout --orphan gh-pages
   git rm -rf .
   mkdir -p conf pool dists
   git add .
   git commit -m "Initial APT repository structure"
   git push origin gh-pages
   ```

2. **Configure GitHub Pages**:
   - Go to repository Settings → Pages
   - Set source to "Deploy from a branch"
   - Select `gh-pages` branch and `/ (root)` folder
   - Save the configuration

3. **Enable GitHub Actions**: The workflow will automatically trigger when you publish a GitHub Release.

## Release Process (For Maintainers)

1. **Create a GitHub Release**:
   - Go to the repository's Releases page
   - Click "Create a new release"
   - Create a new tag (e.g., `v1.2.3`)
   - Fill in release title and description
   - Click "Publish release"

2. **Automated Process**: The GitHub Actions workflow will automatically:
   - Build the project using Bazel
   - Create a `.deb` package using FPM
   - Publish the package to the APT repository
   - Test installation across multiple Ubuntu versions and architectures

3. **Verification**: Check the Actions tab to ensure the workflow completed successfully.

## Usage (For End Users)

### Installation

1. **Add the APT repository**:
   ```bash
   # Add the repository to your sources
   echo "deb [trusted=yes] https://redis-performance.github.io/perf_data_converter focal main" | sudo tee /etc/apt/sources.list.d/perf_data_converter.list
   echo "deb [trusted=yes] https://redis-performance.github.io/perf_data_converter jammy main" | sudo tee -a /etc/apt/sources.list.d/perf_data_converter.list
   echo "deb [trusted=yes] https://redis-performance.github.io/perf_data_converter noble main" | sudo tee -a /etc/apt/sources.list.d/perf_data_converter.list
   ```

2. **Update package list and install**:
   ```bash
   sudo apt-get update
   sudo apt-get install perf-data-converter
   ```

### Usage

After installation, the `perf_to_profile` binary will be available at `/usr/local/bin/perf_to_profile`:

```bash
# Basic usage
perf_to_profile --help

# Convert perf.data to profile format
perf record /bin/ls
perf_to_profile -i perf.data -o profile.pb

# Use with pprof
pprof -web profile.pb
```

## Supported Platforms

The APT repository supports:
- **Ubuntu versions**: 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble)
- **Architectures**: amd64, arm64
- **Package type**: Architecture-independent (works on all supported architectures)

## Troubleshooting

### Common Issues

1. **Package not found**: Ensure you've added the correct repository URL and updated the package list.

2. **Permission denied**: Make sure you're using `sudo` for installation commands.

3. **Dependency issues**: The package depends on `libc6`, `libelf1`, and `libcap2`. These should be automatically installed.

### Manual Installation

If the APT repository is not working, you can download and install the `.deb` package manually:

1. Go to the repository's Releases page
2. Download the latest `.deb` file
3. Install with: `sudo dpkg -i perf-data-converter_*.deb`
4. Fix dependencies if needed: `sudo apt-get install -f`

## Repository Structure

The APT repository follows the standard Debian repository structure:

```
https://redis-performance.github.io/perf_data_converter/
├── dists/
│   ├── focal/
│   ├── jammy/
│   └── noble/
├── pool/
│   └── main/
│       └── p/
│           └── perf-data-converter/
└── conf/
    └── distributions
```

## Security Note

The repository is configured with `[trusted=yes]` to avoid GPG signing complexity. In a production environment, you may want to implement proper package signing for enhanced security.
