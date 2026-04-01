# Marketing Agents — Referenz (14 Agents)

## MKT-01: Brand Guardian
- **Rolle**: Markenhueter und Compliance-Checker
- **model_tier**: mid
- **System Message**: Prueft alle Marketing-Outputs auf Brand-Konformitaet. Erstellt Brand Books, App Style Sheets. Gibt Score 0-100 zurueck.
- **Methoden**:
  - `create_brand_book(brain_directives=None) -> str` — Brand Book (MD + JSON)
  - `create_app_style_sheet(project_slug) -> str` — App-spezifisches Style Sheet
  - `evaluate_name_brand_fit(name, idea) -> dict` — Brand-Fit Score
  - `check_brand_compliance(content, content_type="social_post") -> dict` — Score + Issues
- **Inputs**: Brand-Dateien aus `factory/marketing/brand/`
- **Outputs**: `factory/marketing/brand/`, Compliance-Dicts
- **Abhaengigkeiten**: TheBrain (LLM)

## MKT-02: Strategy Agent
- **Rolle**: Marketing-Strategie und Direktiven
- **model_tier**: mid
- **System Message**: Erstellt Factory-Narrativ, App Story Briefs und Marketing-Direktiven basierend auf Pre-Production und Market-Strategy Outputs.
- **Methoden**:
  - `create_factory_narrative(factory_facts=None) -> dict` — Factory-Narrativ
  - `create_app_story_brief(project_slug) -> str` — App Story Brief (MD)
  - `create_marketing_directive(project_slug) -> str` — Marketing-Direktive (MD)
- **Inputs**: Pre-Production Outputs, Market Strategy, agent_registry.json
- **Outputs**: `factory/marketing/output/{slug}/`
- **Abhaengigkeiten**: TheBrain (LLM), PIPELINE_SOURCES

## MKT-03: Copywriter
- **Rolle**: Content-Produktion fuer alle Plattformen
- **model_tier**: mid
- **System Message**: Schreibt Social Media Packs, Store Listings, Blog-Artikel, Ad Copy. Mehrsprachig, mit A/B-Varianten und Store-Limit-Pruefung.
- **Methoden**:
  - `create_social_media_pack(project_slug, platforms=None, language="de") -> str` — Multi-Platform Pack (MD)
  - `create_store_listing(project_slug, store="both", language="de") -> dict` — Store Listing
  - `create_blog_article(project_slug, article_type="case_study", language="de") -> str`
  - `create_ad_copy(project_slug, platforms=None, language="de") -> str`
- **Inputs**: Story Brief, Marketing-Direktive, Brand Book
- **Outputs**: `factory/marketing/output/{slug}/`
- **Abhaengigkeiten**: TheBrain (LLM), BrandGuardian (optional)

## MKT-04: Naming Agent
- **Rolle**: App-Namensgenerierung mit Verfuegbarkeitspruefung
- **model_tier**: mid
- **System Message**: Generiert App-Namen via LLM, prueft Domain/Social/Store Verfuegbarkeit, erstellt CEO-Gate bei guten Kandidaten.
- **Methoden**:
  - `generate_names(idea, requirements=None) -> dict`
  - `check_availability(name) -> dict`
- **Inputs**: App-Idee/Beschreibung
- **Outputs**: Name-Kandidaten, CEO-Gate
- **Abhaengigkeiten**: TheBrain (LLM), AlertManager (CEO-Gate)

## MKT-05: ASO Agent
- **Rolle**: App Store Optimization
- **model_tier**: mid
- **System Message**: Keyword Research, lokalisierte Store Listings, Competitor Analysis. SerpAPI-Integration fuer Live-Daten.
- **Methoden**:
  - `keyword_research(project_slug, markets=None) -> dict` — Keywords + Ranking
  - `create_localized_listing(project_slug, language="de", market="DE") -> str`
  - `create_whats_new(project_slug, version, changes_summary) -> str`
  - `pre_check_aso(name) -> dict` — Vorab-ASO-Check
  - `competitor_keyword_analysis(competitors, market="US") -> str`
- **Inputs**: Store Listing, Competitor Data, SerpAPI
- **Outputs**: `factory/marketing/output/{slug}/`, RankingDatabase
- **Abhaengigkeiten**: TheBrain (LLM), SerpAPI, RankingDatabase

## MKT-06: Visual Designer
- **Rolle**: Grafik-Erstellung (Social Media, Screenshots, Thumbnails, Ads)
- **model_tier**: mid
- **System Message**: Erstellt Creative Briefs via LLM, rendert mit Template-Engine. A/B-Varianten.
- **Methoden**:
  - `create_social_media_graphics(project_slug, platforms=None) -> dict` — PNG-Dateien
  - `create_app_store_screenshots(project_slug, device_type="iphone", count=5) -> list[str]`
  - `create_youtube_thumbnail(project_slug, headline_text=None) -> str`
  - `create_ad_creatives(project_slug, formats=None) -> dict`
- **Inputs**: Brand Book, Creative Brief, Project Context
- **Outputs**: `factory/marketing/output/{slug}/graphics/`
- **Abhaengigkeiten**: TheBrain (LLM), MarketingTemplateEngine (Pillow)

