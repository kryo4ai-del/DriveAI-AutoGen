// Models/Location/LocationDataModel.swift
import Foundation
import CoreLocation

/// Legal basis for location data processing under GDPR
enum LegalBasis: String, Codable {
    case consent = "GDPR Article 6(1)(a)"
    case legitimateInterest = "GDPR Article 6(1)(f)"
    case contract = "GDPR Article 6(1)(b)"
}

/// Privacy impact level for location data processing
enum PrivacyLevel: String, Codable {
    case minimal
    case moderate
    case high
}
