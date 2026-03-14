@MainActor
class StudyRecommendationViewModel: ObservableObject {
    @Published var recommendations: [StudyRecommendation] = []
    @Published var error: AppError?
    
    func loadRecommendations(from report: ExamReadinessReport) async {
        do {
            self.recommendations = try recommendationEngine.generate(from: report)
        } catch let error as AppError {
            self.error = error
            self.recommendations = []  // Don't show stale recommendations on error
        }
    }
}