// LocalizationService.swift
import Foundation

final class LocalizationService {
    static let shared = LocalizationService()

    private init() {}

    private var currentLocale: Locale = .current

    var isRTL: Bool {
        currentLocale.language.languageCode?.identifier == "ar"
    }

    var languageCode: String {
        currentLocale.language.languageCode?.identifier ?? "en"
    }

    var regionCode: String? {
        currentLocale.region?.identifier
    }

    func localizedString(forKey key: String, bundle: Bundle = .main) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    func setLocale(_ locale: Locale) {
        currentLocale = locale
    }

    func getPrivacyPolicyURL() -> URL? {
        let region = regionCode?.lowercased() ?? "us"
        let language = languageCode.lowercased()

        // AU/CA specific privacy policies
        if region == "au" {
            return URL(string: "https://driveai.app/privacy-au")
        } else if region == "ca" {
            return URL(string: "https://driveai.app/privacy-ca")
        }

        // Default to US/UK privacy policy
        return URL(string: "https://driveai.app/privacy")
    }

    func getTermsURL() -> URL? {
        let region = regionCode?.lowercased() ?? "us"
        let language = languageCode.lowercased()

        if region == "au" {
            return URL(string: "https://driveai.app/terms-au")
        } else if region == "ca" {
            return URL(string: "https://driveai.app/terms-ca")
        }

        return URL(string: "https://driveai.app/terms")
    }
}