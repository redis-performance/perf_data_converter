#!/bin/bash

set -euo pipefail

# Script to set up the gh-pages branch for APT repository
# This should be run once to initialize the repository structure

echo "Setting up gh-pages branch for APT repository..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if gh-pages branch already exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "Warning: gh-pages branch already exists"
    read -p "Do you want to recreate it? This will delete the existing branch. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
    git branch -D gh-pages
fi

# Create orphan gh-pages branch
echo "Creating orphan gh-pages branch..."
git checkout --orphan gh-pages

# Remove all files from the working directory
echo "Cleaning working directory..."
git rm -rf . 2>/dev/null || true

# Create required directories
echo "Creating APT repository structure..."
mkdir -p conf pool/main/p/perf-data-converter dists

# Create .nojekyll file to disable Jekyll processing
touch .nojekyll

# Create initial reprepro configuration
cat > conf/distributions << 'EOF'
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
EOF

# Create a README for the gh-pages branch
cat > README.md << 'EOF'
# APT Repository for perf_data_converter

This branch contains the APT repository structure for distributing perf_data_converter packages.

## Structure

- `conf/`: Repository configuration files
- `pool/`: Package pool containing .deb files
- `dists/`: Distribution metadata
- `README.md`: This file

## Usage

This repository is automatically managed by GitHub Actions. Do not manually edit files unless you know what you're doing.

For installation instructions, see the main repository README.
EOF

# Add and commit the initial structure
echo "Committing initial structure..."
git add .
git commit -m "Initial APT repository structure"

# Push the branch
echo "Pushing gh-pages branch..."
git push -u origin gh-pages

# Return to original branch
echo "Returning to $CURRENT_BRANCH branch..."
git checkout "$CURRENT_BRANCH"

echo ""
echo "✅ gh-pages branch setup complete!"
echo ""
echo "Next steps:"
echo "1. Go to your repository settings on GitHub"
echo "2. Navigate to Pages section"
echo "3. Set source to 'Deploy from a branch'"
echo "4. Select 'gh-pages' branch and '/ (root)' folder"
echo "5. Save the configuration"
echo ""
echo "Your APT repository will be available at:"
echo "https://redis-performance.github.io/perf_data_converter/"
