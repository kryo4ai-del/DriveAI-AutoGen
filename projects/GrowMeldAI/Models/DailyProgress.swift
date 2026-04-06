public struct DailyProgress: Equatable, Sendable {
    public var questionsProgressPercent: Double
    public var questionsRemaining: Int
    
    public init(questionsProgressPercent: Double, questionsRemaining: Int) {
        self.questionsProgressPercent = questionsProgressPercent
        self.questionsRemaining = questionsRemaining
    }
    
    // Keep visual message for sighted users
    public var questionsMotivationalMessage: String {
        switch questionsProgressPercent {
        case 0..<0.2:
            return "🚀 Start your prep — every question counts!"
        case 0.5..<0.8:
            return "⚡ Halfway there — keep going!"
        default:
            return ""
        }
    }
    
    // ✅ Add screen-reader-safe alternative
    public var questionsAccessibilityMessage: String {
        let percentage = Int(questionsProgressPercent * 100)
        return "\(percentage) percent of daily goal completed. \(questionsRemaining) questions remaining."
    }
}