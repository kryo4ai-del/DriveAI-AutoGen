enum FreemiumQuestionLimit {
    case trafficSigns(mastered: Int, total: Int)  // "You've learned 3 of 8 sign types"
    case rightOfWayRules(mastered: Int, total: Int)
    case dailyQuestionCount(remaining: Int)
}

// In TrialStatus:
enum TrialStatus {
    case notStarted
    case active(
        signsMastered: Int,
        signsTotal: Int,
        examReadiness: Int
    )
    case expired
}

// Motivation text example (used in ViewModels)