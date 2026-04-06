import Foundation

/// Computes exam readiness and provides spaced repetition coaching
@globalActor
final actor ExamReadinessService: Sendable {
    static let shared = ExamReadinessService()
    
    func assessReadiness(profile: UserProfile) -> ExamReadiness {
        ExamReadiness(profile: profile)
    }
    
    /// Returns categories that need urgent review (not practiced in 14+ days)
    func categoriesNeedingReview(statistics: UserStatistics) -> [CategoryStatistics] {
        statistics.categoryStats.filter { $0.needsRefresh }
            .sorted { ($0.lastPracticed ?? .distantPast) < ($1.lastPracticed ?? .distantPast) }
    }
    
    /// Suggested study plan based on readiness
    func suggestedStudyPlan(readiness: ExamReadiness) -> StudyPlan {
        StudyPlan(
            dailyMinutes: readiness.recommendedDailyMinutes,
            focusAreas: readiness.level == .notReady ? .allCategories : .weakCategories,
            nextMilestone: readiness.nextCriticalReview ?? Date()
        )
    }
}

struct StudyPlan: Sendable {
    enum FocusArea: Sendable {
        case allCategories
        case weakCategories
    }
    
    let dailyMinutes: Int
    let focusAreas: FocusArea
    let nextMilestone: Date
}