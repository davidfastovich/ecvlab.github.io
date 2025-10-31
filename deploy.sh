#!/bin/bash
set -e  # exit on any error

TARGET_BRANCH="gh-pages"
BUILD_DIR="target/dx/ecvlab-github-io/release/web/public"
CNAME="ecvlab.github.io"

# Build the Dioxus web bundle
dx bundle

# Ensure build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: build directory '$BUILD_DIR' not found."
    exit 1
fi

# Set up a clean gh-pages branch in a temporary directory
git clone --depth 1 --branch $TARGET_BRANCH https://github.com/$GITHUB_REPOSITORY.git gh-pages || \
    git clone --depth 1 https://github.com/$GITHUB_REPOSITORY.git gh-pages && \
    (cd gh-pages && git checkout --orphan $TARGET_BRANCH)

# Clear existing content
rm -rf gh-pages/*

# Copy new site files
cp -r $BUILD_DIR/* gh-pages/
echo "$CNAME" > gh-pages/CNAME

# Add a fallback 404 page for GitHub Pages
cp gh-pages/index.html gh-pages/404.html

# Commit and push changes
cd gh-pages
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add --all
git commit -m "Deploy website"
git push --force origin $TARGET_BRANCH
