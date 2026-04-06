import Foundation

/// Represents the synchronization state with emotional context for driver's license learning
enum SyncState: String, CaseIterable {
    case syncing
    case synced
    case offline
    case error
}

extension SyncState {
    /// Emotionally resonant display title connected to driver's license exam goal
    var displayTitle: String {
        switch self {
        case .syncing:
            return "Deine Antworten werden gesichert – du bist auf der sicheren Seite..."
        case .synced:
            return "Deine Theorie-Prüfung ist geschützt ✓"
        case .offline:
            return "Offline – Änderungen werden lokal gespeichert"
        case .error:
            return "Synchronisierung fehlgeschlagen"
        }
    }

    /// Status message that connects to exam preparation
    var examReadinessMessage: String? {
        switch self {
        case .synced:
            return "Deine Antworten sind für deinen 30-Tage-Plan geschützt."
        case .syncing:
            return "Deine Fortschritte werden gerade gesichert..."
        default:
            return nil
        }
    }
}