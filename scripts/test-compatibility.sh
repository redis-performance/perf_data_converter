#!/usr/bin/env bash
set -euo pipefail

# Test script to verify binary compatibility across Ubuntu versions
# This script tests the perf_to_profile binary on different Ubuntu versions using Docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BINARY_PATH="$PROJECT_ROOT/bazel-bin/src/perf_to_profile"

# Ubuntu versions to test (LTS versions)
UBUNTU_VERSIONS=("22.04" "24.04")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_binary_exists() {
    if [[ ! -f "$BINARY_PATH" ]]; then
        log_error "Binary not found at $BINARY_PATH"
        log_info "Please build the binary first with: bazel build //src:perf_to_profile"
        exit 1
    fi
    log_info "Found binary at $BINARY_PATH"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is required but not installed"
        exit 1
    fi
    log_info "Docker is available"
}

test_on_ubuntu() {
    local version=$1
    local image="ubuntu:$version"
    
    log_info "Testing on Ubuntu $version..."
    
    # Create a temporary directory for the test
    local temp_dir=$(mktemp -d)
    cp "$BINARY_PATH" "$temp_dir/"
    
    # Run the test in Docker
    local exit_code=0
    docker run --rm \
        -v "$temp_dir:/test" \
        "$image" \
        bash -c "
            set -e
            echo 'Ubuntu version:'
            cat /etc/os-release | grep VERSION=
            echo
            echo 'Testing binary dependencies:'
            ldd /test/perf_to_profile || echo 'Static binary (no dynamic dependencies)'
            echo
            echo 'Testing binary execution:'
            /test/perf_to_profile --help 2>&1 | head -5 || echo 'Help command failed'
            echo
            echo 'Testing version command:'
            /test/perf_to_profile --version 2>&1 || echo 'Version command failed'
        " || exit_code=$?
    
    # Clean up
    rm -rf "$temp_dir"
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "✅ Ubuntu $version: PASSED"
        return 0
    else
        log_error "❌ Ubuntu $version: FAILED"
        return 1
    fi
}

analyze_binary() {
    log_info "Analyzing binary compatibility..."
    
    echo "Binary size:"
    ls -lh "$BINARY_PATH"
    echo
    
    echo "Binary dependencies:"
    if ldd "$BINARY_PATH" 2>/dev/null; then
        echo
        echo "Dynamic dependencies found. Checking versions:"
        ldd "$BINARY_PATH" | while read line; do
            if [[ $line =~ libstdc\+\+ ]]; then
                log_warn "libstdc++ is dynamically linked: $line"
            elif [[ $line =~ libgcc ]]; then
                log_warn "libgcc is dynamically linked: $line"
            elif [[ $line =~ libc\. ]]; then
                log_warn "libc is dynamically linked: $line"
            elif [[ $line =~ libelf ]]; then
                log_warn "libelf is dynamically linked: $line"
            elif [[ $line =~ libcap ]]; then
                log_warn "libcap is dynamically linked: $line"
            fi
        done
    else
        log_info "✅ Static binary (no dynamic dependencies)"
    fi
    echo
}

main() {
    log_info "Starting compatibility test for perf_to_profile binary"
    
    check_docker
    check_binary_exists
    analyze_binary
    
    local failed_tests=0
    local total_tests=${#UBUNTU_VERSIONS[@]}
    
    for version in "${UBUNTU_VERSIONS[@]}"; do
        echo "----------------------------------------"
        if ! test_on_ubuntu "$version"; then
            ((failed_tests++))
        fi
        echo
    done
    
    echo "========================================"
    log_info "Test Summary:"
    log_info "Total tests: $total_tests"
    log_info "Passed: $((total_tests - failed_tests))"
    if [[ $failed_tests -gt 0 ]]; then
        log_error "Failed: $failed_tests"
        log_error "Some compatibility tests failed. Consider:"
        log_error "1. Building with full static linking: bazel build --config=static //src:perf_to_profile"
        log_error "2. Building on Ubuntu 20.04 for maximum compatibility"
        log_error "3. Checking that all required libraries are statically linked"
        exit 1
    else
        log_info "✅ All compatibility tests passed!"
    fi
}

# Show usage if --help is passed
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0"
    echo
    echo "Test the perf_to_profile binary compatibility across Ubuntu versions."
    echo "Requires Docker to be installed and the binary to be built."
    echo
    echo "Build the binary first with:"
    echo "  bazel build //src:perf_to_profile"
    echo "  # or with static linking:"
    echo "  bazel build --config=static //src:perf_to_profile"
    exit 0
fi

main "$@"
