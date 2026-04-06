// Services/ABTesting/Core/VariantAssignmentService.swift

protocol VariantAssignmentService: Sendable {
    /// Get or create assignment for user in experiment
    func getOrAssignVariant(
        userId: String,
        experiment: Experiment,
        strategy: ExperimentAssignmentStrategy
    ) async throws -> ExperimentAssignment
    
    /// Get existing assignment
    func getAssignment(
        userId: String,
        experimentId: String
    ) async throws -> ExperimentAssignment?
}

actor VariantAssignmentServiceImpl: VariantAssignmentService {
    private let dataService: ExperimentDataService
    
    func getOrAssignVariant(
        userId: String,
        experiment: Experiment,
        strategy: ExperimentAssignmentStrategy
    ) async throws -> ExperimentAssignment {
        // Check existing assignment
        if let existing = try await getAssignment(userId: userId, experimentId: experiment.id) {
            return existing
        }
        
        // Create new assignment
        let variant = strategy.assignVariant(userId: userId, experiment: experiment)
        let assignment = ExperimentAssignment(
            id: UUID(),
            experimentId: experiment.id,
            userId: userId,
            variantId: variant.id,
            assignedAt: Date(),
            cohort: nil
        )
        
        try await dataService.saveAssignment(assignment)
        return assignment
    }
    
    func getAssignment(
        userId: String,
        experimentId: String
    ) async throws -> ExperimentAssignment? {
        let assignments = try await dataService.fetchAssignments(userId: userId)
        return assignments.first { $0.experimentId == experimentId }
    }
}

// Simplify ABTestingServiceImpl

actor ABTestingServiceImpl: ABTestingService {
    private let dataService: ExperimentDataService
    private let assignmentService: VariantAssignmentService
    private let assignmentStrategy: ExperimentAssignmentStrategy
    private let userId: String
    
    func getCurrentAssignments() async throws -> [ExperimentAssignment] {
        let experiments = try await dataService.fetchExperiments(activeOnly: true)
        var assignments: [ExperimentAssignment] = []
        
        for experiment in experiments {
            do {
                let assignment = try await assignmentService.getOrAssignVariant(
                    userId: userId,
                    experiment: experiment,
                    strategy: assignmentStrategy
                )
                assignments.append(assignment)
            } catch {
                Logger.log("Assignment failed for \(experiment.id): \(error)")
                // Continue with other experiments
            }
        }
        
        return assignments
    }
}