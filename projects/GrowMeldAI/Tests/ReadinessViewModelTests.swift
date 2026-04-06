import XCTest
import Combine
@testable import DriveAI

@MainActor
final class ReadinessViewModelTests: XCTestCase {
    var sut: ReadinessViewModel!
    var mockProgress: MockProgressTrackingService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockProgress = MockProgressTrackingService()
        sut = ReadinessViewModel(progressService: mockProgress)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        mockProgress = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path
    
    func testInitialStateIsRed() {
        XCTAssertEqual(sut.status, .red)
        XCTAssertEqual(sut.readinessPercentage, 0.0)
        XCTAssertEqual(sut.questionsRemaining, 24)
    }
    
    func testStatusTransitionsFromRedToYellowAt19Correct() {
        mockProgress.setCorrectAnswers(19)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.status, .yellow)
        XCTAssertGreaterThanOrEqual(sut.readinessPercentage, 0.79)
    }
    
    func testStatusTransitionsFromYellowToGreenAt24Correct() {
        mockProgress.setCorrectAnswers(24)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.status, .green)
        XCTAssertEqual(sut.readinessPercentage, 1.0)
    }
    
    func testQuestionsRemainingDecreases() {
        mockProgress.setCorrectAnswers(5)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.questionsRemaining, 19)
    }
    
    func testMotivationMessageChangesWithStatus() {
        mockProgress.setCorrectAnswers(0)
        sut.updateReadiness()
        let redMessage = sut.motivationMessage
        
        mockProgress.setCorrectAnswers(24)
        sut.updateReadiness()
        let greenMessage = sut.motivationMessage
        
        XCTAssertNotEqual(redMessage, greenMessage)
        XCTAssertTrue(greenMessage.contains("🎉"))
    }
    
    func testPassRateCalculatedCorrectly() {
        mockProgress.setCorrectAnswers(15)
        mockProgress.setTotalAttempted(20)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.passRatePercentage, 75)
    }
    
    // MARK: - Edge Cases
    
    func testZeroQuestionsCorrect() {
        mockProgress.setCorrectAnswers(0)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.questionsRemaining, 24)
        XCTAssertEqual(sut.readinessPercentage, 0.0)
        XCTAssertEqual(sut.status, .red)
    }
    
    func testMoreThan24CorrectAnswers() {
        mockProgress.setCorrectAnswers(30)
        sut.updateReadiness()
        
        XCTAssertEqual(sut.status, .green)
        XCTAssertEqual(sut.questionsRemaining, 0)
        XCTAssertLessThanOrEqual(sut.questionsRemaining, 0)
    }
    
    func testStatusBoundaryAt18Questions() {
        mockProgress.setCorrectAnswers(18)
        sut.updateReadiness()
        XCTAssertEqual(sut.status, .red)
        
        mockProgress.setCorrectAnswers(19)
        sut.updateReadiness()
        XCTAssertEqual(sut.status, .yellow)
    }
    
    func testStatusBoundaryAt23Questions() {
        mockProgress.setCorrectAnswers(23)
        sut.updateReadiness()
        XCTAssertEqual(sut.status, .yellow)
        
        mockProgress.setCorrectAnswers(24)
        sut.updateReadiness()
        XCTAssertEqual(sut.status, .green)
    }
    
    // MARK: - Observable Properties
    
    func testReadinessPercentagePublishesUpdates() {
        let expectation = XCTestExpectation(description: "readinessPercentage updated")
        var publishedValues: [Double] = []
        
        sut.$readinessPercentage
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockProgress.setCorrectAnswers(12)
        sut.updateReadiness()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValues.count, 2) // Initial + update
    }
    
    func testStatusPublishesUpdates() {
        let expectation = XCTestExpectation(description: "status updated")
        var publishedStatuses: [ReadinessViewModel.ReadinessStatus] = []
        
        sut.$status
            .sink { status in
                publishedStatuses.append(status)
                if publishedStatuses.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockProgress.setCorrectAnswers(24)
        sut.updateReadiness()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(publishedStatuses.contains(.green))
    }
    
    // MARK: - Error Handling
    
    func testHandlesZeroDivisionInPassRate() {
        mockProgress.setCorrectAnswers(10)
        mockProgress.setTotalAttempted(0)
        
        sut.updateReadiness()
        
        // Should not crash; should handle gracefully
        XCTAssertEqual(sut.passRatePercentage, 0)
    }
    
    // MARK: - Memory Management
    
    func testViewModelDeallocatesWithoutLeaks() {
        weak var weakVM: ReadinessViewModel? = nil
        
        autoreleasepool {
            var vm: ReadinessViewModel? = ReadinessViewModel(progressService: mockProgress)
            weakVM = vm
            let _ = vm?.readinessPercentage
            vm = nil
        }
        
        XCTAssertNil(weakVM, "ReadinessViewModel should deallocate without leaks")
    }
}