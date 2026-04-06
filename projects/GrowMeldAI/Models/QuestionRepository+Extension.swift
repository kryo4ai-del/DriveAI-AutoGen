// ✅ CORRECT: Ensure uniqueness
extension QuestionRepository {
    func randomUniqueQuestionIDs(count: Int) throws -> [String] {
        let all = try loadQuestions()
        guard all.count >= count else {
            throw DataError.insufficientQuestions(available: all.count, required: count)
        }
        return all.shuffled().prefix(count).map(\.id).map(String.init)
    }
}