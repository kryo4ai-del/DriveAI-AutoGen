import Foundation
import StoreKit
import Combine

@MainActor
final class StoreKitManager: NSObject, ObservableObject {
    @Published var isPurchasing = false
    @Published var availableProducts: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Error>?

    override init() {
        super.init()
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    func purchase(product: Product) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProductIDs.insert(transaction.productID)
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            // Restore failed silently
        }
    }

    func loadProducts(productIDs: [String]) async {
        do {
            let products = try await Product.products(for: productIDs)
            availableProducts = products
        } catch {
            availableProducts = []
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitManagerError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { break }
                do {
                    let transaction = try await self.checkVerified(result)
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                } catch {
                    // Verification failed
                }
            }
        }
    }

    private func updatePurchasedProducts() async {
        var ids = Set<String>()
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                ids.insert(transaction.productID)
            }
        }
        purchasedProductIDs = ids
    }
}

enum StoreKitManagerError: LocalizedError {
    case verificationFailed
    case purchaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed."
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        }
    }
}