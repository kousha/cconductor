#!/bin/bash
# install-claude.sh — Install Conductor commands for Claude Code
#
# Usage: /path/to/conductor/install-claude.sh [target-dir]
#   target-dir: The project directory to install into (defaults to current directory)
#
# This script:
#   1. Symlinks Claude Code slash commands into .claude/commands/
#   2. Appends Conductor context to the project's CLAUDE.md

set -euo pipefail

# Resolve the absolute path to the conductor repo (where this script lives)
CONDUCTOR_PATH="$(cd "$(dirname "$0")" && pwd)"

# Target project directory (default: current directory)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

COMMANDS_DIR="$TARGET_DIR/.claude/commands"
CLAUDE_MD="$TARGET_DIR/CLAUDE.md"

echo "Conductor — Claude Code Plugin Installer"
echo "========================================="
echo ""
echo "Conductor path: $CONDUCTOR_PATH"
echo "Target project: $TARGET_DIR"
echo ""

# Step 1: Create .claude/commands/ directory
mkdir -p "$COMMANDS_DIR"

# Step 2: Symlink each command file
echo "Installing commands..."
COMMAND_COUNT=0
for cmd_file in "$CONDUCTOR_PATH/claude/commands/"*.md; do
    filename="$(basename "$cmd_file")"
    ln -sf "$cmd_file" "$COMMANDS_DIR/$filename"
    echo "  -> $filename"
    COMMAND_COUNT=$((COMMAND_COUNT + 1))
done
echo ""

# Step 3: Append Conductor context to CLAUDE.md
MARKER="# Conductor Context"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
    echo "CLAUDE.md already contains Conductor context — skipping."
else
    echo "Updating CLAUDE.md..."

    # Read the CLAUDE.md template from conductor repo
    CONDUCTOR_CLAUDE_CONTENT="$(cat "$CONDUCTOR_PATH/CLAUDE.md")"

    # Replace CONDUCTOR_PATH placeholder in the content
    CONDUCTOR_CLAUDE_CONTENT="${CONDUCTOR_CLAUDE_CONTENT//CONDUCTOR_PATH/$CONDUCTOR_PATH}"

    if [ -f "$CLAUDE_MD" ]; then
        # Append to existing CLAUDE.md
        printf "\n\n%s\n" "$CONDUCTOR_CLAUDE_CONTENT" >> "$CLAUDE_MD"
        echo "  -> Appended Conductor context to existing CLAUDE.md"
    else
        # Create new CLAUDE.md
        printf "%s\n" "$CONDUCTOR_CLAUDE_CONTENT" > "$CLAUDE_MD"
        echo "  -> Created CLAUDE.md with Conductor context"
    fi
fi

# Step 4: Ensure CONDUCTOR_PATH is set for template resolution in setup command
# Replace the placeholder in the symlinked setup command's context
echo ""
echo "Setting CONDUCTOR_PATH for template resolution..."
echo "  -> Templates will be resolved from: $CONDUCTOR_PATH/templates/"

echo ""
echo "========================================="
echo "Installation complete!"
echo ""
echo "  $COMMAND_COUNT commands installed to $COMMANDS_DIR/"
echo "  CLAUDE.md updated with Conductor context"
echo ""
echo "Available commands:"
echo "  /conductor:setup      — Set up a new or existing project"
echo "  /conductor:newTrack   — Start a new feature or bug track"
echo "  /conductor:implement  — Execute tasks from the track plan"
echo "  /conductor:status     — View project progress"
echo "  /conductor:review     — Review completed work"
echo "  /conductor:revert     — Revert a track, phase, or task"
echo ""
echo "Get started by opening Claude Code in your project and running:"
echo "  /conductor:setup"
