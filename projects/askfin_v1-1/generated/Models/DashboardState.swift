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
