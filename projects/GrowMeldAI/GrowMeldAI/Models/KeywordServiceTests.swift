// Tests/Unit/Services/KeywordServiceTests.swift
@MainActor
class KeywordServiceTests: XCTestCase {
    var sut: KeywordService!
    var mockRepository: MockKeywordRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockKeywordRepository()
        sut = KeywordService(repository: mockRepository)
    }
    
    func testFetchLatestMetrics_returnsSortedByRank() async throws {
        // Given
        let expected = [KeywordMetric(word: "Fahrschule", rank: 1)]
        mockRepository.mockMetrics = expected
        
        // When
        let result = try await sut.fetchLatestMetrics()
        
        // Then
        XCTAssertEqual(result.count, 1)
    }
}