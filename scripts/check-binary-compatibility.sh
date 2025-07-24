#!/usr/bin/env bash
set -euo pipefail

# Script to check binary compatibility and suggest fixes
# Usage: ./scripts/check-binary-compatibility.sh [binary_path]

BINARY_PATH="${1:-/usr/local/bin/perf_to_profile}"

echo "🔍 Checking binary compatibility for: $BINARY_PATH"

if [[ ! -f "$BINARY_PATH" ]]; then
    echo "❌ Binary not found: $BINARY_PATH"
    exit 1
fi

echo ""
echo "📋 Binary information:"
file "$BINARY_PATH"

echo ""
echo "🔗 Dynamic library dependencies:"
if ldd "$BINARY_PATH" 2>/dev/null; then
    echo ""
    echo "📊 Checking for problematic dependencies..."
    
    # Check for newer glibc requirements
    if ldd "$BINARY_PATH" | grep -q "GLIBC_2.3[0-9]"; then
        echo "⚠️  Warning: Binary requires newer GLIBC (2.30+)"
        echo "   This may not work on older systems like Ubuntu 18.04 or CentOS 7"
    fi
    
    # Check for newer libstdc++ requirements
    if ldd "$BINARY_PATH" | grep -q "GLIBCXX_3.4.3[0-9]"; then
        echo "⚠️  Warning: Binary requires newer GLIBCXX (3.4.30+)"
        echo "   This may not work on older systems"
    fi
    
    # Check if libraries are statically linked
    if ldd "$BINARY_PATH" | grep -q "libstdc++"; then
        echo "⚠️  Warning: libstdc++ is dynamically linked"
        echo "   Consider using --linkopt=-static-libstdc++ for better compatibility"
    fi
    
    if ldd "$BINARY_PATH" | grep -q "libgcc"; then
        echo "⚠️  Warning: libgcc is dynamically linked"
        echo "   Consider using --linkopt=-static-libgcc for better compatibility"
    fi
    
else
    echo "✅ Static binary (no dynamic dependencies) - excellent compatibility!"
fi

echo ""
echo "🧪 Testing basic functionality:"
if "$BINARY_PATH" --help >/dev/null 2>&1; then
    echo "✅ Binary executes successfully"
else
    echo "❌ Binary failed to execute"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "1. Check if you're on a compatible system:"
    echo "   ldd --version"
    echo "2. Install missing dependencies:"
    echo "   sudo apt-get install libc6 libstdc++6 libgcc-s1"
    echo "3. Try running with verbose error output:"
    echo "   LD_DEBUG=libs $BINARY_PATH --help"
fi

echo ""
echo "🏁 Compatibility check complete!"
