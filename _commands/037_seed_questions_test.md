# 037 Seed MockQuestionBank + First Q&A Test

**Status**: pending
**Ziel**: Beispiel-Fragen einfuegen, erste echte Frage-Antwort-Interaktion testen

## Auftrag

### Schritt 1: MockQuestionBank inspizieren

```bash
grep -r "MockQuestionBank\|QuestionBank" projects/askfin_v1-1/ --include="*.swift" -l | grep -v quarantine
```

Lies die Datei und verstehe:
- Welches Question-Model wird erwartet?
- Wie wird `randomQuestion()` aufgerufen?
- Welche Properties braucht eine Question (id, text, answers, correctIndex, category, ...)?

### Schritt 2: Beispiel-Fragen einfuegen

Fuege 5-10 deutschsprachige Fuehrerschein-Fragen ein. Beispiele:

```swift
Question(
    id: "Q1",
    text: "Was bedeutet ein rotes achteckiges Verkehrszeichen?",
    answers: ["Vorfahrt gewähren", "Halt! Vorfahrt gewähren", "Einfahrt verboten", "Parkverbot"],
    correctAnswerIndex: 1,
    category: "Verkehrszeichen"
)
```

Weitere Themen:
- Vorfahrtsregeln
- Geschwindigkeitsbegrenzungen
- Abstandsregeln
- Alkohol am Steuer
- Verhalten bei Unfaellen

Passe die Question-Struktur an das existierende Model an (Properties, Types, etc.)

### Schritt 3: Build + Journey Test

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AskFinUITests/TrainingJourneyTests/testDailyTrainingFullJourney \
  -resultBundlePath /tmp/askfin_qa_results \
  2>&1 | tail -30
```

Falls der Journey-Test nicht ausreicht, erweitere ihn:
- Pruefe ob Frage-Text sichtbar ist
- Pruefe ob Antwort-Buttons sichtbar sind
- Tappe eine Antwort
- Pruefe ob Feedback/Naechste-Frage kommt

### Screenshots

```bash
# Falls moeglich: Screenshots aus dem Test-Run extrahieren
find /tmp/askfin_qa_results -name "*.png" -exec cp {} ~/DriveAI-AutoGen/_commands/ \; 2>/dev/null
```

## Report

Ergebnis in `_commands/037_seed_questions_result.md`:

```
## MockQuestionBank vorher
- [leer / nil]

## Fragen eingefuegt
- Anzahl: X
- Kategorien: [Liste]
- Beispiel: [eine Frage]

## Runtime Test
- Frage angezeigt: [ja/nein]
- Antwort getappt: [ja/nein]
- Feedback: [richtig/falsch angezeigt?]
- Progression: [naechste Frage / Ende / Crash]
- Fragen beantwortet: X

## Interpretation
```

## Git

```bash
git add -A
git commit -m "feat: seed MockQuestionBank + first Q&A test (Report 78-0)

- X Beispiel-Fragen eingefuegt
- Erste echte Frage-Antwort-Interaktion getestet"
git push
```
