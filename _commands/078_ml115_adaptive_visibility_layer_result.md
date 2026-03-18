# 078 Adaptive Visibility Layer — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Visibility Surface: Training-Briefing

Gewählt: `SessionBriefView` previewText — erscheint vor jeder Training-Session.

Warum:
- Existiert bereits (`.brief` Phase)
- User sieht es vor der ersten Frage
- Nicht-intrusiv (verschwindet nach Tap)
- Truthful zu actual logic

## 2. Implementation

`makePreviewText(for:)` in TrainingSessionViewModel erweitert:

| SessionType | Angezeigter Grund |
|---|---|
| .weaknessFocus | "Fokus auf deine Schwächen" |
| .adaptive (weak>0) | "Adaptiv — X schwache Themen priorisiert" |
| .adaptive (all good) | "Adaptiv — alle Themen gut, Wiederholung" |
| .coverageGaps | "Lücken schließen" |
| .spacingReview | "Wiederholung fälliger Themen" |
| .custom | "Dein gewähltes Thema" |

Format: `"Grund\nTopic1, Topic2, Topic3"`

## 3. Build: SUCCEEDED

## 4. Next Step

Runtime-Screenshot des Briefing-Screens mit adaptiver Erklärung.
