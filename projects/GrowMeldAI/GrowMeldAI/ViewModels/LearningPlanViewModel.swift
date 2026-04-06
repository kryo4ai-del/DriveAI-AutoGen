// ViewModels/LearningPlan/LearningPlanViewModel.swift
@MainActor
final class LearningPlanViewModel: ObservableObject {
    @Published var todayRecommendations: [RecommendedQuestion] = []
    @Published var weakCategories: [WeakCategory] = []
    @Published var isLoading = false
    
    private let service: LearningPlanService
    private let userProfile: UserProfile
    
    // View calls this on appear
    func loadTodayPlan() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let plan = try await service.generatePlan(expiryDate: userProfile.examDate)
            self.todayRecommendations = try await service.fetchTodayRecommendations()
            self.weakCategories = plan.weakCategories
        } catch {
            // Handle error
        }
    }
    
    // Integrate with question answering (called by QuestionViewModel)
    func recordQuestionAttempt(questionId: String, isCorrect: Bool) async {
        try? await service.updatePlanProgress(questionId: questionId, isCorrect: isCorrect)
    }
}