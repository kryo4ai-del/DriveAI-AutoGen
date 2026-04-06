// File: Views/CrashReportView.swift
import SwiftUI

/// View displayed when a crash occurs, with GDPR-compliant messaging
struct CrashReportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CrashReportViewModel

    init(error: Error? = nil) {
        _viewModel = StateObject(wrappedValue: CrashReportViewModel(error: error))
    }

    var body: some View {
        VStack(spacing: 24) {
            // App logo/illustration
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.top, 40)

            // Emotional support messaging
            VStack(spacing: 16) {
                Text("Alles gut — wir haben es gesehen!")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("Dein Lernfortschritt ist sicher gespeichert. Wir beheben das und du kannst gleich weitermachen.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.reportCrash()
                    dismiss()
                }) {
                    Text("Bericht senden")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("Später erinnern") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// ViewModel for CrashReportView
final class CrashReportViewModel: ObservableObject {
    private let error: Error?
    private let crashService: CrashReportingServiceProtocol

    init(error: Error?,
         crashService: CrashReportingServiceProtocol = CrashlyticsService()) {
        self.error = error
        self.crashService = crashService
    }

    func reportCrash() {
        if let error = error {
            crashService.record(error: error)
        } else {
            crashService.log(event: "Crash reported by user")
        }
    }
}