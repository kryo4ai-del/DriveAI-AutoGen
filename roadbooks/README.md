# roadbooks/

Technische Roadbooks für den DriveAI-AutoGen Swarm.

## Erstellt von
Roadbook Agent (`~/.claude/agents/roadbook-agent.md`)

## Format
- Dateiname: `roadbook_vN.md` (N = Versionsnummer, nie überschreiben)
- Inhalt: Feature-Übersicht, Details, Implementierungsreihenfolge, Risiken
- Schema: siehe `~/.claude/agents/roadbook-agent.md`

## Workflow
```
Deine Idee
  → master-lead     (Analyse + Feature-Liste)
  → roadbook-agent  (erstellt roadbook_vN.md hier)
  → prompt-engineer (liest Roadbook → specs/ + prompts/)
  → AutoGen Swarm   (python main.py --spec specs/...)
```

## Dateien
| Datei | Feature-Set | Datum | Status |
|-------|------------|-------|--------|
| _(noch keine)_ | | | |