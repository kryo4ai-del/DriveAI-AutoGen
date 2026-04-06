// Tests/Performance/PerformanceModelsTests.swift

import XCTest
@testable import DriveAI

final class QuestionAttemptTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testQuestionAttemptInitialization_WithCorrectAnswer() {
        let questionID = UUID()
        let categoryID = UUID()
        
        let attempt = QuestionAttempt(
            questionID: questionID,
            categoryID: categoryID,
            selectedAnswerIndex: 1,
            correctAnswerIndex: 1,
            timeSpentSeconds: 15.5
        )
        
        XCTAssertEqual(attempt.questionID, questionID)
        XCTAssertEqual(attempt.categoryID, categoryID)
        XCTAssertTrue(attempt.isCorrect)
        XCTAssertEqual(attempt.timeSpentSeconds, 15.5)
        XCTAssertNotNil(attempt.id)
        XCTAssertNotNil(attempt.timestamp)
    }
    
    func testQuestionAttemptInitialization_WithIncorrectAnswer() {
        let attempt = QuestionAttempt(
            questionID: UUID(),
            categoryID: UUID(),
            selectedAnswerIndex: 0,
            correctAnswerIndex: 2,
            timeSpentSeconds: 8.0
        )
        
        XCTAssertFalse(attempt.isCorrect)
    }
    
    func testQuestionAttemptInitialization_BoundaryTimeValues() {
        let attemptZeroTime = QuestionAttempt(
            questionID: UUID(),
            categoryID: UUID(),
            selectedAnswerIndex: 0,
            correctAnswerIndex: 0,
            timeSpentSeconds: 0
        )
        XCTAssertEqual(attemptZeroTime.timeSpentSeconds, 0)
        
        let attemptLongTime = QuestionAttempt(
            questionID: UUID(),
            categoryID: UUID(),
            selectedAnswerIndex: 0,
            correctAnswerIndex: 0,
            timeSpentSeconds: 300
        )
        XCTAssertEqual(attemptLongTime.timeSpentSeconds, 300)
    }
    
    // MARK: - Codable Tests
    
    func testQuestionAttemptCodable_EncodeDecode() throws {
        let original = QuestionAttempt(
            questionID: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!,
            categoryID: UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!,
            selectedAnswerIndex: 2,
            correctAnswerIndex: 2,
            timeSpentSeconds: 25.5
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuestionAttempt.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.questionID, decoded.questionID)
        XCTAssertEqual(original.isCorrect, decoded.isCorrect)
    }
    
    // MARK: - Equatable Tests
    
    func testQuestionAttemptEquatable_SameValues() {
        let id = UUID()
        let questionID = UUID()
        let categoryID = UUID()
        
        let attempt1 = QuestionAttempt(
            questionID: questionID,
            categoryID: categoryID,
            selectedAnswerIndex: 0,
            correctAnswerIndex: 0,
            timeSpentSeconds: 10
        )
        var attempt2 = attempt1
        attempt2.id = id // Force same ID for comparison
        
        XCTAssertEqual(attempt1, attempt2)
    }
}

final class ExamAttemptTests: XCTestCase {
    
    func testExamAttemptInitialization_WithPassingScore() {
        let attempts = [
            QuestionAttempt(questionID: UUID(), categoryID: UUID(), 
                           selectedAnswerIndex: 0, correctAnswerIndex: 0, timeSpentSeconds: 10),
            QuestionAttempt(questionID: UUID(), categoryID: UUID(), 
                           selectedAnswerIndex: 1, correctAnswerIndex: 1, timeSpentSeconds: 12)
        ]
        
        let exam = ExamAttempt(
            attempts: attempts,
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 1800),
            totalScore: 43,
            maxScore: 50,
            categoryScores: [:]
        )
        
        XCTAssertTrue(exam.isPassed)
        XCTAssertEqual(exam.totalScore, 43)
        XCTAssertEqual(exam.duration, 1800)
    }
    
    func testExamAttemptInitialization_WithFailingScore() {
        let exam = ExamAttempt(
            attempts: [],
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 1800),
            totalScore: 42,
            maxScore: 50,
            categoryScores: [:]
        )
        
        XCTAssertFalse(exam.isPassed)
    }
    
    func testExamAttemptAccuracyPercentage_CalculatedCorrectly() {
        let exam = ExamAttempt(
            attempts: [],
            startTime: Date(),
            endTime: Date(),
            totalScore: 45,
            maxScore: 50,
            categoryScores: [:]
        )
        
        XCTAssertEqual(exam.accuracyPercentage, 90.0, accuracy: 0.01)
    }
    
    func testExamAttemptDuration_CalculatedFromDates() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour
        
        let exam = ExamAttempt(
            attempts: [],
            startTime: startTime,
            endTime: endTime,
            totalScore: 45,
            maxScore: 50,
            categoryScores: [:]
        )
        
        XCTAssertEqual(exam.duration, 3600)
    }
    
    func testExamAttemptCategoryScoresMapping() {
        let catID = UUID()
        let score = CategoryScore(
            categoryID: catID,
            categoryName: "Traffic Signs",
            correctAnswers: 8,
            totalQuestions: 10
        )
        
        let exam = ExamAttempt(
            attempts: [],
            startTime: Date(),
            endTime: Date(),
            totalScore: 45,
            maxScore: 50,
            categoryScores: [catID: score]
        )
        
        XCTAssertEqual(exam.categoryScores[catID], score)
        XCTAssertEqual(exam.categoryScores[catID]?.accuracy, 80.0, accuracy: 0.01)
    }
}

