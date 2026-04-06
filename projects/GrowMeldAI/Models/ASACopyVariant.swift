import Foundation

/// Represents a single ad copy variant for Apple Search Ads
struct ASACopyVariant: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let headline: String
    let description: String
    let emotionalHook: String
    let disclaimer: String?

    init(text: String,
         headline: String,
         description: String,
         emotionalHook: String,
         disclaimer: String? = nil) {
        self.text = text
        self.headline = headline
        self.description = description
        self.emotionalHook = emotionalHook
        self.disclaimer = disclaimer
    }

    /// Creates emotionally compelling copy for driver's license exam prep
    static func makeEmotionalCopy() -> [ASACopyVariant] {
        [
            ASACopyVariant(
                text: "Von 'Oh nein, Theorie!' zu 'Ich schaff das!' — DriveAI begleitet dich auf dem Weg zur bestandenen Prüfung.",
                headline: "Bestehe deine Theorieprüfung",
                description: "Lerne mit DriveAI — die smarte App für deine Fahrschulprüfung. Jetzt starten!",
                emotionalHook: "Transformiere Prüfungsangst in Erfolgserlebnisse",
                disclaimer: "DriveAI ist kein offizielles Prüfungsorgan"
            ),
            ASACopyVariant(
                text: "14 Tage kostenlos lernen. Keine automatische Verlängerung. Dein Weg zum Führerschein beginnt hier.",
                headline: "Führerschein in Reichweite",
                description: "Intelligente Lernkarten und Prüfungssimulationen. Jetzt durchstarten!",
                emotionalHook: "Sicherheit durch strukturiertes Lernen",
                disclaimer: "Ergebnisse können variieren"
            )
        ]
    }
}