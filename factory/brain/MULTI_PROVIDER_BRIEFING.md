# TheBrain Multi-Provider Briefing

> Für alle Agents/Pipelines die bisher direkte Anthropic-Calls machen.
> Stand: 2026-03-21

## TL;DR

Die Factory hat jetzt 4 LLM-Provider mit 9 Modellen. Statt direkte Anthropic-Calls zu machen, nutze `get_router()` — das routet automatisch zum günstigsten Modell.

**Kostenvergleich:**
- Haiku direkt: $0.004/1k output tokens
- Mistral Small via TheBrain: $0.0003/1k output tokens (13x günstiger)
- Gemini Flash: $0.0006/1k, aber 1M Context + 65k Output

## Schnellstart

### Einfacher API-Call (ersetzt `anthropic.Anthropic().messages.create()`):

```python
from factory.brain.model_provider import get_router, get_model

# TheBrain wählt automatisch das günstigste Modell
selection = get_model(profile="dev")
router = get_router()

response = router.call(
    model_id=selection["model"],
    provider=selection["provider"],
    messages=[
        {"role": "system", "content": "Du bist ein Analyst."},
        {"role": "user", "content": "Analysiere diesen Text: ..."},
    ],
    max_tokens=4096,
)

print(response.content)       # Antwort-Text
print(response.cost_usd)      # Kosten in USD
print(response.input_tokens)  # Input-Tokens
print(response.output_tokens) # Output-Tokens
```

### Für große Inputs (>100k Tokens):

```python
# Gemini Flash hat 1M Context Window — perfekt für große Inputs
selection = get_model(profile="dev", expected_output_tokens=20000)
# → TheBrain wählt automatisch Gemini Flash (größtes Window)

# Oder direkt Gemini Flash anfordern:
response = router.call(
    model_id="gemini-2.5-flash",
    provider="google",
    messages=[...],
    max_tokens=65536,  # Gemini kann bis 65k Output
)
```

### Für Token-Splitting (Output > Modell-Limit):

```python
from factory.brain.model_provider.auto_splitter import AutoSplitter
from factory.brain.model_provider import get_registry

splitter = AutoSplitter(get_registry())
strategy = splitter.analyze("mistral-small-latest", "mistral", expected_output_tokens=20000)

if strategy.alternative_model:
    # AutoSplitter sagt: nimm ein größeres Modell
    print(f"Switch to {strategy.alternative_model}")
elif strategy.should_split:
    # Muss in N Calls aufgeteilt werden
    print(f"Split into {strategy.call_count} calls")
```

### Mit Fallback (Primary → Secondary):

```python
response = router.call_with_fallback(
    primary_model="mistral-small-latest",
    primary_provider="mistral",
    fallback_model="claude-haiku-4-5",
    fallback_provider="anthropic",
    messages=[...],
)
```

## Verfügbare Modelle

| Provider | Modell | Tier | Output $/1k | Max Output | Max Context | Stärken |
|---|---|---|---|---|---|---|
| **mistral** | mistral-small-latest | low | **$0.0003** | 8k | 128k | Günstigstes, schnell |
| **openai** | gpt-4o-mini | low | $0.0006 | 16k | 128k | Gut für Reviews |
| **google** | gemini-2.5-flash | low | $0.0006 | **65k** | **1M** | Größter Context+Output |
| anthropic | claude-haiku-4-5 | low | $0.004 | 8k | 200k | Bewährt |
| openai | o3-mini | mid | $0.0044 | 65k | 128k | Reasoning |
| openai | gpt-4o | mid | $0.01 | 16k | 128k | Code-Qualität |
| google | gemini-2.5-pro | mid | $0.01 | 65k | 1M | Großer Context |
| anthropic | claude-sonnet-4-6 | mid | $0.015 | 16k | 200k | Beste Code-Qualität |
| anthropic | claude-opus-4-6 | high | $0.075 | 32k | 200k | Premium |

## Für das 200k+ Input Problem

**Strategie: Gemini Flash für große Dokumente**

Gemini 2.5 Flash hat 1M Context Window. 200k Zeichen sind ca. 50-60k Tokens — passt locker rein.

```python
# Alle Reports in einem Call verarbeiten
response = router.call(
    model_id="gemini-2.5-flash",
    provider="google",
    messages=[
        {"role": "system", "content": "Analysiere alle Reports und erstelle eine Zusammenfassung."},
        {"role": "user", "content": all_reports_text},  # 200k+ Zeichen
    ],
    max_tokens=8000,
)
# Kostet: ~50k input tokens × $0.00015/1k = $0.0075
# Statt Haiku: ~50k × $0.0008/1k = $0.04 (und Haiku Context reicht nicht!)
```

**Alternative: Mehrere fokussierte Calls**

```python
# Wenn Output > 8k nötig: Gemini Flash kann 65k Output
# Wenn verschiedene Aspekte analysiert werden sollen: parallele Calls

reports_chunks = [reports[:50000], reports[50000:100000], reports[100000:]]
summaries = []
for chunk in reports_chunks:
    resp = router.call("mistral-small-latest", "mistral",
                       [{"role": "user", "content": f"Zusammenfassung: {chunk}"}],
                       max_tokens=2000)
    summaries.append(resp.content)

# Dann merge
final = router.call("mistral-small-latest", "mistral",
                     [{"role": "user", "content": f"Merge: {summaries}"}],
                     max_tokens=4000)
```

## API Keys

Alle Keys sind in `.env` konfiguriert:
```
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-proj-...
GEMINI_API_KEY=AIza...
MISTRAL_API_KEY=BHrs...
```

`get_router()` lädt sie automatisch.

## Wichtige Dateien

| Datei | Zweck |
|---|---|
| `factory/brain/model_provider/__init__.py` | `get_model()`, `get_router()`, `get_registry()` |
| `factory/brain/model_provider/models_registry.json` | Alle Modelle + Preise |
| `factory/brain/model_provider/provider_router.py` | `ProviderRouter` Klasse |
| `factory/brain/model_provider/auto_splitter.py` | Token-Limit-Management |
| `factory/brain/model_provider/README.md` | Volle Dokumentation |
| `.env` | API Keys |

## Profile → Modell Mapping

| Profile | Tier | Automatisch gewählt |
|---|---|---|
| `dev` | low | Mistral Small ($0.0003) |
| `standard` | mid | o3-mini ($0.0044) |
| `premium` | high | Opus ($0.075) |
