// ✅ IMPROVED: Privacy manifest & label generation
struct PrivacyLabel {
    let dataCollected: [PrivacyDataType]
    let dataUsage: [PrivacyUsagePurpose]
    let dataSharing: [PrivacyDataSharing]
    let trackingDomains: [String]
}

enum PrivacyDataType: String, Codable {
    case userID = "USER_ID"
    case deviceID = "DEVICE_ID"
    case examDate = "EXAM_DATE"
    case progressData = "PROGRESS_DATA"
    case crashData = "CRASH_DATA"
}

enum PrivacyUsagePurpose: String, Codable {
    case appFunctionality = "APP_FUNCTIONALITY"
    case analytics = "ANALYTICS"
    case crashReporting = "CRASH_REPORTING"
    case personalization = "PERSONALIZATION"
}

enum PrivacyDataSharing: String, Codable {
    case notShared = "NOT_SHARED"
    case thirdPartyAnalytics = "THIRD_PARTY_ANALYTICS"
    case thirdPartyCrashReporting = "THIRD_PARTY_CRASH_REPORTING"
}

// Generate privacy declaration for App Store
final class PrivacyLabelGenerator {
    func generateAppStoreDeclaration() -> PrivacyLabel {
        return PrivacyLabel(
            dataCollected: [.examDate, .progressData],
            dataUsage: [.appFunctionality],
            dataSharing: [.notShared],
            trackingDomains: [] // Offline-first = no tracking
        )
    }
    
    func validateCompliance() throws {
        // Ensure analytics/crash reporting declared
        // Ensure third-party SDKs are documented
    }
}