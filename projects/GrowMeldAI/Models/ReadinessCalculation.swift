// Protocols for clarity
protocol ReadinessCalculation {
    var readinessScore: Double { get }
    var status: ReadinessStatus { get }
    var recommendedDailyMinutes: Int { get }
}

protocol CategoryPrioritization {
    var categoriesNeedingReview: [CategoryStats] { get }
    var primaryWeakCategory: CategoryStats? { get }
    var strongCategories: [CategoryStats] { get }
}

// Main struct - cleaner

// ✨ Separate concern: messaging doesn't live in data struct
final class ReadinessPresenter {
    func message(for readiness: ExamReadiness, userStreak: Int) -> String {
        MotivationService.generateMessage(for: readiness, userStreak: userStreak)
    }
}