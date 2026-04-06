struct PaywallSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
            Task {
                await subscriptionViewModel.purchase(product: product)
                if subscriptionViewModel.error == nil {
                    dismiss()  // ⚠️ Timing issue
                }
            }
        })
    }
}