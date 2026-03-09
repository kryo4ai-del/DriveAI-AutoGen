// Services/QuestionAnalysisService.swift
class QuestionAnalysisService {

    private let categoryService = QuestionCategoryDetectionService()

    func analyzeAnswer(_ userAnswer: UserAnswer) -> AnalysisResult {
        let isCorrect = userAnswer.selectedOption == userAnswer.question.correctAnswer
        let answerTexts = userAnswer.question.options.map { $0.text }
        let detection = categoryService.detectCategory(
            questionText: userAnswer.question.text,
            answers: answerTexts
        )
        return AnalysisResult(
            question: userAnswer.question.text,
            userAnswer: userAnswer.selectedOption,
            correctAnswer: userAnswer.question.correctAnswer,
            detectedCategory: detection.category,
            categoryConfidence: detection.confidence
        )
    }

    private func generateFeedback(isCorrect: Bool, correctAnswer: String) -> String {
        return isCorrect ? "Richtig!" : "Falsch! Die richtige Antwort war \(correctAnswer)."
    }
}
