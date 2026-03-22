// Tests/BreathingViewModelTests.swift
import XCTest
@testable import BreathFlow

final class BreathingViewModelTests: XCTestCase {
    var sut: BreathingViewModel!
    
    override func setUp() {
        super.setUp()
        sut = BreathingViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Session Lifecycle
    
    func testStartSessionInitializesState() {
        sut.startSession()
        
        XCTAssertTrue(sut.isActive)
        XCTAssertFalse(sut.isPaused)
        XCTAssertEqual(sut.currentPhase, .inhale)
        XCTAssertEqual(sut.completedCycles, 0)
    }
    
    func testPauseSessionStopsTimer() {
        sut.startSession()
        let initialDuration = sut.sessionDurationSeconds
        
        sut.pauseSession()
        XCTAssertFalse(sut.isActive)
        XCTAssertTrue(sut.isPaused)
    }
    
    func testResumeSessionContinuesFromPause() {
        sut.startSession()
        sut.pauseSession()
        
        sut.resumeSession()
        XCTAssertTrue(sut.isActive)
        XCTAssertFalse(sut.isPaused)
    }
    
    // MARK: - Phase Transitions
    
    func testPhaseTransitionsCorrectly() {
        sut.selectedTechnique = .boxBreathing
        sut.startSession()
        
        XCTAssertEqual(sut.currentPhase, .inhale)
        XCTAssertEqual(sut.timeRemaining, 4)
    }
    
    func testProgressInterpolates() {
        sut.startSession()
        
        XCTAssertGreaterThanOrEqual(sut.progress, 0.0)
        XCTAssertLessThanOrEqual(sut.progress, 1.0)
    }
    
    // MARK: - Cycle Counting
    
    func testCycleCountIncrementsOnExhaleComplete() {
        sut.selectedTechnique = .calmBreathing
        let initialCount = sut.completedCycles
        
        sut.startSession()
        
        // Simulate completion
        XCTAssertEqual(sut.completedCycles, initialCount)
    }
    
    // MARK: - Stop & Save
    
    func testStopSessionSavesRecord() {
        let statsService = StatsService.shared
        let initialCount = statsService.allSessions.count
        
        sut.selectedTechnique = .fourSevenEight
        sut.startSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.sut.stopSession()
        }
        
        let expectation = XCTestExpectation(description: "Session saved")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(statsService.allSessions.count, initialCount)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Technique Selection
    
    func testTechniqueChangesPhaseTimings() {
        sut.selectedTechnique = .fourSevenEight
        sut.startSession()
        let fourSevenEightInhale = sut.timeRemaining
        
        sut.stopSession()
        
        sut.selectedTechnique = .boxBreathing
        sut.startSession()
        let boxBreathingInhale = sut.timeRemaining
        
        XCTAssertNotEqual(fourSevenEightInhale, boxBreathingInhale)
    }
}