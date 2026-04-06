// MARK: - ASA View Components
import SwiftUI

/// ASA Presentation View - Shows the ASA card when appropriate
struct ASAPresentationView: View {
    @EnvironmentObject var asaService: ASAService
    @State private var isPresented = false

    var body: some View {
        Group {
            if asaService.shouldPresentASA() {
                ASAView()
                    .transition(.opacity.combined(with: .scale))
                    .onAppear {
                        asaService.trackImpression(
                            campaignID: asaService.getCampaignConfig().campaignID,
                            keyword: asaService.getCampaignConfig().keyword
                        )
                    }
            }
        }
        .onChange(of: asaService.config.isActive) { isActive in
            if isActive {
                isPresented = true
            }
        }
    }
}

/// Main ASA View - The actual ad card
struct ASAView: View {
    @EnvironmentObject var asaService: ASAService
    @State private var isAnimating = false

    private var config: ASACampaignConfig {
        asaService.getCampaignConfig()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            content
            actionButtons
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.3), value: isAnimating)
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DriveAI")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Führerschein Vorbereitung")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(config.adCopy)
                .font(.body)
                .foregroundColor(.primary)

            Text("Jetzt starten →")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: dismiss) {
                Text("Später")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: installAction) {
                Text("Installieren")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func dismiss() {
        withAnimation {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // In production, this would dismiss the view
        }
    }

    private func installAction() {
        asaService.trackTap(
            campaignID: config.campaignID,
            keyword: config.keyword
        )

        // Simulate install action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            asaService.trackInstall(
                campaignID: config.campaignID,
                keyword: config.keyword
            )
            dismiss()
        }
    }
}

/// ASA Consent View - For GDPR compliance
struct ASAConsentView: View {
    @EnvironmentObject var asaService: ASAService
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Datenschutz-Einstellungen")
                .font(.headline)

            Text("Möchtest du personalisierte Werbung von Apple Search Ads erhalten, um DriveAI besser kennenzulernen?")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Toggle("Personalisierte Werbung zulassen", isOn: Binding(
                get: { asaService.getConsentStatus() == .granted },
                set: { isGranted in
                    UserDefaults.standard.set(isGranted, forKey: "asaConsentGranted")
                }
            ))

            HStack {
                Button("Ablehnen") {
                    UserDefaults.standard.set(false, forKey: "asaConsentGranted")
                    isPresented = false
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Zulassen") {
                    UserDefaults.standard.set(true, forKey: "asaConsentGranted")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
    }
}