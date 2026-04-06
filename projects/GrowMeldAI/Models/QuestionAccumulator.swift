final class QuestionAccumulator {
    var questions: [String: (question: Question, answers: [Answer])] = [:]
    
    func finalize() -> [Question] {
        return questions.mapValues { q, a in
            Question(/* ... answers: a ... */)
        }.values
    }
}