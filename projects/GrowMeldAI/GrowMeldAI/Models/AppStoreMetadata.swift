// AppStoreMetadata.swift
import Foundation

/// Model for App Store metadata optimization
struct AppStoreMetadata {
    let appName: String
    let subtitle: String
    let keywords: String
    let description: String
    let promotionalText: String
    let marketingURL: URL
    let supportURL: URL
    let privacyPolicyURL: URL

    func localized(for locale: Locale) -> AppStoreMetadata {
        // In production, this would return localized versions
        return self
    }
}

extension AppStoreMetadata {
    static func `default`(config: SEOConfiguration) -> AppStoreMetadata {
        AppStoreMetadata(
            appName: config.appName,
            subtitle: "Intelligente Führerschein Vorbereitung",
            keywords: "Führerschein lernen,Fahrschule App,Theorieprüfung bestehen,Fahrschulbögen,MPU Vorbereitung",
            description: config.description,
            promotionalText: "Bestehe deine Theorieprüfung beim ersten Mal mit DriveAI!",
            marketingURL: URL(string: "https://driveai.app")!,
            supportURL: URL(string: "mailto:\(config.supportEmail)")!,
            privacyPolicyURL: config.privacyPolicyURL
        )
    }
}