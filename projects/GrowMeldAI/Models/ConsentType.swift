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
// Struct ConsentRecord declared in Models/ConsentRecord.swift
