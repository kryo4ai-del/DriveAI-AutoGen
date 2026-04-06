extension Question {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let answers = try container.decode([Answer].self, forKey: .answers)
        guard !answers.isEmpty else {
            throw DomainError.invalidData(reason: "Decoded question has no answers")
        }
        
        let index = try container.decode(Int.self, forKey: .correctAnswerIndex)
        guard index >= 0 && index < answers.count else {
            throw DomainError.invalidData(reason: "Correct answer index out of bounds")
        }
        
        self.id = try container.decode(String.self, forKey: .id)
        self.answers = answers
        self.correctAnswerIndex = index
        // ... rest of properties
    }
}