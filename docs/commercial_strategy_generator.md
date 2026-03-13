# Commercial Strategy Generator

Date: 2026-03-13

---

## Purpose

Generates structured commercial strategy documents (Strategy Books) for factory projects. Each book provides actionable positioning, monetization, distribution, and marketing guidance.

This is a planning tool — it does not automate marketing or deploy campaigns. The strategy books serve as reference documents for future marketing agents, web builders, and growth systems.

---

## How It Works

1. Collects project context from:
   - Factory project registry (`factory/projects/project_registry.json`)
   - Premium positioning documents (`docs/<project>_premium_reframing.md`)
   - Compliance decisions (`compliance/`)
   - Architecture docs (`docs/architecture.md`)
   - Factory knowledge entries (product-relevant only)

2. Sends structured prompt to Claude Sonnet with all context

3. Receives a formatted Strategy Book covering 7 sections

4. Saves to `strategy_books/<project>_strategy.md`

---

## Output Structure

Each Strategy Book contains:

| Section | Content |
|---|---|
| 1. Product Positioning | Problem, audience, differentiator, positioning statement |
| 2. Monetization Strategy | Viable models with pros/risks, recommended approach |
| 3. Distribution Strategy | Channels ranked by effort-to-reach ratio |
| 4. Marketing Angles | 3-5 storytelling angles with example headlines |
| 5. Supporting Assets | Must-have and nice-to-have assets with effort estimates |
| 6. Risks and Constraints | Legal, competition, resources, content dependencies |
| 7. Recommended First Steps | Ordered action list |

---

## Usage

### CLI
```bash
# Generate strategy book for a project
python -m factory_strategy.commercial_strategy_generator askfin AskFin

# With only project ID (name defaults to ID)
python -m factory_strategy.commercial_strategy_generator askfin
```

### Python
```python
from factory_strategy.commercial_strategy_generator import generate_and_save

content, path = generate_and_save("askfin", "AskFin")
print(f"Saved to: {path}")
```

---

## Implementation

### Files
- `factory_strategy/__init__.py` — package init
- `factory_strategy/commercial_strategy_generator.py` — generator module

### Key functions
- `generate_strategy_book(project_id, project_name, extra_context)` — generates markdown
- `save_strategy_book(project_id, content)` — saves to strategy_books/
- `generate_and_save(project_id, project_name, extra_context)` — convenience wrapper

### Model
Uses Claude Sonnet (`claude-sonnet-4-6`) directly via Anthropic API. No AutoGen agents involved.

### Token budget
- Input: ~3-6k tokens (context + prompt)
- Output: max 4096 tokens (~12-15k chars)
- Cost per generation: ~$0.08-0.12

---

## Future Integration

The strategy books are designed to later feed into:

1. **Marketing Agent** — reads strategy book to generate campaign content
2. **Web Builder Agent** — uses positioning and assets section for landing pages
3. **Growth System** — uses distribution strategy for channel prioritization
4. **Content Calendar** — uses marketing angles for social media planning

These integrations are not yet built. The strategy book is currently a standalone planning document.

---

## Limitations

1. **LLM-generated**: Content requires human review before acting on it
2. **Single generation**: No iterative refinement or follow-up questions
3. **Context dependent**: Quality depends on available project documentation
4. **No market data**: Does not access real market data, competitor APIs, or pricing databases
5. **Output truncation**: At 4096 max tokens, very detailed strategies may be cut short
