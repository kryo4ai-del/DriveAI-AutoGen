import Foundation

struct IAPProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
}

struct MockIAPTransaction {
    let productID: String
    let transactionID: String
    let purchaseDate: Date

    static func premiumMonthly() -> MockIAPTransaction {
        MockIAPTransaction(
            productID: "premium.monthly",
            transactionID: UUID().uuidString,
            purchaseDate: Date()
        )
    }
}

class MockStoreKitManager {
    var mockProducts: [IAPProduct] = []
    var allTransactions: [MockIAPTransaction] = []
    var transactionUpdates: [MockIAPTransaction] = []

    @MainActor
    func getProducts() async throws -> [IAPProduct] {
        return mockProducts
    }

    func makeTransactionSequence() -> AsyncStream<MockIAPTransaction> {
        let transactions = allTransactions
        return AsyncStream<MockIAPTransaction> { continuation in
            for transaction in transactions {
                continuation.yield(transaction)
            }
            continuation.finish()
        }
    }

    func makeUpdatesSequence() -> AsyncStream<MockIAPTransaction> {
        let updates = transactionUpdates
        return AsyncStream<MockIAPTransaction> { continuation in
            for update in updates {
                continuation.yield(update)
            }
            continuation.finish()
        }
    }
}