import Foundation

@MainActor
class UserDataManager {
    static let shared = UserDataManager()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Keys
    private enum Keys {
        static let user = "com.driveai.user"
        static let onboardingComplete = "com.driveai.onboarding.complete"
        static let lastPracticeDate = "com.driveai.lastPractice"
    }

    // MARK: - User Management

    func loadUser() async throws -> User {
        if let data = defaults.data(forKey: Keys.user) {
            return try decoder.decode(User.self, from: data)
        }
        return User.defaultUser
    }

    func saveUser(_ user: User) async throws {
        let data = try encoder.encode(user)
        defaults.set(data, forKey: Keys.user)
        NotificationCenter.default.post(name: NSNotification.Name("userDidUpdate"), object: nil)
    }

    func hasCompletedOnboarding() async -> Bool {
        defaults.bool(forKey: Keys.onboardingComplete)
    }

    func markOnboardingComplete() async throws {
        defaults.set(true, forKey: Keys.onboardingComplete)
    }

    // MARK: - Progress Tracking

    func recordAnswer(
        questionId: String,
        category: QuestionCategory,
        correct: Bool
    ) async throws {
        var user = try await loadUser()

        let key = category.rawValue

        if user.progressByCategory[key] == nil {
            user.progressByCategory[key] = CategoryProgress()
        }

        user.progressByCategory[key]?.recordAnswer(correct: correct)
        user.totalQuestionsAnswered += 1
        if correct {
            user.totalQuestionsCorrect += 1
        }

        let calendar = Calendar.current
        if let lastPractice = user.lastPracticeDate,
           calendar.isDateInToday(lastPractice) {
            // Same day, streak continues
        } else if let lastPractice = user.lastPracticeDate,
                  calendar.isDateInYesterday(lastPractice) {
            user.currentStreak += 1
        } else {
            user.currentStreak = 1
        }
        user.lastPracticeDate = Date()
        user.longestStreak = max(user.currentStreak, user.longestStreak)

        try await saveUser(user)
    }

    func deleteAllData() async throws {
        defaults.removeObject(forKey: Keys.user)
        defaults.removeObject(forKey: Keys.onboardingComplete)
    }
}

// MARK: - User Model

struct User: Codable {
    var id: String
    var name: String
    var progressByCategory: [String: CategoryProgress]
    var totalQuestionsAnswered: Int
    var totalQuestionsCorrect: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastPracticeDate: Date?

    static var defaultUser: User {
        User(
            id: UUID().uuidString,
            name: "",
            progressByCategory: [:],
            totalQuestionsAnswered: 0,
            totalQuestionsCorrect: 0,
            currentStreak: 0,
            longestStreak: 0,
            lastPracticeDate: nil
        )
    }
}

// MARK: - QuestionCategory

enum QuestionCategory: String, Codable, CaseIterable {
    case general = "general"
    case traffic = "traffic"
    case signs = "signs"
    case safety = "safety"
    case parking = "parking"
}

// MARK: - CategoryProgress

struct CategoryProgress: Codable {
    var questionsAttempted: Int = 0
    var questionsCorrect: Int = 0
    var lastAttempted: Date?

    var percentage: Double {
        guard questionsAttempted > 0 else { return 0 }
        return Double(questionsCorrect) / Double(questionsAttempted) * 100
    }

    mutating func recordAnswer(correct: Bool) {
        questionsAttempted += 1
        if correct {
            questionsCorrect += 1
        }
        lastAttempted = Date()
    }
}