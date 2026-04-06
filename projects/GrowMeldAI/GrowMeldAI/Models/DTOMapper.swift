// Services/Data/DTOMappers.swift — SINGLE PLACE FOR ALL TRANSFORMS
enum DTOMapper {
    
    static func mapQuestion(_ dto: RawQuestionDTO) throws -> Question {
        let answers = try dto.answers.map(mapAnswer)
        return try Question(
            id: UUID(uuidString: dto.id ?? UUID().uuidString) ?? UUID(),
            categoryID: UUID(uuidString: dto.categoryID) ?? UUID(),
            text: dto.text,
            imageURL: dto.imageURL.flatMap(URL.init(string:)),
            answers: answers,
            correctAnswerID: UUID(uuidString: dto.correctAnswerID) ?? UUID(),
            explanation: dto.explanation,
            difficulty: ExamDifficulty(rawValue: dto.difficulty ?? "medium") ?? .medium
        )
    }
    
    static func mapAnswer(_ dto: RawAnswerDTO) throws -> Answer {
        try Answer(
            id: UUID(uuidString: dto.id ?? UUID().uuidString) ?? UUID(),
            text: dto.text,
            isCorrect: dto.isCorrect
        )
    }
    
    static func mapCategory(_ dto: RawCategoryDTO) throws -> Category {
        try Category(
            id: UUID(uuidString: dto.id ?? UUID().uuidString) ?? UUID(),
            name: dto.name,
            description: dto.description,
            icon: dto.icon,
            order: dto.order ?? 0
        )
    }
}

// Usage in JSONDataLoader:
func loadQuestions() async throws -> [Question] {
    // ... load raw JSON ...
    let rawQuestions = try decoder.decode([RawQuestionDTO].self, from: data)
    
    // Transform with error handling
    var valid: [Question] = []
    var skipped: [String] = []
    
    for (index, raw) in rawQuestions.enumerated() {
        do {
            valid.append(try DTOMapper.mapQuestion(raw))
        } catch {
            skipped.append("Question \(index): \(error.localizedDescription)")
        }
    }
    
    if !skipped.isEmpty {
        LoggingService.shared.log(
            level: .warning,
            message: "Skipped \(skipped.count) invalid questions"
        )
    }
    
    return valid
}