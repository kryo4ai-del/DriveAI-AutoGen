// ✅ IMMUTABLE PATTERN
extension CategoryProfile {
    func recordedAttempt(isCorrect: Bool, date: Date = .now) -> CategoryProfile {
        var updated = self
        updated.questionsAttempted += 1
        if isCorrect {
            updated.correctAnswers += 1
        }
        updated.lastAttemptDate = date
        return updated
    }
}

// Usage—intent is explicit:
var profile = learningProfile.categoryProfiles["signs"]!
profile = profile.recordedAttempt(true)  // ✅ Reassignment is visible

// In LearningProfile:
extension LearningProfile {
    mutating func recordQuizAttempt(
        categoryId: String,
        isCorrect: Bool,
        date: Date = .now
    ) {
        guard var profile = categoryProfiles[categoryId] else { return }
        profile = profile.recordedAttempt(isCorrect, date: date)
        categoryProfiles[categoryId] = profile
    }
}