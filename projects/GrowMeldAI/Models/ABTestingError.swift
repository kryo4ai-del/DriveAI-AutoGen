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

// Actor ABTestingService declared in Services/ABTestingService.swift
