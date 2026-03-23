import Combine
@MainActor
final class RecommendationViewModel: ObservableObject {
    @Published var weakAreas: [WeakArea] = []
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let assessmentService: ReadinessAssessmentServiceProtocol
    
    init(assessmentService: ReadinessAssessmentServiceProtocol) {
        self.assessmentService = assessmentService
    }
    
    func generateRecommendations(from assessment: ReadinessAssessment) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let (weakAreas, recommendations) = try await assessmentService
                    .generateRecommendations(from: assessment)
                self.weakAreas = weakAreas
                self.recommendations = recommendations
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}