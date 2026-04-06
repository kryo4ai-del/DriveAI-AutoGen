// File: DriveAI/Features/ASA/Views/ASAComplianceView.swift
import SwiftUI

/// View for managing Apple Search Ads compliance consent
struct ASAComplianceView: View {
    @StateObject private var viewModel = ASAComplianceManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            headerView

            consentCard

            Spacer()

            actionButtons
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Exam Prep Confidence")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Dein Weg zur Prüfungsreife")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Wir helfen dir, gesehen zu werden")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var consentCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vertrauensvolle Vorbereitung")
                .font(.headline)

            Text("Damit wir dich optimal auf deine Führerscheinprüfung vorbereiten können, benötigen wir dein Einverständnis für folgende Funktionen:")

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Personalisierte Lernempfehlungen")
                }

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Prüfungssimulationen basierend auf deinem Fortschritt")
                }

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Erfolgsstatistiken für deine Motivation")
                }
            }
            .font(.subheadline)

            Toggle("Analyse für bessere Prüfungsvorbereitung aktivieren", isOn: Binding(
                get: { viewModel.consentState == .granted },
                set: { isOn in
                    Task {
                        if isOn {
                            do {
                                _ = try await viewModel.requestConsent()
                            } catch {
                                print("Consent request failed: \(error)")
                            }
                        } else {
                            viewModel.consentState = .denied
                        }
                    }
                }
            ))
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    do {
                        let state = try await viewModel.requestConsent()
                        if state.isGranted {
                            dismiss()
                        }
                    } catch {
                        print("Consent request failed: \(error)")
                    }
                }
            }) {
                Text("Weiter")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button("Später entscheiden") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
    }
}