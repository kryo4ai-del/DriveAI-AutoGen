extension SubscriptionStateError {
    var emotionalReframe: String {
        switch self {
        case .trialAlreadyUsed:
            return """
            Deine 7-Tage-Testversion hat dir geholfen, 28 Fragen zu meistern.
            Das ist großartig! Mit Premium schaltest du:
            • Alle 1.600 offiziellen Fragen
            • Prüfungssimulationen
            • Personalisierte Lernpfade
            
            Jetzt starten? Upgrade für €9,99/Monat.
            """
        case .invalidTransition:
            return "Überprüfe deinen Abonnementstatus und versuche es erneut."
        default:
            return "Etwas ist schiefgelaufen. Bitte kontaktiere Support."
        }
    }
}