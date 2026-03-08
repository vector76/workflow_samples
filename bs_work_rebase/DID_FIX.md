---
allowed_transitions:
  - { tag: result, payload: "YES" }
  - { tag: result, payload: "NO" }
---
Look at the review that just completed. Did it result in any actual code changes
or fixes?

- If anything was changed or fixed (even something minor) respond with `<result>YES</result>`
- If nothing was changed (the review found nothing worth fixing, or only made
  observations without modifying anything) respond with  `<result>NO</result>`
