// In fetchLatestSnapshot():
let examDate = profile.examDate
let daysUntilExam: Int? = examDate.map {
    Calendar.current.dateComponents([.day], from: .now, to: $0).day ?? 0
    // NOTE: negative means exam has passed
}

// Store raw (possibly negative) value for ViewModel state decisions
// Apply penalty only for genuinely upcoming exams:
let urgencyPenalty: Double
if let days = daysUntilExam, days >= 0, days < 7, categoryScore < 0.70 {
    urgencyPenalty = 0.05
} else {
    urgencyPenalty = 0.0
}

// Expose to ViewModel as a typed state:
enum ExamDateState {
    case notSet
    case upcoming(days: Int)
    case today
    case passed
}