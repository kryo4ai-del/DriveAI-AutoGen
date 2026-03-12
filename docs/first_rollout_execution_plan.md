# First Rollout -- Execution Plan

Last Updated: 2026-03-12

---

## Ueberblick

5 Schritte, streng sequenziell. Kein Schritt wird gestartet bevor der vorherige validiert ist.

---

## Step 1: Factory Knowledge Scaffold (ERLEDIGT)

**Status:** Done

**Was wurde gemacht:**
- `factory_knowledge/` Verzeichnis angelegt
- `knowledge.json` (leer, Schema bereit)
- `index.json` (leer, Zaehler bereit)
- `README.md` (Quick Reference)
- Schema dokumentiert in `docs/factory_learning_schema.md`

**Validierung:** Struktur existiert, Schema ist definiert, keine Platzhalter-Daten.

---

## Step 2: Creative Director als Advisory Review Pass

**Was:**
- `agents/creative_director.py` erstellen (identische Struktur wie reviewer.py)
- Rolle in `config/agent_roles.json` hinzufuegen
- Toggle in `config/agent_toggles.json` setzen
- Route in `config/model_router.py` hinzufuegen: `creative_direction -> Sonnet`
- Import + Instanziierung in `tasks/task_manager.py`
- Neuer Pass 2b in `main.py` (nach Bug Review, vor Refactor)
- Skip-Logik: nur fuer `feature` und `screen` Templates

**Was NICHT:**
- Kein neues Gate in phase_gates.json
- Kein Veto-Mechanismus -- rein Advisory
- Kein factory_knowledge/ Zugriff
- Kein neuer Manager oder Store

**Dateien die geaendert werden:**
1. `agents/creative_director.py` (neu)
2. `config/agent_roles.json` (1 Eintrag hinzu)
3. `config/agent_toggles.json` (1 Eintrag hinzu)
4. `config/model_router.py` (1 Route hinzu)
5. `tasks/task_manager.py` (Import + Instanziierung)
6. `main.py` (Pass 2b einfuegen)

**Validierung:**
- `python main.py --template screen --name TestScreen --profile dev --approval auto`
- CD-Pass muss im Log auftauchen
- CD-Feedback muss im delivery/ Export erscheinen
- Pipeline darf nicht laenger als +1 Message dauern
- Bei `--template service` muss der CD-Pass uebersprungen werden

**Risiken:**
- CD-Feedback koennte generisch sein ("Looks good, needs more personality") -- das wuerde bedeuten die System Message braucht mehr Kontext
- CD-Pass koennte die Pipeline verlangsamen -- messbar durch Log-Timestamps

---

## Step 3: Manuelles Knowledge Seeding (AskFin)

**Was:**
- 5-10 initiale Eintraege in `factory_knowledge/knowledge.json` basierend auf dem was wir ueber AskFin wissen
- Alle als `hypothesis` oder `validated` (nicht `proven` -- nur 1 Projekt)
- `index.json` aktualisieren

**Warum manuell statt automatisch:**
- Der Factory Learning Agent existiert noch nicht
- Die ersten Eintraege muessen handverlesen sein damit die Qualitaet stimmt
- Automatische Extraktion ohne Referenzdaten erzeugt Muell

**Quellen fuer Eintraege:**
- `docs/askfin_premium_reframing.md` (Experience Pillars, Design-Signatur)
- `docs/factory_premium_product_principles.md` (Allgemeine Prinzipien)
- Bestehende AskFin-Architektur (OCR-Pipeline, MVVM, etc.)
- Bekannte Probleme (LEGAL-001 Copyright, generischer UI-Stand)

**Beispiel-Eintraege die Sinn machen:**
1. OCR-to-LLM Pipeline (technical_pattern, validated)
2. Generischer Fragenkatalog verliert Nutzer (failure_case, hypothesis)
3. Skill Map Pattern (success_pattern, hypothesis)
4. MVVM mit separatem Service Layer (technical_pattern, validated)
5. Pruefungssimulation mit Fehlerpunkten (success_pattern, hypothesis)
6. Dark Theme fuer Abend-Lernsessions (design_insight, hypothesis)
7. Copyright-Risiko bei offiziellen Pruefungsfragen (failure_case, validated)

**Validierung:**
- knowledge.json hat 5-10 Eintraege
- index.json Zaehler stimmen
- Kein Eintrag ist generisch oder ohne konkreten Kontext

---

## Step 4: Creative Director Gate-Modus

**Voraussetzung:** Step 2 ist validiert UND CD-Feedback ist konsistent nuetzlich (nicht generisch).

