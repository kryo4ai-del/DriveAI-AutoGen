# Marketing Adapters — Referenz (16 Adapter)

## Active Adapters (8)

### YouTubeAdapter
- **Plattform**: YouTube
- **Credentials**: `YOUTUBE_API_KEY`
- **Rate Limits**: YouTube Data API Quota (10.000 Units/Tag)
- **Methoden**: upload_video(), get_channel_stats(), get_video_stats(), search_videos()
- **Dry-Run**: Default True, gibt Mock-Responses zurueck

### TikTokAdapter
- **Plattform**: TikTok
- **Credentials**: `TIKTOK_ACCESS_TOKEN`
- **Rate Limits**: TikTok API Limits
- **Methoden**: post_video(), get_profile_stats(), get_video_stats()
- **Dry-Run**: Default True

### XAdapter
- **Plattform**: X (Twitter)
- **Credentials**: `X_API_KEY`, `X_API_SECRET`, `X_ACCESS_TOKEN`, `X_ACCESS_SECRET`
- **Rate Limits**: X API v2 Limits
- **Methoden**: post_tweet(), get_profile_stats(), get_tweet_stats(), create_poll()
- **Dry-Run**: Default True

### AppStoreAdapter
- **Plattform**: Apple App Store
- **Credentials**: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_PATH`
- **Rate Limits**: App Store Connect API Limits
- **Methoden**: get_app_info(), get_reviews(), get_ratings(), respond_to_review()
- **Dry-Run**: Default True

### GooglePlayAdapter
- **Plattform**: Google Play Store
- **Credentials**: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- **Rate Limits**: Google Play Developer API Limits
- **Methoden**: get_app_info(), get_reviews(), get_ratings(), respond_to_review()
- **Dry-Run**: Default True

### GitHubAdapter
- **Plattform**: GitHub
- **Credentials**: `GITHUB_TOKEN`
- **Rate Limits**: 5.000 Requests/Stunde (authenticated)
- **Methoden**: get_repo_info(), search_repos(), get_trending(), track_repo()
- **Dry-Run**: Default True, nutzt echte API fuer Read-Only

### HuggingFaceAdapter
- **Plattform**: HuggingFace Hub
- **Credentials**: `HUGGINGFACE_TOKEN` (optional fuer public)
- **Rate Limits**: Standard API Limits
- **Methoden**: get_model_info(), search_models(), get_trending(), compare_models()
- **Dry-Run**: Default True, nutzt echte API fuer Read-Only

### SMTPAdapter
- **Plattform**: Email (SMTP)
- **Credentials**: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`
- **Rate Limits**: Provider-abhaengig
- **Methoden**: send_email(), send_bulk(), send_press_release()
- **Dry-Run**: Forced True wenn kein SMTP_HOST konfiguriert

## Publishing Stubs (4)

| Adapter | Plattform | STATUS | Methoden |
|---|---|---|---|
| InstagramAdapter | Instagram | stub | post_image(), get_profile_stats() |
| LinkedInAdapter | LinkedIn | stub | post_article(), get_profile_stats() |
| RedditAdapter | Reddit | stub | create_post(), get_subreddit_stats() |
| TwitchAdapter | Twitch | stub | create_clip(), get_channel_stats() |

Alle Stubs: `dry_run=True` immer, geben `{"stub": True, ...}` zurueck. Kein Credential-Check.

## Ad-Platform Stubs (4)

| Adapter | Plattform | STATUS | Credentials |
|---|---|---|---|
| MetaAdsAdapter | Meta/Facebook Ads | stub_phase1 | META_ADS_ACCESS_TOKEN, META_ADS_APP_ID, META_ADS_APP_SECRET, META_ADS_ACCOUNT_ID |
| GoogleAdsAdapter | Google Ads | stub_phase1 | GOOGLE_ADS_CLIENT_ID, GOOGLE_ADS_CLIENT_SECRET, GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_REFRESH_TOKEN, GOOGLE_ADS_CUSTOMER_ID |
| TikTokAdsAdapter | TikTok Ads | stub_phase1 | TIKTOK_ADS_ACCESS_TOKEN, TIKTOK_ADS_ADVERTISER_ID, TIKTOK_ADS_APP_ID |
| AppleSearchAdsAdapter | Apple Search Ads | stub_phase1 | APPLE_SEARCH_ADS_ORG_ID, APPLE_SEARCH_ADS_KEY_ID, APPLE_SEARCH_ADS_TEAM_ID, APPLE_SEARCH_ADS_KEY_PATH |

Alle Ad-Stubs:
- `STATUS = "stub_phase1"`
- `self.dry_run = True` (ignoriert Parameter)
- Kein Credential-Check im __init__
- 5 Methoden: create_campaign(), set_budget(), set_targeting(), get_performance(), pause_campaign()
- Alle Methoden geben `{"stub": True, "method": "...", "platform": "..."}` zurueck
- Phase 2 (Live) erfordert: echtes Produkt im Store + CEO-Freigabe + Budget-Freigabe
