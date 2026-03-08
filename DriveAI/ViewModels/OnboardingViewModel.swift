import Combine

class OnboardingViewModel: ObservableObject {
    @Published var isCompleted: Bool = false

    func completeOnboarding() {
        isCompleted = true
    }
}