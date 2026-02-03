# Lessons from Recent Implementations

> Field experience that shaped the V2 semantic core approach.

## Status

🚧 **In Development** – This document is a placeholder.

---

## Key Observations

When attempting to apply the original DIASCA model in Africa:

- The team only needed:
  - Plots
  - Farmers
  - Buyers
  - Claims
  - Basic transactions
- Many tables were never used
- Confusion arose around which entities were mandatory
- Implementation time increased due to model complexity

---

## What Was Really Needed

1. A plot registry
2. A simple way to relate actors
3. A way to attach claims and evidence

---

## Implications for V2

This experience heavily informs the Semantic Core:

| V1 Complexity | V2 Simplification |
|---------------|-------------------|
| 20+ entity types | 6 core concepts |
| Mandatory fields everywhere | Flexible, profile-based |
| Coupled to specific tools | Tool-agnostic |
| All-or-nothing adoption | Incremental adoption |

---

## Next Steps

- [ ] Document additional implementation case studies
- [ ] Capture specific pain points with V1
- [ ] Validate V2 concepts against real use cases
