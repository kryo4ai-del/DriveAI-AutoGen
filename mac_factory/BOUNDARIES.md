# Mac Factory — Boundary Rules

## Directory Ownership

| Path | Owner | Mac can read? | Mac can write? |
|---|---|---|---|
| `mac_factory/` | Mac | YES | YES |
| `projects/` | Shared | YES | YES |
| `factory/` | Windows | NO | NO |
| `.git/` | Shared | YES (status/log) | YES (commit/push) |

## Rules

1. **Mac agents NEVER read `factory/`** — the version on Mac is outdated.
   All Factory information comes from Windows via HTTP APIs:
   - Agent Registry → `GET http://<windows>:8421/agents/list`
   - Costs → `GET http://<windows>:8421/brain/costs`
   - Reports → `POST http://<windows>:8421/reports/submit`

2. **Mac agents NEVER write to `factory/`** — Windows is the source of truth.

3. **Windows agents NEVER read `mac_factory/`** — they use the HTTP API on port 8420.

4. **Git pull/merge is BLOCKED** on both Windows and Mac.
   Push only. No sync via Git. Sync via HTTP APIs.
   - Unlock pull: `bash .git/unlock-pull.sh`
   - Lock pull: `bash .git/lock-pull.sh`
   - Force merge: `ANDREAS_ALLOW_MERGE=1 git pull`

5. **`projects/` is shared** — Windows uploads via `POST /upload`, Mac builds locally.
   Both can read and write. Conflicts avoided because:
   - Windows only writes during upload
   - Mac only writes during build/repair
   - They don't operate on the same project at the same time
