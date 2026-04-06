import Foundation

// MARK: - Enums

enum FeedbackCategory: String, CaseIterable, Codable {
    case bug = "bug"
    case featureRequest = "feature_request"
    case question = "question"
    case other = "other"
    
    var germanLabel: String {
        switch self {
        case .bug:
            return "Fehler melden"
        case .featureRequest:
            return "Funktion vorschlagen"
        case .question:
            return "Frage stellen"
        case .other:
            return "Sonstiges"
        }
    }
}

// MARK: - Data Model

/// User feedback entity
/// Collected offline, persisted locally, ready for post-MVP cloud sync

// MARK: - Codable Helpers

extension UserFeedback {
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case category
        case message
        case appVersion
        case osVersion
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(category, forKey: .category)
        try container.encode(message, forKey: .message)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(osVersion, forKey: .osVersion)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.category = try container.decode(FeedbackCategory.self, forKey: .category)
        self.message = try container.decode(String.self, forKey: .message)
        self.appVersion = try container.decode(String.self, forKey: .appVersion)
        self.osVersion = try container.decode(String.self, forKey: .osVersion)
    }
}

// MARK: - Bundle Extension for App Version

extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
    
    var buildNumber: String {
        (infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }
}