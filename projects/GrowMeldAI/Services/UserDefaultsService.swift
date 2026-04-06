// Services/UserDefaultsService.swift (UPDATED)
import Foundation

@MainActor
final class UserDefaultsService {
    private let defaults = UserDefaults.standard
    private lazy var encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private lazy var decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    private enum Keys {
        static let userProfile = "com.driveai.userProfile"
        static let examSessions = "com.driveai.examSessions"
        static let appTheme = "com.driveai.theme"
    }
    
    init() { }
    
    // MARK: - User Profile
    
    func loadUserProfile() -> UserProfile {
        guard let data = defaults.data(forKey: Keys.userProfile) else {
            return UserProfile()
        }
        
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            print("Failed to decode user profile: \(error)")
            return UserProfile()
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        do {
            let data = try encoder.encode(profile)
            defaults.set(data, forKey: Keys.userProfile)
        } catch {
            print("Failed to save user profile: \(error)")
        }
    }
    
    // MARK: - Exam Sessions
    
    func loadExamSessions() -> [ExamSession] {
        guard let data = defaults.data(forKey: Keys.examSessions) else {
            return []
        }
        
        do {
            return try decoder.decode([ExamSession].self, from: data)
        } catch {
            print("Failed to decode exam sessions: \(error)")
            return []
        }
    }
    
    func saveExamSession(_ session: ExamSession) {
        var sessions = loadExamSessions()
        sessions.append(session)
        
        do {
            let data = try encoder.encode(sessions)
            defaults.set(data, forKey: Keys.examSessions)
        } catch {
            print("Failed to save exam session: \(error)")
        }
    }
    
    // MARK: - Theme
    
    func getThemePreference() -> String {
        defaults.string(forKey: Keys.appTheme) ?? "system"
    }
    
    func setThemePreference(_ theme: String) {
        defaults.set(theme, forKey: Keys.appTheme)
    }
}