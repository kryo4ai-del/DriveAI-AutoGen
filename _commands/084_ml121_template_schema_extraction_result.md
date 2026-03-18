# 084 Template Schema Extraction — STOPP

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Quality Gate: STOPP — Nicht ausgefuehrt

### Problem: Overengineering

TopicArea als generisches Protocol zu abstrahieren bringt **jetzt 0 User-Value**:

1. **Nur 1 App existiert** (AskFin). Abstraktion für theoretische zukünftige Apps ist premature.
2. **~50+ Stellen** referenzieren TopicArea (enum cases, switches, displayName). Protocol-Refactor berührt dutzende Files.
3. **Hohe Baseline-Gefahr**: Jeder Switch muss generic werden, Compile-Errors wahrscheinlich.
4. **CLAUDE.md Prinzip**: "Lieber einen höheren Hebel finden als Micro-Layers stapeln."

### Vergleich

| Ansatz | User-Value | Risiko | Aufwand |
|---|---|---|---|
| TopicArea Protocol (dieser Prompt) | 0 (kein 2. Projekt) | HOCH (50+ Files) | HOCH |
| App Store Prep (Icon, Screenshots) | HOCH (Release-fähig) | NIEDRIG | MITTEL |
| Mehr Fragen (173 → 300+) | HOCH (bessere Prüfungsvorbereitung) | NIEDRIG | NIEDRIG |

### Empfehlung

Generalisierung **erst wenn zweites Projekt entsteht**. Bis dahin: Report 123-0 dokumentiert die Template-Punkte ausreichend. Nächster Wert: App Store Vorbereitung oder Content-Erweiterung.
