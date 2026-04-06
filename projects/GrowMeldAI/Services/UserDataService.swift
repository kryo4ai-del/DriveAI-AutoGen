import Foundation
import os.log

struct UserProfile: Codable {
    var examDate: Date
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActivityDate: Date = Date()
    var categoryProgress: [String: CategoryProgress] = [:]
}

struct CategoryProgress: Codable {
    var categoryId: String
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0

    var percentage: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

struct QuestionResult: Codable {
    var questionId: String
    var categoryId: String
    var isCorrect: Bool
    var answeredAt: Date

    init(questionId: String, categoryId: String, isCorrect: Bool, answeredAt: Date = Date()) {
        self.questionId = questionId
        self.categoryId = categoryId
        self.isCorrect = isCorrect
        self.answeredAt = answeredAt
    }
}

class UserDataService: ObservableObject {
    @Published var userProfile: UserProfile

    private let userDefaultsKey = "com.driveai.userprofile"
    private let resultsDefaultsKey = "com.driveai.results"
    private let resultsQueue = DispatchQueue(
        label: "com.driveai.userdata",
        attributes: .concurrent
    )

    private var results: [QuestionResult] = []
    private let persistLock = NSLock()

    init() {
        if let savedData = UserDefaults.standard.data(forKey: "com.driveai.userprofile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            self.userProfile = decoded
        } else {
            self.userProfile = UserProfile(examDate: Date().addingTimeInterval(86400 * 60))
        }
        loadResults()
    }

    private func loadResults() {
        if let data = UserDefaults.standard.data(forKey: resultsDefaultsKey),
           let decoded = try? JSONDecoder().decode([QuestionResult].self, from: data) {
            resultsQueue.async(flags: .barrier) {
                self.results = decoded
            }
        }
    }

    func recordQuestionResult(_ result: QuestionResult) {
        resultsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self.results.append(result)

            self.persistLock.lock()
            if let encoded = try? JSONEncoder().encode(self.results) {
                UserDefaults.standard.set(encoded, forKey: self.resultsDefaultsKey)
            }
            self.persistLock.unlock()

            DispatchQueue.main.async {
                self.updateProfile(with: result)
            }
        }
    }

    private func updateProfile(with result: QuestionResult) {
        userProfile.totalQuestionsAnswered += 1

        if result.isCorrect {
            userProfile.correctAnswers += 1
            userProfile.currentStreak += 1
            userProfile.longestStreak = max(userProfile.longestStreak, userProfile.currentStreak)
        } else {
            userProfile.currentStreak = 0
        }

        var categoryProg = userProfile.categoryProgress[result.categoryId]
            ?? CategoryProgress(categoryId: result.categoryId)

        categoryProg.questionsAnswered += 1
        if result.isCorrect {
            categoryProg.correctAnswers += 1
        }
        userProfile.categoryProgress[result.categoryId] = categoryProg

        userProfile.lastActivityDate = Date()

        persistUserProfile()
        self.objectWillChange.send()
    }

    private func persistUserProfile() {
        persistLock.lock()
        defer { persistLock.unlock() }

        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        } else {
            os_log("Failed to persist user profile", type: .error)
        }
    }

    func getResults(for categoryId: String? = nil) -> [QuestionResult] {
        var filtered: [QuestionResult] = []
        resultsQueue.sync {
            if let categoryId = categoryId {
                filtered = results.filter { $0.categoryId == categoryId }
            } else {
                filtered = results
            }
        }
        return filtered
    }

    func clearAllData() {
        resultsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.results = []
            self.persistLock.lock()
            UserDefaults.standard.removeObject(forKey: self.resultsDefaultsKey)
            self.persistLock.unlock()
            DispatchQueue.main.async {
                self.userProfile = UserProfile(examDate: Date().addingTimeInterval(86400 * 60))
                self.persistUserProfile()
                self.objectWillChange.send()
            }
        }
    }
}