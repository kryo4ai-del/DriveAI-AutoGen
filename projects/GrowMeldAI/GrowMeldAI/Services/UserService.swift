// Core/Services/UserService.swift
import Foundation

protocol UserService: AnyObject, Sendable {
    enum UserError: LocalizedError {
        case userNotFound
        case saveFailed(String)
        case invalidInput(String)
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Benutzer nicht gefunden"
            case .saveFailed(let detail):
                return "Fehler beim Speichern: \(detail)"
            case .invalidInput(let detail):
                return "Ungültige Eingabe: \(detail)"
            }
        }
    }
    
    func getCurrentUser() async throws -> User
    func createUser(name: String, examDate: Date) async throws -> User
    func updateExamDate(_ date: Date) async throws
    func completeOnboarding() async throws
}