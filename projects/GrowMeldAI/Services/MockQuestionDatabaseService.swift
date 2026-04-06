import Foundation

protocol QuestionDatabaseServiceProtocol {
    func loadQuestions() async throws -> [Question]
    func saveQuestions(_ questions: [Question]) async throws
    func getQuestionCount() async throws -> Int
    func getQuestion(byId id: String) async throws -> Question?
    func resetDatabase() async throws
}

struct Question: Identifiable, Codable {
    let id: String
    let text: String
    let answers: [String]
    let correctAnswerIndex: Int
    let category: String
    let explanation: String
    let imageName: String?
    let difficulty: Difficulty

    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
    }
}

final class QuestionDatabaseService: QuestionDatabaseServiceProtocol {
    private var questions: [Question] = []

    func loadQuestions() async throws -> [Question] {
        return questions
    }

    func saveQuestions(_ questions: [Question]) async throws {
        self.questions = questions
    }

    func getQuestionCount() async throws -> Int {
        return questions.count
    }

    func getQuestion(byId id: String) async throws -> Question? {
        return questions.first { $0.id == id }
    }

    func resetDatabase() async throws {
        questions = []
    }

    static func mock() -> QuestionDatabaseServiceProtocol {
        let mockQuestions = [
            Question(
                id: "1",
                text: "Was bedeutet dieses Verkehrszeichen?",
                answers: ["Vorfahrt gewähren", "Halt! Vorfahrt gewähren", "Verbot für Fahrzeuge"],
                correctAnswerIndex: 1,
                category: "Verkehrszeichen",
                explanation: "Das Schild bedeutet 'Halt! Vorfahrt gewähren'. Sie müssen an der Haltelinie anhalten und anderen Verkehrsteilnehmern Vorfahrt gewähren.",
                imageName: "verkehrszeichen-halt",
                difficulty: .easy
            ),
            Question(
                id: "2",
                text: "Wie verhalten Sie sich bei diesem Verkehrszeichen?",
                answers: ["Weiterfahren", "Anhalten und Vorfahrt gewähren", "Langsamer fahren"],
                correctAnswerIndex: 1,
                category: "Verkehrszeichen",
                explanation: "Das Dreieck mit rotem Rand bedeutet 'Vorfahrt gewähren'. Sie müssen Ihre Geschwindigkeit anpassen und anderen Vorfahrt gewähren.",
                imageName: "verkehrszeichen-vorfahrt-gewähren",
                difficulty: .medium
            )
        ]
        return MockQuestionDatabaseService(mockQuestions: mockQuestions)
    }
}

private final class MockQuestionDatabaseService: QuestionDatabaseServiceProtocol {
    private var mockQuestions: [Question]

    init(mockQuestions: [Question]) {
        self.mockQuestions = mockQuestions
    }

    func loadQuestions() async throws -> [Question] {
        return mockQuestions
    }

    func saveQuestions(_ questions: [Question]) async throws {
        mockQuestions = questions
    }

    func getQuestionCount() async throws -> Int {
        return mockQuestions.count
    }

    func getQuestion(byId id: String) async throws -> Question? {
        return mockQuestions.first { $0.id == id }
    }

    func resetDatabase() async throws {
        mockQuestions = []
    }
}