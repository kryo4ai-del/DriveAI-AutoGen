import Foundation

@MainActor
final class LearningPlanService: ObservableObject {
    private let categoryProgressRepository: CategoryProgressRepository
    private let localDataService: LocalDataService

    init(categoryProgressRepository: CategoryProgressRepository, localDataService: LocalDataService) {
        self.categoryProgressRepository = categoryProgressRepository
        self.localDataService = localDataService
    }

    func generatePlan() async throws {
        // No-op implementation placeholder
    }
}