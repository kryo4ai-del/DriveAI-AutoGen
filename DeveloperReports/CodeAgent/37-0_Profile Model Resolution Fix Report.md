# Profile Model Resolution Fix Report

**Datum**: 2026-03-15
**Scope**: `--profile standard` soll Sonnet aktivieren, nicht Haiku
**Ziel**: Profile-Intent und Modell-Selektion synchronisieren

---

## 1. Root Cause

Zwei separate Konzepte die nicht verbunden waren:

| Konzept | Flag | Steuert | Konfiguration |
|---|---|---|---|
| **Run-Profile** | `--profile` | mode, approval | `PROFILE_DEFAULTS` dict |
| **LLM-Profile** | `--env-profile` | model, temperature | `config/llm_profiles.json` |

`--profile standard` setzte nur das Run-Profile (mode=full), aber **nicht** den `env_profile`. Der `env_profile` blieb auf dem Default `"dev"` → Haiku.

Zusaetzlich: `PROFILE_DEFAULTS` kannte nur `fast/dev/safe/agentic` — `standard` und `premium` fehlten als Run-Profile-Eintraege.

## 2. Exact Central Fix

### A. Profile-zu-EnvProfile-Bridge

```python
# Wenn --profile einem LLM-Profile-Namen entspricht (dev/standard/premium)
# und kein explizites --env-profile gesetzt ist, nutze --profile als env_profile.
_llm_profile_names = {"dev", "standard", "premium"}
_profile_as_env = profile if (profile and profile in _llm_profile_names) else None

env_profile_raw = (
    a["explicit_env_profile"]     # 1. Explizites --env-profile (hoechste Prio)
    or recipe_cfg.get("env_profile")
    or preset_cfg.get("env_profile")
    or _profile_as_env            # 2. --profile als env_profile (NEU)
    or "dev"                      # 3. Default
)
```

### B. PROFILE_DEFAULTS erweitert

```python
PROFILE_DEFAULTS = {
    "fast":     {"mode": "quick",    "approval": "off"},
    "dev":      {"mode": "standard", "approval": "auto"},
    "standard": {"mode": "full",     "approval": "auto"},   # NEU
    "premium":  {"mode": "full",     "approval": "auto"},   # NEU
    "safe":     {"mode": "standard", "approval": "ask"},
    "agentic":  {"mode": "full",     "approval": "auto"},
}
```

## 3. Effective Precedence After Fix

```
env_profile =
  1. --env-profile (explicit CLI)
  2. recipe.env_profile
  3. preset.env_profile
  4. --profile (if matches LLM profile name)  ← NEU
  5. "dev" (system default)
```

## 4. Validation

| Test | Flags | Model | Mode | Status |
|---|---|---|---|---|
| Default | (keine) | haiku | full | OK |
| `--profile dev` | dev | haiku | standard | OK |
| **`--profile standard`** | standard | **sonnet** | full | **OK (war haiku!)** |
| **`--profile premium`** | premium | **opus** | full | **OK (war haiku!)** |
| `--profile standard --env-profile dev` | standard+dev | haiku | full | OK (Override) |
| `--profile fast` | fast | haiku | quick | OK |
| `--profile agentic` | agentic | haiku | full | OK |

## 5. Files Changed

| Datei | Aenderung |
|---|---|
| `main.py` Zeile 40-46 | `PROFILE_DEFAULTS`: `standard` und `premium` hinzugefuegt |
| `main.py` Zeilen 1333-1341 | Profile-zu-EnvProfile-Bridge mit LLM-Profile-Erkennung |

## 6. Regression Check

Alle 7 Test-Faelle bestanden. Bestehende Profile (`fast/dev/safe/agentic`) verhalten sich identisch. Neue Profile (`standard/premium`) setzen jetzt korrekt das Modell.

## 7. Ready for Next Proof Run

**Ja** — `--profile standard` aktiviert jetzt `claude-sonnet-4-6` + `run_mode: full`. Der naechste Run wird erstmals mit dem korrekten staerkeren Modell laufen.

## 8. Single Next Recommended Step

**Run 13 mit `--profile standard`** — diesmal tatsaechlich mit Sonnet. Der Code-Output sollte qualitativ besser sein als Run 12 (der trotz `standard` noch Haiku nutzte).
