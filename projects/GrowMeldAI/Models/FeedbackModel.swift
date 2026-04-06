import Foundation

struct FeedbackModel: Identifiable, Codable, Sendable {
    let id: UUID
    let text: String
    let category: FeedbackCategory
    let contactEmail: String?
    let timestamp: Date
    let appVersion: String
    let osVersion: String
    var isSynced: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, text, category, contactEmail, timestamp
        case appVersion = "app_version"
        case osVersion = "os_version"
        case isSynced = "is_synced"
    }
    
    init(
        id: UUID = UUID(),
        text: String,
        category: FeedbackCategory = .general,
        contactEmail: String? = nil,
        timestamp: Date = Date(),
        appVersion: String = Bundle.main.appVersion,
        osVersion: String = UIDevice.current.systemVersion,
        isSynced: Bool = false
    ) {
        self.id = id
        self.text = text.trimmingCharacters(in: .whitespaces)
        self.category = category
        self.contactEmail = contactEmail?.trimmingCharacters(in: .whitespaces)
        self.timestamp = timestamp
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.isSynced = isSynced
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}