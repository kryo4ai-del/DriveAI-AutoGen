import Foundation
import Combine

class QuestionViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var loadingError: Error? = nil
    
    private var questionEngine: QuestionParsingEngine
    
    init(dataService: LocalDataService = LocalDataService()) {
        questionEngine = QuestionParsingEngine(dataService: dataService)
        let result = questionEngine.getAllQuestions()
        
        switch result {
        case .success(let questions):
            self.questions = questions
        case .failure(let error):
            self.loadingError = error
        }
    }
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    func nextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else { return }
        currentQuestionIndex += 1
    }
    
    func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
    }
}