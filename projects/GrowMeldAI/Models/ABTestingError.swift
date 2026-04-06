import Foundation

// MARK: - ExperimentAssignment (minimal supporting type)

struct ExperimentAssignment: Codable, Identifiable, Sendable {
    let id: String
    let experimentId: String
    let variantId: String
    let assignedAt: Date

    init(id: String = UUID().uuidString,
         experimentId: String,
         variantId: String,
         assignedAt: Date = Date()) {
        self.id = id
        self.experimentId = experimentId
        self.variantId = variantId
        self.assignedAt = assignedAt
    }
}

// MARK: - ABTestingError

enum ABTestingError: Error {
    case databaseNotInitialized
    case experimentNotFound(String)
    case assignmentFailed([Error])
    case invalidVariantWeight
    case corruptedData(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotInitialized:
            return "A/B testing database not initialized"
        case .experimentNotFound(let id):
            return "Experiment '\(id)' not found"
        case .assignmentFailed(let errors):
            return "Failed to assign user to \(errors.count) experiment(s)"
        case .invalidVariantWeight:
            return "Variant weights must sum to 1.0"
        case .corruptedData(let details):
            return "Corrupted experiment data: \(details)"
        }
    }
}

// MARK: - ABTestingStore (UserDefaults-backed persistence)

final class ABTestingStore: @unchecked Sendable {
    static let shared = ABTestingStore()

    private let defaults = UserDefaults.standard
    private let assignmentsKey = "com.growmeldai.abtesting.assignments"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func saveAssignments(_ assignments: [ExperimentAssignment]) throws {
        let data = try encoder.encode(assignments)
        defaults.set(data, forKey: assignmentsKey)
    }

    func loadAssignments() throws -> [ExperimentAssignment] {
        guard let data = defaults.data(forKey: assignmentsKey) else {
            return []
        }
        return try decoder.decode([ExperimentAssignment].self, from: data)
    }

    func clearAssignments() {
        defaults.removeObject(forKey: assignmentsKey)
    }
}

// MARK: - ABTestingService (actor-isolated)

actor ABTestingService {
    private var isInitialized: Bool = false
    private let store: ABTestingStore
    private let logger = ABTestingLogger.shared

    init(store: ABTestingStore = .shared) {
        self.store = store
    }

    func initialize() {
        isInitialized = true
        logger.log("ABTestingService initialized")
    }

    // MARK: - Public API

    func getCurrentAssignments() async throws -> [ExperimentAssignment] {
        guard isInitialized else {
            throw ABTestingError.databaseNotInitialized
        }
        do {
            let assignments = try store.loadAssignments()
            logger.log("Loaded \(assignments.count) assignment(s)")
            return assignments
        } catch {
            throw ABTestingError.corruptedData(error.localizedDescription)
        }
    }

    func assign(userId: String, to experiment: ABExperiment) async throws -> ExperimentAssignment {
        guard isInitialized else {
            throw ABTestingError.databaseNotInitialized
        }

        let totalWeight = experiment.variants.reduce(0) { $0 + $1.weight }
        guard totalWeight == 100 else {
            throw ABTestingError.invalidVariantWeight
        }

        guard experiment.isActive else {
            throw ABTestingError.experimentNotFound(experiment.id)
        }

        let variantId = selectVariant(for: userId, in: experiment)
        let assignment = ExperimentAssignment(
            experimentId: experiment.id,
            variantId: variantId
        )

        var current = (try? store.loadAssignments()) ?? []
        current.removeAll { $0.experimentId == experiment.id }
        current.append(assignment)

        do {
            try store.saveAssignments(current)
        } catch {
            throw ABTestingError.assignmentFailed([error])
        }

        logger.log("Assigned user to variant '\(variantId)' in experiment '\(experiment.id)'")
        return assignment
    }

    func getAssignment(for experimentId: String) async throws -> ExperimentAssignment {
        guard isInitialized else {
            throw ABTestingError.databaseNotInitialized
        }

        let assignments = try await getCurrentAssignments()
        guard let match = assignments.first(where: { $0.experimentId == experimentId }) else {
            throw ABTestingError.experimentNotFound(experimentId)
        }
        return match
    }

    func removeAssignment(for experimentId: String) async throws {
        guard isInitialized else {
            throw ABTestingError.databaseNotInitialized
        }

        var current = (try? store.loadAssignments()) ?? []
        let before = current.count
        current.removeAll { $0.experimentId == experimentId }

        if current.count == before {
            throw ABTestingError.experimentNotFound(experimentId)
        }

        do {
            try store.saveAssignments(current)
            logger.log("Removed assignment for experiment '\(experimentId)'")
        } catch {
            throw ABTestingError.corruptedData(error.localizedDescription)
        }
    }

    func clearAllAssignments() async throws {
        guard isInitialized else {
            throw ABTestingError.databaseNotInitialized
        }
        store.clearAssignments()
        logger.log("All assignments cleared")
    }

    // MARK: - Private Helpers

    private func selectVariant(for userId: String, in experiment: ABExperiment) -> String {
        let hash = abs(userId.hashValue ^ experiment.id.hashValue) % 100
        var cumulative = 0
        for variant in experiment.variants {
            cumulative += variant.weight
            if hash < cumulative {
                return variant.id
            }
        }
        return experiment.variants.last?.id ?? experiment.control
    }
}