#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$REPO_ROOT/templates/notes-template.md"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: template not found at $TEMPLATE"
  exit 1
fi

YES=false
for arg in "$@"; do
  [[ "$arg" == "--yes" ]] && YES=true
done

# Find all lab folders matching NN-* pattern
mapfile -t LAB_DIRS < <(find "$REPO_ROOT" -maxdepth 1 -type d -name '[0-9][0-9]*' | sort)

if [[ ${#LAB_DIRS[@]} -eq 0 ]]; then
  echo "No lab folders found matching NN-* pattern."
  exit 0
fi

echo "This will reset notes.md in the following lab folders:"
for dir in "${LAB_DIRS[@]}"; do
  echo "  $(basename "$dir")"
done
echo ""

if [[ "$YES" != true ]]; then
  read -r -p "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

for dir in "${LAB_DIRS[@]}"; do
  lab_name="$(basename "$dir")"
  notes_file="$dir/notes.md"

  # Derive a human-readable title from the folder name: 01-pods -> 01 Pods
  title=$(echo "$lab_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

  echo "Resetting: $lab_name/notes.md"
  sed "s/<LAB_TITLE>/$title/" "$TEMPLATE" > "$notes_file"
done

echo ""
echo "Done. All notes.md files reset to blank template."
