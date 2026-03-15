# Command: NetworkMonitor Symbol-Scope Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Loese den `NetworkMonitor` not-in-scope Blocker in OfflineStatusViewModel.swift. Dann Typecheck-Recheck.

## Kontext

`OfflineStatusViewModel.swift:10` — `cannot find 'NetworkMonitor' in scope`
Referenziert `NetworkMonitor.shared.isConnected` — der Typ existiert nicht im Projekt.

## Aufgaben

### 1. Root Cause pruefen

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main

# Existiert NetworkMonitor irgendwo?
grep -rn "class NetworkMonitor\|struct NetworkMonitor\|protocol NetworkMonitor" projects/askfin_v1-1/ --include="*.swift"

# Wo wird es referenziert?
grep -rn "NetworkMonitor" projects/askfin_v1-1/ --include="*.swift"

# Wie sieht OfflineStatusViewModel aus?
cat projects/askfin_v1-1/ViewModels/OfflineStatusViewModel.swift
```

### 2. Symbol-Scope Policy

Erweitere `config/residual_compile_policy.json`:

```json
{
  "missing_infrastructure_type": {
    "policy": "stub-or-minimal-implementation",
    "description": "Wenn ein Infrastructure-Typ (Monitor, Manager, Client) referenziert wird aber nicht existiert, erstelle eine minimale Implementierung wenn der Verwendungskontext klar ist, oder einen Stub wenn nicht.",
    "preference": "Wenn der Typ ein Singleton-Pattern nutzt (.shared), erstelle eine minimal-funktionale Implementierung statt nur eines Stubs."
  }
}
```

### 3. Fix anwenden

`NetworkMonitor` ist typischerweise ein NWPathMonitor-Wrapper. Minimale Implementierung:

```swift
// Services/NetworkMonitor.swift
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
```

Falls `Network` Framework auf dem Mac nicht verfuegbar ist (unwahrscheinlich), erstelle stattdessen einen Stub:

```swift
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    @Published private(set) var isConnected = true
    private init() {}
}
```

### 4. Typecheck Recheck

```bash
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  -not -path "*Tests*" \
  > /tmp/askfin_app_files.txt

swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  $(cat /tmp/askfin_app_files.txt) 2>&1 | head -50
echo "Exit code: $?"
echo "Error count:"
swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  $(cat /tmp/askfin_app_files.txt) 2>&1 | grep "error:" | wc -l
```

### 5. Report

Report in `DeveloperReports/CodeAgent/53-0_NetworkMonitor Fix Report.md` mit:
1. Root Cause (fehlender Typ / Stub vs Implementierung)
2. Was erstellt wurde
3. Typecheck-Ergebnis
4. Ob 0 Errors erreicht oder was noch bleibt

### 6. Commit + Push

```bash
git add -A
git commit -m "factory: missing infrastructure type policy + NetworkMonitor implementation

- Policy: stub-or-minimal-implementation for infrastructure types
- Created: Services/NetworkMonitor.swift (NWPathMonitor wrapper)
- Report 53-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/012_networkmonitor_fix_result.md` speichern.
