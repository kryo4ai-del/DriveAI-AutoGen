import XCTest
import Foundation
@testable import DriveAI

final class QuizTests: XCTestCase {
    
    // MARK: - Referential Integrity
    
    func testQuizValidatesAllQuestionsHaveMatchingQuizId() throws {
        let quizId = UUID()
        
        // ✅ Valid: All questions match parent quiz
        let validQuiz = Quiz(
            id: quizId,
            title: "Traffic Signs",
            category: .carB,
            difficulty: .beginner,
            topicArea: .trafficSigns,
            questionCount: 2,
            estimatedDurationSeconds: 600,
            description: "Test",
            questions: [
                Question(id: UUID(), quizId: quizId, text: "Q1?", 
                        options: ["A", "B", "C", "D"], correctAnswerIndex: 0, 
                        difficulty: .beginner, explanation: "E1"),
                Question(id: UUID(), quizId: quizId, text: "Q2?", 
                        options: ["A", "B", "C", "D"], correctAnswerIndex: 1, 
                        difficulty: .beginner, explanation: "E2"),
            ]
        )
        
        XCTAssertNoThrow(try validQuiz.validate())
        
        // ❌ Invalid: Question has mismatched quizId
        let invalidQuestion = Question(
            id: UUID(), 
            quizId: UUID(),  // Wrong!
            text: "Q3?",
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            difficulty: .beginner,
            explanation: "E3"
        )
        
        let invalidQuiz = Quiz(
            id: quizId,
            title: "Traffic Signs",
            category: .carB,
            difficulty: .beginner,
            topicArea: .trafficSigns,
            questionCount: 1,
            estimatedDurationSeconds: 600,
            description: "Test",
            questions: [invalidQuestion]
        )
        
        XCTAssertThrowsError(try invalidQuiz.validate()) { error in
            XCTAssert(error is QuizError)
        }
    }
    
    func testQuizRequiresAtLeastOneQuestion() throws {
        let emptyQuiz = Quiz(
            id: UUID(),
            title: "Empty",
            category: .carB,
            difficulty: .beginner,
            topicArea: .trafficSigns,
            questionCount: 0,
            estimatedDurationSeconds: 600,
            description: "Test",
            questions: []  // ❌ Invalid
        )
        
        XCTAssertThrowsError(try emptyQuiz.validate()) { error in
            guard case QuizError.noQuestions = error else {
                XCTFail("Expected noQuestions error")
                return
            }
        }
    }
    
    // MARK: - Data Integrity
    
    func testQuizQuestionCountMatchesActualQuestions() throws {
        let quiz = createSampleQuiz(questionCount: 5)
        
        // questionCount field should match actual questions array
        XCTAssertEqual(quiz.questionCount, quiz.questions.count,
                      "questionCount mismatch: field=\(quiz.questionCount), actual=\(quiz.questions.count)")
    }
    
    func testQuizEstimatedDurationIsPositive() throws {
        let quiz = createSampleQuiz()
        XCTAssertGreater(quiz.estimatedDurationSeconds, 0)
    }
    
    func testQuizHashingUsesId() {
        let id = UUID()
        let quiz1 = createSampleQuiz(id: id)
        let quiz2 = createSampleQuiz(id: id)
        
        XCTAssertEqual(quiz1.hashValue, quiz2.hashValue)
    }
    
    func testQuizEquatabilityUsesId() {
        let id = UUID()
        let quiz1 = createSampleQuiz(id: id)
        let quiz2 = createSampleQuiz(id: id, title: "Different Title")
        
        XCTAssertEqual(quiz1, quiz2, "Quizzes with same ID should be equal")
    }
    
    // MARK: - Helpers
    
    private func createSampleQuiz(
        id: UUID = UUID(),
        questionCount: Int = 3,
        title: String = "Test Quiz"
    ) -> Quiz {
        let quizId = id
        return Quiz(
            id: quizId,
            title: title,
            category: .carB,
            difficulty: .intermediate,
            topicArea: .rules,
            questionCount: questionCount,
            estimatedDurationSeconds: 900,
            description: "Test description",
            questions: (0..<questionCount).map { index in
                Question(
                    id: UUID(),
                    quizId: quizId,
                    text: "Question \(index + 1)?",
                    options: ["A", "B", "C", "D"],
                    correctAnswerIndex: index % 4,
                    difficulty: .intermediate,
                    explanation: "Answer explanation"
                )
            }
        )
    }
}