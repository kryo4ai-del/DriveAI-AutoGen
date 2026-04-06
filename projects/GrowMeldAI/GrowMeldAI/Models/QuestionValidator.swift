// Services/ValidationService.swift
struct QuestionValidator {
    static func validate(_ question: Question) -> ValidationResult {
        let errors: [ValidationError] = [
            !question.text.trimmingCharacters(in: .whitespaces).isEmpty ? nil : .emptyText,
            question.answers.count >= 2 ? nil : .tooFewAnswers,
            question.answers.count <= 6 ? nil : .tooManyAnswers,
            Set(question.answers.map { $0.id }).count == question.answers.count ? nil : .duplicateAnswerIDs,
            question.answers.allSatisfy { !$0.text.isEmpty } ? nil : .emptyAnswerText,
            question.correctAnswer != nil ? nil : .missingCorrectAnswer,
            !question.explanationDE.trimmingCharacters(in: .whitespaces).isEmpty ? nil : .emptyExplanation
        ].compactMap { $0 }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
