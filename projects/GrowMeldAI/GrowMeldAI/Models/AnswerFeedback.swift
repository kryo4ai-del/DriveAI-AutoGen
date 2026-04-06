struct AnswerFeedback {
    let isCorrect: Bool
    let message: String
    let explanation: String
    let safetyContext: String // NEW
    let realWorldScenario: String // NEW
}

// Example:
let feedback = AnswerFeedback(
    isCorrect: true,
    message: "🚗 Richtig! Sicherheit gesichert.",
    explanation: "Der Fahrer von rechts hat Vorfahrt.",
    safetyContext: "Diese Regel verhindert Seitenaufpralle.",
    realWorldScenario: "Stellen Sie sich vor: Sie fahren an einer T-Kreuzung an. Links kommt nichts, rechts nähert sich ein Auto. Was tun Sie?"
)

// View:
VStack(alignment: .leading, spacing: 12) {
    Text(feedback.message)
        .font(.headline)
    
    Text(feedback.safetyContext)
        .font(.callout)
        .italic()
        .foregroundColor(.orange) // Safety highlight
    
    Text(feedback.realWorldScenario)
        .font(.body)
        .lineLimit(nil)
}