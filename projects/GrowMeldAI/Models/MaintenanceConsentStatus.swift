// Add to MaintenanceCheckService initialization:

enum MaintenanceConsentStatus: String, Codable {
    case notAsked
    case declined
    case consented
}

// In app initialization:
let consentStatus = try await maintenanceService.getUserConsentStatus()
if consentStatus == .notAsked {
    // Show consent dialog before runWeeklyChecks() can proceed
    let userConsented = await maintenanceService.requestMaintenanceConsent()
    guard userConsented else {
        // Disable maintenance checks
        return
    }
}