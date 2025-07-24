#!/usr/bin/env bash
set -eux

VERSION=$1            # e.g. "v1.2.3"
OUTDIR="$PWD/artifacts"
mkdir -p "$OUTDIR"

# Build the project with Bazel (with static linking for better compatibility)
echo "Building perf_to_profile with Bazel..."
bazel build \
    --config=opt \
    --linkopt=-static-libgcc \
    --linkopt=-static-libstdc++ \
    --linkopt=-Wl,--as-needed \
    --copt=-march=x86-64 \
    --copt=-mtune=generic \
    //src:perf_to_profile

# Install FPM (skip if FPM_SKIP_INSTALL is set, e.g., in CI)
if [[ "${FPM_SKIP_INSTALL:-}" != "1" ]]; then
    if ! command -v fpm &> /dev/null; then
        echo "Installing FPM..."
        sudo gem install --no-document fpm
    else
        echo "FPM already installed"
    fi
else
    echo "Skipping FPM installation (FPM_SKIP_INSTALL=1)"
fi

# Create temporary directory for package contents
TEMP_DIR=$(mktemp -d)
BIN_DIR="$TEMP_DIR/usr/local/bin"
mkdir -p "$BIN_DIR"

# Copy the Bazel-built binary to the temporary directory
cp bazel-bin/src/perf_to_profile "$BIN_DIR/"

# Strip the binary to reduce size and remove debug symbols
strip "$BIN_DIR/perf_to_profile"

# Make sure the binary is executable
chmod +x "$BIN_DIR/perf_to_profile"

# Check binary dependencies for debugging
echo "Binary dependencies:"
ldd "$BIN_DIR/perf_to_profile" || echo "Static binary (no dynamic dependencies)"

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
