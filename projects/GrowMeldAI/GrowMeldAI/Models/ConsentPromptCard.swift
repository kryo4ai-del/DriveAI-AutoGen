import SwiftUI

// MARK: - PushConsentViewModel

final class PushConsentViewModel: ObservableObject {
    @Published var headlineText: String = "Bleib auf Kurs mit smarten Erinnerungen"
    @Published var bodyText: String = "Aktiviere Benachrichtigungen und lass uns Dir helfen, Deine Lernziele zu erreichen."
    @Published var privacyText: String = "Wir respektieren Deine Privatsphäre. Keine Werbung, keine Weitergabe an Dritte."
    @Published var isLoadingPermission: Bool = false

    func deferConsent() {
        // Defer the consent prompt to a later time
        UserDefaults.standard.set(Date().addingTimeInterval(86400), forKey: "consentDeferredUntil")
    }

    func declineConsent() {
        // User explicitly declined notifications
        UserDefaults.standard.set(true, forKey: "consentDeclined")
    }

    func acceptConsent() async {
        await MainActor.run { isLoadingPermission = true }
        do {
            let center = UNUserNotificationCenter.current()
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[PushConsentViewModel] Permission request failed: \(error)")
        }
        await MainActor.run { isLoadingPermission = false }
    }
}

// MARK: - BenefitRow

private struct BenefitRow: View {
    let icon: String
    let text: String
    let accessibilityLabel: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - ConsentPromptCard

struct ConsentPromptCard: View {
    @ObservedObject var viewModel: PushConsentViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Headline
            Text(viewModel.headlineText)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            // Body
            Text(viewModel.bodyText)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            // Benefits
            VStack(spacing: 16) {
                BenefitRow(
                    icon: "checkmark.circle",
                    text: "Tägliche Erinnerungen zu Deinen besten Lernzeiten",
                    accessibilityLabel: "Tägliche Erinnerungen"
                )

                BenefitRow(
                    icon: "flame",
                    text: "Motivieren Dich, Deine Lern-Serie zu halten",
                    accessibilityLabel: "Motivation durch Serie"
                )

                BenefitRow(
                    icon: "graduationcap",
                    text: "Helfen Dir, Dein Prüfungsdatum zu erreichen",
                    accessibilityLabel: "Prüfungsvorbereitung"
                )
            }
            .padding(.horizontal, 16)

            // Privacy
            Text(viewModel.privacyText)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            // Buttons
            HStack(spacing: 12) {
                Button("Später fragen") {
                    viewModel.deferConsent()
                }
                .buttonStyle(.bordered)

                Button("Nein, danke") {
                    viewModel.declineConsent()
                }
                .buttonStyle(.bordered)

                Button("Ja, erinnert mich") {
                    Task { await viewModel.acceptConsent() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoadingPermission)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 400)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}