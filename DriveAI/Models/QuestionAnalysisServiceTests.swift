class QuestionAnalysisServiceTests: XCTestCase {
    var questionAnalysisService: QuestionAnalysisService!
    var localDataServiceMock: LocalDataServiceMock!

    override func setUp() {
        super.setUp()
        localDataServiceMock = LocalDataServiceMock()
        questionAnalysisService = QuestionAnalysisService(localDataService: localDataServiceMock)

        // Optionally pre-populate mock categories and questions
        let questionId = UUID()
        localDataServiceMock.addCategory(for: questionId, category: "Traffic Signs")
        localDataServiceMock.addMockQuestions([
            Question(id: questionId, text: "What does a stop sign mean?", category: "Traffic Signs", options: ["Stop", "Go"], correctOption: 0)
        ])
    }

    override func tearDown() {
        localDataServiceMock.clearStoredData() // Ensure isolation for each test
        questionAnalysisService = nil
        localDataServiceMock = nil
        super.tearDown()
    }

    // Add test cases here
}