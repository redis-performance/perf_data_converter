#!/usr/bin/env bash
set -euo pipefail
echo "Setting up APT repository structure..."
mkdir -p conf pool/main/p/perf-data-converter dists
cat > conf/distributions << 'DISTEOF'
Origin: perf_data_converter
Label: perf_data_converter
Codename: focal
Architectures: amd64 arm64
Components: main
Description: perf data converter APT repository

Origin: perf_data_converter
Label: perf_data_converter
Codename: jammy
Architectures: amd64 arm64
Components: main
Description: perf data converter APT repository

Origin: perf_data_converter
Label: perf_data_converter
Codename: noble
Architectures: amd64 arm64
Components: main
Description: perf data converter APT repository
DISTEOF
echo "APT repository structure setup complete!"
