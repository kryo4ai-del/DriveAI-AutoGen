extension OnboardingConstraints {
    /// Minimum days before exam is allowed to start preparation.
    static let minimumDaysUntilExam: Int = 14
}

// In validation:
let now = Calendar.current.startOfDay(for: Date())  // Midnight
let minExamDate = Calendar.current.date(byAdding: .day, value: Self.minimumDaysUntilExam, to: now)!

guard examDate >= minExamDate else {
    throw ProfileValidationError.examDateTooSoon
}