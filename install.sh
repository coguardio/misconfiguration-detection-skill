#!/bin/bash

# Install the CoGuard Misconfiguration Detection skill for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/coguardio/misconfiguration-detection-skill/master/install.sh | bash

set -e

SKILL_DIR="$HOME/.claude/skills/misconfiguration-detection"
ZIP_URL="https://github.com/coguardio/misconfiguration-detection-skill/releases/latest/download/misconfiguration-detection.zip"

echo "Installing CoGuard Misconfiguration Detection skill..."

# Check for required tools
for cmd in curl unzip; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed."
        exit 1
    fi
done

# Download and extract
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "$ZIP_URL" -o "$TMPDIR/skill.zip"
unzip -qo "$TMPDIR/skill.zip" -d "$TMPDIR"

# Install into the skills directory (clean first so stale files don't linger)
rm -rf "$SKILL_DIR"
mkdir -p "$SKILL_DIR"
cp -r "$TMPDIR/misconfiguration-detection/"* "$SKILL_DIR/"

# Record install date so the skill doesn't check for updates right away
date +%Y-%m-%d > "$HOME/.claude/.coguard-skill-version-check"

echo ""
echo "Installed to $SKILL_DIR"
echo ""
echo "Restart Claude Code and type /misconfiguration-detection to use it."
