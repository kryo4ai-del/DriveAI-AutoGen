import Foundation

protocol ExamService {
    func loadExamQuestions(count: Int) async throws -> [ExamQuestion]
    func validateAnswer(_ answer: String, for question: ExamQuestion) -> Bool
}

struct ExamQuestion {
    let id: String
    let text: String
    let categoryId: String
    let options: [ExamQuestionOption]
    let explanation: String
    let imageUrl: String?
}

struct ExamQuestionOption {
    let id: String
    let text: String
    let isCorrect: Bool
}

final class MockExamService: ExamService {
    func loadExamQuestions(count: Int) async throws -> [ExamQuestion] {
        (0..<count).map { index in
            ExamQuestion(
                id: "exam_q\(index)",
                text: "Exam Question \(index + 1)",
                categoryId: ["signs", "rules", "fines"].randomElement() ?? "signs",
                options: [
                    ExamQuestionOption(id: "a", text: "Option A", isCorrect: index % 2 == 0),
                    ExamQuestionOption(id: "b", text: "Option B", isCorrect: index % 2 != 0),
                    ExamQuestionOption(id: "c", text: "Option C", isCorrect: false),
                    ExamQuestionOption(id: "d", text: "Option D", isCorrect: false),
                ],
                explanation: "Explanation for question \(index + 1)",
                imageUrl: nil
            )
        }
    }

    func validateAnswer(_ answer: String, for question: ExamQuestion) -> Bool {
        question.options.first(where: { $0.id == answer })?.isCorrect ?? false
    }
}