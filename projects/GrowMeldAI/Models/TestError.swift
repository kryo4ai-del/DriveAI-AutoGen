@MainActor
func testQuestionViewModelInitialization() async {
    let mockQuestion = Question(id: "q1", text: "Test?", answers: [])
    let mockService = MockQuestionService(questionToReturn: mockQuestion)
    
    let vm = QuestionScreenViewModel(categoryId: "traffic-signs", questionService: mockService)
    XCTAssertFalse(vm.isInitialized, "Should not be initialized in init")
    XCTAssertNil(vm.currentQuestion, "Question should be nil before init")
    
    await vm.initialize()
    
    XCTAssertTrue(vm.isInitialized, "Should be initialized after await")
    XCTAssertEqual(vm.currentQuestion?.id, "q1")
    XCTAssertNil(vm.initError, "No errors")
}

@MainActor
func testQuestionViewModelInitializationError() async {
    struct TestError: Error { }
    let mockService = MockQuestionService(errorToThrow: TestError())
    
    let vm = QuestionScreenViewModel(categoryId: "traffic-signs", questionService: mockService)
    await vm.initialize()
    
    XCTAssertTrue(vm.isInitialized)
    XCTAssertNotNil(vm.initError)
    XCTAssertNil(vm.currentQuestion)
}