final class MockABTestingService: ABTestingService {
    private nonisolated let assignmentQueue = DispatchQueue(
        label: "com.driveai.abtesting.mock.assignments",
        attributes: .concurrent
    )
    private nonisolated let eventQueue = DispatchQueue(
        label: "com.driveai.abtesting.mock.events",
        attributes: .concurrent
    )
    
    private var mockAssignments: [ExperimentAssignment] = []
    private var savedEvents: [ExperimentEvent] = []
    
    func saveAssignment(_ assignment: ExperimentAssignment) async throws {
        return await withCheckedContinuation { continuation in
            assignmentQueue.async(flags: .barrier) {
                self.mockAssignments.append(assignment)
                continuation.resume()
            }
        }
    }
    
    func getCurrentAssignments() async throws -> [ExperimentAssignment] {
        return await withCheckedContinuation { continuation in
            assignmentQueue.async {
                continuation.resume(returning: self.mockAssignments)
            }
        }
    }
}