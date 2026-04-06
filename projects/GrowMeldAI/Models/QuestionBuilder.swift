class QuestionBuilder {
    private var questionsMap: [String: Question] = [:]
    
    mutating func addAnswer(_ answer: Answer, toQuestionId id: String) {
        // Easier to manage with mutable reference
    }
    
    func build() -> [Question] {
        return Array(questionsMap.values)
    }
}