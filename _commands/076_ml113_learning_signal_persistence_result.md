# 076 Learning Signal Persistence — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## BEREITS IMPLEMENTIERT — kein neuer Code nötig

### 1. Signal Schema (TopicCompetence)

| Signal | Typ | Zweck |
|---|---|---|
| totalAnswers | Int | Coverage Count |
| correctAnswers | Int | Weakness Score |
| weightedAccuracy | Double | Recency-gewichtete Genauigkeit |
| lastReviewedDate | Date? | LastSeen für Spacing |

### 2. Persistence

- **Speicher**: UserDefaults (`driveai_competence_map`, `driveai_spacing_queue`)
- **Format**: JSON-encoded Codable
- **Save**: Nach jedem `record()` und `recordAnswer()` → `persistState()`
- **Load**: In `init()` → `loadPersistedState()`

### 3. Update Logic

- `record(result:)` → aktualisiert TopicCompetence für beantwortetes Topic
- `recordAnswer(topicId:questionId:isCorrect:)` → granulares Update
- Beide rufen `persistState()` auf → sofortige Persistenz

### 4. Validation

- Report 80-0 hat bestätigt: State überlebt Cold Restart (0% → 100%)
- `weakestTopics()` und `dueTopics()` nutzen diese persistierten Signale
- Adaptive Selektion (Report 115-0) basiert auf diesen Signalen

### 5. Next Step

Runtime-Validierung der echten Fragen im Simulator.
