// MARK: - Tests/Mocks.swift

final class MockExamService: ExamService {
    func loadExamQuestions(count: Int) async throws -> [Question] {
        (0..<count).map { index in
            Question(
                id: "exam_q\(index)",
                text: "Exam Question \(index + 1)",
                categoryId: ["signs", "rules", "fines"].randomElement() ?? "signs",
                options: [
                    QuestionOption(id: "a", text: "Option A", isCorrect: index % 2 == 0),
                    QuestionOption(id: "b", text: "Option B", isCorrect: index % 2 != 0),
                    QuestionOption(id: "c", text: "Option C", isCorrect: false),
                    QuestionOption(id: "d", text: "Option D", isCorrect: false),
                ],
                explanation: "Explanation for question \(index + 1)",
                imageUrl: nil
            )
        }
    }
    
    func validateAnswer(_ answer: String, for question: Question) -> Bool {
        question.options.first(where: { $0.id == answer })?.isCorrect ?? false
    }
}