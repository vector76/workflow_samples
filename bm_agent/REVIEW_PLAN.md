---
allowed_transitions:
  - { tag: call, target: PLAN_DID_FIX, return: PLAN_AGAIN_CHOICE }
---
Re-read the plan file `bm_plan.md` and the feature definition document 
`bm_feature.md` carefully — approach the plan as if you are seeing it for the 
first time.

(We are reviewing the plan, not the feature definition, which we are taking as 
given.)

**Scope reminder: this is a planning workflow, not an implementation workflow.**
The goal is a complete, well-structured strategic plan. Do not add code. Do not
begin designing the actual implementation in your head and transcribing it into
the document. If you find yourself reaching for specific function signatures,
class hierarchies, or implementation detail, step back — those decisions belong
to the implementer.

Check for the following and fix any issues directly in the plan file:

- **Missing steps**: Is any work needed before a later step can proceed, but
  absent from the plan? Add it.
- **Dependency violations**: Does any step assume something a prior step has
  not yet delivered? Reorder or add clarifying steps as needed.
- **Coverage gaps**: Does the plan address everything described in the feature?
  Compare the plan directly against the feature definition document and add 
  anything that was overlooked.
- **Over-specification**: Are there code snippets, specific names, or low-level
  implementation decisions that belong in the code, not in a high-level plan?
  Remove or elevate them to strategy.
- **Under-specification**: Are any steps too vague to guide an implementer?
  "Integrate with the database" is evasive — "add a persistence layer for X and
  Y following the existing repository pattern" is strategic. Raise the level of
  clarity without descending into implementation detail.
- **Strategic clarity**: Does each section clearly convey what must be
  accomplished and why? Would a developer know where to start and what success
  looks like at each phase?

Fix any meaningful issues directly in the file. Leave things alone if they are
already correct or merely a matter of preference.

STOP after reviewing and fixing the plan. We are not implementing — do not start
writing code or detailed design artifacts. That is not part of this workflow.
