struct RawQuestionDTO: Codable {
    func toValidated() throws -> Question { ... }  // Repeated in multiple places
}