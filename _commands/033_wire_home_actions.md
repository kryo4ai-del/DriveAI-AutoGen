# 033 Wire Home Actions — Tägliches Training + Schwächen trainieren

**Status**: pending
**Ziel**: Alle 3 Home-Cards funktional machen

## Auftrag

### Schritt 1: Analyse

1. Lies `PremiumHomeView.swift` — wie ist "Thema ueben" verdrahtet?
2. Finde das Pattern: Sheet? NavigationLink? NavigationDestination?
3. Pruefe welche Views schon existieren die als Destination passen:
   ```bash
   grep -r "TrainingSession\|DailyTraining\|WeaknessPractice\|QuestionView\|QuizView" \
     projects/askfin_v1-1/ --include="*.swift" -l | grep -v quarantine
   ```
4. Pruefe ob `ExamSessionViewModel` / `ExamSession` als Training-Session genutzt werden kann

### Schritt 2: Wiring

**Taegliches Training**:
- Oeffnet eine Training-Session mit zufaelligen/adaptiven Fragen
- Einfachster Ansatz: Gleiche Sheet-Pattern wie "Thema ueben" aber mit allen Kategorien
- Oder: NavigationLink zu einer TrainingView die ExamSessionViewModel nutzt

**Schwaechen trainieren**:
- Oeffnet Training nur mit schwachen Kategorien
- Einfachster Ansatz: Gleiche Pattern, aber gefiltert auf weak categories

### Minimale Implementierung

Falls keine passende Training-View existiert, erstelle eine minimale `TrainingSessionView.swift`:
```swift
struct TrainingSessionView: View {
    let mode: TrainingMode

    enum TrainingMode {
        case daily
        case weaknesses
        case topic(String)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
            Text(subtitle)
                .foregroundColor(.secondary)
            // Placeholder fuer echte Quiz-Logik
            Text("Coming Soon")
                .padding()
        }
        .navigationTitle(title)
    }

    private var title: String { ... }
    private var subtitle: String { ... }
}
```

### Schritt 3: Build + Simulator Check

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodebuild -project AskFinPremium.xcodeproj -scheme AskFinPremium \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5

xcrun simctl install booted $(find ~/Library/Developer/Xcode/DerivedData -name "AskFinPremium.app" -path "*/Debug-iphonesimulator/*" | head -1)
xcrun simctl launch booted com.askfin.premium
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/033_home_wired.png
```

## Report

Ergebnis in `_commands/033_wire_home_result.md`:
- Vorher: Welches Pattern nutzt "Thema ueben"
- Nachher: Was wurde fuer die 2 Actions implementiert
- Build: SUCCEEDED / FAILED
- Simulator: Screenshot falls moeglich
- Alle 3 Cards funktional? Ja/Nein

## Git

```bash
git add -A
git commit -m "feat: wire remaining Home actions (Report 74-0)

- Taegliches Training + Schwaechen trainieren verdrahtet
- 3/3 Home Cards funktional"
git push
```
