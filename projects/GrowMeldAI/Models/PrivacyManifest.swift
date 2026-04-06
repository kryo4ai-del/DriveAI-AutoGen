// PrivacyManifest.swift
import Foundation

/// Privacy manifest for DriveAI app to ensure GDPR/DSGVO compliance
/// This file documents all required privacy disclosures for App Store submission
struct PrivacyManifest {
    struct PrivacyDisclosure: Codable {
        let key: String
        let value: String
    }

    static let requiredDisclosures: [PrivacyDisclosure] = [
        .init(
            key: "NSUserTrackingUsageDescription",
            value: "Wir verwenden Tracking-Technologien, um deine Lernfortschritte zu analysieren und DriveAI zu verbessern. Diese Daten helfen uns, dir bessere Lerninhalte anzubieten. Du kannst diese Einstellungen in den iPhone-Einstellungen ändern."
        ),
        .init(
            key: "NSLocationWhenInUseUsageDescription",
            value: "DriveAI benötigt deinen Standort, um dir relevante Fahrschulstandorte und Prüfstellen in deiner Nähe anzuzeigen."
        ),
        .init(
            key: "NSPhotoLibraryUsageDescription",
            value: "Du kannst dein Führerschein-Foto hochladen, um dich auf die Prüfung vorzubereiten."
        )
    ]
}