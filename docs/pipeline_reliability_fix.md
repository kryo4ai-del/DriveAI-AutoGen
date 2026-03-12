# Pipeline Reliability Fix — Context Overflow Mitigation

Date: 2026-03-12

---

## Root Cause

The pipeline uses a single `SelectorGroupChat` instance across all passes (Implementation, Bug Hunter, Creative Director, Refactor, Test Generation, Fix Execution). AutoGen's `SelectorGroupChat` accumulates ALL messages internally across `team.run()` calls:

1. **Manager `_message_thread`**: All messages from all passes, used by the Selector model to pick the next speaker.
2. **Agent `_message_buffer`**: Each agent receives ALL accumulated messages when selected to speak.
3. **Agent `_model_context`**: Each `AssistantAgent` adds all received messages to its own unbounded LLM context.

After the Implementation Pass generates 25-35 files of Swift code (~10 agent turns), the accumulated context exceeds 50,000 tokens. The next pass (Bug Hunter) sends this entire context to Haiku, which has a 50k input tokens/minute rate limit. A single request exceeds the limit.

### Key metrics
- Implementation Pass output: 25-35 Swift files, ~3500-4500 lines of log
- Estimated token count: 60-80k tokens (far above Haiku's 50k/min limit)
- Failure point: Always at Bug Hunter Pass (first pass after Implementation)
- Error: `anthropic.RateLimitError: 429 — 50,000 input tokens per minute`

---

## Chosen Mitigation

**`await team.reset()` between Implementation Pass and Review Passes.**

AutoGen provides `team.reset()` as a public API that:
- Clears `_message_thread` on the group chat manager
- Clears `_model_context` on the selector (speaker selection)
- Clears `_message_buffer` on each agent container
- Calls `agent.on_reset()` which clears each agent's `_model_context`
- Resets the termination condition counter

This is a single line of code inserted after Pass 1 (Implementation) and before Pass 2 (Bug Hunter). Each review pass starts with a clean context and only sees its own task description + agent responses within that pass.

### Code change (main.py)

```python
# After Implementation Pass, before review passes:
await team.reset()
```

---

## Alternatives Considered

| Option | Description | Why not chosen |
|---|---|---|
| **BufferedChatCompletionContext** | Limit selector context to last N messages | Only limits selector, not agent contexts. Agents still accumulate full history. |
| **Separate teams per pass** | Create fresh `SelectorGroupChat` for each pass | Higher complexity, more API calls for team setup, changes orchestration significantly. |
| **Implementation output summarization** | Compress impl output before review passes | Requires a summarization LLM call (cost + latency), adds complexity. |
| **Retry with exponential backoff** | Catch 429 errors and retry | Doesn't fix the root cause — the request is inherently too large. Retrying the same >50k request would fail every time within the same minute. |
| **Switch selector model** | Use a model with higher rate limits | Avoids the symptom but doesn't fix context growth. Would fail again with larger implementations. |

---

## Why This Is the Safest Fix

1. **Public API**: `team.reset()` is documented AutoGen behavior, not a private attribute hack.
2. **One line**: Minimal code change, easy to review and revert.
3. **No behavior change for agents**: Agents still receive the same task descriptions. The task prompt already explains what to review.
4. **No model routing changes**: Same models, same agents, same pipeline flow.
5. **Deterministic**: No randomness, no retry logic, no timing dependencies.

---

## Known Limitations

1. **Review passes lose implementation detail context**: Bug Hunter, Refactor, and Test Generator no longer see the exact generated code from the Implementation Pass. They work from the task description alone. This may reduce review specificity.

2. **Selector loses conversation continuity**: The selector can't reference "what was discussed earlier" to pick better agents. In practice this doesn't matter because each pass task description explicitly states what needs to happen.

3. **Future enhancement**: A compact implementation summary (file list + key patterns) could be prepended to review task descriptions. This would restore some context without the full token load.

---

## How to Validate

```bash
# Standard screen test — should complete all passes without rate limit errors
python main.py --template screen --name TrainingMode --profile dev --approval auto

# Verify in logs:
# 1. Implementation Pass completes
# 2. Bug Hunter Pass completes (no 429 error)
# 3. Creative Director Pass completes (for screen/feature templates)
# 4. Refactor Pass completes
# 5. Test Generation Pass completes
```

### Success criteria
- Pipeline completes all passes without rate limit errors
- Log file shows output from all passes
- Console summary shows message counts for all passes

### Partial success
- If review passes complete but give less specific feedback than before, that's expected. The trade-off (working pipeline vs. detailed reviews) is acceptable for Phase 1.
