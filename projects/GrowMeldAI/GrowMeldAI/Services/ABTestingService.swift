// Services/ABTestingService.swift

import Foundation

// MARK: - ExperimentAssignment

struct ExperimentAssignment: Codable, Identifiable {
    let id: String
    let experimentId: String
    let variantId: String
    let experimentName: String
    let variantName: String
    let assignedAt: Date
    let metadata: [String: String]

    init(
        id: String = UUID().uuidString,
        experimentId: String,
        variantId: String,
        experimentName: String,
        variantName: String,
        assignedAt: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.experimentId = experimentId
        self.variantId = variantId
        self.experimentName = experimentName
        self.variantName = variantName
        self.assignedAt = assignedAt
        self.metadata = metadata
    }
}

// MARK: - ABTestingError

enum ABTestingError: LocalizedError {
    case assignmentsFetchFailed(underlying: Error)
    case experimentNotFound(experimentId: String)
    case variantNotFound(variantId: String)
    case invalidConfiguration(reason: String)
    case storageFailure(reason: String)
    case networkUnavailable
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .assignmentsFetchFailed(let error):
            return "Failed to fetch experiment assignments: \(error.localizedDescription)"
        case .experimentNotFound(let id):
            return "Experiment not found with ID: \(id)"
        case .variantNotFound(let id):
            return "Variant not found with ID: \(id)"
        case .invalidConfiguration(let reason):
            return "Invalid AB testing configuration: \(reason)"
        case .storageFailure(let reason):
            return "Storage failure in AB testing service: \(reason)"
        case .networkUnavailable:
            return "Network unavailable for AB testing service."
        case .decodingFailed(let error):
            return "Failed to decode experiment data: \(error.localizedDescription)"
        }
    }
}

// MARK: - ABTestingService Protocol

protocol ABTestingService {
    /// Fetches all current experiment assignments for the user.
    /// - Throws: `ABTestingError.assignmentsFetchFailed` if the fetch fails,
    ///           `ABTestingError.networkUnavailable` if there is no connectivity,
    ///           `ABTestingError.decodingFailed` if the response cannot be decoded.
    func getCurrentAssignments() async throws -> [ExperimentAssignment]

    /// Returns the assignment for a specific experiment.
    /// - Parameter experimentId: The unique identifier of the experiment.
    /// - Throws: `ABTestingError.experimentNotFound` if no assignment exists for the given ID.
    func getAssignment(for experimentId: String) async throws -> ExperimentAssignment

    /// Records that the user was exposed to a particular experiment variant.
    /// - Parameters:
    ///   - experimentId: The experiment identifier.
    ///   - variantId: The variant identifier the user was exposed to.
    /// - Throws: `ABTestingError.storageFailure` if the exposure event cannot be persisted.
    func recordExposure(experimentId: String, variantId: String) async throws

    /// Records a conversion event for an experiment.
    /// - Parameters:
    ///   - experimentId: The experiment identifier.
    ///   - eventName: The name of the conversion event.
    /// - Throws: `ABTestingError.experimentNotFound` if the experiment is unknown,
    ///           `ABTestingError.storageFailure` if the event cannot be persisted.
    func recordConversion(experimentId: String, eventName: String) async throws

    /// Clears all locally cached assignments.
    /// - Throws: `ABTestingError.storageFailure` if the cache cannot be cleared.
    func clearCachedAssignments() async throws
}

// MARK: - ABTestingServiceImpl

final class ABTestingServiceImpl: ABTestingService {

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let assignmentsCacheKey = "com.growmeldai.abtesting.assignments"
    private let cacheExpiryKey = "com.growmeldai.abtesting.cacheExpiry"
    private let cacheTTL: TimeInterval = 3600 // 1 hour

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - ABTestingService

    func getCurrentAssignments() async throws -> [ExperimentAssignment] {
        // Return cached assignments if still valid
        if let cached = loadCachedAssignments(), isCacheValid() {
            return cached
        }

        // Attempt to fetch fresh assignments
        do {
            let assignments = try await fetchAssignmentsFromServer()
            try cacheAssignments(assignments)
            return assignments
        } catch let error as ABTestingError {
            // If network unavailable, fall back to stale cache if available
            if case .networkUnavailable = error, let stale = loadCachedAssignments() {
                return stale
            }
            throw error
        } catch {
            throw ABTestingError.assignmentsFetchFailed(underlying: error)
        }
    }

    func getAssignment(for experimentId: String) async throws -> ExperimentAssignment {
        let assignments = try await getCurrentAssignments()
        guard let assignment = assignments.first(where: { $0.experimentId == experimentId }) else {
            throw ABTestingError.experimentNotFound(experimentId: experimentId)
        }
        return assignment
    }

    func recordExposure(experimentId: String, variantId: String) async throws {
        var exposures = loadExposures()
        let key = "\(experimentId):\(variantId)"
        exposures[key] = Date()
        do {
            let data = try JSONEncoder().encode(exposures)
            userDefaults.set(data, forKey: "com.growmeldai.abtesting.exposures")
        } catch {
            throw ABTestingError.storageFailure(reason: "Failed to persist exposure: \(error.localizedDescription)")
        }
    }

    func recordConversion(experimentId: String, eventName: String) async throws {
        var conversions = loadConversions()
        let key = "\(experimentId):\(eventName)"
        var events = conversions[key] ?? []
        events.append(Date())
        conversions[key] = events
        do {
            let data = try JSONEncoder().encode(conversions)
            userDefaults.set(data, forKey: "com.growmeldai.abtesting.conversions")
        } catch {
            throw ABTestingError.storageFailure(reason: "Failed to persist conversion: \(error.localizedDescription)")
        }
    }

    func clearCachedAssignments() async throws {
        userDefaults.removeObject(forKey: assignmentsCacheKey)
        userDefaults.removeObject(forKey: cacheExpiryKey)
    }

    // MARK: - Private Helpers

    private func fetchAssignmentsFromServer() async throws -> [ExperimentAssignment] {
        // In a real implementation, this would call your backend.
        // For now, return a default control assignment as a safe fallback.
        return [
            ExperimentAssignment(
                experimentId: "default_experiment",
                variantId: "control",
                experimentName: "Default Experiment",
                variantName: "Control"
            )
        ]
    }

    private func cacheAssignments(_ assignments: [ExperimentAssignment]) throws {
        do {
            let data = try JSONEncoder().encode(assignments)
            userDefaults.set(data, forKey: assignmentsCacheKey)
            userDefaults.set(Date().addingTimeInterval(cacheTTL), forKey: cacheExpiryKey)
        } catch {
            throw ABTestingError.storageFailure(reason: "Failed to cache assignments: \(error.localizedDescription)")
        }
    }

    private func loadCachedAssignments() -> [ExperimentAssignment]? {
        guard let data = userDefaults.data(forKey: assignmentsCacheKey) else { return nil }
        return try? JSONDecoder().decode([ExperimentAssignment].self, from: data)
    }

    private func isCacheValid() -> Bool {
        guard let expiry = userDefaults.object(forKey: cacheExpiryKey) as? Date else { return false }
        return Date() < expiry
    }

    private func loadExposures() -> [String: Date] {
        guard let data = userDefaults.data(forKey: "com.growmeldai.abtesting.exposures"),
              let exposures = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return exposures
    }

    private func loadConversions() -> [String: [Date]] {
        guard let data = userDefaults.data(forKey: "com.growmeldai.abtesting.conversions"),
              let conversions = try? JSONDecoder().decode([String: [Date]].self, from: data) else {
            return [:]
        }
        return conversions
    }
}