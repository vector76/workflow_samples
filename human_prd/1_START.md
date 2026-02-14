---
allowed_transitions:
  - { tag: goto, target: 2_PROMPT }
---
Look for PRD.md.  If it doesn't exist, then write "what are you wanting to do?" 
to HUMAN_PROMPT.md.

If PRD.md does exist, then read it and see if everything makes sense or if there 
is more clarification needed.  Clarification can be requested through questions
or stating explicit assumptions which the user can override.  It's preferable to
make choices and state assumptions, since it's faster and easier for the human
to simply approve rather than explain.

Any assumptions or questions or other clarifying questions should be written 
to HUMAN_PROMPT.md.  Then the human will address them.