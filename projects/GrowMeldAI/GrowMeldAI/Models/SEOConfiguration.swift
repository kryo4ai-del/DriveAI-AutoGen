// SEOConfiguration.swift
import Foundation

/// Configuration for SEO optimization in DriveAI
struct SEOConfiguration {
    let appName: String
    let primaryKeyword: String
    let secondaryKeywords: [String]
    let description: String
    let supportEmail: String
    let privacyPolicyURL: URL
    let termsOfServiceURL: URL
    let appStoreId: String
    let bundleIdentifier: String

    static let `default` = SEOConfiguration(
        appName: "DriveAI",
        primaryKeyword: "Führerschein lernen",
        secondaryKeywords: [
            "Fahrschule App",
            "Theorieprüfung bestehen",
            "Führerschein Test",
            "Fahrschulbögen",
            "MPU Vorbereitung"
        ],
        description: """
        Lerne für deine Führerscheinprüfung mit DriveAI – der intelligenten App für Theorieprüfung und Praxisvorbereitung.
        Mit personalisierten Lernplänen, realistischen Prüfungssimulationen und detaillierten Statistiken.
        Bereite dich optimal vor und bestehe deine Prüfung beim ersten Mal!
        """,
        supportEmail: "support@driveai.app",
        privacyPolicyURL: URL(string: "https://driveai.app/privacy")!,
        termsOfServiceURL: URL(string: "https://driveai.app/terms")!,
        appStoreId: "YOUR_APP_STORE_ID",
        bundleIdentifier: "com.driveai.app"
    )
}