import Foundation

@MainActor
final class PersistenceService {
    static let shared = PersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "com.drivai.quizProgress"
    private let recentQuizzesKey = "com.drivai.recentQuizzes"
    
    private init() {}
    
    func loadAllProgress() -> [UUID: QuizProgress] {
        guard let data = userDefaults.data(forKey: progressKey) else { return [:] }
        
        do {
            return try JSONDecoder().decode([UUID: QuizProgress].self, from: data)
        } catch {
            print("⚠️ Failed to decode progress: \(error)")
            return [:]
        }
    }
    
    func save(_ progress: QuizProgress) {
        var allProgress = loadAllProgress()
        allProgress[progress.quizId] = progress
        
        do {
            let encoded = try JSONEncoder().encode(allProgress)
            userDefaults.set(encoded, forKey: progressKey)
        } catch {
            print("⚠️ Failed to encode progress: \(error)")
        }
    }
    
    func loadRecentQuizzes() -> [UUID] {
        userDefaults.array(forKey: recentQuizzesKey) as? [UUID] ?? []
    }
    
    func saveRecentQuizzes(_ quizzes: [UUID]) {
        userDefaults.set(quizzes, forKey: recentQuizzesKey)
    }
    
    func clearAllProgress() {
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.removeObject(forKey: recentQuizzesKey)
    }
}