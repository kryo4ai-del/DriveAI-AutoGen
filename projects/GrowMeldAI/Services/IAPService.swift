import Foundation
import StoreKit

// MARK: - IAPProduct

struct IAPProduct: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let displayPrice: String
    let price: Decimal
    let storeKitProduct: Product

    init(storeKitProduct: Product) {
        self.id = storeKitProduct.id
        self.displayName = storeKitProduct.displayName
        self.description = storeKitProduct.description
        self.displayPrice = storeKitProduct.displayPrice
        self.price = storeKitProduct.price
        self.storeKitProduct = storeKitProduct
    }
}

// MARK: - IAPError

enum IAPError: LocalizedError {
    case productFetchFailed(Error)
    case purchaseFailed(Error)
    case recoveryFailed(Error)
    case unknownPurchaseResult

    var errorDescription: String? {
        switch self {
        case .productFetchFailed(let error):
            return "Product fetch failed: \(error.localizedDescription)"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .recoveryFailed(let error):
            return "Transaction recovery failed: \(error.localizedDescription)"
        case .unknownPurchaseResult:
            return "Unknown purchase result."
        }
    }
}

// MARK: - IAPLogger

enum IAPLogger {
    static func error(_ message: String) {
        print("[IAPService][ERROR] \(message)")
    }
    static func warning(_ message: String) {
        print("[IAPService][WARNING] \(message)")
    }
    static func info(_ message: String) {
        print("[IAPService][INFO] \(message)")
    }
}

// MARK: - CircuitBreaker

final class CircuitBreaker {
    private var failureCount = 0
    private let threshold: Int
    private var lastFailureDate: Date?
    private let resetInterval: TimeInterval

    init(threshold: Int = 3, resetInterval: TimeInterval = 60) {
        self.threshold = threshold
        self.resetInterval = resetInterval
    }

    func execute<T>(
        cacheKey: String,
        timeout: TimeInterval,
        operation: () async throws -> T
    ) async throws -> T {
        if let lastFailure = lastFailureDate,
           failureCount >= threshold,
           Date().timeIntervalSince(lastFailure) < resetInterval {
            throw IAPError.productFetchFailed(
                NSError(domain: "CircuitBreaker", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Circuit breaker open"])
            )
        }

        do {
            let result = try await operation()
            failureCount = 0
            lastFailureDate = nil
            return result
        } catch {
            failureCount += 1
            lastFailureDate = Date()
            throw error
        }
    }
}

// MARK: - TransactionPersistenceManager

final class TransactionPersistenceManager {
    private let localDataService: IAPLocalDataService

    init(localDataService: IAPLocalDataService) {
        self.localDataService = localDataService
    }

    func recoverOrphanedTransactions() async throws {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                localDataService.markTransactionProcessed(id: transaction.id)
            }
        }
    }

    func persistAndFinish(_ transaction: Transaction) async throws {
        localDataService.markTransactionProcessed(id: transaction.id)
        await transaction.finish()
    }
}

// MARK: - IAPLocalDataService

final class IAPLocalDataService {
    private let defaults = UserDefaults.standard
    private let processedKey = "iap_processed_transactions"

    func markTransactionProcessed(id: UInt64) {
        var processed = processedTransactionIDs()
        processed.insert(String(id))
        defaults.set(Array(processed), forKey: processedKey)
    }

    func isTransactionProcessed(id: UInt64) -> Bool {
        return processedTransactionIDs().contains(String(id))
    }

    private func processedTransactionIDs() -> Set<String> {
        let array = defaults.stringArray(forKey: processedKey) ?? []
        return Set(array)
    }
}

// MARK: - IAPService

@MainActor
final class IAPService: NSObject, ObservableObject {
    @Published private(set) var products: [IAPProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: IAPError?

    private let localDataService: IAPLocalDataService
    private let persistenceManager: TransactionPersistenceManager
    private let circuitBreaker: CircuitBreaker
    private var transactionListenerTask: Task<Void, Never>?

    init(
        localDataService: IAPLocalDataService = IAPLocalDataService(),
        circuitBreaker: CircuitBreaker? = nil
    ) {
        self.localDataService = localDataService
        self.persistenceManager = TransactionPersistenceManager(
            localDataService: localDataService
        )
        self.circuitBreaker = circuitBreaker ?? CircuitBreaker()
    }

    /// Initialize IAP service and recover any orphaned transactions.
    func initialize() async {
        do {
            try await persistenceManager.recoverOrphanedTransactions()
        } catch {
            IAPLogger.error("Recovery failed: \(error)")
            self.error = .recoveryFailed(error)
        }

        startTransactionObserver()
    }

    /// Fetch available products from App Store.
    func fetchProducts() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            self.products = try await circuitBreaker.execute(
                cacheKey: "iap_products",
                timeout: 10
            ) {
                let storeProducts = try await Product.products(
                    for: ["com.driveai.premium.monthly"]
                )
                return storeProducts.map { IAPProduct(storeKitProduct: $0) }
            }
            self.error = nil
        } catch {
            self.error = .productFetchFailed(error)
            throw error
        }
    }

    /// Start observing StoreKit transaction updates.
    private func startTransactionObserver() {
        transactionListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransactionUpdate(result)
            }
        }
    }

    /// Handle a transaction update from StoreKit.
    private func handleTransactionUpdate(
        _ result: VerificationResult<Transaction>
    ) async {
        switch result {
        case .verified(let transaction):
            do {
                try await persistenceManager.persistAndFinish(transaction)
            } catch {
                IAPLogger.error("Failed to handle verified transaction: \(error)")
            }

        case .unverified(let transaction, _):
            IAPLogger.warning("Unverified transaction received: \(transaction.id)")
        }
    }

    /// Purchase a product.
    func purchase(_ product: Product) async throws -> Transaction? {
        do {
            let result = try await product.purchase()

            switch result {
            case .success:
                return nil

            case .userCancelled:
                return nil

            case .pending:
                IAPLogger.info("Purchase pending user action")
                return nil

            @unknown default:
                throw IAPError.unknownPurchaseResult
            }
        } catch {
            throw error
        }
    }

    /// Restore purchases (prompt StoreKit to refresh transactions).
    func restorePurchases() async throws {
        try await AppStore.sync()
    }
}