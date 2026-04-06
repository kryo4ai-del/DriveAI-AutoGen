// App/Persistence/PersistenceService.swift
import Foundation
import os.log

// App/AppState.swift
import Foundation
import Combine
import os.log

@MainActor

// MARK: - Data Models

struct OverallStats: Equatable {
    let totalAnswered: Int
    let accuracy: Double
    let streak: Int
    
    var accuracyPercentage: Int { Int(accuracy * 100) }
}

struct UserSettings: Codable, Equatable {
    var isDarkMode: Bool = true
    var soundEnabled: Bool = true
    var language: String = "de"
    
    static var `default`: UserSettings {
        UserSettings()
    }
}