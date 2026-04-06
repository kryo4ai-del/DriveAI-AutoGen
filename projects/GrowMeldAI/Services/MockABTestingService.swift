import Foundation

final class MockABTestingService: ABTestingService {
    private var mockAssignments: [ExperimentAssignment] = []
    private var savedEvents: [ExperimentEvent] = []
    private let lock = NSLock()

    func saveAssignment(_ assignment: ExperimentAssignment) async throws {
        lock.lock()
        defer { lock.unlock() }
        mockAssignments.append(assignment)
    }

    func getCurrentAssignments() async throws -> [ExperimentAssignment] {
        lock.lock()
        defer { lock.unlock() }
        return mockAssignments
    }

    func getAssignment(for experimentId: String) async throws -> ExperimentAssignment {
        lock.lock()
        defer { lock.unlock() }
        guard let assignment = mockAssignments.first(where: { $0.experimentId == experimentId }) else {
            throw ABTestingError.experimentNotFound(experimentId: experimentId)
        }
        return assignment
    }

    func recordExposure(experimentId: String, variantId: String) async throws {
        // No-op for mock
    }

    func trackEvent(_ event: ExperimentEvent) async throws {
        lock.lock()
        defer { lock.unlock() }
        savedEvents.append(event)
    }

    func getAllTrackedEvents() -> [ExperimentEvent] {
        lock.lock()
        defer { lock.unlock() }
        return savedEvents
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }
        mockAssignments.removeAll()
        savedEvents.removeAll()
    }
}