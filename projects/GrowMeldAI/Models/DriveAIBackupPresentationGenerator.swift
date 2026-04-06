// File: DriveAIBackupPresentationGenerator.swift
import Foundation

/// Generates presentation content for the DriveAI backup system
/// Handles both internal stakeholder presentations and user-facing content
struct DriveAIBackupPresentationGenerator {

    // MARK: - Content Generation

    /// Generates a complete presentation for internal stakeholders
    /// - Parameters:
    ///   - featureEnabled: Whether backup feature is enabled in current build
    ///   - complianceStatus: Current compliance audit status
    /// - Returns: Structured presentation content
    func generateInternalPresentation(featureEnabled: Bool,
                                     complianceStatus: ComplianceStatus) -> InternalPresentation {
        let emotionalHook = generateEmotionalHook(featureEnabled: featureEnabled)
        let technicalOverview = generateTechnicalOverview()
        let complianceSection = generateComplianceSection(status: complianceStatus)
        let riskMitigation = generateRiskMitigation()

        return InternalPresentation(
            emotionalHook: emotionalHook,
            technicalOverview: technicalOverview,
            complianceSection: complianceSection,
            riskMitigation: riskMitigation,
            callToAction: generateCallToAction()
        )
    }

    /// Generates user-facing presentation content
    /// - Parameters:
    ///   - userName: Optional user name for personalization
    ///   - examDate: Optional exam date for countdown messaging
    /// - Returns: User-facing presentation content
    func generateUserPresentation(userName: String? = nil,
                                 examDate: Date? = nil) -> UserPresentation {
        let emotionalHook = generateUserEmotionalHook(userName: userName, examDate: examDate)
        let featureBenefits = generateUserBenefits()
        let legalDisclaimers = generateLegalDisclaimers()
        let accessibilityInfo = generateAccessibilityInfo()

        return UserPresentation(
            emotionalHook: emotionalHook,
            featureBenefits: featureBenefits,
            legalDisclaimers: legalDisclaimers,
            accessibilityInfo: accessibilityInfo,
            nextSteps: generateUserNextSteps(examDate: examDate)
        )
    }

    // MARK: - Private Content Generation

    private func generateEmotionalHook(featureEnabled: Bool) -> String {
        if featureEnabled {
            return "Stell dir vor, dein Handy geht kaputt – 3 Tage vor der Prüfung. Dein Backup ist aktuell. Kein Stress. Mit DriveAI Backup bist du auf der sicheren Seite."
        } else {
            return "Deine Theorieprüfung rückt näher. Mit DriveAI Backup bist du auf der sicheren Seite – sobald es verfügbar ist."
        }
    }

    private func generateUserEmotionalHook(userName: String?, examDate: Date?) -> String {
        let namePart = userName.map { "\($0)," } ?? "Du,"
        let datePart = examDate.map { formatExamDate($0) } ?? "in Kürze"

        return """
        \(namePart) deine Theorieprüfung naht.
        Mit DriveAI Backup bist du abgesichert – falls das Schicksal mal wieder zuschlägt.
        """
    }

    private func generateTechnicalOverview() -> TechnicalOverview {
        TechnicalOverview(
            architecture: "Lokale Verschlüsselung mit CryptoKit + optionale iCloud-Sicherung",
            encryption: "AES-256-Verschlüsselung mit gerätespezifischem Schlüssel",
            storage: "Lokale Speicherung + optionale Ende-zu-Ende-Verschlüsselung in der Cloud",
            retention: "Automatische Löschung nach bestandener Prüfung oder manuelle Löschung jederzeit möglich"
        )
    }

    private func generateComplianceSection(status: ComplianceStatus) -> ComplianceSection {
        ComplianceSection(
            gdprStatus: status.gdprCompliant ? "DSGVO-konform" : "Auditing erforderlich",
            appStoreStatus: status.appStoreCompliant ? "App Store-konform" : "Review erforderlich",
            consumerProtection: status.consumerProtectionCompliant ? "UWG-konform" : "Prüfung empfohlen",
            notes: generateComplianceNotes(status: status)
        )
    }

