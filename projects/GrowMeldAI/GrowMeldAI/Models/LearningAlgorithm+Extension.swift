// Services/Domain/LearningAlgorithm.swift
extension LearningAlgorithm {
    /// Formats a date for accessibility (VoiceOver-friendly German)
    /// Example: "22. Januar 2025" instead of "2025-01-22T10:30:00Z"
    static func accessibleDateDescription(_ date: Date, locale: Locale = .init(identifier: "de_DE")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .long  // "22. Januar 2025"
        formatter.timeStyle = .none   // No time (for spaced repetition context)
        return formatter.string(from: date)
    }
}

// Usage in ViewModels:
let nextReviewDate = try await domainService.getExamReadiness()
let accessibleDateString = LearningAlgorithm.accessibleDateDescription(nextReviewDate.nextReviewDate)
// Screen reader announces: "Nächste Wiederholung: 22. Januar 2025"