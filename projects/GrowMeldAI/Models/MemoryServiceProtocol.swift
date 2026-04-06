// Testable protocol
protocol MemoryServiceProtocol {
    var allQuestions: [RememberedQuestion] { get }
    func recordAnswer(...) async throws
}

// In tests:
class MockMemoryService: MemoryServiceProtocol {
    var allQuestions: [RememberedQuestion] = []
    func recordAnswer(...) async throws { /* test stub */ }
}