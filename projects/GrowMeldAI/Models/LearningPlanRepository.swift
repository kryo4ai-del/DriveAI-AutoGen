// Services/LearningPlan/LearningPlanRepository.swift
protocol LearningPlanRepository {
    func savePlan(_ plan: LearningPlan) async throws
    func fetchCurrentPlan() async throws -> LearningPlan?
    func deletePlan(id: UUID) async throws
}

// Concrete implementation wraps LocalDataService
final class LocalLearningPlanRepository: LearningPlanRepository {
    private let localDataService: LocalDataService
    
    func savePlan(_ plan: LearningPlan) async throws {
        let encoded = try JSONEncoder().encode(plan)
        try await localDataService.save(
            key: "learning_plan_\(plan.id)",
            data: encoded
        )
    }
    
    func fetchCurrentPlan() async throws -> LearningPlan? {
        guard let data = try await localDataService.load(key: "learning_plan_current") else {
            return nil
        }
        return try JSONDecoder().decode(LearningPlan.self, from: data)
    }
}