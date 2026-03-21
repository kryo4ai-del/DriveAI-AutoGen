# TheBrain — Model & Provider Intelligence

Central model selection and optimization for the DriveAI Swarm Factory.

## Architecture

TheBrain is the boss. No agent in any department chooses its own model.
Every LLM call goes through TheBrain's selection.

### Components

| Module | Purpose |
|---|---|
| model_registry.py | Database of all models, prices, limits |
| models_registry.json | Model data (9 models, 4 providers) |
| provider_router.py | Multi-provider API via LiteLLM |
| auto_splitter.py | Token limit management, auto-split |
| benchmark_runner.py | Controlled experiments per agent |
| chain_optimizer.py | Pipeline chain cost optimization |
| chain_tracker.py | Per-run data collection |
| price_monitor.py | Provider health, new models |

### Selection Flow

```
Agent requests model
  -> Check ChainProfile (optimized selection)
  -> Fallback: tier-based selection from registry
  -> ProviderRouter routes API call via LiteLLM
  -> AutoSplitter handles token limits
  -> ChainTracker records results
```

### CLI Commands

```bash
python main.py --brain-models              # All models with prices
python main.py --brain-models --tier low    # Filter by tier
python main.py --brain-chain android        # Chain profile
python main.py --brain-benchmark            # Run benchmarks (all agents)
python main.py --brain-benchmark --agent X  # Benchmark specific agent
python main.py --brain-optimize             # Optimize chain
python main.py --brain-health               # Provider health check
python main.py --brain-costs                # Cost overview
python main.py --brain-summary              # Quick summary
python main.py --brain-stats                # Detailed stats
```

### Cost Impact

| Pipeline Mode | Cost/Run | vs Legacy |
|---|---|---|
| Legacy (SelectorGroupChat all) | $63 | baseline |
| Hybrid (single-call reviews) | $0.10 | 630x cheaper |
| Optimized (chain optimizer) | $0.021 | 3000x cheaper |

### Benchmark Results (2026-03-21)

| Agent | Best Model | Quality | Cost | Value |
|---|---|---|---|---|
| Bug Hunter | Mistral Small | 0.90 | $0.0002 | 4934 |
| Creative Director | Mistral Small | 0.90 | $0.0001 | 6221 |
| Refactor | Mistral Small | 1.00 | $0.0001 | 17361 |
| Test Generator | Mistral Small | 0.90 | $0.0001 | 13146 |
