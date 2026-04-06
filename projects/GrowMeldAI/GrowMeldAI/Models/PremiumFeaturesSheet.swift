// Views/Purchase/PremiumFeaturesSheet.swift
struct PremiumFeaturesSheet: View {
    @StateObject private var viewModel: PurchaseViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Premium Features")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Schalte unbegrenzte Features frei")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    // Feature Cards
                    ForEach(viewModel.availableProducts) { product in
                        PremiumFeatureCard(
                            product: product,
                            isUnlocked: viewModel.unlockedFeatures.contains(product.feature),
                            onPurchase: {
                                Task { await viewModel.purchase(product) }
                            }
                        )
                    }
                    
                    Spacer()
                    
                    // Restore Purchases Button
                    Button(action: {
                        Task { await viewModel.restorePurchases() }
                    }) {
                        Text("Käufe wiederherstellen")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") { dismiss() }
                }
            }
            .task {
                await viewModel.loadAvailableProducts()
            }
        }
    }
}

// Views/Purchase/FeatureLockBadge.swift