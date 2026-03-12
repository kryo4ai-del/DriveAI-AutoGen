import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var progress: Double = 0.0

    func startQuiz() {
        // Logic to start the quiz
    }

    func loadProgress() {
        // Placeholder for loading progress
        progress = 50.0
    }
}
