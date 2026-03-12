import XCTest
@testable import DriveAI

class EndToEndFlowTest: XCTestCase {
    
    func testOnboardingToQuizFlow() {
        let onboardingViewModel = OnboardingViewModel()
        onboardingViewModel.examDate = Date().addingTimeInterval(3600) // Simulate user selecting a future date
        
        XCTAssertTrue(onboardingViewModel.isReady)
        
        onboardingViewModel.completeOnboarding()
        
        let homeViewModel = HomeViewModel()
        homeViewModel.calculateProgress() // Ensure progress calculation is reflected
        XCTAssertFalse(homeViewModel.progress.isEmpty)
        
        let quizViewModel = QuizViewModel()
        XCTAssertNotNil(quizViewModel.currentQuestion)
        XCTAssertEqual(quizViewModel.questions.count, 2)

        if let question = quizViewModel.currentQuestion {
            quizViewModel.submitAnswer(question.correctAnswer)
            XCTAssertEqual(quizViewModel.score, 1)
        }

        while quizViewModel.currentQuestion != nil {
            quizViewModel.submitAnswer(quizViewModel.currentQuestion!.correctAnswer)
        }
        
        XCTAssertTrue(quizViewModel.passed)
    }
    
    func testQuizPassingCriteria() {
        let quizViewModel = QuizViewModel()
        // Simulate answering incorrectly and testing score increments...
        quizViewModel.submitAnswer("Incorrect Answer")
        quizViewModel.submitAnswer(quizViewModel.questions[0].correctAnswer)
        
        XCTAssertEqual(quizViewModel.score, 1) // Verify score updates correctly
    }
}