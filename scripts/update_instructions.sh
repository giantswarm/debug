#!/bin/bash

# Define the source file
SOURCE_FILE="system-prompt-gs-sre.md"

# Define destination files
DEST_CURSOR_RULE=".cursor/rules/giantswarm-sre-guidelines.mdc"
DEST_GITHUB_COPILOT=".github/copilot-instructions.md"

# Define the header for the Cursor rule file
CURSOR_RULE_HEADER="---
description: 
globs: 
alwaysApply: true
---"

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' not found."
    exit 1
fi

# Create destination directories if they don't exist
mkdir -p "$(dirname "$DEST_CURSOR_RULE")"
mkdir -p "$(dirname "$DEST_GITHUB_COPILOT")"

# Update the Cursor rule file with header and content
echo "Updating $DEST_CURSOR_RULE..."
echo "$CURSOR_RULE_HEADER" > "$DEST_CURSOR_RULE"
cat "$SOURCE_FILE" >> "$DEST_CURSOR_RULE"
echo "Updated $DEST_CURSOR_RULE"

# Update the GitHub Copilot instructions file (direct copy)
echo "Updating $DEST_GITHUB_COPILOT..."
cp "$SOURCE_FILE" "$DEST_GITHUB_COPILOT"
echo "Updated $DEST_GITHUB_COPILOT"

echo "Script finished." 