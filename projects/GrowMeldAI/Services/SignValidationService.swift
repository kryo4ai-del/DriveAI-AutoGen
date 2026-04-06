// Services/Learning/SignValidationService.swift
protocol SignValidationService {
    func validate(_ sign: RecognizedSign) -> ValidationResult
    func getCategoryForSign(_ sign: RecognizedSign) -> ExamCategory?
}
