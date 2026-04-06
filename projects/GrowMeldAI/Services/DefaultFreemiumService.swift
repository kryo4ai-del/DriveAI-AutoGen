final class DefaultFreemiumService: FreemiumService {
    private let userDefaults: UserDefaults
    private let dateProvider: DateProviding
    private let localDataService: LocalDataService
    private let lock = NSLock()
    
    func checkTrialStatus() -> TrialStatus {
        lock.lock()
        defer { lock.unlock() }
        
        guard let trialPeriod = getActiveTrialPeriod() else {
            return .noTrialActive
        }
        // ... rest of implementation
    }
    
    nonisolated func isPremium() -> Bool {
        // This CAN be nonisolated if it only reads a UserDefaults bool
        // But only if wrapped in a thread-safe primitive
    }
}