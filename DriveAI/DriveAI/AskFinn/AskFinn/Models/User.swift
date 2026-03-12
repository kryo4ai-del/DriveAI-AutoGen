import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var examDate: Date
    var score: Int

    init(id: UUID = UUID(), examDate: Date, score: Int = 0) {
        self.id = id
        self.examDate = examDate
        self.score = score
    }

    mutating func updateScore(to newScore: Int) {
        score = newScore
    }

    /// Days remaining until the exam date. Returns 0 if the exam date has passed.
    var daysUntilExam: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0)
    }
}
