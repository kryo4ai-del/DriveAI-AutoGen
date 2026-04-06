struct SubscribeButton: View {
    @State private var isPurchasing = false
    @State private var purchaseTimeout: Task<Void, Never>?
    
    let plan: SubscriptionPlan
    let onPurchase: (SubscriptionPlan) async -> Result<Void, PurchaseError>
    
    var body: some View {
        Button(action: handlePurchaseStart) {
            if isPurchasing {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text("Wird verarbeitet...", comment: "Processing")
                        .font(.headline)
                }
            } else {
                Text("Jetzt abonnieren", comment: "Subscribe CTA")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
        .disabled(isPurchasing)
        .accessibilityLabel("Abonnement abschließen")
        .accessibilityHint("Öffnet den App-Store-Kaufdialog. \(plan.price)€/\(plan.billingPeriod.localizedString)")
        .onChange(of: isPurchasing) { _, newValue in
            if newValue {
                AccessibilityAnnouncementManager.shared.announce(
                    "Kauf wird verarbeitet. Bitte warten Sie.",
                    priority: .important
                )
                // Set 30-second timeout
                purchaseTimeout = Task {
                    try? await Task.sleep(nanoseconds: 30_000_000_000)
                    if isPurchasing {
                        isPurchasing = false
                        AccessibilityAnnouncementManager.shared.announce(
                            "Kauf-Timeout. Bitte versuchen Sie erneut.",
                            priority: .important
                        )
                    }
                }
            } else {
                purchaseTimeout?.cancel()
                purchaseTimeout = nil
            }
        }
    }
    
    private func handlePurchaseStart() {
        isPurchasing = true
        Task {
            let result = await onPurchase(plan)
            
            switch result {
            case .success:
                AccessibilityAnnouncementManager.shared.announce(
                    "Kauf erfolgreich!",
                    priority: .important
                )
            case .failure(let error):
                isPurchasing = false
                AccessibilityAnnouncementManager.shared.announce(
                    "Kauf fehlgeschlagen: \(error.errorDescription ?? "Unbekannter Fehler")",
                    priority: .important
                )
            }
        }
    }
}