import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var examDate: Date = Date()
    
    var isReady: Bool {
        return examDate > Date() // Ensure the date is in the future
    }
    
    func completeOnboarding() {
        // Logic to store user profile could be added here
        // Transition to HomeView could also be triggered
    }
}