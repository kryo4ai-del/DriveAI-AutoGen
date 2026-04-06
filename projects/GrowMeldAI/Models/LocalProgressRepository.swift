// ❌ No deletion method
class LocalProgressRepository: ProgressRepository {
    private let userDefaults = UserDefaults.standard
    
    func loadProgress() -> UserProgress { ... }
    func saveProgress(_ progress: UserProgress) { ... }
    func recordAnswer(...) { ... }
    // Missing: deleteAllUserData()
}