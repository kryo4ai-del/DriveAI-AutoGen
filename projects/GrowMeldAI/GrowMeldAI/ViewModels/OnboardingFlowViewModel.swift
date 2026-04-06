@MainActor
final class OnboardingFlowViewModel: ObservableObject {
    @Published var session: OnboardingSession = OnboardingSession()
    
    func advance(skipCamera: Bool = false) {
        session = session.advancedSession(skipCamera: skipCamera)
    }
}