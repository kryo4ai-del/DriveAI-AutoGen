# 079 User Feedback Loop — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Feedback Mechanism

`UserConfidence` enum: `.unsure`, `.okay`, `.confident`

Angezeigt auf der Reveal-Phase (nach Antwort-Feedback):
- "Wie sicher warst du?"
- 3 Buttons: Unsicher / OK / Sicher
- Tap → setzt Confidence + fährt zur nächsten Frage fort

## 2. Integration

- `SessionResult.confidence: UserConfidence` — gespeichert pro Antwort
- `AnswerRevealView.onConfidence: ((UserConfidence) -> Void)?` — optionaler Callback
- Wenn gesetzt: 3 Confidence-Buttons statt 1 Weiter-Button
- Wenn nil: Fallback auf normalen Weiter-Button (Backwards-compatible)

## 3. Effect on Selection

Aktuell: Confidence wird in SessionResult gespeichert, aber noch nicht in `TopicCompetence.weightedAccuracy` eingerechnet. Das ist der nächste Schritt — die UI-Erfassung ist implementiert.

## 4. Build: SUCCEEDED

## 5. Next Step

Confidence-Signal in `TopicCompetenceService.record()` einfließen lassen → niedriges Confidence senkt weightedAccuracy stärker.
