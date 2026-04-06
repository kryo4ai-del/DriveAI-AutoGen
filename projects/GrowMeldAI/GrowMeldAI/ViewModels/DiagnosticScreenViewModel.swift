import Foundation

@MainActor
class DiagnosticScreenViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedGapID: UUID?
    @Published var expandedGapID: UUID?
    
    private let diagnosisUseCase: DiagnoseLearningGapsUseCase
    private let recommendationUseCase: GenerateRecommendationsUseCase
    private let analyticsService: AnalyticsService
    
    init(
        diagnosisUseCase: DiagnoseLearningGapsUseCase,
        recommendationUseCase: GenerateRecommendationsUseCase,
        analyticsService: AnalyticsService
    ) {
        self.diagnosisUseCase = diagnosisUseCase
        self.recommendationUseCase = recommendationUseCase
        self.analyticsService = analyticsService
    }
    
    func diagnose(examResult: ExamResult) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let gaps = try await diagnosisUseCase.execute(for: examResult)
            self.recommendations = try await recommendationUseCase.execute(for: gaps)
            analyticsService.track(.diagnosisCompleted(gapCount: gaps.count))
        } catch {
            errorMessage = error.localizedDescription
            analyticsService.track(.diagnosisError(error: error.localizedDescription))
        }
        
        isLoading = false
    }
    
    func performAction(
        _ action: DiagnosticAction,
        for recommendation: Recommendation
    ) {
        switch action {
        case .practiceNow(let topic, let count):
            analyticsService.track(.recommendationActed(
                action: "practiceNow",
                topic: topic,
                gapSeverity: recommendation.gap.gapSeverity.rawValue
            ))
            // Navigation handled in view layer
            
        case .scheduleForLater(let topic, let dueDate):
            analyticsService.track(.recommendationActed(
                action: "scheduled",
                topic: topic,
                dueDate: dueDate.ISO8601Format()
            ))
            
        case .markAsReview(let topic):
            analyticsService.track(.recommendationActed(
                action: "marked",
                topic: topic
            ))
            
        case .skipForNow(let topic, let reason):
            analyticsService.track(.recommendationActed(
                action: "skipped",
                topic: topic,
                reason: reason
            ))
        }
    }
    
    func toggleGapExpansion(gapID: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            expandedGapID = expandedGapID == gapID ? nil : gapID
        }
    }
}

// MARK: - Exam Result (stub, adjust to match your domain)

struct IncorrectAnswer: Identifiable {
    let id: UUID
    let questionID: String
    let topic: String
    let correctAnswer: String
    let userAnswer: String
}