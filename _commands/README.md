# _commands/ — Cross-Platform Command Queue

Dieser Ordner dient als Brücke zwischen Windows und Mac.

## Workflow

```
Windows (Claude Code):
  1. Erstellt .md Datei in _commands/ mit Auftrag
  2. git commit + push

Mac (Claude Code in VS Code):
  1. git pull
  2. Liest die .md Datei
  3. Führt den Befehl aus
  4. Schreibt Ergebnis in _results/<dateiname>_result.md
  5. git commit + push

Windows:
  1. git pull
  2. Liest das Ergebnis
```

## Datei-Format

Jede Command-Datei ist eine `.md` mit:

```markdown
# Command: <kurzer Titel>
Status: pending | in_progress | done
Created: <Datum>

## Aufgabe
<Was der Mac-Agent tun soll>

## Befehle
<Konkrete Shell-Befehle>

## Erwartetes Ergebnis
<Was zurückkommen soll>
```

## Ergebnis-Format

```markdown
# Result: <Titel>
Status: done
Executed: <Datum>

## Output
<Rohe Ausgabe>

## Zusammenfassung
<Kurze Bewertung>
```
