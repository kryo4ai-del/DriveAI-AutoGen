import SwiftUI

struct PrivacyOnboardingView: View {
    @StateObject private var consentManager = PrivacyConsentManager()
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with reassuring message
                VStack(spacing: 16) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Dein Fortschritt gehört dir — wir schützen ihn")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Wir arbeiten zusammen, um deine Daten sicher zu halten, während du dich auf deine Prüfung vorbereitest.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Data categories explanation
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(DataPurpose.allCases, id: \.self) { purpose in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: purpose.iconName)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(purpose.title.localized)
                                    .font(.headline)

                                Text(purpose.description.localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Consent toggles
                VStack(spacing: 16) {
                    Toggle("Essenzielle Daten erlauben", isOn: Binding(
                        get: { consentManager.hasUserConsented },
                        set: { _ in }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .disabled(true)

                    Text("Ohne diese Daten können wir dir nicht helfen, dich auf deine Prüfung vorzubereiten.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Weiter ohne Tracking")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // In a real app, this would show the full privacy settings
                        hasCompletedOnboarding = true
                    }) {
                        Text("Einstellungen anpassen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

private extension DataPurpose {
    var iconName: String {
        switch self {
        case .examProgress: return "book.fill"
        case .userProfile: return "person.fill"
        case .crashReporting: return "ant.fill"
        case .analytics: return "chart.bar.fill"
        }
    }

    var title: String {
        switch self {
        case .examProgress: return "Lernfortschritt"
        case .userProfile: return "Benutzerprofil"
        case .crashReporting: return "App-Stabilität"
        case .analytics: return "Verbesserungen"
        }
    }

    var description: String {
        switch self {
        case .examProgress:
            return "Speichert deine Prüfungsfortschritte, damit du dort weitermachen kannst, wo du aufgehört hast."
        case .userProfile:
            return "Deine persönlichen Einstellungen und Prüfungsdaten."
        case .crashReporting:
            return "Hilft uns, Fehler zu finden und die App zu verbessern."
        case .analytics:
            return "Zeigt uns, wie du die App nutzt, um sie besser zu machen."
        }
    }
}