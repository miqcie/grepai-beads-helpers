#!/bin/bash

# index-all-projects.sh - Initialize grepai for all projects
# Usage: ~/scripts/index-all-projects.sh

set -e

GREPAI="$HOME/go/bin/grepai"
TOTAL=0
INDEXED=0
SKIPPED=0

echo "🔍 Indexing all projects with grepai..."
echo ""

# Function to index a directory
index_dir() {
  local dir="$1"
  TOTAL=$((TOTAL + 1))

  echo "[$TOTAL] $(basename "$dir")"

  # Skip if already indexed
  if [ -d "$dir/.grepai" ]; then
    echo "    ✓ Already indexed, skipping"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  # Initialize with defaults (Ollama + GOB storage)
  cd "$dir" && "$GREPAI" init --yes --provider ollama --backend gob > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "    ✓ Initialized"
    INDEXED=$((INDEXED + 1))
  else
    echo "    ✗ Failed"
  fi
}

# Index GitHub repos
if [ -d ~/GitHub ]; then
  echo "📁 ~/GitHub/"
  for dir in ~/GitHub/*/; do
    [ -d "$dir" ] && index_dir "$dir"
  done
  echo ""
fi

# Index projects
if [ -d ~/projects ]; then
  echo "📁 ~/projects/"
  for dir in ~/projects/*/; do
    [ -d "$dir" ] && index_dir "$dir"
  done
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Complete"
echo "  Total:   $TOTAL projects"
echo "  Indexed: $INDEXED new"
echo "  Skipped: $SKIPPED already indexed"
echo ""
echo "💡 Tip: Run 'grepai watch --background' in any project to keep index updated"
