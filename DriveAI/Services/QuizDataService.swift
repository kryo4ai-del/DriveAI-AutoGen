import Foundation

class QuizDataService {
    func loadMockQuestions() throws -> [Question] {
        return [
            Question(id: UUID(), text: "Was bedeutet ein rotes Ampellicht?", correctAnswer: "Halt", choices: ["Fahren", "Halt", "Vorfahrt gewähren"]),
            Question(id: UUID(), text: "Was sollten Sie an einem Stoppschild tun?", correctAnswer: "Vor voll anhalten", choices: ["Beschleunigen", "Vor voll anhalten", "Vorfahr erwarten"]),
        ]
    }
}