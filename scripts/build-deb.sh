#!/usr/bin/env bash
set -eux

VERSION=$1            # e.g. "v1.2.3"
OUTDIR="$PWD/artifacts"
mkdir -p "$OUTDIR"

# Build the project with Bazel
echo "Building perf_to_profile with Bazel..."
bazel build //src:perf_to_profile

# Install FPM
gem install --no-document fpm

# Create temporary directory for package contents
TEMP_DIR=$(mktemp -d)
BIN_DIR="$TEMP_DIR/usr/local/bin"
mkdir -p "$BIN_DIR"

# Copy the Bazel-built binary to the temporary directory
cp bazel-bin/src/perf_to_profile "$BIN_DIR/"
chmod +x "$BIN_DIR/perf_to_profile"

# Create the .deb package using FPM
fpm -s dir -t deb \
    -n perf-data-converter \
    -v "${VERSION#v}" \
    -a all \
    --description "Convert perf.data files to profile.proto format for use with pprof" \
    --url "https://github.com/redis-performance/perf_data_converter" \
    --license "Apache-2.0" \
    --vendor "Redis Performance Team" \
    --maintainer "redis-performance@redis.com" \
    --depends "libc6" \
    --depends "libelf1" \
    --depends "libcap2" \
    --package "$OUTDIR/perf-data-converter_${VERSION#v}_all.deb" \
    --chdir "$TEMP_DIR" \
    usr

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Successfully created: $OUTDIR/perf-data-converter_${VERSION#v}_all.deb"
ls -la "$OUTDIR/"
