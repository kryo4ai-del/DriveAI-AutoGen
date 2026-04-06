enum ConsentCheckResult: Equatable {
    case granted
    case denied
    case unknown(reason: String) // Database error, corruption, etc.
}

func checkConsent(for type: NotificationType) async -> ConsentCheckResult {
    do {
        let userId = await getCurrentUserId()
        guard let consent = try await persistenceService.loadConsent(for: userId) else {
            logger.warning("No consent record found for user \(userId)")
            return .denied
        }
        
        if consent.isValid(for: type) {
            return .granted
        } else {
            logger.info("Consent expired or not granted for type \(type.rawValue)")
            return .denied
        }
    } catch {
        logger.error("Critical: Failed to check consent — \(error.localizedDescription)")
        // Fail safe: don't send if we can't verify consent
        return .unknown(reason: error.localizedDescription)
    }
}

// Caller code:
switch await permissionService.checkConsent(for: .examReadinessCheckpoint) {
case .granted:
    // Safe to send
    break
case .denied:
    // User explicitly declined
    return
case .unknown(let reason):
    // Log to monitoring, don't send, alert team
    logger.error("Cannot verify consent: \(reason)")
    alertMonitoring(issue: "Consent verification failed")
    return
}