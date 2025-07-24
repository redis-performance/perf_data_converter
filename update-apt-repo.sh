#!/usr/bin/env bash
set -euo pipefail
ARTIFACTS_DIR="${1:-./artifacts}"
echo "Updating APT repository with packages from: $ARTIFACTS_DIR"

if [[ ! -d "$ARTIFACTS_DIR" ]]; then
    echo "Error: Artifacts directory '$ARTIFACTS_DIR' does not exist"
    exit 1
fi

DEB_FILES=("$ARTIFACTS_DIR"/*.deb)
if [[ ! -e "${DEB_FILES[0]}" ]]; then
    echo "Error: No .deb files found in '$ARTIFACTS_DIR'"
    exit 1
fi

echo "Found .deb files:"
ls -la "$ARTIFACTS_DIR"/*.deb

echo "Moving .deb files to pool..."
mkdir -p pool/main/p/perf-data-converter
mv "$ARTIFACTS_DIR"/*.deb pool/main/p/perf-data-converter/

echo "Updating repository for each suite..."
for suite in focal jammy noble; do
    echo "Processing suite: $suite"
    reprepro -b . --ignore=wrongdistribution includedeb "$suite" pool/main/p/perf-data-converter/*.deb
done

echo "APT repository update complete!"
