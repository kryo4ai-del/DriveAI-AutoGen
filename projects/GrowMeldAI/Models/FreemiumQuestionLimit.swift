enum FreemiumQuestionLimit {
    case trafficSigns(mastered: Int, total: Int)  // "You've learned 3 of 8 sign types"
    case rightOfWayRules(mastered: Int, total: Int)
    case dailyQuestionCount(remaining: Int)
}

// In TrialStatus:
enum TrialStatus {
    case active(
        signsMastered: Int,
        signsTotal: Int,
        examReadiness: Int
    )
}

// In ViewModel for motivation:
let motivationText = """
Du kennst schon 42 von 87 Verkehrsschildern! \
Premium zeigt dir gezielt die 45 Zeichen, die dir noch fehlen.
"""