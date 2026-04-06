// PrivacyConsentView.swift
import SwiftUI

struct PrivacyConsentView: View {
    @EnvironmentObject var consentManager: PrivacyConsentManager
    @Environment(\.dismiss) var dismiss

    let onConsent: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("Privacy Settings")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("We respect your privacy and want to be transparent about how we collect and use data.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                Text("Analytics & Crash Reporting")
                    .font(.headline)

                Text("""
                We use analytics to improve the app and crash reporting to fix issues. This helps us provide a better learning experience.

                Your data is never sold or shared with third parties for marketing purposes.
                """)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            VStack(spacing: 12) {
                Button(action: {
                    consentManager.giveConsent()
                    onConsent()
                    dismiss()
                }) {
                    Text("Accept & Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("Deny") {
                    consentManager.denyConsent()
                    onConsent()
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Text("View Privacy Policy")
                    .font(.footnote)
            }
        }
        .padding()
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}