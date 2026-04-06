struct RawQuestionDTO: Codable {
    func toValidated() throws -> Question {
        fatalError("Not implemented")
    }
}

struct Question: Codable {
}