import Foundation

class DataService: DataServiceProtocol {
    func loadQuestions(completion: @escaping ([Question]) -> Void) {
        // Simulating data fetching from DB
        let correctId1 = UUID()
        let correctId2 = UUID()
        let questions = [
            Question(
                id: UUID(),
                text: "Was ist hier erlaubt?",
                options: [
                    Answer(id: correctId1, text: "Parken erlaubt"),
                    Answer(id: UUID(), text: "Parken verboten")
                ],
                correctAnswerId: correctId1,
                explanation: "Parken ist hier erlaubt."
            ),
            Question(
                id: UUID(),
                text: "Welche Farbe hat ein Stoppschild?",
                options: [
                    Answer(id: correctId2, text: "Rot"),
                    Answer(id: UUID(), text: "Gelb")
                ],
                correctAnswerId: correctId2,
                explanation: "Stoppschilder sind rot."
            )
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(questions)
        }
    }
}
