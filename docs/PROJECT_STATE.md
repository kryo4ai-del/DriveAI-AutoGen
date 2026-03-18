# AskFin Project State

Last Updated: 2026-03-18 — App Store Prep complete, 131 Reports, 15 Golden Gates

---

# Project

AskFin Premium (askfin_v1-1)

Slogan: "Nutze Fin und sage Ja"

An AI-powered iOS coaching app for German driver's license exam preparation.

Architecture: SwiftUI + MVVM (~200+ Swift files)

Location: `projects/askfin_v1-1/`

Built using the AI App Factory with 21 autonomous agents + 14 Autonomy Proof Runs.

---

# Current System Status

| Aspect | Status |
|---|---|
| Xcode Build | SUCCEEDED (xcodegen, iPhone 17 Pro Simulator) |
| Golden Gates | 15 Gates, 20+ XCUITests, 0 Failures |
| App Runtime | Stable, all features functional |
| Persistence | UserDefaults, survives Cold Restart |
| App Store Prep | Metadata + Privacy + Screenshots + Icon Spec done |
| Submission Blockers | App Icon (1024x1024) + Apple Developer Account |

---

# 4 Product Pillars (all gate-protected)

## 1. Training Mode
- 3 Modi: Adaptiv, Thema, Schwaechen
- 173 echte Fuehrerschein-Fragen (JSON Bundle)
- Adaptive Selection (schwache Kategorien priorisiert)
- Learning Signal Persistence (per-Question richtig/falsch)
- Confidence-basierte Kompetenz-Berechnung
- User Feedback Loop (Erklaerung nach jeder Antwort)
- Adaptive Visibility (Kategorie-Label, Schwaechen-Indikator)

## 2. Exam Simulation (Generalprobe)
- Pre-Start → Timed Exam (30 Fragen) → Result
- Gap-Analyse mit Kategorie-Breakdown
- Drilldown auf Einzelfragen (richtig/falsch)
- "Thema ueben" CTA direkt aus falsch beantworteten Fragen
- "Schwaechen trainieren" CTA → TrainingSessionView(.weaknessFocus)
- Ergebnis-Persistenz in Verlauf

## 3. Skill Map (Lernstand)
- Domain-Grid mit Topic-Cells
- Kompetenz-Level pro Kategorie
- Reagiert auf Training-Updates
- Nutzt echte Confidence-Daten

## 4. Readiness Score
- 0-100% Milestone-basiert
- Persistiert ueber Restart
- Reflektiert echten Lernfortschritt

---

# Insight-to-Action Loop

```
Generalprobe → Result Screen → Gap-Analyse → Drilldown
  → "Thema ueben" CTA → Training fuer betroffene Kategorie
  → "Schwaechen trainieren" CTA → WeaknessFocus Training
```

---

# Golden Gate Suite (15 Gates)

| Gate | Schuetzt |
|---|---|
| 1. Build | Xcode Build SUCCEEDED |
| 2. Launch | App startet im Simulator |
| 3. Shell | 4/4 Tabs navigierbar |
| 4. Home Flows | 3/3 Home Entry Cards funktional |
| 5. Training Journey | End-to-End Training Roundtrip |
| 6. Persistent Learning Loop | Training → History → Restart → State |
| 7. Skill Map | Lernstand Tab + Skill Map Rendering |
| 8. Persistence | State ueberlebt Cold Restart |
| 9. Generalprobe | Exam Simulation Flow |
| 10. Exam Result Persistence | Generalprobe-Ergebnis in Verlauf |
| 11. Exam Result History | Verlauf Detail-View |
| 12. Weakness Analysis | Gap-Analyse auf Result Screen |
| 13. Weakness CTA | "Schwaechen trainieren" → Training |
| 14. Full Loop | Generalprobe → Drilldown → "Thema ueben" → Training |
| 15. Adaptive Learning | Training → Confidence → Skill Map Reflection |

Script: `projects/askfin_v1-1/scripts/run_golden_gates.sh`

---

# App Store Readiness

| Artefakt | Status |
|---|---|
| APP_STORE_METADATA.md | Fertig (Name, Subtitle, Beschreibung, Keywords) |
| PRIVACY_POLICY.md | Fertig (Offline-only, keine Daten) |
| APP_ICON_SPEC.md | Spec fertig, Icon muss erstellt werden |
| APP_STORE_CHECKLIST.md | Aktualisiert, 2 Blocker offen |
| Screenshot Tests | Automatisiert (4 Hauptscreens) |
| Launch Strategy | TestFlight → Soft Launch → Full Release |

Submission Blockers:
1. App Icon (1024x1024 PNG)
2. Apple Developer Account

---

# Quarantine (7 Files FROZEN)

Status: FROZEN until next generation cycle.
Alle zu tief inkompatibel fuer sichere Rehabilitation.
Siehe: `quarantine/QUARANTINE_STATUS.md`

---

# Development Pipeline

## Agent Pipeline (6 Passes)
1. Implementation (CodeExtractor with inline type dedup)
2. Bug Review
3. Creative Director Review (advisory, profile-aware gate)
4. UX Psychology Review (advisory)
5. Refactor
6. Test Generation

## Operations Layer (Post-Generation)
Output Integration (5-layer dedup) → Completion Verification → Compile Hygiene (6 checks) → Type Stub Generator → Property Shape Repairer → Swift Compile Check → Recovery → Run Memory → Knowledge Writeback

## Two-Agent System
- Windows: Factory/Prompts/Quality Gate
- Mac: Build/Test/Runtime via `_commands/` Git Queue
- Reports: `MasterPrompt/reportAgent/` (ab Report 102)

---

# Report History

| Range | Phase |
|---|---|
| 1-0 to 41-0 | Factory Core + Operations Layer + 14 Proof Runs |
| 42-0 to 70-0 | Compile-to-Ship (swiftc → typecheck → Xcode Build) |
| 71-0 to 84-0 | Runtime + Simulator + Golden Gates |
| 85-0 to 101-0 | Feature Expansion + Quarantine Cleanup |
| 102-0 to 112-0 | MasterPrompt Dispatch + Factory Reflection |
| 113-0 to 122-0 | Adaptive Learning |
| 123-0 to 131-0 | App Store Prep + Launch Strategy |
