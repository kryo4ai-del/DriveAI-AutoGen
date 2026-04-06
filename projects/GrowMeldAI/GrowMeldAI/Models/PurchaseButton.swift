struct PurchaseButton: View {
    @ObservedObject var purchaseManager: PurchaseFlowViewModel
    
    var body: some View {
        Button(action: handlePurchase) {
            if purchaseManager.isProcessing {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Processing...")
                }
            } else {
                Text("Upgrade to Premium")
            }
        }
        .disabled(purchaseManager.isProcessing)
        .accessibilityLabel("Upgrade to Premium")
        .accessibilityHint(
            purchaseManager.isProcessing ?
            "Purchase processing, please wait" :
            "Unlocks unlimited questions for 7 days"
        )
        .accessibilityAddTraits(purchaseManager.isProcessing ? .isNotEnabled : [])
    }
    
    private func handlePurchase() {
        Task {
            try await purchaseManager.purchase()
        }
    }
}