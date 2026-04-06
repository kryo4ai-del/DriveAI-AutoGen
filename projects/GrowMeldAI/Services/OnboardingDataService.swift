@MainActor
final class OnboardingDataService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    var savedOnboardingState: OnboardingState? {
        guard let data = userDefaults.data(forKey: UserDefaultsKey.onboardingState.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(OnboardingState.self, from: data)
        } catch {
            #if DEBUG
            print("⚠️ Failed to decode state: \(error)")
            #endif
            reset()
            return nil
        }
    }
    
    func save(onboardingState: OnboardingState) {
        do {
            let data = try encoder.encode(onboardingState)
            userDefaults.set(data, forKey: UserDefaultsKey.onboardingState.rawValue)
        } catch {
            #if DEBUG
            print("❌ Failed to encode state: \(error)")
            #endif
        }
    }
}