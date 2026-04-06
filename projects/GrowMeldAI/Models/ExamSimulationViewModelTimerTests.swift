@MainActor
final class ExamSimulationViewModelTimerTests: XCTestCase {
    var viewModel: ExamSimulationViewModel!
    var mockDataService: MockLocalDataService!
    var mockTimerService: TimerService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        mockTimerService = TimerService()
        viewModel = ExamSimulationViewModel(
            dataService: mockDataService,
            timerService: mockTimerService
        )
    }
    
    // HAPPY PATH: Timer counts down
    func testTimerCountsDown() async {
        // Arrange
        let initialTime = 600 // 10 minutes
        mockTimerService.startCountdown(seconds: initialTime)
        
        // Act
        try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
        
        // Assert: Time decreased (with tolerance for execution time)
        XCTAssertGreaterThanOrEqual(mockTimerService.secondsRemaining, 597)
        XCTAssertLessThanOrEqual(mockTimerService.secondsRemaining, 599)
    }
    
    // HAPPY PATH: Timer finishes exam at zero
    func testTimerFinishesExamAtZero() async {
        // Arrange
        mockTimerService.startCountdown(
            seconds: 2,
            onFinish: { [weak self] in
                self?.viewModel.finishExam()
            }
        )
        
        // Act
        try? await Task.sleep(nanoseconds: 3_000_000_000) // Wait for timer to expire
        
        // Assert
        XCTAssertEqual(viewModel.examState, .submitted)
        XCTAssertEqual(mockTimerService.secondsRemaining, 0)
    }
    
    // EDGE CASE: Timer at 5-minute mark shows warning
    func testTimerWarningAt5Minutes() async {
        // Arrange
        mockTimerService.startCountdown(seconds: 305) // 5m 5s
        
        // Act
        try? await Task.sleep(nanoseconds: 6_000_000_000)
        
        // Assert
        XCTAssertTrue(mockTimerService.isWarning, "Should show warning < 5 min")
    }
    
    // BUG TEST: Multiple startCountdown calls (race condition)
    func testNoTimerAccumulationOnMultipleStarts() async {
        // Arrange
        let startExpectation = expectation(description: "Timer started")
        var timerFireCount = 0
        
        let onTick = {
            timerFireCount += 1
        }
        
        // Act: Call startCountdown 3 times rapidly
        mockTimerService.startCountdown(seconds: 10, onTick: onTick)
        mockTimerService.startCountdown(seconds: 10, onTick: onTick)
        mockTimerService.startCountdown(seconds: 10, onTick: onTick)
        
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Assert: Should have ~3 ticks (one timer), not ~9 (three timers)
        XCTAssertLessThan(timerFireCount, 6, "Should not accumulate timers")
        startExpectation.fulfill()
        
        await fulfillment(of: [startExpectation])
    }
    
    // EDGE CASE: Pause and resume timer
    func testTimerPauseAndResume() async {
        // Arrange
        mockTimerService.startCountdown(seconds: 100)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let timeBeforePause = mockTimerService.secondsRemaining
        
        // Act: Pause
        mockTimerService.pause()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let timeAfterPause = mockTimerService.secondsRemaining
        
        // Assert: Time didn't change
        XCTAssertEqual(timeBeforePause, timeAfterPause, "Pause should stop timer")
        
        // Act: Resume
        mockTimerService.resume()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Assert: Time resumed decreasing
        XCTAssertLess(mockTimerService.secondsRemaining, timeAfterPause)
    }
}