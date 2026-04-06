// Localizable.strings (German)
"question.count" = "%d Fragen";
"timer.remaining" = "Zeit: %@";
"exam.passed.score" = "Sie haben %d von %d Fragen richtig beantwortet";

// Usage in code
struct LocalizedStrings {
    static func questionCount(_ count: Int) -> String {
        String(format: NSLocalizedString("question.count", comment: ""), count)
    }
    
    static func timerRemaining(_ time: String) -> String {
        String(format: NSLocalizedString("timer.remaining", comment: ""), time)
    }
}