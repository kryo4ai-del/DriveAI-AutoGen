// Services/QuestionAnalysisService.swift
import Foundation

struct UserAnswer {
    let question: Question
    let selectedOption: String
}

class QuestionAnalysisService {

    private let categoryService = QuestionCategoryDetectionService()

    func analyzeAnswer(_ userAnswer: UserAnswer) -> AnalysisResult {
        let correctAnswer = userAnswer.question.options.first(where: { $0.id == userAnswer.question.correctAnswerId })?.text ?? ""
        let answerTexts = userAnswer.question.options.map { $0.text }
        let detection = categoryService.detectCategory(
            questionText: userAnswer.question.text,
            answers: answerTexts
        )
        return AnalysisResult(
            question: userAnswer.question.text,
            userAnswer: userAnswer.selectedOption,
            correctAnswer: correctAnswer,
            detectedCategory: detection.category,
            categoryConfidence: detection.confidence
        )
    }

    private func generateFeedback(isCorrect: Bool, correctAnswer: String) -> String {
        return isCorrect ? "Richtig!" : "Falsch! Die richtige Antwort war \(correctAnswer)."
    }
}
