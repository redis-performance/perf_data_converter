#!/usr/bin/env bash
set -euo pipefail

# Script to set up APT repository structure and configuration
# This script is called from GitHub Actions but can also be run manually

echo "Setting up APT repository structure..."

# Create directories if they don't exist
mkdir -p conf pool/main/p/perf-data-converter dists

echo "Creating reprepro configuration..."

# Create reprepro configuration with separate distribution blocks
cat > conf/distributions << 'EOF'
Origin: perf_data_converter
Label: perf_data_converter
Codename: focal
Architectures: amd64 arm64 all
Components: main
Description: perf data converter APT repository
SignWith: no

Origin: perf_data_converter
Label: perf_data_converter
Codename: jammy
Architectures: amd64 arm64 all
Components: main
Description: perf data converter APT repository
SignWith: no

Origin: perf_data_converter
Label: perf_data_converter
Codename: noble
Architectures: amd64 arm64 all
Components: main
Description: perf data converter APT repository
SignWith: no
EOF

echo "APT repository structure setup complete!"
echo "Created directories:"
echo "  - conf/"
echo "  - pool/main/p/perf-data-converter/"
echo "  - dists/"
echo ""
echo "Created configuration:"
echo "  - conf/distributions (with focal, jammy, noble suites)"
