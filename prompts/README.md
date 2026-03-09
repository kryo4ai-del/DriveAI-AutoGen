# prompts/

Generierte CLI-Befehle für den DriveAI-AutoGen Swarm.

## Erstellt von
Prompt Engineer Agent (`~/.claude/agents/prompt-engineer.md`)

## Verwendung
```bash
# Alle Befehle eines Roadbooks sequentiell ausführen
bash prompts/generated_cli_commands.sh

# Oder einzelnen Befehl kopieren und direkt ausführen
python main.py --spec specs/<feature_name>.md --profile dev --approval auto
```

## Wichtig
- `set -e` ist aktiv — stoppt bei erstem Fehler
- Reihenfolge respektiert Abhängigkeiten aus dem Roadbook
- Neue Roadbook-Runs werden als neue Sektion angehängt (nicht überschrieben)