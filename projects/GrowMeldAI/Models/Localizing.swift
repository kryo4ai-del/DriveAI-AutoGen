import Foundation

/// Protocol for localization service
protocol Localizing {
    func localize(_ key: String, arguments: [String: String]) -> String
}

/// Default implementation using Strings Catalog (iOS 16+)
struct DefaultLocalizer: Localizing {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    func localize(_ key: String, arguments: [String: String] = [:]) -> String {
        // iOS 16+: Uses Strings Catalog
        var result = NSLocalizedString(key, bundle: bundle, comment: "")
        
        // Replace placeholders
        for (placeholder, value) in arguments {
            result = result.replacingOccurrences(of: "{\(placeholder)}", with: value)
        }
        
        return result
    }
}

// MARK: - Strings Catalog Keys (Reference)
/*
 trial.expired.upgrade_cta = "Upgrade zum Premium-Paket, um weiterhin Fragen zu üben"
 trial.expiring_soon.upgrade_cta = "Deine Trial läuft in {days} Tagen ab — jetzt upgraden"
 trial.high_progress.premium_cta = "Du bist fast bereit! Premium entsperrt personalisierte Schwachstellen-Drills"
 trial.active.unlock_all_cta = "Unlock alle Lerntools mit Premium"
 
 trial_status.active = "Trial aktiv — {days} Tage verbleibend, {progress}% Fortschritt"
 trial_status.expiring_soon = "⚠️ Trial läuft in {days} Tagen ab"
 trial_status.expired = "Trial abgelaufen vor {daysSince} Tagen"
 trial_status.none = "Kein aktiver Trial"
 */