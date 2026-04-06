import Combine

@MainActor
final class AppState: ObservableObject {
    private let persistence: UserPreferencesService
    
    @Published var hasCompletedOnboarding: Bool = false {
        didSet {
            Task {
                try? await persistence.setHasCompletedOnboarding(hasCompletedOnboarding)
            }
        }
    }
    
    init(persistence: UserPreferencesService = .shared) {
        self.persistence = persistence
        Task {
            self.hasCompletedOnboarding = await persistence.getHasCompletedOnboarding()
            self.examDate = await persistence.getExamDate()
        }
    }
}