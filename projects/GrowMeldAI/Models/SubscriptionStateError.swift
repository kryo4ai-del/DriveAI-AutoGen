import Foundation
enum SubscriptionStateError: LocalizedError {
    case invalidTransition(from: String, to: String)
    case trialAlreadyUsed
    case cannotRenewal
    
    var userFacingMessage: String {
        switch self {
        case .invalidTransition(let from, let to):
            if from.contains("trial") && to.contains("active") {
                return "Du hast die Testversion beendet. Starte hier dein Abonnement."
            }
            if from.contains("paused") && to.contains("active") {
                return "Dein Abonnement wurde wiederhergestellt. Viel Erfolg beim Lernen!"
            }
            return "Kann diesen Schritt nicht ausführen. Überprüfe deinen Abonnementstatus."
            
        case .trialAlreadyUsed:
            return "Du hast deine 7-Tage-Testversion bereits verwendet. Upgrade jetzt, um alles zu entsperren."
            
        case .cannotRenewal:
            return "Dein Abonnement ist nicht mehr aktiv. Starte hier neu."
        }
    }
}