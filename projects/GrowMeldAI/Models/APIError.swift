enum APIError: LocalizedError, Equatable {
    case networkAndCacheUnavailable
    case offlineNoCacheAvailable
    case cacheExpired
    case corruptedData(String)
    case syncFailed(String)
    
    var errorDescription: String? {
        let bundle = Bundle(for: type(of: self))
        
        switch self {
        case .cacheExpired:
            return NSLocalizedString(
                "error.cache_expired",
                bundle: bundle,
                value: "Gepufferte Daten sind veraltet",
                comment: "Cache has passed expiration date"
            )
        
        case .corruptedData(let context):
            return String(
                format: NSLocalizedString(
                    "error.corrupted_data",
                    bundle: bundle,
                    value: "Datenbeschädigung: %@",
                    comment: "Data integrity error with context"
                ),
                context
            )
        
        case .offlineNoCacheAvailable:
            return NSLocalizedString(
                "error.offline_no_cache",
                bundle: bundle,
                value: "Offline – keine Fragen verfügbar",
                comment: "User is offline and no cached questions exist"
            )
        
        case .syncFailed(let reason):
            return String(
                format: NSLocalizedString(
                    "error.sync_failed",
                    bundle: bundle,
                    value: "Synchronisierung fehlgeschlagen: %@",
                    comment: "Data sync failed with reason"
                ),
                reason
            )
        
        case .networkAndCacheUnavailable:
            return NSLocalizedString(
                "error.network_and_cache",
                bundle: bundle,
                value: "Netzwerkfehler und keine Daten verfügbar",
                comment: "Network failed and no cache fallback"
            )
        }
    }
    
    var recoverySuggestion: String? {
        let bundle = Bundle(for: type(of: self))
        
        switch self {
        case .cacheExpired, .offlineNoCacheAvailable:
            return NSLocalizedString(
                "error.recovery_reconnect",
                bundle: bundle,
                value: "Stelle eine Internetverbindung her und versuche erneut",
                comment: "Recovery hint: reconnect to network"
            )
        
        case .corruptedData:
            return NSLocalizedString(
                "error.recovery_reinstall",
                bundle: bundle,
                value: "Deinstalliere und installiere die App neu",
                comment: "Recovery hint: reinstall app"
            )
        
        case .syncFailed:
            return NSLocalizedString(
                "error.recovery_retry",
                bundle: bundle,
                value: "Versuche es später erneut oder kontaktiere den Support",
                comment: "Recovery hint: retry later or contact support"
            )
        
        case .networkAndCacheUnavailable:
            return NSLocalizedString(
                "error.recovery_contact_support",
                bundle: bundle,
                value: "Kontaktiere den Support für Hilfe",
                comment: "Recovery hint: contact support"
            )
        }
    }
}