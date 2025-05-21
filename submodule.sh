#!/bin/bash

OUTPUT_FILE="submodule_hashes.txt"
true > "$OUTPUT_FILE"  # clear the output file

# Ensure .gitmodules exists
if [ ! -f .gitmodules ]; then
  echo ".gitmodules file not found."
  exit 1
fi

# Parse submodule paths and names
grep -E '^\[submodule' .gitmodules | while read -r line; do
  name=$(echo "$line" | sed -n 's/.*"\(.*\)".*/\1/p')
  path=$(git config -f .gitmodules --get "submodule.$name.path")

  if [ -d "$path" ]; then
    # Get the current commit hash of the submodule
    hash=$(git -C "$path" rev-parse HEAD 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo "$name=$hash" >> "$OUTPUT_FILE"
    else
      echo "$name: <error getting hash>" >> "$OUTPUT_FILE"
    fi
  else
    echo "$name: <path not found>" >> "$OUTPUT_FILE"
  fi
done

echo "Submodule hashes written to $OUTPUT_FILE"