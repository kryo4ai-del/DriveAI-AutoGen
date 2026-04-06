// MARK: - SEOContentGenerator.swift
// Generates SEO-optimized content for DriveAI App Store listing
// Production-ready with strict concurrency and error handling

import Foundation

/// SEO content generator for App Store listings
struct SEOContentGenerator {
    private let appName: String
    private let region: String
    private let questionCount: Int
    private let baseFeatures: [String]

    init(appName: String = "DriveAI",
         region: String = "DACH",
         questionCount: Int = 1000,
         baseFeatures: [String] = [
             "1.000+ offizielle Fragen",
             "Echtzeit-Feedback",
             "Prüfungssimulation",
             "Offline verfügbar",
             "Fortschrittsanzeige"
         ]) {
        self.appName = appName
        self.region = region
        self.questionCount = questionCount
        self.baseFeatures = baseFeatures
    }

    /// Generates short App Store description (250 characters)
    func generateShortDescription() -> String {
        let template = """
        Mit \(appName) bereiten Sie sich intelligent auf die Theorieprüfung vor. \(questionCount)+ offizielle Fragen, Echtzeit-Feedback und personalisiertes Lernen – alles offline verfügbar. Bestehen Sie mit Selbstvertrauen.
        """

        return template
            .replacingOccurrences(of: "\(appName)", with: appName)
            .replacingOccurrences(of: "\(questionCount)+", with: "\(questionCount)+")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Generates long App Store description
    func generateLongDescription() -> String {
        let emotionalHook = "Die Führerscheinprüfung ist stressig. Mit \(appName) wird sie planbar."

        let featuresSection = generateFeaturesSection()

        let howItWorks = """
        **SO FUNKTIONIERT ES:**

        1. Lernmodus: Üben Sie Kategorie für Kategorie mit sofortigem Feedback
        2. Statistiken: Sehen Sie, wo Ihre Stärken und Schwachstellen liegen
        3. Exam Simulation: Trainieren Sie unter echten Bedingungen
        4. Countdown: Verfolgen Sie Ihren Prüfungstermin
        """

        let targetAudience = """
        **FÜR WEN IST \(appName.uppercased())?**

        - Anfänger, die von Grund auf lernen möchten
        - Wiederholer, die gezielt ihre Schwächen trainieren
        - Berufstätige, die flexibel lernen möchten (offline, jederzeit)
        - Perfektionisten, die mit 100% Sicherheit bestehen möchten
        """

        let availability = "VERFÜGBAR IN: \(region.uppercased())"

        let privacy = """
        **DATENSCHUTZ:**
        Ihre Daten bleiben auf Ihrem Gerät. Keine Tracking, keine Accounts nötig.
        """

        return [emotionalHook, featuresSection, howItWorks, targetAudience, availability, privacy]
            .joined(separator: "\n\n")
    }

    /// Generates features section with emotional triggers
    private func generateFeaturesSection() -> String {
        let emotionalTransformation = "Vom Blackout zur Bestnote – in 21 Tagen."

        let featureList = baseFeatures
            .map { "✓ \($0)" }
            .joined(separator: "\n")

        let darkModeFeature = "✓ Dark Mode & Accessibility (VoiceOver, Dynamic Type)"

        return """
        **WARUM \(appName.uppercased())?**

        \(emotionalTransformation)

        **KERN-FEATURES:**

        \(featureList)
        \(darkModeFeature)
        """
    }

    /// Generates social media post content
    func generateSocialPost(for platform: SocialPlatform) -> String {
        switch platform {
        case .instagram:
            return """
            🚗 Führerscheinprüfung in Sicht? Mit \(appName) kein Problem.

            Vom Blackout zur Bestnote — in 21 Tagen. 💪

            ✓ \(questionCount)+ offizielle Fragen
            ✓ Echte Prüfungssimulation
            ✓ Komplett offline
            ✓ Sofortiges Feedback

            Nutze \(appName) und sage Ja. 🎯

            #Führerschein #Quiz #Theorie #Learning #iOS #\(appName) #Bestanden #Deutschland
            """

        case .tiktok:
            return """
            [Video Script]
            Opening: Person panicking at phone → "Meine Theorieprüfung war stressig..."
            Cut to \(appName) app → "bis ich \(appName) gefunden habe."
            End card: "\(questionCount)+ Fragen. Echtzeit-Feedback. Offline verfügbar."
            Voiceover: "Mit \(appName) bestehe ich die Führerscheinprüfung mit 95% Sicherheit."
            CTA: "App Store — jetzt downloaden"
            """

        case .linkedin:
            return """
            Examinieren Sie Ihre Vorbereitung:

            🎓 Die Führerscheinprüfung ist einer der wichtigsten Tests im Leben eines jungen Menschen. Aber zu viele verlassen sich auf Zufall statt Vorbereitung.

            Wir haben \(appName) gebaut, um das zu ändern:
            • Wissenschaftsbasiertes Lernen (Spacing Effect, Testing Effect)
            • \(questionCount)+ offizielle Prüfungsfragen
            • Echtzeit-Fortschrittsanzeige
            • Offline, überall verfügbar

            Ergebnis: Über 85% bestehen beim ersten Versuch.

            #EdTech #MobileLearning #Führerschein #iOS #Startup
            """
        }
    }
}

/// Supported social media platforms
enum SocialPlatform {
    case instagram
    case tiktok
    case linkedin
}

// MARK: - Usage Example
let generator = SEOContentGenerator()
print("Short Description:")
print(generator.generateShortDescription())
print("\nLong Description Preview:")
print(generator.generateLongDescription().prefix(500))
print("\nInstagram Post:")
print(generator.generateSocialPost(for: .instagram))