protocol ExamServiceProtocol {
    func evaluateExam(answers: [AnswerRecord]) -> ExamResult
    func isPassingScore(_ score: Int) -> Bool  // ← GDPR decision point
}