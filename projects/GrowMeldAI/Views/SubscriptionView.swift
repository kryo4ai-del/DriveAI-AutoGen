import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProductID: String?
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Premium freischalten")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Unbegrenzter Zugriff auf alle Lerninhalte")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                    
                    // Product Cards
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if subscriptionManager.products.isEmpty {
                        Text("Produkte nicht verfügbar")
                            .foregroundColor(.secondary)
                            .frame(maxHeight: .infinity)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(subscriptionManager.products, id: \.id) { product in
                                SubscriptionProductCard(
                                    product: product,
                                    isSelected: selectedProductID == product.id,
                                    onSelect: { selectedProductID = product.id }
                                )
                            }
                        }
                        
                        Spacer()
                        
                        // Purchase Button
                        Button(action: { Task { await purchaseSelected() } }) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Abonnieren")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(selectedProductID == nil || isProcessing)
                        
                        // Restore Button
                        Button(action: { Task { await restorePurchases() } }) {
                            Text("Käufe wiederherstellen")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("Fehler", isPresented: .constant(subscriptionManager.transactionError != nil)) {
                Button("OK") {
                    subscriptionManager.transactionError = nil
                }
            } message: {
                if let error = subscriptionManager.transactionError {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private func purchaseSelected() async {
        guard let productID = selectedProductID,
              let product = subscriptionManager.products.first(where: { $0.id == productID }) else {
            return
        }
        
        isProcessing = true
        let transaction = await subscriptionManager.purchase(product)
        isProcessing = false
        
        if transaction != nil {
            dismiss()
        }
    }
    
    private func restorePurchases() async {
        await subscriptionManager.restorePurchases()
    }
}

// MARK: - Product Card

struct SubscriptionProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let period = product.subscription?.localizedSubscriptionPeriod {
                            Text("Erneuert sich \(period)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let period = product.subscription?.introductoryOffer?.period {
                            Text("Kostenlos für \(period)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Text("Ausgewählt")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Extension for Subscription Period Formatting

extension Product.SubscriptionPeriod {
    var localizedSubscriptionPeriod: String {
        switch unit {
        case .day:
            return "\(value)x täglich"
        case .week:
            return "\(value)x wöchentlich"
        case .month:
            return "\(value)x monatlich"
        case .year:
            return "\(value)x jährlich"
        @unknown default:
            return "periodisch"
        }
    }
}