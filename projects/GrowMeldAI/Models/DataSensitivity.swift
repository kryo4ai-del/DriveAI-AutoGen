import Foundation
import CryptoKit

// MARK: - Privacy Data Classification
enum DataSensitivity: String, Codable, CaseIterable {
    case essential = "Essential"      // Required for core functionality
    case analytics = "Analytics"      // Improves app experience
    case optional = "Optional"        // Enhances personalization
}

// MARK: - Data Collection Purpose
enum DataPurpose: String, Codable, CaseIterable {
    case examProgress = "ExamProgress"    // Track learning progress
    case userProfile = "UserProfile"      // Personal settings
    case crashReporting = "CrashReporting" // App stability
    case analytics = "Analytics"          // Usage statistics
}

// MARK: - Privacy Data Model
struct PrivacyData: Identifiable, Codable {
    let id = UUID()
    let sensitivity: DataSensitivity
    let purpose: DataPurpose
    let isEnabled: Bool
    let retentionDays: Int
    let lastUpdated: Date

    init(sensitivity: DataSensitivity, purpose: DataPurpose, isEnabled: Bool = true, retentionDays: Int = 365) {
        self.sensitivity = sensitivity
        self.purpose = purpose
        self.isEnabled = isEnabled
        self.retentionDays = retentionDays
        self.lastUpdated = Date()
    }
}

// MARK: - Privacy Consent Manager