#!/bin/bash

# Look for a fullspec_<name>.md file where there is no plan_<name>.md or beads_<name>.md

eligible=""
for fullspec in fullspec_*.md; do
    [ -f "$fullspec" ] || continue
    name="${fullspec#fullspec_}"
    name="${name%.md}"
    if [ ! -f "plan_${name}.md" ] && [ ! -f "beads_${name}.md" ]; then
        eligible="$fullspec"
        break
    fi
done

if [ -z "$eligible" ]; then
    echo "<result>DONE</result>"
else
    echo "<function return=\"DONE\" input=\"$eligible\">DRAFT_PLAN</function>"
fi
