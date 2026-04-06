@MainActor
final class QuestionFlowIntegrationTests: XCTestCase {
    private var viewModel: QuestionViewModel!
    private var progressService: ProgressService!
    private var dataService: LocalDataService!
    
    override func setUp() {
        super.setUp()
        // Use real services with in-memory database
        progressService = ProgressService(using: InMemoryProgressDatabase())
        dataService = LocalDataService()
        
        viewModel = QuestionViewModel(
            dataService: dataService,
            progressService: progressService
        )
    }
    
    func testAnswerQuestion_UpdatesProgressInDatabase() async throws {
        // Load a real question
        let questions = try await dataService.loadQuestions(for: "traffic_signs")
        let testQuestion = questions.first!
        
        viewModel.currentQuestion = testQuestion
        viewModel.selectAnswer(testQuestion.correctIndex)
        
        // Verify it was persisted
        let progress = progressService.getProgress(for: "traffic_signs")
        XCTAssertEqual(progress.answeredCount, 1)
        XCTAssertEqual(progress.correctCount, 1)
    }
    
    func testCompleteExam_PersistsAllAnswers() async throws {
        let examService = ExamService(progressService: progressService)
        let questions = try await examService.startExamSimulation()
        
        var correctCount = 0
        for question in questions {
            let isCorrect = Int.random(in: 0...1) == 1  // Simulate 50% correctness
            if isCorrect { correctCount += 1 }
            
            try await progressService.recordAnswer(
                questionId: question.id,
                categoryId: "exam",
                correct: isCorrect
            )
        }
        
        // Verify all 30 answers were recorded
        let examProgress = progressService.getProgress(for: "exam")
        XCTAssertEqual(examProgress.answeredCount, 30)
        XCTAssertEqual(examProgress.correctCount, correctCount)
    }
}