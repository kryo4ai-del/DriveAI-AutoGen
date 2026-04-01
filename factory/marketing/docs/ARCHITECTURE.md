# Marketing Department — Architecture

## Layer-Diagramm

```
+---------------------------------------------------------------+
|  Layer 8: Integration & Automation                             |
|  [MarketingFeedbackLoop] [MarketingKnowledgeBase]             |
|  [MarketingCostReporter] [MarketingPipelineRunner]            |
+---------------------------------------------------------------+
|  Layer 7: Performance Marketing & Optimization                 |
|  [MKT-14 CampaignPlanner] [BudgetController]                 |
|  [ABTestTool] [SurveySystem]                                  |
+---------------------------------------------------------------+
|  Layer 6: PR & Outreach                                        |
|  [MKT-12 StorytellingAgent] [MKT-13 PRAgent]                 |
|  [PressKitGenerator] [PressDatabase] [InfluencerDatabase]     |
|  [CommunityTemplates]                                         |
+---------------------------------------------------------------+
|  Layer 5: Research & Intelligence                              |
|  [TrendMonitor] [TikTokCreativeScraper] [CompetitorTracker]  |
|  [SentimentAnalyzer] [ContentTrendAnalyzer] [AppMarketScanner]|
+---------------------------------------------------------------+
|  Layer 4: Analytics & Community                                |
|  [MKT-09 ReportAgent] [MKT-10 ReviewManager]                 |
|  [MKT-11 CommunityAgent] [KPITracker] [SocialAnalyticsCollector]|
|  [HQBridge] [RankingDatabase]                                 |
+---------------------------------------------------------------+
|  Layer 3: Publishing & Distribution                            |
|  [MKT-08 PublishingOrchestrator]                              |
|  8 Active Adapters | 4 Publishing Stubs | 4 Ad-Platform Stubs |
+---------------------------------------------------------------+
|  Layer 2: Content Production                                   |
|  [MKT-03 Copywriter] [MKT-04 NamingAgent] [MKT-05 ASOAgent] |
|  [MKT-06 VisualDesigner] [MKT-07 VideoScriptAgent]           |
|  [MarketingTemplateEngine] [MarketingVideoPipeline]           |
|  [ContentCalendar]                                            |
+---------------------------------------------------------------+
|  Layer 1: Brand & Strategy                                     |
|  [MKT-01 BrandGuardian] [MKT-02 StrategyAgent]               |
+---------------------------------------------------------------+
|  Foundation: TheBrain (Model Routing), AlertManager, DB        |
+---------------------------------------------------------------+
```

## Datenfluss

```
                    TheBrain (LLM Routing)
                           |
          +----------------+----------------+
          |                                 |
    MKT-02 Strategy  <--  Pre-Production Outputs
          |                Factory Roadbooks
          v
    MKT-03 Copywriter ----> ContentCalendar
    MKT-05 ASO       ----> RankingDatabase
    MKT-06 Visual     ----> TemplateEngine ----> Output Files
    MKT-07 VideoScript ----> VideoPipeline ----> MP4 Files
          |
          v
    MKT-01 BrandGuardian (Compliance Check)
          |
          v
    MKT-08 PublishingOrchestrator
          |
    +-----+-----+-----+-----+
    |     |     |     |     |
   YT  TikTok   X   App   GP   (+ 4 Stubs + 4 Ad Stubs)
          |
          v
    Analytics Layer
    |-- SocialAnalyticsCollector --> RankingDatabase
    |-- KPITracker --> AlertManager
    |-- ReviewManager --> CEO-Gate (Zwei-Stufen)
          |
          v
    Research Layer
    |-- TrendMonitor (SerpAPI)
    |-- CompetitorTracker (Change Detection)
    |-- SentimentAnalyzer (Narrative Shift)
    |-- ContentTrendAnalyzer (Hook Library)
          |
          v
    Integration Layer
    |-- FeedbackLoop --> Insights --> Agents (ROUTING Map)
    |-- KnowledgeBase --> Persistentes Lernen
    |-- CostReporter --> TheBrain Kosten
    |-- PipelineRunner --> Full Marketing Cycle
```

