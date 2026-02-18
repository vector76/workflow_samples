#!/bin/bash
PROMPT_FILE="HUMAN_PROMPT.md"
NEXT_STATE="4_RESPONSE.md"
FINAL_STATE="5_CLEANUP"

echo -e "\n\n<!-- COMPOSING -->" >> "$PROMPT_FILE"

while grep -q '<!-- COMPOSING -->' "$PROMPT_FILE" 2>/dev/null; do
  inotifywait -qq -e modify "$PROMPT_FILE" 2>/dev/null || sleep 1
done

if grep -q '[^[:space:]]' "$PROMPT_FILE" 2>/dev/null; then
  echo "<goto>$NEXT_STATE</goto>"
else
  echo "<goto>$FINAL_STATE</goto>"
fi
