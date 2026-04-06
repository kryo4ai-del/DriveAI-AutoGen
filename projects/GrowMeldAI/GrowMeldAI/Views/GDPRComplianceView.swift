// File: GDPRComplianceManager.swift
import Foundation
import Combine
import SwiftUI

// MARK: - GDPR Compliance States
enum GDPRConsentState: String, Codable, CaseIterable {
    case notAsked
    case granted
    case denied
    case revoked
}

// MARK: - Data Category Classification
enum DataCategory: String, Codable, CaseIterable {
    case examDate
    case progressTracking
    case streakCounter
    case categoryPerformance
    case userProfile
    case analytics

    var description: String {
        switch self {
        case .examDate: return "Prüfungstermin"
        case .progressTracking: return "Lernfortschritt"
        case .streakCounter: return "Lernstreak"
        case .categoryPerformance: return "Kategorienleistung"
        case .userProfile: return "Benutzerprofil"
        case .analytics: return "Nutzungsstatistiken"
        }
    }

    var retentionPeriod: String {
        switch self {
        case .examDate, .progressTracking, .streakCounter, .categoryPerformance, .userProfile:
            return "Bis zur Löschanfrage"
        case .analytics:
            return "90 Tage"
        }
    }
}

// MARK: - Data Processing Purpose
enum DataPurpose: String, Codable, CaseIterable {
    case examPreparation = "Prüfungsvorbereitung"
    case userExperience = "Nutzererlebnis"
    case analytics = "Analysen"
    case serviceImprovement = "Dienstverbesserung"

    var description: String {
        switch self {
        case .examPreparation: return "Speicherung deiner Lernfortschritte und Prüfungstermine"
        case .userExperience: return "Personalisierung der Lerninhalte"
        case .analytics: return "Verbesserung der App-Funktionalität"
        case .serviceImprovement: return "Fehlerbehebung und Updates"
        }
    }
}

// MARK: - User Data Model
struct UserDataRecord: Identifiable, Codable {
    let id: UUID
    let category: DataCategory
    let value: String
    let timestamp: Date
    let purpose: DataPurpose
}

// MARK: - GDPR Compliance Manager
final class GDPRComplianceManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var consentState: GDPRConsentState = .notAsked
    @Published private(set) var userDataRecords: [UserDataRecord] = []

    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let dataRetentionDays: Int = 90
    private let privacyPolicyURL = URL(string: "https://driveai.app/privacy")!
    private let termsOfServiceURL = URL(string: "https://driveai.app/terms")!

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadConsentState()
        loadUserData()
        cleanupOldData()
    }

    // MARK: - Consent Management
    func requestConsent() {
        guard consentState == .notAsked else { return }
        consentState = .granted
        saveConsentState()
    }

    func revokeConsent() {
        consentState = .revoked
        deleteAllUserData()
        saveConsentState()
    }

    // MARK: - Data Management
    func recordData(category: DataCategory, value: String, purpose: DataPurpose) {
        guard consentState == .granted else { return }

        let record = UserDataRecord(
            id: UUID(),
            category: category,
            value: value,
            timestamp: Date(),
            purpose: purpose
        )

        userDataRecords.append(record)
        saveUserData()
    }

    func deleteData(for category: DataCategory) {
        userDataRecords.removeAll { $0.category == category }
        saveUserData()
    }

    func deleteAllUserData() {
        userDataRecords.removeAll()
        saveUserData()
    }

    // MARK: - Privacy Policy
    var privacyPolicyText: String {
        """
        Datenschutzerklärung für DriveAI

        1. Verantwortlicher
        DriveAI ("wir", "uns", "unser") nimmt den Schutz deiner persönlichen Daten ernst.

        2. Erfasste Daten
        Wir speichern:
        - Prüfungstermine
        - Lernfortschritte
        - Lernstatistiken
        - Benutzerprofile

        3. Speicherdauer
        Deine Daten werden gespeichert bis du die Löschung anforderst.

        4. Deine Rechte
        Du hast das Recht auf:
        - Auskunft über deine Daten
        - Berichtigung falscher Daten
        - Löschung deiner Daten
        - Datenübertragbarkeit

        5. Kontakt
        Bei Fragen: support@driveai.app
        """
    }

    // MARK: - Private Helpers
    private func saveConsentState() {
        userDefaults.set(consentState.rawValue, forKey: "gdprConsentState")
    }

    private func loadConsentState() {
        if let stateString = userDefaults.string(forKey: "gdprConsentState"),
           let state = GDPRConsentState(rawValue: stateString) {
            consentState = state
        }
    }

    private func saveUserData() {
        if let encoded = try? JSONEncoder().encode(userDataRecords) {
            userDefaults.set(encoded, forKey: "userDataRecords")
        }
    }

    private func loadUserData() {
        if let data = userDefaults.data(forKey: "userDataRecords"),
           let decoded = try? JSONDecoder().decode([UserDataRecord].self, from: data) {
            userDataRecords = decoded
        }
    }

    private func cleanupOldData() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -dataRetentionDays, to: Date())!
        userDataRecords.removeAll { $0.timestamp < cutoffDate }
        saveUserData()
    }
}

// MARK: - GDPR Compliance View
struct GDPRComplianceView: View {
    @StateObject private var complianceManager = GDPRComplianceManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    Text("Deine Privatsphäre ist uns wichtig")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text("Wir schützen deine Daten — genau wie du dich auf deine Fahrprüfung vorbereitest.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // Consent Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Datenschutz-Einstellungen")
                        .font(.headline)

                    Text("Wir speichern nur Daten, die du uns erlaubst. Alles bleibt lokal auf deinem Gerät — kein Cloud-Sync, keine Werbung, keine Weitergabe.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(DataCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(category.description)
                                    .font(.subheadline)
                                Spacer()
                                Text(category.retentionPeriod)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Consent Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            complianceManager.requestConsent()
                            dismiss()
                        }) {
                            Text("Alles gut — ich stimme zu")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: {
                            complianceManager.consentState = .denied
                            dismiss()
                        }) {
                            Text("Nein danke")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)

                // Privacy Policy Link
                Link("Datenschutzerklärung lesen", destination: complianceManager.privacyPolicyURL)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.bottom, 16)
            }
        }
        .navigationTitle("Datenschutz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct GDPRComplianceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GDPRComplianceView()
        }
    }
}