## MKT-07: Video Script Agent
- **Rolle**: Video-Skripte und Video-Erstellung
- **model_tier**: mid
- **System Message**: Schreibt Skripte fuer TikTok/Shorts/YouTube/Reels, erstellt Videos via FFmpeg Pipeline.
- **Methoden**:
  - `create_video_script(project_slug, format="tiktok", content_type="showcase") -> str` — Script (MD)
  - `create_daily_factory_content(topic=None) -> str` — Daily Content
  - `create_video_from_script(script_path, format_name="tiktok") -> str` — MP4 via FFmpeg
- **Inputs**: Story Brief, Brand Book
- **Outputs**: `factory/marketing/output/{slug}/video/`
- **Abhaengigkeiten**: TheBrain (LLM), MarketingVideoPipeline (FFmpeg)

## MKT-08: Publishing Orchestrator
- **Rolle**: Cross-Platform Publishing (Dry-Run Default)
- **model_tier**: (deterministisch, kein LLM)
- **System Message**: Orchestriert Veroeffentlichung ueber alle Adapter. Gestaffelter Kalender.
- **Methoden**: publish(), schedule(), get_publishing_status()
- **Inputs**: Content aus MKT-03/06/07
- **Outputs**: Publishing-Status, Calendar
- **Abhaengigkeiten**: Alle Adapter (Active + Stubs)

## MKT-09: Report Agent
- **Rolle**: Marketing-Berichte (Daily/Weekly/Monthly)
- **model_tier**: mid
- **System Message**: Erstellt zusammenfassende Reports basierend auf allen Analytics-Daten.
- **Methoden**: create_daily_report(), create_weekly_report(), create_monthly_report()
- **Inputs**: RankingDatabase, KPITracker, SocialAnalyticsCollector
- **Outputs**: `factory/marketing/reports/`
- **Abhaengigkeiten**: TheBrain (LLM), RankingDatabase

## MKT-10: Review Manager
- **Rolle**: Store-Review-Management mit Zwei-Stufen-System
- **model_tier**: mid
- **System Message**: Kategorisiert Reviews nach Tier (1=autonom, 2=CEO-Gate). KEIN LLM fuer Stufen-Entscheidung.
- **Methoden**:
  - `classify_review(review) -> dict` — Tier + Triggers (deterministisch)
  - `process_review(review, store="app_store") -> dict` — Respond oder Gate
  - `process_batch(reviews, store="app_store") -> dict` — Batch-Verarbeitung
- **Inputs**: Store Reviews (via AppStore/GooglePlay Adapter)
- **Outputs**: CEO-Gates, Response-Vorschlaege
- **Abhaengigkeiten**: AlertManager, TheBrain (nur fuer Tier-1 Antworten)

## MKT-11: Community Agent
- **Rolle**: Social Media Community Management
- **model_tier**: mid
- **System Message**: Zwei-Stufen-System fuer Social Media Kommentare. Keine automatischen Antworten auf negative Inhalte.
- **Methoden**: classify_comment(), respond_to_comment()
- **Inputs**: Social Media Kommentare
- **Outputs**: Response-Vorschlaege, CEO-Gates
- **Abhaengigkeiten**: AlertManager, TheBrain (nur fuer positive Antworten)

## MKT-12: Storytelling Agent
- **Rolle**: Content-Storytelling (Case Studies, Behind-the-Scenes)
- **model_tier**: mid
- **System Message**: Erstellt narrative Inhalte ueber die Factory. Nutzt ECHTE Daten aus agent_registry.json.
- **Methoden**:
  - `create_case_study(project_slug) -> str`
  - `create_behind_the_scenes(topic) -> str`
  - `create_milestone_story(milestone_description) -> str`
  - `create_cost_comparison(project_slug) -> str`
  - `create_technical_deep_dive(topic) -> str`
- **Inputs**: agent_registry.json (LIVE), Pre-Production Outputs
- **Outputs**: `factory/marketing/output/storytelling/`
- **Abhaengigkeiten**: TheBrain (LLM)

## MKT-13: PR Agent
- **Rolle**: Pressemitteilungen und Outreach
- **model_tier**: mid
- **System Message**: Erstellt PMs, Product Hunt Packages, Event Materials, Crisis Response. Crisis = IMMER CEO-Gate.
- **Methoden**:
  - `create_press_release(occasion, key_facts, target_regions=None) -> dict`
  - `plan_outreach(press_release_path, target_topics, target_countries) -> str`
  - `create_product_hunt_package(project_slug) -> str`
  - `create_event_materials(event_name, event_type) -> str`
  - `create_crisis_response_draft(situation_description) -> dict` — IMMER CEO-Gate
- **Inputs**: Press Database, Factory Facts
- **Outputs**: `factory/marketing/output/pr/`, CEO-Gates
- **Abhaengigkeiten**: TheBrain (LLM), PressDatabase, AlertManager

## MKT-14: Campaign Planner
- **Rolle**: Marketing-Kampagnen planen (nur Dokumente, KEIN echtes Geld)
- **model_tier**: mid
- **System Message**: Plant Launch/Content-Kampagnen mit Timeline, Budget-Verteilung, Kanal-Mix. Nutzt BudgetController.
- **Methoden**:
  - `plan_launch_campaign(project_slug) -> str` — 3-Phasen-Plan (Teaser/Launch/Sustain)
  - `plan_content_campaign(project_slug) -> str` — Thematische Content-Serie
  - `get_campaign_summary(project_slug) -> dict` — Deterministisch, liest JSON-Meta
- **Inputs**: BudgetController, Adapter-Liste, agent_registry.json
- **Outputs**: `factory/marketing/output/{slug}/campaigns/`
- **Abhaengigkeiten**: BudgetController, TheBrain (LLM)
