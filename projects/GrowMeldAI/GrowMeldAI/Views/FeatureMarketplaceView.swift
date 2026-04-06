struct FeatureMarketplaceView: View {
    @StateObject private var viewModel: FeatureMarketplaceViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.features) { feature in
                FeatureRow(feature: feature)
                    .onTapGesture { viewModel.selectFeature(feature) }
            }
            .navigationTitle("Premium Features")
        }
        .sheet(isPresented: $viewModel.showPurchaseConfirmation) {
            if let feature = viewModel.selectedFeature {
                PurchaseConfirmationView(feature: feature, isProcessing: viewModel.isLoading) {
                    Task { await viewModel.purchaseFeature(feature) }
                }
            }
        }
    }
}