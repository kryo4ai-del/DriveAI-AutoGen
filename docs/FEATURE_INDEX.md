# AskFin Feature Index

Last Updated: 2026-03-18 — App Store Prep complete

---

# Product Features

## Training Mode
| Feature | Status |
|---|---|
| Taegliches Training (adaptive) | Complete |
| Thema ueben (TopicPicker → Training) | Complete |
| Schwaechen trainieren (weaknessFocus) | Complete |
| TrainingSessionView (Swipe/Tap) | Complete |
| AnswerRevealView (Feedback + Erklaerung) | Complete |
| Training Brief (Pre-Session) | Complete |
| Training Summary (Post-Session) | Complete |

## Exam Simulation (Generalprobe)
| Feature | Status |
|---|---|
| ExamSimulationView | Complete |
| Pre-Start Screen | Complete |
| Timed Exam (30 Fragen) | Complete |
| SimulationResultView | Complete |
| Gap-Analyse (Kategorie-Breakdown) | Complete |
| Drilldown (Einzelfragen richtig/falsch) | Complete |
| "Thema ueben" CTA (aus falsch beantworteten) | Complete |
| "Schwaechen trainieren" CTA | Complete |
| "Alle Antworten ansehen" CTA | Complete |
| "Nochmal simulieren" CTA | Complete |
| Exam Result Persistence (Verlauf) | Complete |

## Skill Map (Lernstand)
| Feature | Status |
|---|---|
| SkillMapView (Domain-Grid) | Complete |
| SkillMapViewModel | Complete |
| TopicCells mit Kompetenz-Level | Complete |
| Live-Update nach Training | Complete |

## Readiness Score
| Feature | Status |
|---|---|
| ReadinessScore (0-100%) | Complete |
| Milestone-basierte Berechnung | Complete |
| Persistenz ueber Restart | Complete |

## Verlauf (History)
| Feature | Status |
|---|---|
| SessionHistoryStore | Complete |
| Verlauf Tab | Complete |
| Detail-Sheet (Score, Datum, Dauer, Kategorien) | Complete |
| Training + Exam Sessions | Complete |

---

# Adaptive Learning System
| Feature | Status |
|---|---|
| QuestionLoader (JSON Bundle) | Complete |
| 173 echte Fuehrerschein-Fragen | Complete |
| Adaptive Selection (schwache Kategorien priorisiert) | Complete |
| Learning Signal Persistence (per-Question) | Complete |
| Confidence Integration (echte Antwort-Daten) | Complete |
| User Feedback Loop (Erklaerung nach Antwort) | Complete |
| Adaptive Visibility (Kategorie-Label, Indikator) | Complete |

---

# App Shell
| Feature | Status |
|---|---|
| PremiumRootView (4 Tabs) | Complete |
| PremiumHomeView (3 Entry Cards) | Complete |
| NavigationStack | Complete |
| Dark Theme | Complete |

---

# Persistence
| Feature | Status |
|---|---|
| TopicCompetenceService (UserDefaults) | Complete |
| SessionHistoryStore (UserDefaults) | Complete |
| Learning Signal Store (UserDefaults) | Complete |
| Cold Restart Recovery | Complete |

---

# Testing / Quality
| Feature | Status |
|---|---|
| GoldenGateTests (15 Gates) | Complete |
| InFlowSmokeTests | Complete |
| TrainingJourneyTests | Complete |
| PostSessionStateTests | Complete |
| MultiSessionTests | Complete |
| SkillMapRuntimeTests | Complete |
| GeneralprobeRuntimeTests | Complete |
| ScreenshotTests (4 Screens) | Complete |
| run_golden_gates.sh | Complete |

---

# App Store Prep
| Feature | Status |
|---|---|
| APP_STORE_METADATA.md | Complete |
| PRIVACY_POLICY.md | Complete |
| APP_ICON_SPEC.md | Complete (Icon muss erstellt werden) |
| APP_STORE_CHECKLIST.md | Complete |
| Asset Catalog (AccentColor, AppIcon) | Complete (Placeholder) |
| Launch Strategy | Complete |

---

# Not Implemented / Out of Scope
| Feature | Status | Reason |
|---|---|---|
| Real Backend/API | Not planned for v1 | Offline-first |
| Multi-Language | Not planned for v1 | German only |
| Content Management (CRUD) | Not planned for v1 | Static JSON |
| CI/CD Pipeline | Not implemented | Gates run locally |
| CoreML Integration | Not implemented | Not needed for exam prep |
