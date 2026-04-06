// Domain/BackupSystem/Tests/BackupModelsTests.swift

import XCTest
@testable import DriveAI

final class BackupModelsTests: XCTestCase {
    
    // MARK: - UserBackup Validation
    
    func test_userBackupValidation_success() throws {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        XCTAssertNoThrow(try backup.validate())
    }
    
    func test_userBackupValidation_failsWithPastExamDate() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(-1), // Past date
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        XCTAssertThrowsError(try backup.validate()) { error in
            XCTAssertTrue(error is BackupError)
        }
    }
    
    func test_userBackupValidation_failsWithInvalidScore() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 150, // Out of range
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        XCTAssertThrowsError(try backup.validate()) { error in
            guard let backupError = error as? BackupError else {
                XCTFail("Expected BackupError")
                return
            }
            
            if case .invalidData(let message) = backupError {
                XCTAssertTrue(message.contains("0-100"))
            } else {
                XCTFail("Expected invalidData error")
            }
        }
    }
    
    func test_userBackupValidation_failsWithNegativeQuestionCount() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: -1, // Invalid
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        XCTAssertThrowsError(try backup.validate())
    }
    
    func test_userBackupValidation_failsWithInvalidCategoryProgress() {
        let invalidCategory = CategoryProgress(
            id: "test",
            categoryName: "Test",
            questionsCorrect: 10,
            questionsTotal: 5, // More correct than total
            lastReviewedDate: nil,
            mastered: false
        )
        
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [invalidCategory],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        XCTAssertThrowsError(try backup.validate())
    }
    
    // MARK: - CategoryProgress Validation
    
    func test_categoryProgressValidation_success() {
        let category = CategoryProgress(
            id: "verkehrszeichen",
            categoryName: "Verkehrszeichen",
            questionsCorrect: 8,
            questionsTotal: 10,
            lastReviewedDate: Date(),
            mastered: true
        )
        
        XCTAssertTrue(category.isProgressValid())
    }
    
    func test_categoryProgressValidation_failsWithInvalidCounts() {
        let category = CategoryProgress(
            id: "test",
            categoryName: "Test",
            questionsCorrect: -1,
            questionsTotal: 10,
            lastReviewedDate: nil,
            mastered: false
        )
        
        XCTAssertFalse(category.isProgressValid())
    }
    
    func test_categoryProgressPercentage_calculation() {
        let category = CategoryProgress(
            id: "test",
            categoryName: "Test",
            questionsCorrect: 7,
            questionsTotal: 10,
            lastReviewedDate: nil,
            mastered: false
        )
        
        XCTAssertEqual(category.progressPercentage, 0.7, accuracy: 0.01)
    }
    
    func test_categoryProgressPercentage_zeroTotal() {
        let category = CategoryProgress(
            id: "test",
            categoryName: "Test",
            questionsCorrect: 0,
            questionsTotal: 0,
            lastReviewedDate: nil,
            mastered: false
        )
        
        XCTAssertEqual(category.progressPercentage, 0.0)
    }
    
    // MARK: - Backup Staleness
    
    func test_backupStaleness_recentBackup() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(), // Created now
            appVersion: "1.0.0"
        )
        
        XCTAssertFalse(backup.isStale())
    }
    
    func test_backupStaleness_oldBackup() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date().addingTimeInterval(-14 * 24 * 3600), // 14 days old
            appVersion: "1.0.0"
        )
        
        XCTAssertTrue(backup.isStale())
    }
    
    func test_backupStaleness_customThreshold() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date().addingTimeInterval(-3 * 24 * 3600), // 3 days old
            appVersion: "1.0.0"
        )
        
        XCTAssertFalse(backup.isStale(threshold: 7 * 24 * 3600)) // 7 day threshold
        XCTAssertTrue(backup.isStale(threshold: 1 * 24 * 3600))  // 1 day threshold
    }
    
    // MARK: - Exam Readiness
    
    func test_daysUntilExam_upcoming() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(15 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        let days = backup.daysUntilExam()
        XCTAssertEqual(days, 15, accuracy: 1)
    }
    
    func test_examReadinessMessage_examinationDay() {
        let backup = UserBackup(
            examDate: Date(),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        let message = backup.examReadinessMessage()
        XCTAssertTrue(message.contains("🎯"))
    }
    
    func test_examReadinessMessage_withinWeek() {
        let backup = UserBackup(
            examDate: Date().addingTimeInterval(3 * 24 * 3600),
            overallScore: 75,
            totalQuestionsAnswered: 150,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        let message = backup.examReadinessMessage()
        XCTAssertTrue(message.contains("⚠️"))
        XCTAssertTrue(message.contains("3"))
    }
    
    // MARK: - Codable Conformance
    
    func test_userBackupEncodingDecoding() throws {
        let original = UserBackup(
            examDate: Date().addingTimeInterval(30 * 24 * 3600),
            overallScore: 85,
            totalQuestionsAnswered: 200,
            categoryProgress: [makeMockCategoryProgress()],
            backupMetadata: .current(),
            createdAt: Date(),
            appVersion: "1.0.0"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserBackup.self, from: encoded)
        
        XCTAssertEqual(original.overallScore, decoded.overallScore)
        XCTAssertEqual(original.totalQuestionsAnswered, decoded.totalQuestionsAnswered)
    }
    
    // MARK: - Helpers
    
    private func makeMockCategoryProgress() -> CategoryProgress {
        CategoryProgress(
            id: "test_category",
            categoryName: "Test Category",
            questionsCorrect: 8,
            questionsTotal: 10,
            lastReviewedDate: Date(),
            mastered: true
        )
    }
}

// Extension for convenient assertion
extension XCTest {
    func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, 
                            _ message: @autoclosure () -> String = "") {
        do {
            _ = try expression()
        } catch {
            XCTFail("Expected no throw, but got: \(error). \(message())")
        }
    }
}