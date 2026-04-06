// QuestionDatabaseService+Mock.swift
import Foundation

extension QuestionDatabaseService {
    /// Mock implementation for testing and previews
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
        mockQuestions
    }

    func saveQuestions(_ questions: [Question]) async throws {
        mockQuestions = questions
    }

    func getQuestionCount() async throws -> Int {
        mockQuestions.count
    }

    func getQuestion(byId id: String) async throws -> Question? {
        mockQuestions.first { $0.id == id }
    }

    func resetDatabase() async throws {
        mockQuestions = []
    }
}