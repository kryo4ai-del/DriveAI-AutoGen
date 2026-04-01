# Marketing Tools — Referenz (24 Tools)

## Uebersicht

| # | Tool | Typ | DB-Tabellen |
|---|---|---|---|
| 1 | MarketingTemplateEngine | deterministisch | - |
| 2 | MarketingVideoPipeline | deterministisch | - |
| 3 | ContentCalendar | deterministisch | - |
| 4 | RankingDatabase | deterministisch | ALLE 20 |
| 5 | SocialAnalyticsCollector | deterministisch | social_metrics, post_performance |
| 6 | KPITracker | deterministisch | app_metrics |
| 7 | HQBridge | deterministisch | - |
| 8 | TrendMonitor | hybrid (SerpAPI + LLM) | trends |
| 9 | TikTokCreativeScraper | hybrid (Scraping + LLM) | - |
| 10 | CompetitorTracker | hybrid (API + LLM) | competitors, competitor_snapshots |
| 11 | SentimentAnalyzer | hybrid (SerpAPI + LLM) | sentiment_data, factory_mentions |
| 12 | ContentTrendAnalyzer | hybrid (LLM fuer Extraktion) | hook_library, format_performance, post_performance |
| 13 | AppMarketScanner | LLM | - |
| 14 | PressDatabase | deterministisch | press_contacts |
| 15 | InfluencerDatabase | deterministisch | influencers |
| 16 | PressKitGenerator | deterministisch | - |
| 17 | CommunityTemplates | deterministisch | - |
| 18 | BudgetController | deterministisch | - |
| 19 | ABTestTool | deterministisch (scipy) | ab_tests |
| 20 | SurveySystem | hybrid (LLM fuer Analyse) | surveys |
| 21 | MarketingFeedbackLoop | deterministisch | feedback_tasks, post_performance, hook_library, format_performance, sentiment_data, competitor_snapshots |
| 22 | MarketingKnowledgeBase | deterministisch | marketing_knowledge |
| 23 | MarketingCostReporter | deterministisch | - |
| 24 | MarketingPipelineRunner | deterministisch | pipeline_runs |

## Detail

### 1. MarketingTemplateEngine
Pillow-basierte Bild-Generierung. 11 Formate, 7 Methoden. Liest Brand-Farben aus brand_book.json.

### 2. MarketingVideoPipeline
FFmpeg-basierte Video-Generierung. 5 Formate (TikTok, Shorts, YouTube, Reels, Stories). Lokal, $0 Kosten.

### 3. ContentCalendar
Deterministischer Content-Kalender. 8 Methoden. Launch-Kampagnen-Planung, Plattform-uebergreifend.

### 4. RankingDatabase
SQLite-basierte zentrale Datenbank. 20 Tabellen, 40+ Methoden. Alle Marketing-Metriken.

### 5. SocialAnalyticsCollector
Sammelt Social Media Metriken von allen aktiven Adaptern. Speichert in social_metrics + post_performance.

### 6. KPITracker
7 KPIs (D1/D7/D30 Retention, Store Rating, Crash Rate, ARPU, DAU). Warning/Critical Thresholds. Erstellt Alerts.

### 7. HQBridge
JSON-Export fuer das CEO Dashboard. Konvertiert interne Daten in Dashboard-kompatibles Format.

### 8. TrendMonitor
SerpAPI + LLM. Google News Trends, App-Trends. Keyword-Fallback wenn kein API-Key.

### 9. TikTokCreativeScraper
Dreistufig: Scraping -> SerpAPI -> LLM. 137 Hashtags live gescrapt (Phase 2 Test).

### 10. CompetitorTracker
App-Level + Factory-Level. Change Detection via Hash-Vergleich. Differentiator Matrix.

### 11. SentimentAnalyzer
3 Ebenen (ai_apps, autonomous_ai, driveai). SerpAPI-Scan + LLM-Analyse. Narrative Shift Detection.

### 12. ContentTrendAnalyzer
Hook-Bibliothek (hypothesis -> proven -> deprecated). Format-Performance-Matrix. Auto-Promotion/Deprecation.

### 13. AppMarketScanner
Marktluecken-Finder. find_market_gaps(category) -> Ideen -> CEO-Gate Pipeline.

### 14. PressDatabase
15 Seed-Kontakte. 3-Tier Research. Search, Status-Updates, Stats.

### 15. InfluencerDatabase
Auto-Tier (nano/micro/macro/mega). Auto-Discover. Search, Status, Stats.

### 16. PressKitGenerator
Liest LIVE aus agent_registry.json. Factory + App Press Kits. ZIP-Package.

### 17. CommunityTemplates
6 Plattform-Templates (Reddit AI/ML, HN, PH, Dev.to, Indie Hackers). Deterministisch, fill_template().

### 18. BudgetController
100% deterministisch. calculate_budget_split() (rundungsfehler-frei), project_roi() (CPM-basiert), validate_budget(), compare_campaigns(). KEIN ECHTES GELD.

### 19. ABTestTool
Z-Test fuer zwei Proportionen. scipy.stats mit Fallback auf Abramowitz & Stegun (max Fehler <7.5e-8). Sample-Size Berechnung.

### 20. SurveySystem
Plattform-spezifische Limits (X: 4 Opts, Reddit: 6, YouTube: 4). Validierung, Formatierung, DB-Speicherung.

### 21. MarketingFeedbackLoop
9 Insight-Typen, ROUTING Map zu 7 Agents. Analysiert: Post-Performance, Hooks, Formate, Sentiment, Competitors. Task Lifecycle: open -> executed -> measured.

### 22. MarketingKnowledgeBase
5 Kategorien, 8 Agents im AGENT_KNOWLEDGE_MAP. Auto-Promotion: hypothesis (1) -> confirmed (2+) -> established (5+). Jaccard-Similarity Deduplizierung.

### 23. MarketingCostReporter
Versucht Live-Daten aus TheBrain, Fallback auf Schaetzung. Factory vs Market Benchmark ($163k). JSON-Export + MD-Report.

### 24. MarketingPipelineRunner
12 Steps, orchestriert den gesamten Marketing-Zyklus. Graceful failure (try/except pro Step). Alert bei Fehler. DB-Tracking.