    private func generateComplianceNotes(status: ComplianceStatus) -> [String] {
        var notes: [String] = []

        if !status.gdprCompliant {
            notes.append("DSGVO: Explizite Einwilligung für Backup-Speicherung erforderlich")
        }

        if !status.appStoreCompliant {
            notes.append("App Store: Exportkontrolle (EAR) für Verschlüsselung prüfen")
        }

        if !status.consumerProtectionCompliant {
            notes.append("UWG: Keine Angstmache in Benachrichtigungen")
        }

        return notes.isEmpty ? ["Alle Compliance-Anforderungen erfüllt"] : notes
    }

    private func generateRiskMitigation() -> RiskMitigation {
        RiskMitigation(
            dataLoss: "0% Datenverlust durch lokale + Cloud-Backup",
            examFailure: "Backup garantiert keine Prüfungsbestandung – nur Datenintegrität",
            deviceFailure: "Schneller Wechsel auf neues Gerät ohne Datenverlust",
            privacy: "Ende-zu-Ende-Verschlüsselung schützt vor unbefugtem Zugriff"
        )
    }

    private func generateLegalDisclaimers() -> [String] {
        [
            "Die DriveAI Backup-Funktion sichert deine Lernfortschritte, nicht dein Prüfungsergebnis.",
            "Eine aktuelle Sicherung reduziert Stress, garantiert aber keine bestandene Prüfung.",
            "DSGVO-konforme Datenverarbeitung: Du kannst deine Backups jederzeit löschen.",
            "Die Verschlüsselung entspricht den höchsten Sicherheitsstandards (AES-256)."
        ]
    }

    private func generateAccessibilityInfo() -> AccessibilityInfo {
        AccessibilityInfo(
            voiceOver: "Alle Backup-Informationen sind mit VoiceOver kompatibel",
            dynamicType: "Unterstützt Textskalierung bis 200%",
            notifications: "7-Tage-Vorwarnung wird akustisch und visuell angezeigt",
            contrast: "Alle Elemente erfüllen WCAG 2.1 AA Kontrastanforderungen"
        )
    }

    private func generateCallToAction() -> String {
        """
        Nächste Schritte:
        1. Compliance-Audit abschließen
        2. Backup-Funktion in Einstellungen aktivieren
        3. Erste Sicherung manuell auslösen
        4. Regelmäßige automatische Backups prüfen
        """
    }

    private func generateUserNextSteps(examDate: Date?) -> [String] {
        var steps = [
            "Backup in den Einstellungen aktivieren",
            "Erste manuelle Sicherung durchführen",
            "Automatische Backups prüfen"
        ]

        if let examDate = examDate {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 7
            steps.insert("Erinnerung für \(daysLeft) Tage vor Prüfung aktivieren", at: 0)
        }

        return steps
    }

    private func formatExamDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}

// MARK: - Data Models

struct InternalPresentation: Equatable {
    let emotionalHook: String
    let technicalOverview: TechnicalOverview
    let complianceSection: ComplianceSection
    let riskMitigation: RiskMitigation
    let callToAction: String
}

struct UserPresentation: Equatable {
    let emotionalHook: String
    let featureBenefits: [String]
    let legalDisclaimers: [String]
    let accessibilityInfo: AccessibilityInfo
    let nextSteps: [String]
}

struct TechnicalOverview: Equatable {
    let architecture: String
    let encryption: String
    let storage: String
    let retention: String
}

struct ComplianceSection: Equatable {
    let gdprStatus: String
    let appStoreStatus: String
    let consumerProtection: String
    let notes: [String]
}

struct RiskMitigation: Equatable {
    let dataLoss: String
    let examFailure: String
    let deviceFailure: String
    let privacy: String
}

struct AccessibilityInfo: Equatable {
    let voiceOver: String
    let dynamicType: String
    let notifications: String
    let contrast: String
}

struct ComplianceStatus: Equatable {
    let gdprCompliant: Bool
    let appStoreCompliant: Bool
    let consumerProtectionCompliant: Bool
}