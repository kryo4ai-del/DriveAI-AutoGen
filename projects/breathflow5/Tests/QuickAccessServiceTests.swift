class QuickAccessServiceTests: XCTestCase {
    var service: QuickAccessService!
    var exerciseSelectionMock: MockExerciseSelectionService!
    var quizProgressMock: MockQuizProgressService!
    
    func test_resumeLastQuiz_whenExerciseExists() async throws {
        // Arrange
        quizProgressMock.lastIncompleteExercise = Exercise(id: "1")
        
        // Act
        let path = try await service.resolveNavigationPath(
            from: .homeScreenButton,
            userState: .authenticated
        )
        
        // Assert
        guard case .resumeLastQuiz = path else {
            XCTFail("Expected resumeLastQuiz path")
            return
        }
    }
}