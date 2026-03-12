# Projektstatus – AskFinn + Factory

**Stand:** 2026-03-12

## AskFinn iOS App
- BUILD SUCCEEDED (iPhone 17 Pro Simulator, iOS 26.3)
- Bundle ID: com.kryo4ai.AskFinn
- Pfad: `DriveAI/DriveAI/AskFinn/`
- 184 Swift-Dateien (Models, Services, ViewModels, Views)

## Bereinigung (2026-03-12)
- Alte DriveAI-Duplikate gelöscht:
  - `DriveAI/ContentView.swift`, `DriveAIApp.swift`, `Assets.xcassets/`, `DriveAI.xcodeproj/`
  - `DriveAI/DriveAI/ContentView.swift`, `DriveAIApp.swift`, `Assets.xcassets/`
  - `DriveAI/DriveAI/Models/` (mit Test-Files gemischt), `Services/`, `ViewModels/`, `Views/`
- 68 AutoGen-Conversation-Logs gelöscht (`logs/` — waren nicht in Git)
- Nur AskFinn unter `DriveAI/DriveAI/AskFinn/` bleibt

## Factory Status
- 23 Agents aktiv
- Neue Agents: StrategyReportAgent, ResearchMemoryGraph, AutoResearchAgent
- Control Center: 19 Streamlit Pages

## Nächste Schritte
- AskFinn auf Mac in Xcode testen
- Factory Agent-Pipeline verbessern (CompileGate, Extraction-Fix, Echo-Detection)
- UI der App anpassen und Features implementieren
