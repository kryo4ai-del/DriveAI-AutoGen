enum DataAvailability {
    case online(questionCount: Int)
    case offline(cachedQuestionCount: Int)
    case unavailable(reason: String)
}
