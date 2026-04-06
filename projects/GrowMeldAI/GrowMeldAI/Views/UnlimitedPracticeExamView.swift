// Views/IAP/IAP+FeatureGating.swift
import SwiftUI

extension View {
    @MainActor
    func requiresPremium(
        feature: String,
        entitlementService: EntitlementService,
        onShowPaywall: @escaping () -> Void
    ) -> some View {
        Group {
            if entitlementService.hasFeatureAccess(feature) {
                self
            } else {
                Button(action: onShowPaywall) {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.title)
                        Text("Premium Feature")
                            .font(.headline)
                        Text("Upgrade to unlock")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

// Usage:
struct UnlimitedPracticeExamView: View {
    @StateObject var entitlementService: EntitlementService
    @State var showPaywall = false
    
    var body: some View {
        PracticeExamContent()
            .requiresPremium(
                feature: "unlimited_exams",
                entitlementService: entitlementService
            ) {
                showPaywall = true
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
    }
}

// ✅ GOOD: Reusable across all premium features
// ❌ AVOID: Copy-pasting paywall logic into every premium view