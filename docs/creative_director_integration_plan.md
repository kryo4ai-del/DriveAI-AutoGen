# Creative Director -- Integration Plan

Last Updated: 2026-03-12

---

## Plausibilitaets-Check

Vor der Planung: 3 Risiken die ich in den bisherigen Strategy-Docs gefunden habe.

### Risiko 1: Doppelte Pipeline-Insertion
Das Roles-Proposal sagt: Creative Director arbeitet VOR dem Architect (pre-impl) UND reviewed NACH dem SwiftDeveloper (post-impl). Das Gates-Proposal definiert 3 Gates die den Creative Director brauchen (Innovation Gate, Experience Uniqueness Gate, Premium Design Gate).

**Problem:** Zwei Pipeline-Eingriffe gleichzeitig erhoehen die Komplexitaet massiv. Die aktuelle Pipeline in `main.py` ist linear und simpel (Pass 1-5 nacheinander). Zwei neue Insertion-Points gleichzeitig = hohes Risiko fuer Seiteneffekte.

**Entscheidung:** Phase 1 startet NUR mit post-implementation Review. Pre-implementation Gates kommen erst in Phase 2, nachdem der Review Agent stabil laeuft.

### Risiko 2: Creative Director als Full Agent im SelectorGroupChat
Die aktuelle Pipeline nutzt `SelectorGroupChat` mit `MaxMessageTermination(max_messages=10)`. Ein Creative Director im Team wuerde Nachrichten verbrauchen die fuer Code-Generierung gebraucht werden. Bei 10 Messages ist jede Nachricht wertvoll.

**Entscheidung:** Creative Director laeuft NICHT im Haupt-SelectorGroupChat. Er laeuft als separater Pass (wie Bug Hunter), nicht als Team-Mitglied.

### Risiko 3: Abhaengigkeit von factory_knowledge/
Das Learning-Loop-Doc sagt der Creative Director bekommt Kontext aus `factory_knowledge/`. Aber factory_knowledge existiert noch nicht und hat keine Daten.

**Entscheidung:** Phase 1 des Creative Directors arbeitet ohne factory_knowledge. Er bekommt stattdessen die statischen Prinzipien aus `docs/factory_premium_product_principles.md` als System Message Kontext.

---

## Empfohlene Implementierungsform

**Review Agent als separater Pipeline-Pass.**

Nicht Full Agent im Team, nicht Hook, nicht Service Module.

Begruendung:
- Ein Full Agent im SelectorGroupChat verbraucht kostbare Messages und konkurriert mit dem Lead/Architect/Developer um Redezeit
- Ein Hook waere zu simpel -- der Creative Director braucht den generierten Code als Kontext fuer sinnvolles Feedback
- Ein Service Module ist regelbasiert -- Design-Review braucht LLM-Reasoning

Die Form ist identisch zu Bug Hunter, Refactor Agent und Test Generator: ein separater Pass der nach der Implementation laeuft und die generierten Messages als Input bekommt.

---

## Pipeline-Einordnung

### Aktuelle Pipeline (main.py Zeilen 354-478)
```
Pass 1: Implementation (team.run)              -> result.messages
Pass 2: Bug Review (team.run mit bug_task)     -> bug_result_msgs     [standard+full]
Pass 3: Refactor (team.run mit refactor_task)  -> refactor_result_msgs [standard+full]
Pass 4: Test Generation (team.run mit test_task) -> test_result_msgs  [standard+full]
Pass 5: Fix Execution (team.run mit fix_task)  -> fix_result_msgs     [full only]
```

### Erweiterte Pipeline (Phase 1)
```
Pass 1: Implementation                        -> result.messages
Pass 2: Bug Review                             -> bug_result_msgs     [standard+full]
Pass 2b: Creative Director Review  <-- NEU     -> cd_result_msgs      [standard+full]
Pass 3: Refactor (bekommt Bug + CD Feedback)   -> refactor_result_msgs [standard+full]
Pass 4: Test Generation                        -> test_result_msgs    [standard+full]
Pass 5: Fix Execution                          -> fix_result_msgs     [full only]
```

**Warum nach Bug Review und vor Refactor:**
- Der CD braucht den Implementation-Output als Input (erst nach Pass 1 verfuegbar)
- CD-Feedback kann an den Refactor-Pass weitergegeben werden (Refactor bekommt Bug + CD Befunde)
- Kein neuer Agent im Team noetig -- gleiche team.run() Mechanik wie Bug Hunter

---

## Beeinflusste bestehende Agents

| Agent | Wie beeinflusst | Aenderung noetig |
|---|---|---|
| swift_developer | Sein Output wird vom CD reviewed | Keine Aenderung -- CD liest seinen Output |
| refactor_agent | Bekommt CD-Feedback zusaetzlich zu Bug-Feedback | Refactor-Task-String erweitern |
| ios_architect | Nicht direkt betroffen (Phase 1 = post-impl only) | Keine Aenderung |
| reviewer | Nicht betroffen -- anderer Fokus (Code-Qualitaet vs. Produkt-Qualitaet) | Keine Aenderung |

---

## Inputs und Outputs

### Input
1. `result.messages` -- die generierten Implementation-Nachrichten (selber Kontext wie Bug Hunter)
2. `user_task` -- die urspruengliche Aufgabe
3. System Message mit Premium Product Principles (statisch, aus Docs)
4. Template-Typ (`feature`, `screen`, `service`, `viewmodel`) fuer Skip-Logik

