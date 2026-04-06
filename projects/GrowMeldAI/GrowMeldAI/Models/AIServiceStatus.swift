// ✅ Good
enum AIServiceStatus {
    case online
    case offline
    case degraded(reason: String)  // reason is user-facing
    
    var userDescription: String {
        switch self {
        case .online:
            return "AI-Funktionen aktiv"  // ← German user description
        // ...
        }
    }
}

// ❌ Avoid
enum AIServiceStatus {
    case online
    case offline
    case fehler(grund: String)  // ← Mixed German/English is confusing
}