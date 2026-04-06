import Foundation
import Combine

// MARK: - Supporting Protocols

protocol AppLocalDataServiceProtocol: AnyObject {
    func fetchQuestions() -> [Any]
}

protocol AppProgressTrackerProtocol: AnyObject {
    func recordProgress(for questionId: Int, correct: Bool)
    func getProgress(for questionId: Int) -> Double
}

// MARK: - Default Implementations

final class LocalDataServiceImpl: AppLocalDataServiceProtocol {
    func fetchQuestions() -> [Any] {
        return []
    }
}

final class ProgressTrackerImpl: AppProgressTrackerProtocol {
    private var progressData: [Int: [Bool]] = [:]

    func recordProgress(for questionId: Int, correct: Bool) {
        progressData[questionId, default: []].append(correct)
    }

    func getProgress(for questionId: Int) -> Double {
        guard let records = progressData[questionId], !records.isEmpty else { return 0 }
        let correct = records.filter { $0 }.count
        return Double(correct) / Double(records.count)
    }
}

final class AppUserPreferences {
    static let shared = AppUserPreferences()
    private let defaults = UserDefaults.standard

    init() {}

    var prefersCachedExplanations: Bool {
        get { defaults.bool(forKey: "prefersCachedExplanations") }
        set { defaults.set(newValue, forKey: "prefersCachedExplanations") }
    }

    var selectedLanguage: String {
        get { defaults.string(forKey: "selectedLanguage") ?? "de" }
        set { defaults.set(newValue, forKey: "selectedLanguage") }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding") }
    }
}

// MARK: - AppDataService Protocol

protocol AppDataService {
    var questions: AppLocalDataServiceProtocol { get }
    var progress: AppProgressTrackerProtocol { get }
    var preferences: AppUserPreferences { get }
}

// MARK: - AppDataService Implementation

final class AppDataServiceImpl: AppDataService {
    let questions: AppLocalDataServiceProtocol
    let progress: AppProgressTrackerProtocol
    let preferences: AppUserPreferences

    init(
        questions: AppLocalDataServiceProtocol = LocalDataServiceImpl(),
        progress: AppProgressTrackerProtocol = ProgressTrackerImpl(),
        preferences: AppUserPreferences = .shared
    ) {
        self.questions = questions
        self.progress = progress
        self.preferences = preferences
    }
}