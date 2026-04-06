// Services/UserProfileService.swift
import Foundation

protocol UserProfileService: ObservableObject {
    var profile: UserProfile { get set }
    func setExamDate(_ date: Date)
    func addExamResult(_ result: ExamResult)
    func saveProfile()
    func loadProfile()
}

@MainActor
final class UserProfileServiceImpl: UserProfileService {
    @Published var profile: UserProfile = UserProfile()
    
    private let userDefaultsKey = "driveai_profile"
    
    init() {
        loadProfile()
    }
    
    func setExamDate(_ date: Date) {
        profile.examDate = date
        saveProfile()
    }
    
    func addExamResult(_ result: ExamResult) {
        profile.examResults.append(result)
        profile.totalScore = result.score
        updateStreak(result.isPassed)
        saveProfile()
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        }
    }
    
    private func updateStreak(_ isCorrect: Bool) {
        if isCorrect {
            profile.currentStreak += 1
            if profile.currentStreak > profile.longestStreak {
                profile.longestStreak = profile.currentStreak
            }
        } else {
            profile.currentStreak = 0
        }
    }
}