// Sources/Domains/UserProfile/Services/UserProfileServiceMock.swift
import Foundation

@MainActor
final class UserProfileServiceMock: UserProfileServiceProtocol {
    @Published var mockProfile: UserProfile = .empty()
    
    var shouldFail = false
    var failureError: UserProfileError = .invalidData
    
    // Simulate real queue behavior
    nonisolated private let queue: DispatchQueue
    
    init() {
        self.queue = DispatchQueue(
            label: "com.driveai.profile.mock",
            attributes: .concurrent
        )
    }
    
    func loadProfile() async throws -> UserProfile {
        if shouldFail {
            throw failureError
        }
        
        // Simulate I/O delay
        try await Task.sleep(nanoseconds: 100_000_000)
        return mockProfile
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        if shouldFail {
            throw failureError
        }
        
        return try await queue.async(flags: .barrier) { [weak self] in
            guard let self else { throw UserProfileError.invalidData }
            
            try await MainActor.run {
                self.mockProfile = profile
            }
        }
    }
    
    func updateProgress(
        categoryId: String,
        categoryName: String,
        correct: Bool
    ) async throws -> UserProfile {
        if shouldFail {
            throw failureError
        }
        
        return try await queue.async(flags: .barrier) { [weak self] in
            guard let self else { throw UserProfileError.invalidData }
            
            var profile = self.mockProfile
            var progress = profile.categoryProgress[categoryId]
                ?? CategoryProgress(categoryId: categoryId, categoryName: categoryName)
            
            progress.questionsAttempted += 1
            if correct {
                progress.correctAnswers = min(progress.correctAnswers + 1, progress.questionsAttempted)
                profile.currentStreak += 1
            } else {
                profile.currentStreak = 0
            }
            progress.lastAttemptDate = .now
            
            profile.categoryProgress[categoryId] = progress
            profile.totalScore = profile.categoryProgress.values.reduce(0) { $0 + $1.correctAnswers }
            profile.attemptCount += 1
            
            return profile
        }
    }
    
    func recordExamAttempt(_ attempt: ExamAttempt) async throws -> UserProfile {
        if shouldFail {
            throw failureError
        }
        
        return try await queue.async(flags: .barrier) { [weak self] in
            guard let self else { throw UserProfileError.invalidData }
            
            var profile = self.mockProfile
            profile.examAttempts.append(attempt)
            
            if attempt.passed {
                profile.currentStreak += 1
            } else {
                profile.currentStreak = 0
            }
            
            return profile
        }
    }
    
    func updateExamDate(_ date: Date) async throws -> UserProfile {
        if shouldFail {
            throw failureError
        }
        
        return try await queue.async(flags: .barrier) { [weak self] in
            guard let self else { throw UserProfileError.invalidData }
            
            var profile = self.mockProfile
            profile.examDate = date
            
            return profile
        }
    }
    
    func deleteProfile() async throws {
        if shouldFail {
            throw failureError
        }
        
        return try await queue.async(flags: .barrier) { [weak self] in
            guard let self else { throw UserProfileError.invalidData }
            
            await MainActor.run {
                self.mockProfile = .empty()
            }
        }
    }
}