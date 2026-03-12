import Foundation
import Combine

// Mock LocalDataService for testing
class MockLocalDataService: LocalDataServiceProtocol {
    var shouldThrowError = false

    func fetchQuestions() throws -> [Question] {
        if shouldThrowError {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        let answerId = UUID()
        return [
            Question(
                id: UUID(),
                text: "Was ist ein Fußgängerüberweg?",
                options: [
                    Answer(id: UUID(), text: "Stoppschild"),
                    Answer(id: answerId, text: "Zebra"),
                    Answer(id: UUID(), text: "Ampel")
                ],
                correctAnswerId: answerId,
                explanation: "Ein Fußgängerüberweg wird auch Zebrastreifen genannt."
            )
        ]
    }
}
