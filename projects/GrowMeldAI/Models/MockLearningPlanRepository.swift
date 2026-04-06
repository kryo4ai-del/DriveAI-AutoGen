import Foundation

// MARK: - LearningPlan Model

struct LearningPlan: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var steps: [LearningStep]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        steps: [LearningStep] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.steps = steps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct LearningStep: Identifiable, Codable {
    let id: String
    var title: String
    var isCompleted: Bool

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - LearningPlanRepository Protocol

protocol LearningPlanRepositoryProtocol {
    func fetchAll() -> [LearningPlan]
    func fetch(byID id: String) -> LearningPlan?
    func save(_ plan: LearningPlan)
    func delete(byID id: String)
}

// MARK: - LearningPlanService

class LearningPlanService {
    private let repository: LearningPlanRepositoryProtocol

    init(repository: LearningPlanRepositoryProtocol) {
        self.repository = repository
    }

    func getAllPlans() -> [LearningPlan] {
        repository.fetchAll()
    }

    func getPlan(byID id: String) -> LearningPlan? {
        repository.fetch(byID: id)
    }

    func savePlan(_ plan: LearningPlan) {
        repository.save(plan)
    }

    func deletePlan(byID id: String) {
        repository.delete(byID: id)
    }
}

// MARK: - MockLearningPlanRepository

class MockLearningPlanRepository: LearningPlanRepositoryProtocol {
    private var store: [String: LearningPlan] = [:]

    init() {
        // Seed with sample data
        let sample = LearningPlan(
            id: "mock-plan-1",
            title: "Swift Fundamentals",
            description: "Learn the core concepts of Swift programming.",
            steps: [
                LearningStep(id: "step-1", title: "Variables and Constants", isCompleted: true),
                LearningStep(id: "step-2", title: "Optionals", isCompleted: false),
                LearningStep(id: "step-3", title: "Closures", isCompleted: false)
            ]
        )
        store[sample.id] = sample
    }

    func fetchAll() -> [LearningPlan] {
        Array(store.values).sorted { $0.createdAt < $1.createdAt }
    }

    func fetch(byID id: String) -> LearningPlan? {
        store[id]
    }

    func save(_ plan: LearningPlan) {
        store[plan.id] = plan
    }

    func delete(byID id: String) {
        store.removeValue(forKey: id)
    }
}