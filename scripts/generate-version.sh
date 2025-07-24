#!/usr/bin/env bash
set -euo pipefail

# Script to generate version information for perf_to_profile
# Usage: ./scripts/generate-version.sh [output_file]

OUTPUT_FILE="${1:-src/version.h}"

# Try to get version from git
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get the latest tag
    if GIT_TAG=$(git describe --tags --exact-match 2>/dev/null); then
        # We're on a tagged commit
        VERSION="$GIT_TAG"
    elif GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null); then
        # Get commit count since last tag and short hash
        COMMIT_COUNT=$(git rev-list --count "${GIT_TAG}..HEAD")
        SHORT_HASH=$(git rev-parse --short HEAD)
        VERSION="${GIT_TAG}-${COMMIT_COUNT}-g${SHORT_HASH}"
    else
        # No tags found, use commit hash
        SHORT_HASH=$(git rev-parse --short HEAD)
        VERSION="git-${SHORT_HASH}"
    fi
    
    # Add dirty suffix if working directory is not clean
    if ! git diff-index --quiet HEAD --; then
        VERSION="${VERSION}-dirty"
    fi
else
    # Not a git repository, use default
    VERSION="development"
fi

echo "Generating version: $VERSION"

# Create the version header file
cat > "$OUTPUT_FILE" << EOF
/*
 * Copyright (c) 2024, Google Inc.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#ifndef PERFTOOLS_VERSION_H_
#define PERFTOOLS_VERSION_H_

// Version information for perf_to_profile
// Generated automatically by scripts/generate-version.sh

#define PERF_TO_PROFILE_VERSION "$VERSION"

#endif  // PERFTOOLS_VERSION_H_
EOF

echo "Version header generated: $OUTPUT_FILE"
