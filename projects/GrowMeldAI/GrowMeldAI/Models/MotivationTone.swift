public enum MotivationTone: Sendable {
    case celebration    // Mastered: green, larger font
    case encouragement  // 60-79%: yellow, standard font
    case momentum       // Starting: blue, small font
    case warning        // Exam imminent: red, bold
    
    public var recommendedUIElement: String {
        switch self {
        case .celebration: return "headline"
        case .encouragement: return "body"
        case .momentum: return "caption"
        case .warning: return "headline"
        }
    }
}

extension UserProgress {
    public var motivationTone: MotivationTone {
        if mastered { return .celebration }
        if accuracy >= 0.8 { return .encouragement }
        if accuracy >= 0.6 { return .momentum }
        return .warning
    }
}