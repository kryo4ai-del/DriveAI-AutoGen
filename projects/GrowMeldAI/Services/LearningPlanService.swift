// ✅ Single source of truth
final class LearningPlanService: ObservableObject {
    private let categoryProgressRepository: CategoryProgressRepository
    private let localDataService: LocalDataService
    
    // Composes existing services—no duplication
    func generatePlan() async throws { ... }
}