#!/usr/bin/env bash
set -eux

VERSION=$1            # e.g. "v1.2.3"
OUTDIR="$PWD/artifacts"
mkdir -p "$OUTDIR"

# Generate version information
echo "Generating version information..."
./scripts/generate-version.sh

# Build the project with Bazel (with static linking for better compatibility)
echo "Building perf_to_profile with Bazel..."

# Try full static linking first, fall back to partial static if it fails
echo "Attempting full static linking..."
if bazel build \
    --compilation_mode=opt \
    --config=static \
    //src:perf_to_profile 2>/dev/null; then
    echo "✅ Full static linking successful"
else
    echo "⚠️  Full static linking failed, trying partial static linking..."
    if bazel build \
        --compilation_mode=opt \
        --config=partial-static \
        //src:perf_to_profile; then
        echo "✅ Partial static linking successful"
    else
        echo "❌ Both static linking approaches failed, falling back to default build..."
        bazel build \
            --compilation_mode=opt \
            --linkopt=-static-libgcc \
            --linkopt=-static-libstdc++ \
            //src:perf_to_profile
    fi
fi

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

# Make sure the binary is writable and executable before stripping
chmod u+w "$BIN_DIR/perf_to_profile"
chmod +x "$BIN_DIR/perf_to_profile"

# Strip the binary to reduce size and remove debug symbols
strip "$BIN_DIR/perf_to_profile" || echo "Warning: Could not strip binary (not critical)"

# Check binary dependencies for debugging
echo "Binary dependencies:"
ldd "$BIN_DIR/perf_to_profile" || echo "Static binary (no dynamic dependencies)"

# Determine package dependencies based on binary linking
DEPENDS_ARGS=""
if ldd "$BIN_DIR/perf_to_profile" >/dev/null 2>&1; then
    echo "Binary has dynamic dependencies, adding package dependencies..."
    # Check which libraries are dynamically linked and add appropriate dependencies
    if ldd "$BIN_DIR/perf_to_profile" | grep -q "libc\.so"; then
        DEPENDS_ARGS="$DEPENDS_ARGS --depends libc6"
    fi
    if ldd "$BIN_DIR/perf_to_profile" | grep -q "libelf"; then
        DEPENDS_ARGS="$DEPENDS_ARGS --depends libelf1"
    fi
    if ldd "$BIN_DIR/perf_to_profile" | grep -q "libcap"; then
        DEPENDS_ARGS="$DEPENDS_ARGS --depends libcap2"
    fi
else
    echo "Static binary detected, minimal dependencies required"
    # Even static binaries typically need basic libc for system calls
    DEPENDS_ARGS="--depends libc6"
fi

echo "Package dependencies: $DEPENDS_ARGS"

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
    $DEPENDS_ARGS \
    --package "$OUTDIR/perf-data-converter_${VERSION#v}_all.deb" \
    --chdir "$TEMP_DIR" \
    usr

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Successfully created: $OUTDIR/perf-data-converter_${VERSION#v}_all.deb"
ls -la "$OUTDIR/"
