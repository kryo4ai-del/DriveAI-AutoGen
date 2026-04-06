import Foundation
import Combine

@MainActor
class ExamPrepViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var questions: [ExamQuestion] = []
    @Published var userAnswers: [String: Int] = [:]
    @Published var hasPassed: Bool = false

    func resetExam() {
        score = 0
        questions = []
        userAnswers = [:]
        hasPassed = false
    }
}

struct ExamQuestion: Identifiable {
    let id: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
}
