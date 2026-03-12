# Factory Knowledge

Cross-project knowledge base for the AI App Factory.

## Files

| File | Purpose |
|---|---|
| `knowledge.json` | All knowledge entries (patterns, insights, failures) |
| `index.json` | Meta-information: counts, last update, projects |

## Schema

See `docs/factory_learning_schema.md` for the full schema definition.

## Quick Reference

Entry types: `ux_insight`, `design_insight`, `technical_pattern`, `motivational_mechanic`, `failure_case`, `success_pattern`

Confidence levels: `hypothesis` -> `validated` -> `proven` (or `disproven`)

Entry IDs: `FK-NNN` (sequential)

## Rules

- One entry per insight -- no duplicates
- Title max 80 characters
- Description max 3 sentences
- Always include `applicable_to` for cross-project reuse
- New entries start as `hypothesis`
- Promote to `validated` after positive result in source project
- Promote to `proven` after positive result in second project
- Never delete `disproven` entries -- they serve as warnings
