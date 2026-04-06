import Foundation
enum PurchaseError: LocalizedError, Equatable, Hashable {
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Netzwerkfehler – die Verbindung zum App Store ist unterbrochen."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Überprüfen Sie Ihre WLAN- oder Datenverbindung und versuchen Sie erneut."
        }
    }
    
    var accessibilityDescription: String {
        // Combines error + recovery for screen readers
        let base = errorDescription ?? "Ein Fehler ist aufgetreten"
        if let recovery = recoverySuggestion {
            return "\(base) \(recovery)"
        }
        return base
    }
}