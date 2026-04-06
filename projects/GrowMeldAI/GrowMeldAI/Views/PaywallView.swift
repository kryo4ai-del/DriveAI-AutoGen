// Views/IAP/PaywallView.swift
struct PaywallView: View {
    @StateObject var viewModel: PaywallViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header: What you'll get
            VStack(alignment: .leading, spacing: 12) {
                Text("Premium Features")
                    .font(.title2.bold())
                
                ForEach(viewModel.featuresList, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(feature)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Pricing tiers
            VStack(spacing: 12) {
                ForEach(viewModel.availableProducts) { product in
                    PricingTierButton(
                        product: product,
                        isSelected: viewModel.selectedProductId == product.id,
                        onTap: { viewModel.selectProduct(product.id) }
                    )
                }
            }
            
            // Purchase button
            Button(action: { viewModel.purchase() }) {
                Text(viewModel.purchaseButtonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.isPurchasing || viewModel.selectedProductId == nil)
            
            // Restore purchases link
            Button("Restore Purchases") {
                viewModel.restorePurchases()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding()
        .alert("Purchase Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

// ViewModels/PaywallViewModel.swift
@MainActor
class PaywallViewModel: ObservableObject {
    @Published var availableProducts: [IAPProduct] = []
    @Published var selectedProductId: String?
    @Published var isPurchasing = false
    @Published var error: IAPError?
    
    let featuresList = [
        "Unlimited practice exams",
        "Spaced repetition scheduling",
        "Detailed progress analytics",
        "Offline question syncing"
    ]
    
    var purchaseButtonLabel: String {
        isPurchasing ? "Processing..." : "Subscribe Now"
    }
    
    func purchase() { /* delegate to StoreKitManager */ }
    func restorePurchases() { /* delegate to StoreKitManager */ }
}