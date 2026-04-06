// Tests/Unit/Services/ProgressRepositoryTests.swift

import XCTest
@testable import DriveAI

class ProgressRepositoryTests: XCTestCase {
    var repository: LocalProgressRepository!
    
    override func setUp() {
        repository = LocalProgressRepository()
    }
    
    func testDeleteAllUserDataRemovesProgress() throws {
        // Arrange
        var progress = UserProgress()
        progress.examDate = Date().addingTimeInterval(86400 * 30)
        repository.saveProgress(progress)
        
        // Act
        try repository.deleteAllUserData()
        
        // Assert
        let deletedProgress = repository.loadProgress()
        XCTAssertNil(deletedProgress.examDate, "Exam date should be cleared")
        XCTAssertEqual(deletedProgress.questionsAnswered, 0, "Questions answered should be zero")
    }
    
    func testDeleteAllUserDataIsIrrevocable() throws {
        // Verify deletion cannot be undone (important for GDPR compliance)
        try repository.deleteAllUserData()
        let reloadedProgress = repository.loadProgress()
        XCTAssertTrue(reloadedProgress.equals(.empty), "Data should be unrecoverable")
    }
}