// Use String everywhere, localize at display time
struct ExamReadiness: Identifiable, Codable {
    enum ReadinessLevel: String, Codable {
        case notReady, onTrack, exceeding
        
        var label: String { // ✅ String, not LocalizedStringKey
            switch self {
            case .notReady: return NSLocalizedString("exam_not_ready", comment: "")
            // ...
            }
        }
    }
}

// In Views, wrap with Text()
// [FK-019 sanitized] Text(readiness.readinessLevel.label) // SwiftUI auto-localizes