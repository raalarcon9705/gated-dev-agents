#!/usr/bin/env bash
# Installs the agents and skills as plain files (no plugin), with unprefixed names.
# Usage: ./install.sh [--project <dir>] [--uninstall]
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) DEST="$(cd "${2:?--project needs a directory}" && pwd)/.claude"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) sed -n 2,3p "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

AGENTS=$(cd "$SRC/agents" && ls *.md)
SKILLS=$(cd "$SRC/skills" && ls)

if [ "$UNINSTALL" = 1 ]; then
  for a in $AGENTS; do rm -f "$DEST/agents/$a"; done
  for s in $SKILLS; do rm -rf "$DEST/skills/$s"; done
  echo "Removed from $DEST"
  exit 0
fi

mkdir -p "$DEST/agents" "$DEST/skills"
# Plugin installs namespace everything as gated-dev:<name>; plain files use bare names.
for a in $AGENTS; do
  [ -e "$DEST/agents/$a" ] && echo "Overwriting $DEST/agents/$a"
  sed 's/gated-dev://g' "$SRC/agents/$a" > "$DEST/agents/$a"
done
for s in $SKILLS; do
  [ -e "$DEST/skills/$s" ] && echo "Overwriting $DEST/skills/$s"
  rm -rf "$DEST/skills/$s"
  mkdir -p "$DEST/skills/$s"
  for f in "$SRC/skills/$s"/*; do
    sed 's/gated-dev://g' "$f" > "$DEST/skills/$s/$(basename "$f")"
  done
done

echo "Installed $(echo $AGENTS | wc -w | tr -d ' ') agents and $(echo $SKILLS | wc -w | tr -d ' ') skills into $DEST"
echo "Restart Claude Code to load them."
