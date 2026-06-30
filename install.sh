#!/bin/bash
# install.sh — Standard installer for sol-migration-skill

set -e

SKILL_DIR="${HOME}/.claude/skills"
SKILL_NAME="sol-migration-skill"

echo "Installing ${SKILL_NAME}..."

# Create directories if they don't exist
mkdir -p "${SKILL_DIR}/${SKILL_NAME}"

# Copy skill modules
cp -r skill "${SKILL_DIR}/${SKILL_NAME}/"

# Copy agents if present
if [ -d "agents" ]; then
  cp -r agents "${SKILL_DIR}/${SKILL_NAME}/"
fi

# Copy commands if present
if [ -d "commands" ]; then
  cp -r commands "${SKILL_DIR}/${SKILL_NAME}/"
fi

# Copy rules if present
if [ -d "rules" ]; then
  cp -r rules "${SKILL_DIR}/${SKILL_NAME}/"
fi

# Copy CLAUDE.md to ~/.claude if it doesn't exist there yet
if [ ! -f "${HOME}/.claude/CLAUDE.md" ]; then
  cp CLAUDE.md "${HOME}/.claude/CLAUDE.md"
  echo "✓ Copied CLAUDE.md to ~/.claude/"
else
  echo "⚠  CLAUDE.md already exists at ~/.claude/ — skipping."
  echo "   Merge manually if needed: diff CLAUDE.md ~/.claude/CLAUDE.md"
fi

echo "✓ ${SKILL_NAME} installed to ${SKILL_DIR}/${SKILL_NAME}"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to activate the skill."
echo "  2. Optional: install Context7 MCP for live doc fetching."
echo "     See https://context7.com for setup instructions."
echo "  3. Try it: open any project in Claude Code and run /assess-migration"