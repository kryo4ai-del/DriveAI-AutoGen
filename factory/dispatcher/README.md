# Pipeline Dispatcher

Central queue manager connecting all factory departments.

## Usage

```bash
python main.py --factory-submit --idea "App idea" --title "AppName"
python main.py --factory-queue
python main.py --factory-next
python main.py --factory-execute
python main.py --factory-run "AppName" --auto-ceo-go
python main.py --factory-advance "AppName" --phase ceo_go
```

## Product Lifecycle

```
idea_submitted -> pre_production -> ceo_review -> ceo_go
  -> market_strategy -> mvp_scope -> cd_roadbook
  -> production -> assembly -> store_prep -> store_live
```
