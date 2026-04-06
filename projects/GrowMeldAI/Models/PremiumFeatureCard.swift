import SwiftUI
struct PremiumFeatureCard: View {
    let product: PurchaseProduct
    let isUnlocked: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: product.feature.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)  // ✅ Scales with Dynamic Type
                    
                    Text(product.description)
                        .font(.body)      // ✅ Scales with Dynamic Type
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Text(product.price)
                    .font(.title3)        // ✅ Scales with Dynamic Type
                    .fontWeight(.semibold)
            }
            
            Button(action: onPurchase) {
                Text(isUnlocked ? "Freigeschaltet" : "Kaufen")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .font(.callout)       // ✅ Scales with Dynamic Type
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUnlocked)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}