### Output
- Text-Feedback: Was ist generisch, was fehlt, was muss ueberarbeitet werden
- Bewertung: pass / conditional_pass / fail
- Konkrete Verbesserungsvorschlaege (Micro-Copy, Animationen, emotionale Funktion)

### Was der Creative Director NICHT tut
- Keinen Code generieren (das macht der SwiftDeveloper)
- Keine Architektur-Entscheidungen treffen (das macht der Architect)
- Keine Bugs suchen (das macht der Bug Hunter)
- Keine technischen Refactorings vorschlagen (das macht der Refactor Agent)
- Nicht die Pipeline blockieren bei Phase 1 -- sein Output ist Advisory
- Nicht factory_knowledge/ lesen/schreiben in Phase 1

---

## Skip-Logik

Der CD-Pass laeuft nicht bei jedem Template:

| Template | CD-Pass |
|---|---|
| `feature` | Ja -- volles Review |
| `screen` | Ja -- volles Review |
| `viewmodel` | Nur wenn der ViewModel UI-Feedback enthalt |
| `service` | Nein -- kein UI, kein Design |

Implementation: `template` Variable existiert bereits in `_run_pipeline()`. Einfacher `if template in ("feature", "screen"):` Check.

---

## Wie man Workflow-Bloat vermeidet

1. **Phase 1 = Advisory only** -- CD-Output hat kein Gate-Veto. Pipeline laeuft weiter unabhaengig vom CD-Ergebnis. Feedback wird geloggt und im Refactor-Pass beruecksichtigt, aber stoppt nichts.
2. **Phase Gate erst ab Phase 2** -- Wenn der CD stabil laeuft und nuetzliches Feedback gibt, wird er zum Gate mit pass/fail Logik.
3. **Kein eigener Agent-File in Phase 1** -- Der CD nutzt die gleiche `team.run()` Mechanik wie Bug Hunter. Der Unterschied ist nur der Task-String und eine angepasste System Message im Team.
4. **Kein neuer Manager, kein neuer Store** -- CD-Output landet im bestehenden delivery/ Export wie alle anderen Passes.

---

## Minimaler Rollout-Plan

### Phase 1: Advisory Review Pass (minimal, kein Risiko)

**Was:**
- Creative Director als separater Pipeline-Pass nach Bug Review
- Nur fuer `feature` und `screen` Templates
- Advisory: Output wird geloggt, kein Gate-Veto
- System Message basiert auf `factory_premium_product_principles.md`

**Aenderungen:**
- `config/agent_roles.json` -- neue Rolle `creative_director` hinzufuegen
- `agents/creative_director.py` -- Agent-File (identische Struktur wie `reviewer.py`)
- `config/agent_toggles.json` -- `"creative_director": true`
- `config/model_router.py` -- Route: `"creative_direction": Sonnet`
- `tasks/task_manager.py` -- Import + Instanziierung (wie alle anderen Agents)
- `main.py` -- Neuer Pass 2b zwischen Bug Review und Refactor

**Nicht aendern:**
- `phase_gates.json` -- kein neues Gate
- `workflows/phase_gate_manager.py` -- keine neue Logik
- Keine neuen Verzeichnisse oder Stores

### Phase 2: Gate-Integration (nach Validierung)

**Voraussetzung:** Phase 1 laeuft stabil, CD-Feedback ist nuetzlich und nicht generisch.

**Was:**
- CD-Output bekommt pass/conditional_pass/fail Semantik
- Neues Gate `creative_review` in `phase_gates.json`
- `PhaseGateManager` erweitert fuer neuen Gate-Typ
- Bei `fail`: Refactor-Pass bekommt expliziten CD-Feedback-Kontext
- Bei `pass`: Pipeline laeuft normal weiter

### Phase 3: Pre-Implementation Gates (nach Learning Loop)

**Voraussetzung:** Phase 2 stabil, factory_knowledge/ hat Daten, Learning Agent laeuft.

**Was:**
- Innovation Gate vor Implementation
- CD bekommt factory_knowledge/ Kontext
- Pre-impl Check prueft Differenzierungsfaktor und Motivations-Mechanik
- Kann Implementation blockieren wenn kein klares Produkt-Konzept vorliegt

---

## Technische Details

### Agent-File Struktur (Phase 1)
Identisch zu allen anderen Agents:
```python
# agents/creative_director.py
from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role

class CreativeDirectorAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("creative_director")
        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )
        self.agent = AssistantAgent(
            name="creative_director",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )

def create_creative_director_agent() -> AssistantAgent:
    return CreativeDirectorAgent().agent
```

### Task-String fuer CD-Pass (Phase 1)
```python
cd_review_task = (
    f"Review the generated implementation for '{user_task}' from a product quality perspective. "
    "Evaluate: Does this feel like a premium product or a generic template? "
    "Check for: emotional screen function, micro-copy quality, design consistency, "
    "interaction patterns beyond basic tap. "
    "Rate: pass / conditional_pass / fail. "
    "For each finding, give a concrete improvement suggestion."
)
```

### System Message Kern (agent_roles.json)
```
You are the Creative Director for the DriveAI AI Factory.

Your role:
- Evaluate generated UI/UX code for product quality (not technical correctness)
- Check if each screen has an emotional function (motivate, confirm, challenge)
- Check if micro-copy has personality vs generic labels
- Check if the design follows a consistent visual identity
- Check if there are meaningful interaction patterns beyond basic button taps

Rules:
- Generic output is not acceptable
- "It works" is not enough -- it must feel intentional
- Focus on what makes this product different from every other app
- Give concrete suggestions, not vague feedback
- You do NOT write code -- you evaluate and suggest

Reference: docs/factory_premium_product_principles.md
```
