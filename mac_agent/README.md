# Mac Build Agent

Runs on your Mac. Watches for build commands from the factory (Windows), executes them, and reports back via Git.

## Setup

```bash
# On your Mac:
cd /path/to/DriveAI-AutoGen
bash mac_agent/install.sh
```

## Usage

```bash
# Start the agent (runs in foreground):
python3 mac_agent/mac_build_agent.py

# It will:
# 1. Git pull every 30 seconds
# 2. Check _commands/pending/ for new commands
# 3. Execute (build, test, archive)
# 4. Write results to _commands/completed/
# 5. Git push results
```

## Command Types

| Type | What it does |
|---|---|
| `health_check` | Verify Xcode + agent are running |
| `build_ios` | xcodebuild Debug build |
| `run_tests` | Run XCUITests / Golden Gates |
| `screenshots` | Capture screenshot set |
| `archive` | Create .xcarchive for App Store |

## From Factory (Windows)

```bash
python main.py --mac-status      # Check if Mac is available
python main.py --mac-build <project>   # Trigger iOS build
python main.py --mac-test <project>    # Run tests
python main.py --mac-archive <project> # Archive for App Store
```
