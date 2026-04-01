# Marketing Operations Guide

## Marketing-Zyklus starten

```python
from factory.marketing.tools.pipeline_runner import MarketingPipelineRunner

pr = MarketingPipelineRunner()
result = pr.run_full_cycle("echomatch", dry_run=True)
# result: {"steps_total": 12, "steps_completed": N, "steps_failed": N, ...}
```

12 Steps: Strategy -> Copywriter -> ASO -> Visual -> Video -> Brand Check -> Press Kit -> Case Study -> PR

Jeder Step ist unabhaengig — ein Fehler bricht NICHT die Pipeline ab.

## Einzelnen Step ausfuehren

```python
result = pr.run_step("echomatch", step_number=3)  # nur Social Media Pack
```

## Pipeline-Status pruefen

```python
status = pr.get_pipeline_status("echomatch")
# {"steps_total": 12, "completed": N, "failed": N, "steps": [...]}
```

## Alerts pruefen

```python
from factory.marketing.alerts.alert_manager import MarketingAlertManager

am = MarketingAlertManager()
alerts = am.get_active_alerts()                    # Alle offenen
alerts = am.get_active_alerts(priority_filter="critical")  # Nur kritische
stats = am.get_alert_stats()                       # Uebersicht
```

## CEO-Gates bearbeiten

```python
gates = am.get_pending_gates()
for gate in gates:
    print(f"{gate['gate_id']}: {gate['title']}")
    for opt in gate['options']:
        print(f"  - {opt['label']}: {opt['description']}")

# Entscheidung treffen
am.resolve_gate("MKT-G001-...", decision="approve", note="Go ahead")
```

## Neuen Agent hinzufuegen

1. **Persona-JSON**: `factory/marketing/agents/agent_<name>.json`
   ```json
   {"id": "MKT-15", "name": "...", "role": "...", "department": "Marketing",
    "status": "active", "task_type": "...", "model_tier": "mid",
    "default_model": "via TheBrain", "provider": "dynamic", "routing": "TheBrain"}
   ```

2. **Python-Datei**: `factory/marketing/agents/<name>.py`
   - SYSTEM_MESSAGE Konstante
   - Klasse mit `_call_llm()` und Public Methods

3. **Registry**: In `factory/agent_registry.json` eintragen (im Marketing-Block)

4. **__init__.py**: Import in `factory/marketing/agents/__init__.py`

## Hook-Bibliothek aktualisieren

```python
from factory.marketing.tools.content_trend_analyzer import ContentTrendAnalyzer

cta = ContentTrendAnalyzer()

# Hook speichern
hook_id = cta.save_hook("Wusstest du...?", "tiktok", "factory", "question")

# Nach Nutzung: Erfolg melden
cta.record_hook_usage(hook_id, successful=True)  # -> "proven" nach 2x

# Empfohlene Hooks abrufen
hooks = cta.get_recommended_hooks("tiktok")
```

## A/B-Test durchfuehren

```python
from factory.marketing.tools.ab_test_tool import ABTestTool

abt = ABTestTool()

# 1. Sample Size berechnen
size = abt.calculate_sample_size(baseline_rate=0.05, min_detectable_effect=0.20)
# size["sample_size_per_variant"] ~ 6000-7000

# 2. Test auswerten
result = abt.evaluate_test(
    "cta_headline", n_a=10000, conv_a=600, n_b=10000, conv_b=500,
    hypothesis="Neue Headline hat hoehere CTR",
    variant_a_desc="Neue Headline", variant_b_desc="Alte Headline",
)
# result["significant"], result["winner"], result["p_value"]
```

## Kampagne planen

```python
from factory.marketing.agents.campaign_planner import CampaignPlanner

cp = CampaignPlanner()
output = cp.plan_launch_campaign("echomatch")  # 3-Phasen-Plan (MD + JSON)
output = cp.plan_content_campaign("echomatch")  # Thematische Serie
summary = cp.get_campaign_summary("echomatch")  # Deterministisch
```

## Tagesroutine (CEO-Morgen-Check)

1. **Alerts pruefen**: `MarketingAlertManager().get_active_alerts(priority_filter="critical")`
2. **Gates entscheiden**: `am.get_pending_gates()` — offene Entscheidungen
3. **KPIs pruefen**: `KPITracker().run_daily_check("echomatch")`
4. **Feedback-Loop**: `MarketingFeedbackLoop().analyze_and_route(7)` — letzte Woche
5. **Knowledge-Report**: `MarketingKnowledgeBase().get_knowledge_stats()`
6. **Kosten**: `MarketingCostReporter().calculate_marketing_costs()`

## Feedback-Loop nutzen

```python
from factory.marketing.tools.feedback_loop import MarketingFeedbackLoop

fl = MarketingFeedbackLoop()
result = fl.analyze_and_route(period_days=7)
# result: {"insights_found": N, "tasks_created": N, "tasks": [...]}

# Offene Tasks
tasks = fl.get_open_tasks(target_agent="MKT-03")

# Nach Umsetzung: Ergebnis tracken
fl.track_feedback_execution(task_id, "Hooks auf Fragen umgestellt")
```

## Knowledge Base nutzen

```python
from factory.marketing.tools.marketing_knowledge import MarketingKnowledgeBase

kb = MarketingKnowledgeBase()

# Wissen hinzufuegen
kid = kb.add_knowledge("content_insights", "Short-form beats long-form auf TikTok", "A/B-Test Q1")

# Wissen fuer Agent abrufen
insights = kb.get_knowledge_for_agent("MKT-03")  # Top 10, nach Confidence sortiert

# Wissen bestaetigen (Auto-Promotion)
kb.confirm_knowledge(kid)  # hypothesis -> confirmed (ab 2)
```