final class PerformanceMetricsTests: XCTestCase {
    
    func testMetricsInitialization_Empty() {
        let metrics = PerformanceMetrics(
            totalAttempts: 0,
            totalExams: 0,
            overallAccuracy: 0,
            totalTimeSpent: 0,
            categoryMetrics: [:],
            lastActivityDate: nil
        )
        
        XCTAssertEqual(metrics.totalAttempts, 0)
        XCTAssertEqual(metrics.averageTimePerQuestion, 0)
        XCTAssertTrue(metrics.weakestCategories.isEmpty)
    }
    
    func testMetricsAverageTimePerQuestion_Calculated() {
        let metrics = PerformanceMetrics(
            totalAttempts: 10,
            totalExams: 1,
            overallAccuracy: 85,
            totalTimeSpent: 250, // 250s total
            categoryMetrics: [:],
            lastActivityDate: nil
        )
        
        XCTAssertEqual(metrics.averageTimePerQuestion, 25.0)
    }
    
    func testMetricsWeakestCategories_Sorted() {
        let cat1 = UUID()
        let cat2 = UUID()
        let cat3 = UUID()
        let cat4 = UUID()
        
        let metrics = PerformanceMetrics(
            totalAttempts: 40,
            totalExams: 1,
            overallAccuracy: 85,
            totalTimeSpent: 400,
            categoryMetrics: [
                cat1: CategoryMetric(categoryID: cat1, categoryName: "Cat1", attempts: 10, correctAttempts: 7, totalTimeSpent: 100),
                cat2: CategoryMetric(categoryID: cat2, categoryName: "Cat2", attempts: 10, correctAttempts: 6, totalTimeSpent: 100),
                cat3: CategoryMetric(categoryID: cat3, categoryName: "Cat3", attempts: 10, correctAttempts: 9, totalTimeSpent: 100),
                cat4: CategoryMetric(categoryID: cat4, categoryName: "Cat4", attempts: 10, correctAttempts: 8, totalTimeSpent: 100)
            ],
            lastActivityDate: nil
        )
        
        let weakest = metrics.weakestCategories
        XCTAssertEqual(weakest.count, 3) // top 3 weakest
        XCTAssertEqual(weakest[0], cat2) // 60% accuracy
        XCTAssertEqual(weakest[1], cat1) // 70% accuracy
        XCTAssertEqual(weakest[2], cat4) // 80% accuracy
    }
}

final class StreakDataTests: XCTestCase {
    
    func testStreakData_CurrentlyActive() {
        let today = Calendar.current.startOfDay(for: Date())
        let streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActivityDate: today,
            totalActiveDays: 20
        )
        
        XCTAssertTrue(streak.isStreakActive)
    }
    
    func testStreakData_BrokenOneHourAgo() {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActivityDate: oneHourAgo,
            totalActiveDays: 20
        )
        
        XCTAssertTrue(streak.isStreakActive)
    }
    
    func testStreakData_BrokenTwoDaysAgo() {
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 3600)
        let streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActivityDate: twoDaysAgo,
            totalActiveDays: 20
        )
        
        XCTAssertFalse(streak.isStreakActive)
    }
    
    func testStreakData_NoActivity() {
        let streak = StreakData(
            currentStreak: 0,
            longestStreak: 0,
            lastActivityDate: nil,
            totalActiveDays: 0
        )
        
        XCTAssertFalse(streak.isStreakActive)
    }
}

final class PerformanceErrorTests: XCTestCase {
    
    func testPerformanceErrorEquatable() {
        let error1 = PerformanceError.recordingFailed("DB error")
        let error2 = PerformanceError.recordingFailed("DB error")
        
        XCTAssertEqual(error1, error2)
    }
    
    func testPerformanceErrorEquatable_DifferentReasons() {
        let error1 = PerformanceError.recordingFailed("Reason A")
        let error2 = PerformanceError.recordingFailed("Reason B")
        
        XCTAssertNotEqual(error1, error2)
    }
    
    func testPerformanceErrorEquatable_DifferentCases() {
        let error1 = PerformanceError.databaseUnavailable
        let error2 = PerformanceError.corruptedData
        
        XCTAssertNotEqual(error1, error2)
    }
    
    func testPerformanceErrorLocalizedDescription() {
        let error = PerformanceError.recordingFailed("Test reason")
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }
}