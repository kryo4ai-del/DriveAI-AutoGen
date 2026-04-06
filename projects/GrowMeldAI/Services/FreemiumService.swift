protocol FreemiumService {
    /// Record a question answer and return feedback
    func recordQuestionAnswered() throws -> QuestionRecordingFeedback
}

struct QuestionRecordingFeedback {
    let wasRecorded: Bool
    let remainingQuestionsToday: Int
    let isNearingLimit: Bool
    let a11yAnnouncement: String
}

// In DefaultFreemiumService:
func recordQuestionAnswered() throws -> QuestionRecordingFeedback {
    resetDailyCountersIfNeeded()
    
    guard remainingQuestionsToday() > 0 else {
        let feedback = QuestionRecordingFeedback(
            wasRecorded: false,
            remainingQuestionsToday: 0,
            isNearingLimit: true,
            a11yAnnouncement: localizer.localize(
                "a11y.daily_limit_reached",
                arguments: ["resetTime": formatResetTime()]
            )
        )
        throw FreemiumError.dailyLimitExceeded(feedback)
    }
    
    let current = userDefaults.integer(forKey: Constants.questionsAnsweredTodayKey)
    userDefaults.set(current + 1, forKey: Constants.questionsAnsweredTodayKey)
    
    let remaining = remainingQuestionsToday()
    let isNearing = remaining <= 2  // Alert when 2 or fewer questions left
    
    let announcement: String
    if isNearing && remaining > 0 {
        announcement = localizer.localize(
            "a11y.few_questions_remaining",
            arguments: ["count": String(remaining)]
        )
    } else if remaining == 0 {
        announcement = localizer.localize(
            "a11y.daily_limit_reached",
            arguments: ["resetTime": formatResetTime()]
        )
    } else {
        announcement = ""  // No announcement needed
    }
    
    return QuestionRecordingFeedback(
        wasRecorded: true,
        remainingQuestionsToday: remaining,
        isNearingLimit: isNearing,
        a11yAnnouncement: announcement
    )
}

// Localization strings (German):
a11y.daily_limit_reached = "Deine heutigen Fragen sind aufgebraucht. Du kannst morgen um %@ wieder üben."
a11y.few_questions_remaining = "Du hast noch %d Fragen für heute."