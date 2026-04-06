// Services/Learning/SignValidationService.swift

import Foundation

protocol SignValidationServiceProtocol {
    func validate(_ sign: RecognizedSign) async -> ValidationResult
    func getCategoryForSign(_ sign: RecognizedSign) async -> ExamCategory?
}

@MainActor