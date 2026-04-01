# Marketing Security Rules

## CEO-Gates

### Permanente CEO-Gates (IMMER Gate, keine Ausnahme)
- **Crisis Response**: PRAgent.create_crisis_response_draft() erstellt IMMER ein CEO-Gate
- **App-Ideen**: AppMarketScanner.submit_idea_to_pipeline() erstellt IMMER ein CEO-Gate
- **Namensentscheidung**: NamingAgent bei guten Kandidaten

### Stufenweise CEO-Gates
- **Reviews Stufe 2**: Rating <= 2 ODER Rating 3 mit Tier-2-Keywords
- **Community Stufe 2**: Negative/kontroverse Social-Media-Kommentare
- **Budget-Freigabe**: Echte Kampagnen (Phase 2, noch nicht implementiert)

## Zwei-Stufen-System

### Stufe 1 (Autonom)
- Positiv (Rating >= 4) UND keine Tier-2-Keywords
- LLM generiert Antwort, wird automatisch vorgeschlagen
- ABER: noch kein automatisches Posten (Dry-Run Default)

### Stufe 2 (CEO-Gate)
- Rating <= 2 (immer)
- Rating 3 mit mindestens einem Tier-2-Keyword
- Erstellt Gate-Request, KEINE automatische Antwort
- CEO muss entscheiden

### Tier-2 Keywords (deterministisch, kein LLM)
```
betrug, scam, abzocke, diebstahl, luege, fake,
funktioniert nicht, crashes, abstuerz, absturz,
geld zurueck, refund, erstattung,
datenschutz, privacy, daten gestohlen, daten verkauft,
anwalt, rechtsanwalt, klage, verklagen,
gefaehrlich, unsicher,
diskriminier, rassist, sexist,
politisch, propaganda,
besser als, wechsle zu, alternative
```

### Warum kein LLM fuer Stufen-Entscheidung
- LLMs koennen halluzinieren und falsch klassifizieren
- Ein falsch-positives Auto-Response auf einen wuetenden Kunden = PR-Krise
- Keyword-Matching ist 100% deterministisch und nachvollziehbar
- Lieber ein CEO-Gate zu viel als eine falsche Antwort

## Dry-Run Defaults

### Immer Dry-Run
- Alle Ad-Platform-Stubs: `self.dry_run = True` (ignoriert Parameter)
- Alle Publishing-Stubs: Dry-Run Default
- SMTPAdapter: Forced Dry-Run wenn kein SMTP_HOST

### Dry-Run Default (ueberschreibbar)
- Alle Active Adapter: `dry_run=True` als Default
- get_adapter(platform, dry_run=True)
- Publishing Orchestrator: Dry-Run Default

### Wann Live erlaubt
- NUR mit explizitem `dry_run=False`
- NUR wenn Credentials konfiguriert
- NUR nach CEO-Freigabe (manuell, nicht automatisiert)

## Budget-Hard-Limits

### BudgetController
- Kein echtes Geld — nur Planung und Simulation
- `simulation_only: True` in allen Outputs
- project_roi() nutzt Branchen-Durchschnitte, keine echten Daten

### MarketingCostReporter
- Liest nur, schreibt nicht
- Market Benchmarks (hardcoded):
  - Marketing Team (6 Monate): $120,000
  - Content Production (Agentur): $15,000
  - Market Research: $8,000
  - PR Outreach: $12,000
  - Performance Marketing Setup: $5,000
  - Analytics Tools: $3,000
  - **Total: $163,000**

### Ad-Platform Stubs
- KEIN create_campaign() mit echtem Budget
- KEIN set_budget() mit echtem Geld
- Alles gibt `{"stub": True}` zurueck
- Phase 2 (Live) erfordert separate Freigabe

## Dashboard-Schutz

### Warum Phase 9 (noch nicht implementiert)
- Dashboard zeigt nur READ-ONLY Daten
- KEIN Live-Publishing ueber Dashboard
- KEIN Budget-Freigabe ueber Dashboard
- KEIN automatisches Review-Response ueber Dashboard

### Was das Dashboard zeigen wird
- Alert-Uebersicht (read-only)
- Gate-Entscheidungen (via Gate-System, nicht direkt)
- KPI-Dashboard (read-only)
- Pipeline-Status (read-only)

## Kein Live-Publishing

### Regel
KEIN Content wird automatisch veroeffentlicht. Alles ist Dry-Run.

### Ausnahmen (nur mit CEO-Freigabe)
1. CEO setzt explizit `dry_run=False`
2. Credentials sind konfiguriert
3. Content hat Brand-Compliance bestanden (score >= 70)
4. Kein Tier-2-Keyword-Match im Content

### Warum
- Einmal veroeffentlicht = nicht zuruecknehmbar
- Ein falscher Post kann den Ruf zerstoeren
- Lieber 100 Dry-Runs als 1 falscher Live-Post
