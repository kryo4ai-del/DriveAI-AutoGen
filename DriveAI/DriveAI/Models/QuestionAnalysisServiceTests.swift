import XCTest

class QuestionAnalysisServiceTests: XCTestCase {
    var service: QuestionAnalysisService!
    
    override func setUp() {
        super.setUp()
        service = QuestionAnalysisService()
    }
    
    func testAnalyzeAnswer_Correct() {
        let question = Question(id: UUID(), text: "What is the speed limit?", correctAnswer: "50 km/h", options: ["30 km/h", "50 km/h", "70 km/h"])
        let userAnswer = UserAnswer(question: question, selectedOption: "50 km/h")
        
        let result = service.analyzeAnswer(userAnswer)
        
        XCTAssertTrue(result.correct)
        XCTAssertEqual(result.feedback, "Richtig!")
    }

    func testAnalyzeAnswer_Incorrect() {
        let question = Question(id: UUID(), text: "What is the speed limit?", correctAnswer: "50 km/h", options: ["30 km/h", "50 km/h", "70 km/h"])
        let userAnswer = UserAnswer(question: question, selectedOption: "30 km/h")
        
        let result = service.analyzeAnswer(userAnswer)
        
        XCTAssertFalse(result.correct)
        XCTAssertEqual(result.feedback, "Falsch! Die richtige Antwort war 50 km/h.")
    }
}