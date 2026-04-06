// ✅ Add integration test
@MainActor
final class LocalDataServiceIntegrationTests: XCTestCase {
    func testLoadQuestionsFromBundle() async {
        let service = LocalDataService()
        await service.initialize()
        
        let questions = await service.fetchAllQuestions()
        XCTAssertGreaterThan(questions.count, 0)
        XCTAssertNotNil(questions.first?.imageURL)
    }
}