class LocalDataService {
    private var questionCache: [Question]?
    
    func loadQuestions() -> [Question] {
        if let cachedQuestions = questionCache {
            return cachedQuestions
        } else {
            let questions = fetchQuestions()
            questionCache = questions
            return questions
        }
    }
}