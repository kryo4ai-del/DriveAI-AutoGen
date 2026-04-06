import Foundation

struct TestQuestions {
    // MARK: - Valid Questions
    
    static let validQuestion = Question(
        id: UUID(uuidString: "12345678-1234-5678-1234-567812345678")!,
        category: .trafficSigns,
        text: "Was bedeutet das Stoppschild?",
        imageURL: nil,
        options: ["Anhalten", "Vorsicht", "Parkverbot"],
        correctAnswerIndex: 0,
        explanation: "Das Stoppschild bedeutet, dass du anhalten musst.",
        difficulty: .medium,
        topicTags: ["Grundlagen"]
    )
    
    static let easyQuestion = Question(
        id: UUID(),
        category: .general,
        text: "Wie viele Räder hat ein Auto?",
        imageURL: nil,
        options: ["3", "4", "5"],
        correctAnswerIndex: 1,
        explanation: "Ein normales Auto hat 4 Räder.",
        difficulty: .easy,
        topicTags: ["Anfänger"]
    )
    
    static let hardQuestion = Question(
        id: UUID(),
        category: .rightOfWay,
        text: "Wer hat Vorfahrt an dieser Kreuzung?",
        imageURL: "traffic_intersection_01",
        options: ["Auto A", "Auto B", "Beide gleich"],
        correctAnswerIndex: 1,
        explanation: "Das Fahrzeug von rechts hat Vorfahrt.",
        difficulty: .hard,
        topicTags: ["Vorfahrtsregeln"]
    )
    
    static let questionsWithInvalidIndex = Question(
        id: UUID(),
        category: .trafficSigns,
        text: "Invalid question",
        imageURL: nil,
        options: ["A", "B"],
        correctAnswerIndex: 999,  // ❌ Out of bounds
        explanation: "This should fail validation",
        difficulty: .easy,
        topicTags: []
    )
    
    static let questionWithEmptyText = Question(
        id: UUID(),
        category: .fines,
        text: "",  // ❌ Empty
        imageURL: nil,
        options: ["Option"],
        correctAnswerIndex: 0,
        explanation: "Empty text",
        difficulty: .easy,
        topicTags: []
    )
    
    // MARK: - Mock Collections
    
    static let sampleQuestionSet: [Question] = [
        validQuestion,
        easyQuestion,
        hardQuestion
    ]
    
    static let largeQuestionSet: [Question] = {
        (0..<100).map { index in
            Question(
                id: UUID(),
                category: QuestionCategory.allCases[index % 5],
                text: "Sample question \(index)",
                imageURL: nil,
                options: ["A", "B", "C"],
                correctAnswerIndex: index % 3,
                explanation: "Explanation for question \(index)",
                difficulty: [.easy, .medium, .hard][index % 3],
                topicTags: ["tag\(index % 5)"]
            )
        }
    }()
}

// MARK: - Test Data Builders

extension Question {
    static func builder() -> QuestionBuilder {
        QuestionBuilder()
    }
}

class QuestionBuilder {
    private var id = UUID()
    private var category = QuestionCategory.general
    private var text = "Test question"
    private var imageURL: String?
    private var options = ["A", "B", "C"]
    private var correctAnswerIndex = 0
    private var explanation = "Test explanation"
    private var difficulty = Difficulty.medium
    private var topicTags: [String] = []
    
    func withCategory(_ category: QuestionCategory) -> Self {
        self.category = category
        return self
    }
    
    func withText(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    func withOptions(_ options: [String]) -> Self {
        self.options = options
        return self
    }
    
    func withCorrectAnswer(_ index: Int) -> Self {
        self.correctAnswerIndex = index
        return self
    }
    
    func withDifficulty(_ difficulty: Difficulty) -> Self {
        self.difficulty = difficulty
        return self
    }
    
    func build() -> Question {
        Question(
            id: id,
            category: category,
            text: text,
            imageURL: imageURL,
            options: options,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            difficulty: difficulty,
            topicTags: topicTags
        )
    }
}