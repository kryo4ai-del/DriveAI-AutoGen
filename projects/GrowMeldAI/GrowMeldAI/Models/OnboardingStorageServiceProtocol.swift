// Features/Onboarding/Services/OnboardingStorageService.swift
import Foundation

protocol OnboardingStorageServiceProtocol: Sendable {
    func saveProfile(_ profile: UserProfile) async throws
    func loadProfile() async throws -> UserProfile?
    func completeOnboarding(profile: UserProfile) async throws
    func clearOnboarding() async throws
    func isOnboardingComplete() async -> Bool
}

actor OnboardingStorageService: OnboardingStorageServiceProtocol {
    private let userDefaults: UserDefaults
    
    private static let profileKey = "com.driveai.onboarding.profile"
    private static let completionKey = "com.driveai.onboarding.completed"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Async/Await Correct Implementation
    
    func saveProfile(_ profile: UserProfile) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)
        
        // UserDefaults is main-thread-safe
        await MainActor.run {
            self.userDefaults.set(data, forKey: Self.profileKey)
        }
    }
    
    func loadProfile() async throws -> UserProfile? {
        let data = await MainActor.run { () -> Data? in
            self.userDefaults.data(forKey: Self.profileKey)
        }
        
        guard let data = data else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(UserProfile.self, from: data)
    }
    
    func completeOnboarding(profile: UserProfile) async throws {
        // Save profile first (atomic operation)
        try await saveProfile(profile)
        
        // Mark as complete
        await MainActor.run {
            self.userDefaults.set(true, forKey: Self.completionKey)
        }
    }
    
    func clearOnboarding() async throws {
        await MainActor.run {
            self.userDefaults.removeObject(forKey: Self.profileKey)
            self.userDefaults.removeObject(forKey: Self.completionKey)
        }
    }
    
    func isOnboardingComplete() async -> Bool {
        await MainActor.run {
            self.userDefaults.bool(forKey: Self.completionKey)
        }
    }
}

// Mock for Testing
final class MockOnboardingStorageService: OnboardingStorageServiceProtocol {
    var shouldFail = false
    private(set) var savedProfile: UserProfile?
    private(set) var isCompleted = false
    
    func saveProfile(_ profile: UserProfile) async throws {
        if shouldFail {
            throw StorageError.saveFailed
        }
        savedProfile = profile
    }
    
    func loadProfile() async throws -> UserProfile? {
        if shouldFail {
            throw StorageError.loadFailed
        }
        return savedProfile
    }
    
    func completeOnboarding(profile: UserProfile) async throws {
        if shouldFail {
            throw StorageError.saveFailed
        }
        savedProfile = profile
        isCompleted = true
    }
    
    func clearOnboarding() async throws {
        savedProfile = nil
        isCompleted = false
    }
    
    func isOnboardingComplete() async -> Bool {
        return isCompleted
    }
}