## DB-Schema (20 Tabellen)

### Analytics & Tracking
| Tabelle | Spalten | Zweck |
|---|---|---|
| keyword_rankings | id, date, app_id, store, keyword, position, country | ASO Keyword-Positionen |
| app_metrics | id, date, app_id, store, metric_type, value, metadata_json | App KPIs |
| review_log | id, date, app_id, store, review_id, rating, title, body, author, response_text, response_status, stufe | Store Reviews + Responses |
| social_metrics | id, date, platform, metric_type, value, metadata_json | Social Media KPIs |
| post_performance | id, date, platform, post_id, content_type, impressions, engagements, likes, shares, comments | Post-Level Performance |

### Research & Intelligence
| Tabelle | Spalten | Zweck |
|---|---|---|
| trends | id, date, source, topic, description, relevance_score, urgency, content_suggestion, action_taken | Trend-Erkennung |
| competitors | id, date, level, competitor_name, category, store, store_rating, review_count, keyword_overlap, last_update, notes | Wettbewerber-Daten |
| competitor_snapshots | id, date, competitor_name, listing_text_hash, rating, review_count, version, metadata_json | Change Detection |
| github_repos | id, date, owner, repo, stars, forks, open_issues, language, last_push, description | GitHub Tracking |
| sentiment_data | id, date, topic, source, sentiment_score, sentiment_label, dominant_narratives, sample_count, confidence, summary | Sentiment-Analyse |
| factory_mentions | id, date, source, url, context, sentiment | Erwaehungen der Factory |

### Content & Hooks
| Tabelle | Spalten | Zweck |
|---|---|---|
| hook_library | id, hook_text, platform, topic, category, times_used, times_successful, success_rate, status, created_date, last_used | Hook-Bibliothek |
| format_performance | id, date, platform, format_type, avg_engagement, sample_count | Format-Vergleich |

### PR & Outreach
| Tabelle | Spalten | Zweck |
|---|---|---|
| press_contacts | id, name, outlet, email, role, topics, reach_estimate, country, language, status, last_contacted, notes | Presse-Kontakte |
| influencers | id, name, platform, handle, url, followers, topics, tier, engagement_rate, country, language, status, last_contacted, last_post_about_us, notes | Influencer-Datenbank |

### Phase 7: Optimization
| Tabelle | Spalten | Zweck |
|---|---|---|
| ab_tests | id, test_name, hypothesis, variant_a_desc, variant_b_desc, metric, start_date, end_date, winner, confidence, p_value, learnings | A/B Test-Ergebnisse |
| surveys | id, title, survey_type, platforms, questions_json, status, created_date, close_date, results_json, analysis | Umfragen |

### Phase 8: Integration
| Tabelle | Spalten | Zweck |
|---|---|---|
| feedback_tasks | id, task_id, insight_type, target_agent, description, data_json, recommended_action, priority, status, created_date, executed_date, result | Feedback-Loop Tasks |
| marketing_knowledge | id, category, insight, evidence, confidence, observations_count, first_observed, last_confirmed, source_agent, tags | Persistentes Wissen |
| pipeline_runs | id, project_slug, step_number, step_name, status, started_at, completed_at, output_path, error_message | Pipeline-Tracking |

## Adapter-Architektur

| Typ | Adapter | Status |
|---|---|---|
| Active (8) | YouTube, TikTok, X, AppStore, GooglePlay, GitHub, HuggingFace, SMTP | Funktional (Dry-Run Default) |
| Publishing Stubs (4) | Instagram, LinkedIn, Reddit, Twitch | Platzhalter, STATUS="stub" |
| Ad-Platform Stubs (4) | Meta Ads, Google Ads, TikTok Ads, Apple Search Ads | STATUS="stub_phase1", dry_run IMMER True |

Alle Adapter: `get_adapter(platform, dry_run=True)` aus `adapters/__init__.py`.
