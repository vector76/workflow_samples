---
allowed_transitions:
  - { tag: goto, target: 3_REVIEW_FIX.md }
---
Re-read the feature document (you have the filename from earlier in this
conversation).

Then explore the parts of the codebase relevant to this feature. The codebase
may be large — use grep, glob, and targeted reads to find what is pertinent.
Focus on:

- Files, modules, and patterns directly related to the feature
- Existing architecture and conventions that the implementation must follow
- Integration points: what existing code will need to be called or modified
- Any existing partial work, related utilities, or test patterns to build on

**Scope reminder: your job is to plan, not to implement.** The codebase research
informs strategic decisions — where things live, what patterns exist, what will
need to change — but that knowledge must not become code in the plan. The
implementer will read the same codebase themselves. Keep every statement in the
plan at the level of strategy and intent.

Based on the feature document and your research, write a detailed, high-level
implementation plan to the plan file whose name you stated in step 1 of this
workflow.

The plan must be:

- **Thorough**: every meaningful aspect of the feature should be addressed —
  don't skip pieces just because they seem obvious
- **Strategic**: describe *what* must be accomplished and *why*, not the code
  itself. The implementer is capable and will write their own code.
- **Sequentially ordered**: steps should be sequenced so that each builds on
  what came before — no step should depend on work that has not yet been done
- **Dependency-explicit**: where a step depends on another, say so clearly so
  the implementer knows what order to work in and what each phase requires
- **Implementation-free**: do not include code snippets, specific function
  signatures, class names, or variable names. Describe the approach at the
  level of strategy: "add a service that does X using the existing Y pattern"
  rather than "create class Foo with method bar(baz)"

Structure the plan with clearly named phases or sections. Where relevant, each
section should address: the goal of the phase, what strategic work must be done,
what prior phases must have delivered, and what this phase delivers for
subsequent phases. Adapt this structure to the feature — a simple phase may
need less scaffolding than a complex one.

STOP after writing the plan file. Do not begin reviewing or refining the plan
yet — that happens in a later step.

After writing the file, respond with exactly:
<goto>3_REVIEW_FIX.md</goto>
