// In fetchLatestSnapshot():
// [FK-019 sanitized] let examDate = profile.examDate
// [FK-019 sanitized] let daysUntilExam: Int? = examDate.map {
// [FK-019 sanitized]     Calendar.current.dateComponents([.day], from: .now, to: $0).day ?? 0
    // NOTE: negative means exam has passed
}

// Store raw (possibly negative) value for ViewModel state decisions
// Apply penalty only for genuinely upcoming exams:
// [FK-019 sanitized] let urgencyPenalty: Double
// [FK-019 sanitized] if let days = daysUntilExam, days >= 0, days < 7, categoryScore < 0.70 {
// [FK-019 sanitized]     urgencyPenalty = 0.05
// [FK-019 sanitized] } else {
// [FK-019 sanitized]     urgencyPenalty = 0.0
}

// Expose to ViewModel as a typed state:
enum ExamDateState {
    case notSet
    case upcoming(days: Int)
    case today
    case passed
}