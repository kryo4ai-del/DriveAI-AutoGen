import XCTest
import Combine
@testable import DriveAI

// Mocked ViewModel class for testing purposes, simulating fetch results
class MockedHomeViewModel: HomeViewModel {
    var shouldSimulateFetchSuccess = true

    override func fetchUserProgress() {
        isLoading = true

        // Simulate a fetch result based on shouldSimulateFetchSuccess
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSimulateFetchSuccess {
                self.userProgress = UserProgress(completedQuizzes: 5, totalQuestions: 30, streak: 3)
                self.errorMessage = nil
            } else {
                self.errorMessage = NSLocalizedString("fetch_error", comment: "Error message when fetching user progress fails")
                self.userProgress = UserProgress(completedQuizzes: 0, totalQuestions: 0, streak: 0)
            }
            self.isLoading = false
        }
    }
}

class HomeViewModelTests: XCTestCase {
    var homeViewModel: HomeViewModel!

    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModel()
    }

    func test_fetchUserProgress_whenSuccess_updatesUserProgress() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fetch user progress successfully")

        // Act
        homeViewModel.fetchUserProgress()

        // Validate the output after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Assert success
            XCTAssertEqual(self.homeViewModel.userProgress.completedQuizzes, 5)
            XCTAssertEqual(self.homeViewModel.userProgress.totalQuestions, 30)
            XCTAssertEqual(self.homeViewModel.userProgress.streak, 3)
            XCTAssertNil(self.homeViewModel.errorMessage)
            XCTAssertFalse(self.homeViewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func test_fetchUserProgress_whenFailure_updatesErrorMessage() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fetch user progress failure")
        let mockedViewModel = MockedHomeViewModel()
        mockedViewModel.shouldSimulateFetchSuccess = false
        
        // Act
        mockedViewModel.fetchUserProgress()

        // Validate error response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Assert
            XCTAssertEqual(mockedViewModel.errorMessage, NSLocalizedString("fetch_error", comment: "Error message when fetching user progress fails"))
            XCTAssertEqual(mockedViewModel.userProgress.completedQuizzes, 0)
            XCTAssertFalse(mockedViewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func test_onQuizCompleted_withPassingScore_updatesProgress() {
        // Arrange
        let initialQuizzes = homeViewModel.userProgress.completedQuizzes
        let initialStreak = homeViewModel.userProgress.streak

        // Act
        homeViewModel.onQuizCompleted(quizScore: 15, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.completedQuizzes, initialQuizzes + 1)
        XCTAssertEqual(homeViewModel.userProgress.streak, initialStreak + 1, "Streak should increment upon successful completion.")
    }

    func test_onQuizCompleted_withFailingScore_resetsStreak() {
        // Arrange
        homeViewModel.userProgress.streak = 5 // Simulate a prior streak

        // Act
        homeViewModel.onQuizCompleted(quizScore: 10, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.streak, 0, "Streak should be reset to zero upon failure.")
    }

    func test_onQuizCompleted_capsStreakAtTen() {
        // Arrange
        homeViewModel.userProgress.streak = 10

        // Act
        homeViewModel.onQuizCompleted(quizScore: 15, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.streak, 10, "Streak should not exceed maximum limit of 10.")
    }

    func test_onQuizCompleted_whenAchievingStreakCap_doesNotIncrement() {
        // Arrange
        homeViewModel.userProgress.streak = 10 // Simulate a capped streak
        
        // Act
        homeViewModel.onQuizCompleted(quizScore: 15, totalQuestions: 30)

        // Assert
        XCTAssertEqual(homeViewModel.userProgress.streak, 10, "Streak should remain capped at 10 and not increment further.")
    }

    override func tearDown() {
        homeViewModel = nil
        super.tearDown()
    }
}