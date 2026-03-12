import Foundation

class QuizDataService {
    func loadMockQuestions() throws -> [Question] {
        let haltId = UUID()
        let anhaltenId = UUID()
        return [
            Question(
                id: UUID(),
                text: "Was bedeutet ein rotes Ampellicht?",
                options: [
                    Answer(id: UUID(), text: "Fahren"),
                    Answer(id: haltId, text: "Halt"),
                    Answer(id: UUID(), text: "Vorfahrt gewähren")
                ],
                correctAnswerId: haltId,
                explanation: "Ein rotes Ampellicht bedeutet Halt."
            ),
            Question(
                id: UUID(),
                text: "Was sollten Sie an einem Stoppschild tun?",
                options: [
                    Answer(id: UUID(), text: "Beschleunigen"),
                    Answer(id: anhaltenId, text: "Vor voll anhalten"),
                    Answer(id: UUID(), text: "Vorfahr erwarten")
                ],
                correctAnswerId: anhaltenId,
                explanation: "An einem Stoppschild müssen Sie vollständig anhalten."
            ),
        ]
    }
}
