import Foundation

// MARK: - Privacy Data Classification
enum DataSensitivity: String, Codable, CaseIterable {
    case essential = "Essential"
    case analytics = "Analytics"
    case optional = "Optional"
}

// MARK: - Data Collection Purpose
enum DataPurpose: String, Codable, CaseIterable {
    case examProgress = "ExamProgress"
    case userProfile = "UserProfile"
    case crashReporting = "CrashReporting"
    case usageAnalytics = "Analytics"
}

// MARK: - Privacy Data Model
struct PrivacyData: Identifiable, Codable {
    let id: UUID
    let sensitivity: DataSensitivity
    let purpose: DataPurpose
    let isEnabled: Bool
    let retentionDays: Int
    let lastUpdated: Date

    init(sensitivity: DataSensitivity, purpose: DataPurpose, isEnabled: Bool = true, retentionDays: Int = 365) {
        self.id = UUID()
        self.sensitivity = sensitivity
        self.purpose = purpose
        self.isEnabled = isEnabled
        self.retentionDays = retentionDays
        self.lastUpdated = Date()
    }
}

// MARK: - Privacy Consent Manager