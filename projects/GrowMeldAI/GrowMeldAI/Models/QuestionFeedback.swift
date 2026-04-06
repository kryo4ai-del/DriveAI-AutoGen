// After answer submission:
// 1. "Korrekt! Warum ist A die beste Antwort?" [let user think 3 sec]
// 2. User taps or timer expires
// 3. Reveal: "Weil die Vorfahrtsregel besagt..."
// 4. Full explanation below

struct QuestionFeedback {
    let isCorrect: Bool
    let shortPrompt: String      // e.g., "Warum ist das falsch?"
    let explanation: String
    let officialReference: String?
    
    func elaborativeQuestion() -> String {
        if isCorrect {
            return "Warum ist '\(correctAnswer)' korrekt?"
        } else {
            return "Warum ist '\(userAnswer)' falsch?"
        }
    }
}