import Foundation

enum DashboardLoadState {
    case idle
    case loading
    case loaded(DashboardContent)
    case error(String)
}

struct DashboardContent: Equatable {
    let examCountdown: ExamCountdown
    let progressSummary: ProgressSummary
    let streakData: StreakData
    let resumableQuiz: QuizSession?
}

// MARK: - Exam Countdown

struct ExamCountdown: Equatable {
    let daysRemaining: Int
    let examDate: Date
    let status: ExamCountdownStatus
}

enum ExamCountdownStatus: Equatable, CustomStringConvertible {
    case upcoming
    case imminent
    case today
    case passed

    var description: String {
        switch self {
        case .upcoming: return "exam.status.upcoming"
        case .imminent: return "exam.status.imminent"
        case .today: return "exam.status.today"
        case .passed: return "exam.status.passed"
        }
    }
}

// MARK: - Progress Summary

struct ProgressSummary: Equatable {
    let totalCategories: Int
    let completedCategories: Int
    let averageScore: Int
    let questionsAnswered: Int
    let correctAnswers: Int

    var completionPercentage: Int {
        guard totalCategories > 0 else { return 0 }
        return (completedCategories * 100) / totalCategories
    }

    var accuracyPercentage: Int {
        guard questionsAnswered > 0 else { return 0 }
        return (correctAnswers * 100) / questionsAnswered
    }
}

// MARK: - Streak Data

struct StreakData: Equatable {
    let currentStreak: Int
    let longestStreak: Int
    let lastActivityDate: Date?

    var isActive: Bool {
        guard let lastDate = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
            || Calendar.current.isDateInYesterday(lastDate)
    }
}

// MARK: - Quiz Session

struct QuizSession: Equatable, Identifiable {
    let id: UUID
    let categoryName: String
    let progress: Double
    let lastActivityDate: Date

    init(
        id: UUID = UUID(),
        categoryName: String,
        progress: Double,
        lastActivityDate: Date = Date()
    ) {
        self.id = id
        self.categoryName = categoryName
        self.progress = progress
        self.lastActivityDate = lastActivityDate
    }
}
