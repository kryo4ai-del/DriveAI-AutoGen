@MainActor
final class ExamReadinessViewModel: ObservableObject {
    @Published var readiness: ExamReadiness?
    
    func updateReadiness(userProfile: UserProfile, categoryStats: [CategoryStats]) {
        readiness = ExamReadiness(
            userProfile: userProfile,
            allCategoryStats: categoryStats
        )
    }
}