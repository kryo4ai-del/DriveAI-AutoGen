// UserProgressManager.swift
import Foundation
import Combine

final class UserProgressManager: ObservableObject {
    static let shared = UserProgressManager()

    @Published private(set) var currentProgress: Int = 0
    @Published private(set) var examDate: Date?

    private let progressKey = "userProgress"
    private let examDateKey = "examDate"

    private init() {
        loadProgress()
    }

    private func loadProgress() {
        currentProgress = UserDefaults.standard.integer(forKey: progressKey)
        examDate = UserDefaults.standard.object(forKey: examDateKey) as? Date
    }

    func updateProgress(_ newValue: Int) {
        currentProgress = min(max(newValue, 0), 100)
        UserDefaults.standard.set(currentProgress, forKey: progressKey)
    }

    func setExamDate(_ date: Date) {
        examDate = date
        UserDefaults.standard.set(date, forKey: examDateKey)
    }

    var daysUntilExam: Int? {
        guard let examDate = examDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: examDate).day
    }
}