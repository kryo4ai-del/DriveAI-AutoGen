// Sources/Domains/UserProfile/Services/UserProfileService.swift
import Foundation

protocol UserProfileServiceProtocol: Sendable {
    func loadProfile() async throws -> UserProfile
    func saveProfile(_ profile: UserProfile) async throws
    func updateProgress(
        categoryId: String,
        categoryName: String,
        correct: Bool
    ) async throws -> UserProfile
    func recordExamAttempt(_ attempt: ExamAttempt) async throws -> UserProfile
    func updateExamDate(_ date: Date) async throws -> UserProfile
    func deleteProfile() async throws
}

@MainActor
class UserProfileService: UserProfileServiceProtocol {
    func loadProfile() async throws -> UserProfile {
        fatalError("Not implemented")
    }

    func saveProfile(_ profile: UserProfile) async throws {
        fatalError("Not implemented")
    }

    func updateProgress(
        categoryId: String,
        categoryName: String,
        correct: Bool
    ) async throws -> UserProfile {
        fatalError("Not implemented")
    }

    func recordExamAttempt(_ attempt: ExamAttempt) async throws -> UserProfile {
        fatalError("Not implemented")
    }

    func updateExamDate(_ date: Date) async throws -> UserProfile {
        fatalError("Not implemented")
    }

    func deleteProfile() async throws {
        fatalError("Not implemented")
    }
}