class QuestionBankService {
    enum ValidationError: LocalizedError {
        case missingCorrectAnswer
        case emptyOptions
        case duplicateQuestionID
        case missingExplanation
        case invalidImageReference
    }
    
    func loadAndValidateQuestions(region: Region) throws -> [Question] {
        let questions = try loadQuestionsFromDB(region: region)
        try validateQuestionBank(questions)
        return questions
    }
    
    private func validateQuestionBank(_ questions: [Question]) throws {
        var seenIDs = Set<UUID>()
        
        for question in questions {
            // Check for duplicates
            guard !seenIDs.contains(question.id) else {
                throw ValidationError.duplicateQuestionID
            }
            seenIDs.insert(question.id)
            
            // Check correctness
            guard 0..<question.options.count ~= question.correctAnswer else {
                throw ValidationError.missingCorrectAnswer
            }
            
            guard !question.options.isEmpty else {
                throw ValidationError.emptyOptions
            }
            
            // Check explanation exists (best practice for learning)
            guard !question.explanation.isEmptyOrNil else {
                throw ValidationError.missingExplanation
            }
        }
    }
}