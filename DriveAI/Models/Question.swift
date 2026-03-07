import SwiftUI
import Combine

// MARK: - Question Model
struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}

// MARK: - TestFixService Protocol
protocol TestFixServiceProtocol {
    func fetchQuestions() throws -> [Question]
}

// MARK: - LoadingError Enum
enum LoadingError: Error {
    case networkError
    case invalidData

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Bitte überprüfen Sie Ihre Internetverbindung." // "Please check your internet connection."
        case .invalidData:
            return "Erhaltene Daten sind ungültig." // "Received invalid data."
        }
    }
}

// MARK: - TestFixViewModel
class TestFixViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var questions: [Question] = []   
    @Published private(set) var currentQuestionIndex: Int = 0 
    @Published private(set) var selectedAnswer: Int? 
    @Published private(set) var isAnswerCorrect: Bool? 
    @Published private(set) var score: Int = 0 
    @Published private(set) var isTestCompleted: Bool = false 
    @Published var loadError: String? 
    @Published private(set) var isLoading: Bool = false 
    
    private let service: TestFixServiceProtocol

    // MARK: - Initialization
    init(service: TestFixServiceProtocol) {
        self.service = service
        loadQuestions() 
    }
    
    // MARK: - Load Questions
    func loadQuestions() {
        setLoadingState(to: true)

        DispatchQueue.global().async {
            do {
                let loadedQuestions = try self.service.fetchQuestions()
                self.updateQuestions(with: loadedQuestions)
            } catch let error as LoadingError {
                self.handleLoadingError(error)
            } catch {
                self.loadError = "Fehler beim Laden der Fragen: \(error.localizedDescription)" // "Error loading questions"
                self.questions = self.mockQuestions()
                self.setLoadingState(to: false)
            }
        }
    }
    
    private func setLoadingState(to state: Bool) {
        DispatchQueue.main.async {
            self.isLoading = state
        }
    }

    private func updateQuestions(with questions: [Question]) {
        DispatchQueue.main.async {
            self.questions = questions
            self.setLoadingState(to: false)
        }
    }

    private func handleLoadingError(_ error: LoadingError) {
        DispatchQueue.main.async {
            self.loadError = error.localizedDescription
            self.questions = self.mockQuestions()
            self.setLoadingState(to: false)
        }
    }

    // MARK: - Answer Selection
    func selectAnswer(_ answerIndex: Int) {
        guard isValidAnswerIndex(answerIndex) else {
            loadError = "Ungültige Antwortauswahl." // "Invalid answer selection."
            return
        }
        self.selectedAnswer = answerIndex
        checkAnswer()
    }

    private func isValidAnswerIndex(_ index: Int) -> Bool {
        return index >= 0 && index < questions[currentQuestionIndex].options.count
    }
    
    private func checkAnswer() {
        guard let selectedAnswer = selectedAnswer, isCurrentQuestionValid() else {
            loadError = "Ungültige Frage." // "Invalid question."
            return
        }

        isAnswerCorrect = (selectedAnswer == questions[currentQuestionIndex].correctAnswerIndex)

        if isAnswerCorrect == true {
            score += 1
        }

        advanceToNextQuestion()
    }
    
    private func isCurrentQuestionValid() -> Bool {
        return currentQuestionIndex >= 0 && currentQuestionIndex < questions.count
    }
    
    private func advanceToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil // Reset selected answer for the next question
        } else {
            completeTest()
        }
    }
    
    private func completeTest() {
        isTestCompleted = true
    }

    // MARK: - Reset Functionality
    func resetTest() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        score = 0
        isTestCompleted = false
        isAnswerCorrect = nil
        loadError = nil
    }
}

// MARK: - Mock Questions for Demo
extension TestFixViewModel {
    private func mockQuestions() -> [Question] {
        return [
            Question(text: "Was ist ein Fußgängerüberweg?", options: ["Stoppschild", "Zebra", "Ampel"], correctAnswerIndex: 1),
            Question(text: "Was zeigt das Rotlicht an?", options: ["Fahren", "Anhalten", "Biegen"], correctAnswerIndex: 1),
            // Additional mock questions as necessary
        ]
    }
}