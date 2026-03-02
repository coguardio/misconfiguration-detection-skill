#!/bin/bash

# Package CoGuard skill for Claude
# This script creates a properly structured ZIP file for uploading to claude.ai

set -e

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ./package.sh"
    echo "Creates coguard.zip in the parent directory for upload to claude.ai"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="$PARENT_DIR/coguard"
ZIP_FILE="$PARENT_DIR/coguard.zip"

# Verify required files exist
REQUIRED_FILES=(SKILL.md README.md EXAMPLES.md CONTRIBUTING.md LICENSE)
for f in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
        echo "Error: Required file '$f' not found in $SCRIPT_DIR"
        exit 1
    fi
done

echo "Packaging CoGuard skill..."

# Clean up any existing temp directory or ZIP file
rm -rf "$TEMP_DIR" "$ZIP_FILE"

# Create temporary directory with correct name
mkdir -p "$TEMP_DIR"

# Copy required files
echo "Copying files..."
for f in "${REQUIRED_FILES[@]}"; do
    cp "$SCRIPT_DIR/$f" "$TEMP_DIR/"
done

# Create ZIP file
echo "Creating ZIP file..."
cd "$PARENT_DIR"
zip -r coguard.zip coguard/

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo "Package created: $ZIP_FILE ($(du -h "$ZIP_FILE" | cut -f1))"
echo ""
echo "Next steps:"
echo "1. Go to https://claude.ai"
echo "2. Navigate to Settings -> Skills"
echo "3. Click 'Upload Custom Skill'"
echo "4. Upload the file: $ZIP_FILE"
echo ""
echo "The skill will be available as /misconfiguration-detection in Claude Code."
