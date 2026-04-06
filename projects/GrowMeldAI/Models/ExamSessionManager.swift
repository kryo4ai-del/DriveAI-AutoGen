class ExamSessionManager {
    func loadExamQuestions() -> Result<[Question], ExamError> {
        guard let questions = repository.fetchRandomQuestions(count: 30) else {
            return .failure(.couldNotLoadQuestions)
        }
        return .success(questions)
    }
}
