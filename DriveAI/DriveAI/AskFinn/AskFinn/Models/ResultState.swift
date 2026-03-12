import SwiftUI
import Combine

// MARK: - ResultState 
struct ResultState {
    var score: Int = 0
    var totalQuestions: Int = 30
    var isPassed: Bool = false
    var feedbackMessage: String = ""
    var scoreBreakdown: [String: Int] = [:] // e.g., ["Correct": 20, "Incorrect": 10]
}

// MARK: - ResultViewModel
class ResultViewModel: ObservableObject {
    @Published private(set) var state = ResultState()
    
    private let passingRate: Double = 0.6  // Flexible passing rate property
    private var cancellables = Set<AnyCancellable>() // Placeholder for future Combine usage

    // Evaluates results based on user score
    func evaluateResults(userScore: Int) {
        updateScore(with: userScore)
        state.isPassed = userScore >= passingScore()
        state.feedbackMessage = generateFeedbackMessage(for: userScore)
        calculateScoreBreakdown(correctCount: userScore) // More flexible breakdown
    }
    
    // Updates the score state safely
    private func updateScore(with value: Int) {
        state.score = value
    }
    
    // Calculates the passing score based on the defined rate
    private func passingScore() -> Int {
        return Int(Double(state.totalQuestions) * passingRate)
    }
    
    // Generates feedback messages based on the user's score
    private func generateFeedbackMessage(for score: Int) -> String {
        switch score {
        case 0..<passingScore():
            return "Leider nicht bestanden. Besuchen Sie die Lernseite für zusätzliche Fragen."
        case passingScore()...state.totalQuestions:
            return "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor."
        default:
            return "Unbekannter Fehler."
        }
    }

    // Calculates score breakdown based on the correct answer count
    private func calculateScoreBreakdown(correctCount: Int) {
        state.scoreBreakdown = [
            "Correct": correctCount,
            "Incorrect": state.totalQuestions - correctCount
        ]
    }
}