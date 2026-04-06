// Services/AppDataService.swift
import Foundation
import Combine

// MARK: - Supporting Protocols

protocol LocalDataService: AnyObject {
    func fetchQuestions() -> [Any]
}

protocol ProgressTracker: AnyObject {
    func recordProgress(for questionId: Int, correct: Bool)
    func getProgress(for questionId: Int) -> Double
}

// MARK: - Default Implementations

final class LocalDataServiceImpl: LocalDataService {
    func fetchQuestions() -> [Any] {
        return []
    }
}

final class ProgressTrackerImpl: ProgressTracker {
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

final class UserPreferences {
    static let shared = UserPreferences()
    private let defaults = UserDefaults.standard

    private init() {}

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
    var questions: LocalDataService { get }
    var progress: ProgressTracker { get }
    var preferences: UserPreferences { get }
}

// MARK: - AppDataService Implementation

final class AppDataServiceImpl: AppDataService {
    let questions: LocalDataService
    let progress: ProgressTracker
    let preferences: UserPreferences

    init(
        questions: LocalDataService = LocalDataServiceImpl(),
        progress: ProgressTracker = ProgressTrackerImpl(),
        preferences: UserPreferences = .shared
    ) {
        self.questions = questions
        self.progress = progress
        self.preferences = preferences
    }
}