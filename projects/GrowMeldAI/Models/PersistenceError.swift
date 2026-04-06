// App/Persistence/PersistenceService.swift
import Foundation
import os.log

// App/AppState.swift
import Foundation
import Combine
import os.log

@MainActor

// MARK: - Data Models

// Struct OverallStats declared in Models/PerformanceMetric.swift

struct UserSettings: Codable, Equatable {
    var isDarkMode: Bool = true
    var soundEnabled: Bool = true
    var language: String = "de"
    
    static var `default`: UserSettings {
        UserSettings()
    }
}