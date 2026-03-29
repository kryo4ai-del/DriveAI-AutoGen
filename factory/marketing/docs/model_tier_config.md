# Marketing Agents — Model Tier Config

Uebersicht aller LLM-Aufrufe in den Marketing-Agents.
`expected_output_tokens` wird an TheBrain `get_model()` weitergereicht und beeinflusst die Modellwahl.

## Richtwerte

| Kategorie | Tokens | Typische Outputs |
|---|---|---|
| Kurz | 1024-2048 | Naming, Compliance-Check, Creative Brief, Whats-New |
| Mittel | 4096 | Social Media Packs, Video-Skripte, Keyword Research, Ad Copy |
| Lang | 8192 | Store Listings, Blog-Artikel, Brand Book, Direktiven, Lokalisierte Listings |

## Agent-Methoden

### MKT-01 Brand Guardian (`brand_guardian.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `create_brand_book()` | 8192 | Lang |
| `create_app_style_sheet()` | 4096 | Mittel |
| `check_brand_compliance()` | 2048 | Kurz |

### MKT-02 Strategy (`strategy.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `create_factory_narrative()` | 8192 | Lang |
| `create_app_story_brief()` | 8192 | Lang |
| `create_marketing_directive()` | 8192 | Lang |

### MKT-03 Copywriter (`copywriter.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `create_social_media_pack()` | 4096 | Mittel |
| `create_store_listing()` | 8192 | Lang |
| `create_blog_article()` | 8192 | Lang |
| `create_ad_copy()` | 4096 | Mittel |

### MKT-04 Naming Agent (`naming_agent.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `generate_names()` | 2048 | Kurz |

### MKT-05 ASO Agent (`aso_agent.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `keyword_research()` | 4096 | Mittel |
| `create_localized_listing()` | 8192 | Lang |
| `create_whats_new()` | 1024 | Kurz |
| `competitor_keyword_analysis()` | 4096 | Mittel |

### MKT-06 Visual Designer (`visual_designer.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `_generate_creative_brief()` | 2048 | Kurz |
| `create_app_store_screenshots()` | 1024 | Kurz |

### MKT-07 Video Script Agent (`video_script_agent.py`)

| Methode | max_tokens | Kategorie |
|---|---|---|
| `create_video_script()` | 4096 | Mittel |
| `create_daily_factory_content()` | 2048 | Kurz |

## Hinweise

- Alle Agents nutzen `get_model(profile="standard", expected_output_tokens=max_tokens)`
- TheBrain filtert Modelle nach `max_output_tokens >= expected_output_tokens`
- AutoSplitter entscheidet ob Split/Switch noetig (wenn Token > 90% des Modell-Max)
- Kein Agent hat hardcoded Modellnamen — nur Tier-Level ueber `profile` Parameter
