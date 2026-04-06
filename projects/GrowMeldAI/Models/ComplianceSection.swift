import Foundation

/// Represents a single screen in the compliance presentation flow.
struct ComplianceSection: Identifiable, Codable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let screenType: ScreenType
    let order: Int
    let iconName: String?
    
    enum ScreenType: String, Codable {
        case intro = "intro"
        case dataCollection = "data_collection"
        case userRights = "user_rights"
        case consentManagement = "consent_management"
        case dataExport = "data_export"
        case summary = "summary"
    }
}

/// Full disclosure content for a section (loaded from JSON)
struct ComplianceContent: Codable {
    let section: ComplianceSection
    let body: String  // Localized HTML or markdown
    let items: [ContentItem]
    let actions: [ComplianceAction]
}

/// Individual item within a section (e.g., list of data types)
struct ContentItem: Identifiable, Codable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let icon: String?
}

/// Actionable element (e.g., "Delete Account", "Export Data")
struct ComplianceAction: Identifiable, Codable {
    let id: String
    let titleKey: String
    let style: ActionStyle
    let target: ActionTarget
    
    enum ActionStyle: String, Codable {
        case primary
        case secondary
        case destructive
    }
    
    enum ActionTarget: Codable {
        case exportData
        case deleteAccount
        case viewPolicy(url: URL)
        case contactSupport
        case custom(id: String)
    }
}