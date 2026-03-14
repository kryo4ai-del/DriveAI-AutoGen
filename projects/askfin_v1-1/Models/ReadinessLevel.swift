enum ReadinessLevel {
    case notStarted, beginner, intermediate, advanced, mastered
    
    var label: String {
        switch self {
        case .notStarted: return "Not Started"
        case .beginner: return "Beginner (0–40%)"
        case .intermediate: return "Intermediate (40–70%)"
        case .advanced: return "Advanced (70–90%)"
        case .mastered: return "Mastered (90%+)"
        }
    }
}