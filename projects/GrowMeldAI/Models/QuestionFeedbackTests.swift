import XCTest
@testable import DriveAI

final class QuestionFeedbackTests: XCTestCase {
    
    let metadata = DrivingTheoryMetadata(
        stvoSection: "StVO §3 Abs. 1",
        trafficSignNumber: "Zeichen 205",
        legalExplanation: "Außerorts beträgt die Höchstgeschwindigkeit 100 km/h.",
        commonMistakes: ["120 km/h ist nur auf Autobahnen erlaubt"],
        relatedTopics: ["Geschwindigkeit", "Verkehrsschilder"],
        severity: .safety,
        mnemonicHint: "1-0-0 außerorts"
    )
    
    // MARK: - Correct Answer Feedback
    
    func testCorrectAnswerFeedback() {
        let feedback = QuestionFeedback(
            isCorrect: true,
            explanation: "100 km/h ist die korrekte Höchstgeschwindigkeit außerorts.",
            domainMetadata: metadata,
            selectedAnswer: Answer(id: "a1", text: "100 km/h"),
            correctAnswer: Answer(id: "a1", text: "100 km/h")
        )
        
        XCTAssertTrue(feedback.isCorrect)
        XCTAssertEqual(feedback.performanceMessage, "Richtig!")
        XCTAssertEqual(feedback.severity, .safety)
        XCTAssertFalse(feedback.shouldShowHint)  // No hint on correct answer
    }
    
    // MARK: - Incorrect Answer Feedback
    
    func testIncorrectAnswerFeedbackWithHint() {
        let feedback = QuestionFeedback(
            isCorrect: false,
            explanation: "120 km/h ist nur auf Autobahnen erlaubt.",
            domainMetadata: metadata,
            selectedAnswer: Answer(id: "a2", text: "120 km/h"),
            correctAnswer: Answer(id: "a1", text: "100 km/h")
        )
        
        XCTAssertFalse(feedback.isCorrect)
        XCTAssertEqual(feedback.performanceMessage, "Leider falsch")
        XCTAssertTrue(feedback.shouldShowHint)  // Show mnemonic on wrong
        XCTAssertEqual(feedback.domainMetadata.mnemonicHint, "1-0-0 außerorts")
    }
    
    // MARK: - Domain Context Exposure
    
    func testFeedbackExposesStovoSection() {
        let feedback = QuestionFeedback(
            isCorrect: true,
            explanation: "Correct",
            domainMetadata: metadata,
            selectedAnswer: Answer(id: "a1", text: "100 km/h"),
            correctAnswer: Answer(id: "a1", text: "100 km/h")
        )
        
        XCTAssertEqual(feedback.domainMetadata.stvoSection, "StVO §3 Abs. 1")
        XCTAssertEqual(feedback.domainMetadata.trafficSignNumber, "Zeichen 205")
    }
    
    // MARK: - Equatable
    
    func testFeedbackEquality() {
        let feedback1 = QuestionFeedback(
            isCorrect: true,
            explanation: "Explanation",
            domainMetadata: metadata,
            selectedAnswer: Answer(id: "a1", text: "Answer"),
            correctAnswer: Answer(id: "a1", text: "Answer")
        )
        
        let feedback2 = QuestionFeedback(
            isCorrect: true,
            explanation: "Different explanation",
            domainMetadata: metadata,
            selectedAnswer: Answer(id: "a1", text: "Answer"),
            correctAnswer: Answer(id: "a1", text: "Answer")
        )
        
        XCTAssertEqual(feedback1, feedback2)  // Same is/correct & answers
    }
}