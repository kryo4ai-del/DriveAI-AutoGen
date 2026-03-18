# 083 Factory Transition — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Capability Summary nach Gate 15

| Capability | Status | Reusable? |
|---|---|---|
| SwiftUI MVVM App Shell | 4 Tabs, Dark Mode, Navigation | ✅ Template-fähig |
| Training Mode (Swipe/Tap) | Adaptive Session, Brief → Question → Reveal → Summary | ✅ Generisch |
| Exam Simulation | Timed, Fehlerpunkte, Pass/Fail, Result | ✅ Generisch |
| Skill Map | Domain-Grid, Competence-Level, Puls-Indikatoren | ✅ Generisch |
| Readiness Score | Milestone-basiert, 0-100% | ✅ Generisch |
| Persistence (UserDefaults) | Competence + History + Settings | ✅ Reusable |
| Adaptive Learning | Topic-Priorisierung, Spaced Repetition, Confidence | ✅ Reusable |
| Insight-to-Action Loop | Result → Gap → Drilldown → Training | ✅ Pattern |
| Golden Gate Suite | 15 automatisierte Acceptance Tests | ✅ Pattern |
| Question JSON Bundle | 173 Fragen, Schema, QuestionLoader | ⚠️ Domain-spezifisch |
| xcodegen Build System | project.yml → .xcodeproj | ✅ Reusable |

## 2. Reusable Factory Components

### Sofort wiederverwendbar (Domain-agnostisch)
- **App Shell**: TabView + NavigationStack Pattern
- **Training Engine**: SessionViewModel + QuestionBank Protocol + Swipe/Tap
- **Competence Service**: TopicCompetence + Persistence + Adaptive Selection
- **Exam Engine**: ExamSimulationViewModel + Fehlerpunkte + Result
- **History Store**: SessionHistoryStore Pattern
- **Golden Gate Script**: `run_golden_gates.sh`
- **Build Pipeline**: xcodegen + project.yml

### Domain-spezifisch (müssen angepasst werden)
- **Question Dataset**: JSON Schema bleibt, Inhalte ändern sich
- **Topic Areas**: Enum Cases domain-spezifisch
- **Fehlerpunkte-Logik**: Führerschein-spezifisch
- **UI-Texte**: Deutsch, Führerschein-Kontext

## 3. Factory Template Concept

Ein "Learning App Template" würde bestehen aus:
```
Template/
├── App/          ← Shell (TabView, Root, Entry Point)
├── Models/       ← TopicArea enum (PLACEHOLDER), Question, Competence
├── Services/     ← CompetenceService, QuestionLoader, HistoryStore
├── ViewModels/   ← TrainingVM, SimulationVM, SkillMapVM
├── Views/        ← Training/, Simulation/, SkillMap/
├── Resources/    ← questions.json (PLACEHOLDER)
├── UITests/      ← GoldenGateTests (generic)
├── scripts/      ← run_golden_gates.sh
└── project.yml   ← xcodegen config
```

Customization Points: TopicArea enum, questions.json, App-Name, Farben, Fehlerpunkte-Logik.

## 4. Gaps to Full Factory Replication

| Gap | Impact | Effort |
|---|---|---|
| TopicArea/Question Schema Abstraction | HOCH — aktuell hardcoded | Mittel |
| Theming/Branding Layer | MITTEL — Dark Theme hardcoded | Niedrig |
| CI/CD Pipeline | MITTEL — nur lokales Script | Mittel |
| App Store Prep (Icon, Screenshots, Metadata) | HOCH — fehlt komplett | Mittel |
| Content Management (Questions CRUD) | NIEDRIG für v1 | Hoch |
| Multi-Language | NIEDRIG für v1 | Mittel |

## 5. Single Next Step

**TopicArea + Question Schema als generisches Protocol definieren** — damit die gleiche Engine für Führerschein, Medizin, Recht etc. wiederverwendbar wird. Das ist der höchste Factory-Hebel.
