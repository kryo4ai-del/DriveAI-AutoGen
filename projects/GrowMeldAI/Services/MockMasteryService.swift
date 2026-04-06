import Foundation

class MockMasteryService: MasteryCalculationServiceProtocol {
    func calculateMastery(for categoryId: String, from quizHistory: [QuizAttempt]) -> MasteryRecord? {
        nil
    }

    func updateMastery(after quizCompletion: QuizSession) {}

    func fetchMasteryByCategory() -> [MasteryRecord] {
        [
            MasteryRecord(
                id: UUID(),
                categoryId: "traffic_signs",
                categoryName: "Verkehrsschilder",
                correctAnswers: 38,
                totalAnswers: 40,
                lastUpdated: Date()
            ),
            MasteryRecord(
                id: UUID(),
                categoryId: "right_of_way",
                categoryName: "Vorfahrtsregeln",
                correctAnswers: 28,
                totalAnswers: 35,
                lastUpdated: Date()
            ),
            MasteryRecord(
                id: UUID(),
                categoryId: "fines",
                categoryName: "Bußgelder",
                correctAnswers: 18,
                totalAnswers: 30,
                lastUpdated: Date()
            ),
        ]
    }

    func fetchOverallMastery() -> Double {
        84.0
    }
}