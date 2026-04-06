// Services/IAP/SubscriptionManagementView.swift
import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Subscription Management")
                .font(.title2)
                .fontWeight(.semibold)

            Text("You can manage your subscription through the App Store")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                openSubscriptionSettings()
            }) {
                Text("Manage Subscription")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Text("You'll be redirected to the App Store to manage your subscription")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openSubscriptionSettings() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url)
    }
}