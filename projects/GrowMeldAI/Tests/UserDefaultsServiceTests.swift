// Tests/Services/UserDefaultsServiceTests.swift
import XCTest
@testable import DriveAI

class UserDefaultsServiceTests: XCTestCase {
    var sut: UserDefaultsService!
    var testDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use in-memory UserDefaults for testing
        testDefaults = UserDefaults(suiteName: UUID().uuidString)!
        sut = UserDefaultsService(userDefaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testDefaults.suiteName!)
        super.tearDown()
    }
    
    // MARK: - Happy Path
    
    func test_saveAndLoadProgress_roundTrip() {
        let originalProgress = UserProgress(
            examDate: Date(),
            totalCorrect: 50,
            totalAttempted: 100,
            currentStreak: 5
        )
        
        sut.saveProgress(originalProgress)
        let loaded = sut.loadProgress()
        
        XCTAssertEqual(loaded.totalCorrect, originalProgress.totalCorrect)
        XCTAssertEqual(loaded.totalAttempted, originalProgress.totalAttempted)
        XCTAssertEqual(loaded.currentStreak, originalProgress.currentStreak)
    }
    
    // MARK: - Edge Cases
    
    func test_loadProgress_whenNothingSaved_returnsDefault() {
        let loaded = sut.loadProgress()
        
        XCTAssertEqual(loaded.totalCorrect, 0)
        XCTAssertEqual(loaded.totalAttempted, 0)
        // examDate should be ~60 days in future (default)
        XCTAssertGreaterThan(loaded.daysUntilExam, 50)
    }
    
    func test_saveProgress_withZeroValues() {
        let progress = UserProgress(
            examDate: Date(),
            totalCorrect: 0,
            totalAttempted: 0,
            currentStreak: 0
        )
        
        sut.saveProgress(progress)
        let loaded = sut.loadProgress()
        
        XCTAssertEqual(loaded.totalCorrect, 0)
    }
}