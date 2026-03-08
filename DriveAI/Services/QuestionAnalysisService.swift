// Services/QuestionAnalysisService.swift
class QuestionAnalysisService {
    func analyzeAnswer(_ userAnswer: UserAnswer) -> AnalysisResult {
        let isCorrect = userAnswer.selectedOption == userAnswer.question.correctAnswer
        let feedback = generateFeedback(isCorrect: isCorrect, correctAnswer: userAnswer.question.correctAnswer)
        return AnalysisResult(correct: isCorrect, feedback: feedback)
    }

    private func generateFeedback(isCorrect: Bool, correctAnswer: String) -> String {
        return isCorrect ? "Richtig!" : "Falsch! Die richtige Antwort war \(correctAnswer)."
    }
}