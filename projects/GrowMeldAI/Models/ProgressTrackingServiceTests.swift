// Tests/Services/ProgressTrackingServiceTests.swift
import XCTest
@testable import DriveAI

class ProgressTrackingServiceTests: XCTestCase {
    var sut: ProgressTrackingService!
    
    override func setUp() {
        super.setUp()
        sut = ProgressTrackingService()
        sut.resetAllData()  // Clean state
    }
    
    override func tearDown() {
        sut.resetAllData()
        super.tearDown()
    }
    
    // MARK: - Answer Recording Tests
    
    func testRecordAnswer_CorrectAnswer() {
        let questionID = UUID()
        let optionID = UUID()
        let category = Category.trafficSigns
        
        sut.recordAnswer(
            questionID: questionID,
            selectedOptionID: optionID,
            correctOptionID: optionID,  // Same = correct
            category: category,
            timeTaken: 5.0
        )
        
        // Allow time for async dispatch
        let expectation = XCTestExpectation(description: "Record async")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.userProfile.totalQuestionsAnswered, 1)
            XCTAssertEqual(sut.userProfile.totalCorrectAnswers, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecordAnswer_IncorrectAnswer() {
        let questionID = UUID()
        let selectedID = UUID()
        let correctID = UUID()
        
        sut.recordAnswer(
            questionID: questionID,
            selectedOptionID: selectedID,
            correctOptionID: correctID,  // Different = incorrect
            category: .rightOfWay,
            timeTaken: 10.0
        )
        
        let expectation = XCTestExpectation(description: "Record async")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.userProfile.totalQuestionsAnswered, 1)
            XCTAssertEqual(sut.userProfile.totalCorrectAnswers, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecordAnswer_UpdatesCategory() {
        let category = Category.trafficSigns
        let optionID = UUID()
        
        sut.recordAnswer(
            questionID: UUID(),
            selectedOptionID: optionID,
            correctOptionID: optionID,
            category: category,
            timeTaken: 3.0
        )
        
        let expectation = XCTestExpectation(description: "Record async")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let stats = sut.userProfile.categoryStats[category.rawValue]
            XCTAssertNotNil(stats, "Should create category stats")
            XCTAssertEqual(stats?.questionsAnswered, 1)
            XCTAssertEqual(stats?.correctAnswers, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecordAnswer_MultipleCalls_AccumulateStats() {
        let optionID = UUID()
        
        for i in 0..<5 {
            sut.recordAnswer(
                questionID: UUID(),
                selectedOptionID: optionID,
                correctOptionID: optionID,
                category: .generalRules,
                timeTaken: Double(i + 1)
            )
        }
        
        let expectation = XCTestExpectation(description: "Record multiple")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.userProfile.totalQuestionsAnswered, 5)
            XCTAssertEqual(sut.userProfile.totalCorrectAnswers, 5)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Exam Result Recording Tests
    
    func testRecordExamResult() {
        let result = ExamResult(
            date: Date(),
            questionCount: 30,
            correctCount: 25,
            timeTakenSeconds: 1500,
            categoryBreakdown: [:],
            passed: true
        )
        
        sut.recordExamResult(result)
        
        let expectation = XCTestExpectation(description: "Record result")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.userProfile.examResults.count, 1)
            XCTAssertEqual(sut.userProfile.examResults.first?.passed, true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Exam Date Tests
    
    func testSetExamDate() {
        let date = Date().addingTimeInterval(86400 * 30)  // 30 days from now
        
        sut.setExamDate(date)
        
        let expectation = XCTestExpectation(description: "Set date")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.userProfile.examDate, date)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Persistence Tests
    
    func testProfilePersists_AfterRecreation() {
        sut.setExamDate(Date().addingTimeInterval(86400 * 14))
        
        let expectation = XCTestExpectation(description: "Persist")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Simulate app restart
            let newService = ProgressTrackingService()
            
            XCTAssertNotNil(newService.userProfile.examDate)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentRecording_NoDataLoss() {
        let group = DispatchGroup()
        let optionID = UUID()
        
        for i in 0..<10 {
            group.enter()
            DispatchQueue.global().async {
                self.sut.recordAnswer(
                    questionID: UUID(),
                    selectedOptionID: optionID,
                    correctOptionID: optionID,
                    category: .trafficSigns,
                    timeTaken: Double(i)
                )
                group.leave()
            }
        }
        
        group.wait()
        
        let expectation = XCTestExpectation(description: "Concurrent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.userProfile.totalQuestionsAnswered, 10, "Should not lose data with concurrent access")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}