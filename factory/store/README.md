# Store Submission Pipeline

Prepares apps for App Store, Play Store, and Web deployment.

## Usage

```bash
# Full pipeline
python main.py --store-pipeline <project>

# Just readiness check
python main.py --store-readiness <project>

# Prepare metadata for a platform
python main.py --store-prepare <project> --platform ios

# Check compliance
python main.py --store-compliance <project> --platform android
```

## Components

| Module | Purpose |
|---|---|
| metadata_generator | App name, description, keywords, privacy |
| compliance_checker | Review guideline checks (deterministic) |
| build_packager | Platform-specific packaging |
| submission_preparer | Submission folder organization |
| readiness_report | CEO-readable status assessment |
