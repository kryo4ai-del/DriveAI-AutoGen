# DriveAI Commands

Quick reference for CLI usage.

---

# Run Modes

Quick run (fastest):

python main.py --mode quick

Standard development run:

python main.py --mode standard

Full development run:

python main.py --mode full

---

# Approval Modes

Auto integrate generated code:

--approval auto

Ask before integrating code:

--approval ask

Skip integration:

--approval off

---

# Profiles

Development profile:

--profile dev

Safe review profile:

--profile safe

Agentic full profile:

--profile agentic

---

# Generate Feature

Example:

python main.py --template feature --name FeatureName --profile dev --approval auto

Example:

python main.py --template feature --name LearningMode --profile dev --approval auto

---

# Task Packs

Example:

python main.py --pack screen_plus_viewmodel --name Settings

---

# Queue System

Add task:

python main.py --queue-add "Create Settings Screen"

Run next task:

python main.py --queue-run

Run all tasks:

python main.py --queue-run-all

Limit batch:

python main.py --queue-run-all --limit 3

---

# Templates

List templates:

python main.py --list-templates

Use template:

python main.py --template screen --name Home

---

# Analytics

Show analytics:

python main.py --analytics-summary

---

# Import / Export

Export backlog:

python main.py --export-backlog file.json

Import backlog:

python main.py --import-backlog file.json

---

# Session Presets

List presets:

python main.py --list-session-presets

Use preset:

python main.py --session-preset fast_local