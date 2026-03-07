import Foundation
import Combine

// Define a struct to represent user's progress
struct UserProgress {
    var completedQuizzes: Int
    var totalQuestions: Int
    var streak: Int
}

final class HomeViewModel: ObservableObject {
    // Published properties to notify views of state changes
    @Published var userProgress: UserProgress = UserProgress(completedQuizzes: 0, totalQuestions: 0, streak: 0)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // Initializer
    init() {
        fetchUserProgress()
    }
    
    // Method to fetch user progress with error handling
    func fetchUserProgress() {
        isLoading = true

        // Simulate a fetch with potential failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let success = Bool.random() // Simulating random success/failure
            if success {
                // Simulating a successful data fetch
                self.userProgress = UserProgress(completedQuizzes: 5, totalQuestions: 30, streak: 3)
                self.errorMessage = nil // Clear any previous error messages
            } else {
                // Assigning an error message on failure
                self.errorMessage = "Fehler beim Laden des Fortschritts. Bitte versuchen Sie es erneut."
            }
            self.isLoading = false
        }
    }
    
    // Method to handle quiz completion (to be implemented)
    func onQuizCompleted(quizScore: Int, totalQuestions: Int) {
        // Example logic for updating the user's progress
        if quizScore >= (totalQuestions / 2) { // Assuming passing score is 50%
            userProgress.completedQuizzes += 1
            userProgress.streak += 1
            // Add cap for streak management, e.g., maximum of 10
            if userProgress.streak > 10 {
                userProgress.streak = 10
            }
        } else {
            userProgress.streak = 0 // Reset streak on failure
        }
    }
}