#!/bin/bash
set -e
# Find an underspec file that doesn't yet have a corresponding in_progress or fullspec.

for underspec in underspec_*.md; do
    [ -f "$underspec" ] || continue
    name="${underspec#underspec_}"
    in_progress="in_progress_$name"
    fullspec="fullspec_$name"
    if [ ! -f "$in_progress" ] && [ ! -f "$fullspec" ]; then
        cp "$underspec" "$in_progress"
        echo "<function return=\"DONE\" input=\"$in_progress\">ANALYZE</function>"
        exit 0
    fi
done

# No unprocessed underspec files found.
echo "<result>DONE</result>"
