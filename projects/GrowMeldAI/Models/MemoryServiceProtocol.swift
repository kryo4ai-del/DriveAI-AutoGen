// Testable protocol
protocol MemoryServiceProtocol {
    var allQuestions: [RememberedQuestion] { get }
    func recordAnswer(_ answer: Any) async throws
}

// In tests:
class MockMemoryService: MemoryServiceProtocol {
    var allQuestions: [RememberedQuestion] = []
    func recordAnswer(_ answer: Any) async throws { /* test stub */ }
}