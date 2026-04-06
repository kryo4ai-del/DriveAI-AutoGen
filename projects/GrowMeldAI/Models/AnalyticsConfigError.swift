import Foundation
enum AnalyticsConfigError: Error, LocalizedError, Sendable {
    case firebaseNotInitialized
    case invalidEventParameters
    
    var errorDescription: String? {
        NSLocalizedString(
            self.localizationKey,
            comment: self.localizationComment
        )
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .firebaseNotInitialized:
            return NSLocalizedString(
                "Bitte stellen Sie sicher, dass Firebase korrekt konfiguriert ist.",
                comment: "recovery suggestion for firebase initialization"
            )
        case .invalidEventParameters:
            return NSLocalizedString(
                "Versuchen Sie, die App neu zu starten.",
                comment: "recovery suggestion for invalid parameters"
            )
        }
    }
    
    private var localizationKey: String {
        switch self {
        case .firebaseNotInitialized:
            return "Firebase wurde nicht initialisiert"
        case .invalidEventParameters:
            return "Das Ereignis enthält ungültige Parameter"
        }
    }
    
    private var localizationComment: String {
        switch self {
        case .firebaseNotInitialized:
            return "error: firebase not initialized"
        case .invalidEventParameters:
            return "error: invalid event parameters"
        }
    }
}