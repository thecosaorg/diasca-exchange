# Design Principles

> Guiding principles for DIASCA data model design.

## Status

🚧 **In Development** – This document is a placeholder.

---

## Core Principles

### 1. Small Core, Many Profiles

> Define the minimum shared vocabulary, then extend via exchange profiles.

- The semantic core has only 6 concepts
- Exchange profiles add use-case-specific structure
- No profile can break the core

### 2. Tool-Agnostic

> Data exchange standards, not software.

- DIASCA defines data structures, not applications
- Any tool can implement DIASCA
- No vendor lock-in

### 3. Implementation-Friendly

> Easy to understand, easy to implement.

- Clear documentation with examples
- SQL, DBML, JSON schemas provided
- Incremental adoption path

### 4. Field-Proven

> Shaped by real implementation experience.

- Lessons from EUDR implementations
- Validated with NGOs and governments
- Practical over theoretical

### 5. Easy to Explain Visually

> If you can't diagram it simply, it's too complex.

- 6 concepts fit on one slide
- Relationships are intuitive
- Non-technical stakeholders can understand

---

## Anti-Patterns to Avoid

- ❌ Trying to model everything upfront
- ❌ Coupling data collection tools with data exchange
- ❌ Requiring all fields for all use cases
- ❌ Creating new apps when standards would suffice

---

## Next Steps

- [ ] Add examples for each principle
- [ ] Document decision rationale
- [ ] Create visual principle cards
