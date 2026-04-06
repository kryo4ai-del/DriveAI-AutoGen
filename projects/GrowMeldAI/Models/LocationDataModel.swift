import Foundation
import CoreLocation

struct LocationDataModel {
    struct UseCase {
        let id: String // "exam_center_locator", "traffic_alerts"
        let purpose: String // GDPR transparency
        let requiredAccuracy: CLLocationAccuracy
        let backgroundModeRequired: Bool
        let dataRetentionDays: Int
    }
    
    struct ConsentContext {
        let useCase: UseCase
        let legalRationale: String // User-friendly explanation
        let privacyImpact: PrivacyLevel // minimal, moderate, high
        let optOutUrl: URL? // Link to disable in settings
    }
}

enum PrivacyLevel {
    case minimal
    case moderate
    case high
}