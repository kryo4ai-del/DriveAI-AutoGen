protocol OnboardingServiceProtocol {
    func saveOnboardingState(examDate: Date, dailyGoal: Int) async throws
    func getOnboardingState() -> OnboardingState?
    func getExamDate() -> Date?
    func markOnboardingAsComplete()
}

final class OnboardingService: OnboardingServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "driveai_onboarding"
    
    func saveOnboardingState(examDate: Date, dailyGoal: Int) async throws {
        let state = OnboardingState(examDate: examDate, completed: true, dailyGoal: dailyGoal)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(state)
            userDefaults.set(data, forKey: onboardingKey)
        } catch {
            throw AppError.saveFailed("Onboarding state")
        }
    }
    
    func getOnboardingState() -> OnboardingState? {
        guard let data = userDefaults.data(forKey: onboardingKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(OnboardingState.self, from: data)
    }
    
    func getExamDate() -> Date? {
        getOnboardingState()?.examDate
    }
    
    func markOnboardingAsComplete() {
        var state = getOnboardingState() ?? OnboardingState()
        state.completed = true
        try? saveOnboardingState(examDate: state.examDate ?? Date(), dailyGoal: state.dailyGoal)
    }
}