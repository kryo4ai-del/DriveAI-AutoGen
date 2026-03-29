# DAI-Core Brand Integration Guide

## Tier-System

| Tier | Wann | Departments | Was wird injiziert |
|---|---|---|---|
| **A (Full)** | Oeffentliche Dokumente, Store Listings | Marketing, Roadbook, Store, DocSecretary | Komplette Brand Bible (~4KB) |
| **B (Summary)** | Creative Assets, Design-Entscheidungen | Design Vision, Forges, Visual Audit, Market Strategy | Brand Summary (~500B) |
| **C (None)** | Engineering, QA, interne Prozesse | QA, Janitor, Brain, Assembly, Operations | Nichts |

## Integration in einen neuen Agent

```python
from factory.brand.brand_loader import load_brand_context

# In der Methode wo der System Prompt gebaut wird:
brand_context = load_brand_context(department="dein_department")
system_prompt = f"{base_prompt}\n{brand_context}"
```

## Integration in TheBrain

TheBrain hat eine `BRAND_AWARENESS` Konstante in `brain_system_prompt.py`.
Diese wird automatisch in den System Prompt eingefuegt.
TheBrain routet Brand-Context an Agents basierend auf Tier.

## Dateien

| Datei | Zweck |
|---|---|
| `brand_loader.py` | Zentrale API (load_brand_context, get_brand_info etc.) |
| `DAI-CORE_Brand_Bible_v1.0.md` | Vollstaendige Brand Bible (Tier A) |
| `brand_summary.md` | Kompakte Zusammenfassung (Tier B) |
| `css/brand_variables.css` | CSS Custom Properties |
| `assets/` | Logo-Varianten (manuell kopieren) |

## Regeln
- KEIN "DriveAI-AutoGen" in oeffentlichen Outputs
- IMMER "we" statt "I" (Kollektiv-Voice)
- IMMER Brand-Farben verwenden (Magenta + Cyan auf Dark)
- Store Listings: "Built by DAI-Core"
