import Combine

class MockQuestionAnalysisViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var answers: [Answer] = []
    @Published var resultSummary: String = ""

    init() {
        loadMockData()
        analyzeAnswers()
    }

    private func loadMockData() {
        let dataService = QuizDataService()
        do {
            self.questions = try dataService.loadMockQuestions()
            // Sample answers
            self.answers = [
                Answer(questionId: questions[0].id, selectedAnswer: "Fahren", isCorrect: false),
                Answer(questionId: questions[1].id, selectedAnswer: "Vor voll anhalten", isCorrect: true),
            ]
        } catch {
            print("Failed to load mock questions: \(error)")
            // Handle error gracefully
        }
    }

    private func analyzeAnswers() {
        let correctCount = answers.filter { $0.isCorrect }.count
        let totalQuestions = answers.count
        resultSummary = "Korrekte Antworten: \(correctCount) von \(totalQuestions)"
    }
}