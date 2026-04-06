import Foundation

// MARK: - Consent Types
enum ConsentType: String, Codable, CaseIterable {
    case dataCollection = "data_collection"
    case analytics = "analytics_tracking"
    case futureSync = "cross_device_sync"
    
    var germanDescription: String {
        switch self {
        case .dataCollection:
            return "Datenerfassung"
        case .analytics:
            return "Nutzungsanalyse"
        case .futureSync:
            return "Geräteübergreifende Synchronisierung"
        }
    }
}

// MARK: - Consent Record
struct ConsentRecord: Identifiable, Codable {
    let id: UUID
    let consentType: ConsentType
    let isConsented: Bool
    let timestamp: Date
    let policyVersion: String
    
    init(
        id: UUID = UUID(),
        consentType: ConsentType,
        isConsented: Bool,
        timestamp: Date = Date(),
        policyVersion: String = "1.0"
    ) {
        self.id = id
        self.consentType = consentType
        self.isConsented = isConsented
        self.timestamp = timestamp
        self.policyVersion = policyVersion
    }
}