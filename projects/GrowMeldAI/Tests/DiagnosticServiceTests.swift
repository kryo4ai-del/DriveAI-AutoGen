// ✅ Domain tests need NO mocks (pure functions)
class DiagnosticServiceTests: XCTestCase {
    let service = DiagnosticService()
    
    func testAnalyzeCategoryStrength() {
        let quizResults = [
            QuizResult(category: .signs, isCorrect: true),
            QuizResult(category: .signs, isCorrect: true),
            QuizResult(category: .signs, isCorrect: false),
        ]
        
        let strength = service.analyzeCategoryStrength(quizResults)
        XCTAssertEqual(strength.accuracy, Accuracy(2, 3))
    }
}

// ✅ Repository tests use in-memory implementations
class DiagnosticRepositoryTests: XCTestCase {
    var sut: DiagnosticRepository!
    var mockStorage: InMemoryDiagnosticStorage!
    
    override func setUp() {
        mockStorage = InMemoryDiagnosticStorage()
        sut = DiagnosticRepositoryImpl(storage: mockStorage)
    }
}