# Factory Knowledge — Proposal System

Date: 2026-03-12

---

## What This Is

A controlled mechanism that analyzes pipeline run results and generates candidate knowledge entries (proposals) for human review. Proposals are stored separately and never automatically committed to the main knowledge base.

---

## How Proposals Are Generated

**File**: `factory_knowledge/proposal_generator.py`
**Function**: `generate_proposals(run_id, user_task, template, bug_messages, cd_messages, refactor_messages)`

The generator scans agent output text from Bug Hunter, Creative Director, and Refactor passes using deterministic regex patterns. It looks for 5 signal types:

| Signal | Source | Trigger | Proposal type |
|---|---|---|---|
| Critical bugs | Bug Hunter | Severity: CRITICAL in output | failure_case |
| CD fail rating | Creative Director | Rating: fail | ux_insight |
| Emotional design gaps | Creative Director | Findings tagged [Emotion/Motivation/Retention] in conditional_pass or fail | ux_insight |
| File duplication | Refactor | Duplication/redundant files mentioned | failure_case |
| Lifecycle bugs | Bug Hunter | @MainActor missing, memory leaks, retain cycles, task cancellation | technical_pattern |

### Selection logic

- Each signal is checked independently
- Each signal can produce at most 1 proposal
- Total capped at MAX_PROPOSALS_PER_RUN = 3
- No LLM involved in proposal generation
- All extraction is regex-based on agent output text

---

## Where Proposals Are Stored

```
factory_knowledge/
├── knowledge.json          ← Main knowledge base (never auto-modified)
├── index.json              ← Meta-information
├── knowledge_reader.py     ← Reader for CD injection
├── proposal_generator.py   ← Proposal generation logic
└── proposals/
    ├── README.md
    └── proposal_<run_id>.json   ← One file per run
```

### Proposal file format

```json
{
  "run_id": "20260312_203754",
  "generated": "2026-03-12T21:07:09",
  "proposal_count": 2,
  "proposals": [
    {
      "title": "Bug pattern: Massive File Duplication",
      "type": "failure_case",
      "lesson": "Critical bug detected: ...",
      "evidence": "Bug Hunter flagged as CRITICAL in run 20260312_203754",
      "source_run": "20260312_203754",
      "source_project": "askfin",
      "confidence": "hypothesis",
      "tags": ["bug-pattern", "code-quality"],
      "status": "pending_review",
      "reason": "Recurring failure patterns should be captured..."
    }
  ]
}
```

---

## How Proposals Should Be Reviewed

### Manual review workflow

1. Check `factory_knowledge/proposals/` for new files
2. Read each proposal entry
3. For each proposal, decide:
   - **Promote**: Add to `knowledge.json` with a proper FK-NNN ID and update `index.json`
   - **Discard**: Delete the proposal file (the lesson was not reusable)
   - **Defer**: Keep the file for now, revisit after more runs provide evidence

### Review criteria

- Is this lesson reusable beyond this specific run?
- Is it concrete enough to act on?
- Does it overlap with an existing knowledge entry?
- Would it help the CD or future agents give better advice?

---

## Why Automatic Commits Are Dangerous

1. **Quality control**: Not every run produces genuine insights. Auto-committing would fill the knowledge base with noise.
2. **Context loss**: A regex-extracted proposal may miss nuance that a human reviewer catches immediately.
3. **Duplication risk**: The same pattern may be detected in 10 consecutive runs, creating 10 duplicate entries.
4. **Confidence inflation**: Auto-committed entries would all be hypothesis-level but might be treated as validated by injection logic.
5. **Irreversibility**: Once an entry influences CD reviews, removing it requires active curation. Prevention is cheaper than cleanup.

The proposal system explicitly separates detection from commitment to maintain knowledge quality.

---

## Where It Is Called

**File**: `main.py` (after analytics, before console summary)

```python
# Knowledge proposals (analyze run results, store separately for review)
try:
    _proposals = generate_proposals(
        run_id=run_id,
        user_task=user_task,
        template=template,
        bug_messages=bug_result_msgs,
        cd_messages=cd_result_msgs,
        refactor_messages=refactor_result_msgs,
    )
    _proposal_path = save_proposals(run_id, _proposals)
except Exception as _pe:
    print(f"Knowledge proposals: error ({_pe})")
```

### Error handling

The entire proposal block is wrapped in try/except. If proposal generation fails, the pipeline still completes normally. Proposals are a side-effect, not a critical path.

---

## Limitations

1. **Regex-based extraction**: Depends on agents producing consistently formatted output. Unusual formatting may cause missed signals.
2. **No cross-run deduplication**: The same pattern detected in multiple runs will generate duplicate proposals. Human review is needed to spot these.
3. **No semantic understanding**: The generator matches keywords, not meaning. A Bug Hunter mentioning "memory leak" in a negative context ("no memory leaks found") would still trigger a proposal.
4. **Only 3 agent sources**: Currently only analyzes Bug Hunter, CD, and Refactor output. Test Generator and Implementation pass output are not scanned.
5. **No proposal aging**: Old proposal files accumulate. Periodic cleanup is needed.

---

## Future Improvements

- Cross-run deduplication (check if a similar proposal already exists)
- Template-aware proposal filtering (different signals matter for screen vs. service)
- Proposal summary in console output or Control Center dashboard
- Semi-automatic promotion workflow (approve proposal → auto-add to knowledge.json)
