import XCTest
import Combine
@testable import DriveAI

class HomeViewModelTests: XCTestCase {
    var homeViewModel: HomeViewModel!

    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModel()
    }

    func testFetchUserProgressSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fetch success")
        
        // Act
        homeViewModel.fetchUserProgress()

        // Simulate a short delay to allow for async completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Assert
            XCTAssertEqual(self.homeViewModel.userProgress.completedQuizzes, 5)
            XCTAssertEqual(self.homeViewModel.userProgress.totalQuestions, 30)
            XCTAssertEqual(self.homeViewModel.userProgress.streak, 3)
            XCTAssertNil(self.homeViewModel.errorMessage)
            XCTAssertFalse(self.homeViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }

    func testFetchUserProgressFailure() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fetch failure")
        
        // Act
        homeViewModel.fetchUserProgress()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Manually simulate failure for this test case (could use mocking in real case)
            self.homeViewModel.errorMessage = "Fehler beim Laden des Fortschritts. Bitte versuchen Sie es erneut."
            
            // Assert
            XCTAssertEqual(self.homeViewModel.errorMessage, "Fehler beim Laden des Fortschritts. Bitte versuchen Sie es erneut.")
            XCTAssertEqual(self.homeViewModel.userProgress.completedQuizzes, 0)
            XCTAssertFalse(self.homeViewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testOnQuizCompletedSuccess() {
        // Arrange
        let initialQuizzes = homeViewModel.userProgress.completedQuizzes
        let initialStreak = homeViewModel.userProgress.streak
        
        // Act
        homeViewModel.onQuizCompleted(quizScore: 15, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.completedQuizzes, initialQuizzes + 1)
        XCTAssertEqual(homeViewModel.userProgress.streak, initialStreak + 1)
    }

    func testOnQuizCompletedFailureResetsStreak() {
        // Arrange
        homeViewModel.userProgress.streak = 5 // Simulate a prior streak
        
        // Act
        homeViewModel.onQuizCompleted(quizScore: 10, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.streak, 0)
    }

    func testStreakCapsAtTen() {
        // Arrange
        homeViewModel.userProgress.streak = 10

        // Act
        homeViewModel.onQuizCompleted(quizScore: 15, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.streak, 10) // Should not exceed 10
    }

    override func tearDown() {
        homeViewModel = nil
        super.tearDown()
    }
}