**Was:**
- CD-Output bekommt strukturiertes Format: `{"rating": "pass|conditional_pass|fail", "findings": [...]}`
- Neues Gate `creative_review` in `phase_gates.json`
- `PhaseGateManager.evaluate_gate()` erweitern fuer neuen Gate-Typ
- Bei `conditional_pass`: Refactor-Pass bekommt CD-Findings als zusaetzlichen Kontext
- Bei `fail`: Pipeline stoppt nach CD-Pass (nur im `full` Mode -- im `standard` Mode Advisory)

**Dateien:**
1. `workflows/phase_gates.json` (1 Gate hinzu)
2. `workflows/phase_gate_manager.py` (evaluate_gate erweitern)
3. `main.py` (Gate-Check vor CD-Pass + Conditional-Logik)

**Validierung:**
- `--mode full` mit generischem Template-Output -> CD sagt `fail` -> Pipeline stoppt
- `--mode standard` mit generischem Output -> CD sagt `fail` -> Pipeline laeuft weiter (Advisory)
- `--mode quick` -> CD-Pass wird uebersprungen

---

## Step 5: Factory Learning Writeback (nach AskFin-Validierung)

**Voraussetzung:** Steps 2-4 stabil, Knowledge Store hat manuelle Eintraege.

**Was:**
- `agents/factory_learning_agent.py` erstellen (Tier 3, Haiku)
- Laeuft als letzter Post-Processing Schritt nach dem Git Commit
- Liest: alle Messages aus dem Run (impl + bug + cd + refactor + test + fix)
- Schreibt: neue Eintraege in `factory_knowledge/knowledge.json`
- Vorhandene Eintraege: Confidence-Level Promotion wenn ein Pattern erneut bestaetigt wird

**Architektur-Entscheidung: Kein LLM fuer Phase 1 des Learning Agent**
- Phase 1: Regelbasierte Extraktion (Keywords in Messages -> Eintraege)
- Phase 2: LLM-basierte Extraktion (Haiku analysiert Messages und generiert Eintraege)
- Begruendung: Regelbasiert ist kostenlos und deterministisch. LLM-Extraktion lohnt sich erst wenn klar ist welche Eintraege nuetzlich sind.

**Dateien:**
1. `agents/factory_learning_agent.py` (neu)
2. `config/agent_roles.json` (1 Eintrag)
3. `config/agent_toggles.json` (1 Eintrag)
4. `main.py` (Post-Processing nach Git Commit)
5. Utility: `factory_knowledge/knowledge_manager.py` (CRUD fuer knowledge.json)

**Validierung:**
- Pipeline-Run erzeugt mindestens 1 neuen Eintrag in knowledge.json
- Kein Eintrag ist ein Duplikat
- index.json Zaehler werden korrekt aktualisiert

---

## Was WARTET (zu frueh)

| Was | Warum zu frueh |
|---|---|
| Pre-Implementation Gates (Innovation Gate, Motivation Gate) | Brauchen Creative Director + Knowledge Store die stabil laufen |
| UX Psychology Agent | Braucht Erfahrung mit CD-Feedback zuerst -- sonst Redundanz |
| Dynamic Model Upgrade in model_router.py | Kein messbarer Bedarf aktuell -- 3-Tier funktioniert |
| Android/Web Agents reaktivieren | Kein Android/Web Projekt geplant |
| Erweiterte factory_knowledge/ Struktur (Snapshots, separate Dateien) | Kein zweites Projekt, <50 Eintraege erwartet |

---

## Was mit AskFin validiert werden kann BEVOR verallgemeinert wird

| Konzept | AskFin-Test | Verallgemeinerbar wenn... |
|---|---|---|
| CD Review Pass | Screen/Feature Template fuer AskFin generieren, CD-Feedback pruefen | Feedback ist spezifisch und umsetzbar, nicht generisch |
| Knowledge Seeding | AskFin-Erkenntnisse manuell eintragen | Eintraege sind bei Re-Read nuetzlich fuer Agents |
| CD Gate-Modus | AskFin Feature mit generischem Output -> Gate blockt | Gate blockiert korrekterweise UND der nachfolgende Run ist besser |
| Learning Writeback | AskFin Pipeline-Run -> automatische Eintraege | Automatische Eintraege sind qualitativ vergleichbar mit manuellen |

---

## Timeline (geschaetzt, keine Garantie)

| Step | Abhaengigkeit | Umfang |
|---|---|---|
| Step 1 | Keine | Erledigt |
| Step 2 | Keine | 6 Dateien, ~200 Zeilen Code-Aenderungen |
| Step 3 | Step 2 validiert | 1 Datei, ~10 JSON-Eintraege |
| Step 4 | Step 2 + 3 validiert, CD-Feedback nuetzlich | 3 Dateien, ~50 Zeilen |
| Step 5 | Step 4 validiert | 5 Dateien, ~150 Zeilen |
