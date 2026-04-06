// Core/Services/DataValidationService.swift
@MainActor
protocol DataValidationService {
    func validateQuestion(_ question: Question) throws
    func validateUserProfile(_ profile: UserProfile) throws
    func validateExamResult(_ result: ExamResult) throws
}

// Moves validation logic out of service layer
// Makes testing easier
// Provides single place to enforce data rules