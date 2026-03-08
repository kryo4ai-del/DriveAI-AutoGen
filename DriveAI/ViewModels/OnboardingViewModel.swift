import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var examDate: Date = Date()
    
    func startLearning() {
        // Logic to navigate to the Dashboard
    }
}