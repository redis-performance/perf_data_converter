# Static Linking for Cross-Ubuntu Compatibility

This document explains the static linking approach used to ensure the `perf_to_profile` binary works across different Ubuntu versions (20.04, 22.04, 24.04).

## Problem

The original binary was dynamically linked against system libraries, causing compatibility issues:

```
perf_to_profile: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.38' not found
perf_to_profile: /lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.32' not found
```

This happens when a binary built on a newer Ubuntu version (with newer glibc/libstdc++) is run on an older version.

## Solution

We've implemented a multi-tier static linking approach:

### 1. Full Static Linking (Preferred)

```bash
bazel build --config=static //src:perf_to_profile
```

This configuration:
- Links everything statically (`--linkopt=-static`)
- Statically links libgcc and libstdc++ 
- Statically links libelf and libcap
- Results in a fully self-contained binary

### 2. Partial Static Linking (Fallback)

```bash
bazel build --config=partial-static //src:perf_to_profile
```

This configuration:
- Statically links libgcc and libstdc++
- Statically links libelf and libcap
- Still dynamically links glibc (but uses older symbols)

### 3. Minimal Static Linking (Last Resort)

```bash
bazel build --linkopt=-static-libgcc --linkopt=-static-libstdc++ //src:perf_to_profile
```

This is the original approach that only statically links the C++ runtime.

## Build Process

The `scripts/build-deb.sh` script automatically tries these approaches in order:

1. Attempts full static linking
2. Falls back to partial static linking if full static fails
3. Falls back to minimal static linking if partial static fails

## Package Dependencies

The package dependencies are automatically determined based on the binary's linking:

- **Static binary**: Only depends on `libc6` (for basic system calls)
- **Dynamic binary**: Depends on `libc6`, `libelf1`, `libcap2` as needed

## Testing Compatibility

Use the provided test script to verify compatibility:

```bash
# Build the binary first
bazel build --config=static //src:perf_to_profile

# Test compatibility across Ubuntu versions
./scripts/test-compatibility.sh
```

This script tests the binary on Ubuntu 20.04, 22.04, and 24.04 using Docker.

## CI/CD Changes

The CI pipeline now:

1. **Builds on Ubuntu 20.04** for maximum compatibility
2. **Uses static linking configurations** automatically
3. **Tests on multiple Ubuntu versions** to verify compatibility

## Troubleshooting

### If static linking fails:

1. **Check dependencies**: Ensure static versions of libraries are available
   ```bash
   sudo apt-get install libelf-dev libcap-dev
   ```

2. **Check Bazel cache**: Clear cache if needed
   ```bash
   bazel clean --expunge
   ```

3. **Use partial static**: If full static fails, partial static usually works
   ```bash
   bazel build --config=partial-static //src:perf_to_profile
   ```

### If binary still has compatibility issues:

1. **Check dynamic dependencies**:
   ```bash
   ldd bazel-bin/src/perf_to_profile
   ```

2. **Analyze required symbols**:
   ```bash
   objdump -T bazel-bin/src/perf_to_profile | grep GLIBC
   ```

3. **Test on target system**:
   ```bash
   ./scripts/test-compatibility.sh
   ```

## Benefits

- ✅ **Cross-version compatibility**: Works on Ubuntu 20.04, 22.04, 24.04
- ✅ **Reduced dependencies**: Fewer package dependencies
- ✅ **Easier deployment**: Self-contained binary
- ✅ **Automated fallback**: Build script handles different linking approaches

## Trade-offs

- ⚠️ **Larger binary size**: Static linking increases binary size
- ⚠️ **Build complexity**: Multiple linking strategies add complexity
- ⚠️ **Security updates**: Static libraries don't get automatic security updates

## Configuration Files

- **`.bazelrc`**: Contains static linking configurations
- **`scripts/build-deb.sh`**: Implements fallback linking strategy
- **`scripts/test-compatibility.sh`**: Tests compatibility across Ubuntu versions
