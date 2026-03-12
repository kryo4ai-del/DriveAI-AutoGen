import Foundation
import Combine

class FeatureAnnouncementViewModel: ObservableObject {
    @Published var introduction: String = "🚗 Bereit für die Fahrschule? 🌟"
    @Published var featureSummary: [String] = [
        "Interaktive Fragen",
        "Statistik-Tracking",
        "Prüfungssimulation",
        "Offline verfügbar",
        "Benutzerfreundliches Design"
    ]
    @Published var mainFeatures: [String] = [
        "Interaktive Fragen mit sofortigem Feedback",
        "Statistik-Tracking für deinen Lernfortschritt",
        "Prüfungssimulation mit 30 Fragen",
        "Offline verfügbar – jederzeit lernen!",
        "Benutzerfreundliches Design für besseres Lernen"
    ]
    @Published var callToAction: String = "Lade die App jetzt im App Store herunter und starte deine Reise zur Fahrerlaubnis!"
    
    var localizedIntroduction: String {
        NSLocalizedString("FEATURE_ANNOUNCEMENT_INTRO", comment: "")
    }
    
    var localizedCallToAction: String {
        NSLocalizedString("FEATURE_ANNOUNCEMENT_CALL_TO_ACTION", comment: "")
    }
    
    init() {
        // Initialization logic if needed
    }
}