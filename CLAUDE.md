# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen
- **Typ**: Multi-Agent AI System + SwiftUI iOS App (DriveAI)
- **Sprachen**: Python (Backend/Agents), Swift/SwiftUI (iOS App)
- **Repo**: `/Users/andreasott/DriveAI-AutoGen/`
- **Besitzer**: Andreas Ott

## Projektstruktur
- `main.py` – Haupt-Einstiegspunkt (Python)
- `DriveAI/` – Xcode/SwiftUI iOS App
  - `DriveAI/Models/` – Swift Datenmodelle
  - `DriveAI/Views/` – SwiftUI Views
  - `DriveAI/ViewModels/` – ViewModels
  - `DriveAI/Services/` – Services
- `agents/` – AI Agenten (Python)
- `config/` – Konfiguration
- `factory/` – Factory Layer
- `control_center/` – Control Center
- `workflows/` – Workflow-Definitionen
- `docs/` – Dokumentation
- `venv/` – Python Virtual Environment

## Bekannte Probleme
- `DriveAI/DriveAI/` enthält ein verschachteltes `.git` Repo – muss bereinigt werden
- Doppelte Ordner (Models, Services, ViewModels, Views) in DriveAI/ und DriveAI/DriveAI/

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in MEMORY.md und CLAUDE.md dokumentieren

## Erledigtes
- [2026-03-12] Projekt analysiert, Strukturproblem mit verschachteltem Git-Repo identifiziert
