import Foundation
import Combine

class TestFixViewModel: ObservableObject {
    private let dataService: LocalDataServiceProtocol

    @Published var questions: [Question] = []
    @Published var score: Int = 0
    @Published var currentQuestionIndex: Int = 0
    @Published var isAnswerCorrect: Bool?
    @Published var isTestCompleted: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(dataService: LocalDataServiceProtocol = MockLocalDataService()) {
        self.dataService = dataService
        loadQuestions()
    }

    func loadQuestions() {
        do {
            self.questions = try dataService.fetchQuestions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectAnswer(_ index: Int?) {
        guard let index = index,
              currentQuestionIndex < questions.count else { return }

        let question = questions[currentQuestionIndex]
        let isCorrect = question.options.indices.contains(index) &&
                        question.options[index].id == question.correctAnswerId
        self.isAnswerCorrect = isCorrect
        if isCorrect {
            score += 1
        }

        if currentQuestionIndex >= questions.count - 1 {
            isTestCompleted = true
        } else {
            currentQuestionIndex += 1
        }
    }

    func resetTest(completion: (() -> Void)? = nil) {
        currentQuestionIndex = 0
        score = 0
        isTestCompleted = false
        isAnswerCorrect = nil
        completion?()
    }

    func fetchTestFixData() {
        isLoading = true
        errorMessage = nil
        loadQuestions()
        isLoading = false
    }
}
