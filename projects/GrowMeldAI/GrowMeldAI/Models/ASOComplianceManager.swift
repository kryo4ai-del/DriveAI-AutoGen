// ASOComplianceManager.swift
import Foundation

/// Centralized manager for ASO compliance requirements
/// Handles all legal disclaimers, regulatory compliance, and policy alignment
final class ASOComplianceManager {
    static let shared = ASOComplianceManager()

    private init() {} // Singleton pattern

    // MARK: - Legal Disclaimers

    func getGermanDisclaimer() -> String {
        """
        WICHTIGER HINWEIS:
        DriveAI ist ein Lernhilfe-Tool zur Vorbereitung auf die theoretische Führerscheinprüfung.
        Das App ist NICHT offiziell mit Behörden wie TÜV, DEKRA oder dem Kraftfahrt-Bundesamt verbunden.
        Die Prüfungsfragen basieren auf öffentlich zugänglichen Quellen und dienen ausschließlich der Übung.
        Bestehende Chancen auf die tatsächliche Prüfung hängen von Ihrer Vorbereitung ab.
        """
    }

    func getEnglishDisclaimer() -> String {
        """
        IMPORTANT NOTICE:
        DriveAI is a study aid for preparing for the theoretical driver's license exam.
        The app is NOT officially affiliated with authorities such as TÜV, DEKRA, or the German Federal Motor Transport Authority (KBA).
        The exam questions are based on publicly available sources and are intended solely for practice purposes.
        Your actual exam success depends on your preparation.
        """
    }

    // MARK: - Copyright Notice

    func getCopyrightNotice() -> String {
        """
        © 2024 DriveAI. Alle Rechte vorbehalten.
        All questions are © respective official authorities (TÜV/DEKRA/KBA).
        Used under license or fair use for educational purposes.
        """
    }

    // MARK: - Regulatory Compliance

    func validateMarketingClaims(_ claims: [String]) -> [String] {
        var validatedClaims = [String]()
        let prohibitedTerms = [
            "offiziell", "amtlich", "garantiert bestehen",
            "100% Erfolgsquote", "staatlich anerkannt"
        ]

        for claim in claims {
            let lowercased = claim.lowercased()
            let containsProhibited = prohibitedTerms.contains { term in
                lowercased.contains(term)
            }

            if containsProhibited {
                validatedClaims.append("[REDACTED: Contains prohibited claim]")
            } else {
                validatedClaims.append(claim)
            }
        }

        return validatedClaims
    }
}