import Foundation
import Combine

class MockQuestionAnalysisViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var questionAnswers: [QuestionAnswer] = []
    @Published var resultSummary: String = ""

    init() {
        loadMockData()
        analyzeAnswers()
    }

    private func loadMockData() {
        let dataService = QuizDataService()
        do {
            self.questions = try dataService.loadMockQuestions()
            // Sample answers using QuestionAnswer type
            self.questionAnswers = [
                QuestionAnswer(questionId: questions[0].id, isCorrect: false, timeTaken: 5.0),
                QuestionAnswer(questionId: questions[1].id, isCorrect: true, timeTaken: 3.0),
            ]
        } catch {
            print("Failed to load mock questions: \(error)")
        }
    }

    private func analyzeAnswers() {
        let correctCount = questionAnswers.filter { $0.isCorrect }.count
        let totalQuestions = questionAnswers.count
        resultSummary = "Korrekte Antworten: \(correctCount) von \(totalQuestions)"
    }
}
