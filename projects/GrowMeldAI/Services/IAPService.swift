import Foundation
import StoreKit

// MARK: - IAPProduct

struct IAPProduct: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let displayPrice: String
    let product: Product

    init(storeKitProduct: Product) {
        self.id = storeKitProduct.id
        self.displayName = storeKitProduct.displayName
        self.description = storeKitProduct.description
        self.displayPrice = storeKitProduct.displayPrice
        self.product = storeKitProduct
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
            return "Failed to fetch products: \(error.localizedDescription)"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .recoveryFailed(let error):
            return "Recovery failed: \(error.localizedDescription)"
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

// MARK: - TransactionPersistenceManager

final class TransactionPersistenceManager {
    private let defaults = UserDefaults.standard
    private let persistedKey = "iap_persisted_transaction_ids"

    init(localDataService: IAPLocalDataService) {}

    func recoverOrphanedTransactions() async throws {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
        }
    }

    func persistAndFinish(_ transaction: Transaction) async throws {
        var ids = defaults.stringArray(forKey: persistedKey) ?? []
        let idString = String(transaction.id)
        if !ids.contains(idString) {
            ids.append(idString)
            defaults.set(ids, forKey: persistedKey)
        }
        await transaction.finish()
    }
}

// MARK: - CircuitBreaker

final class CircuitBreaker {
    private var failureCount = 0
    private let threshold: Int
    private var lastFailureTime: Date?
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
        if let lastFailure = lastFailureTime,
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
            lastFailureTime = nil
            return result
        } catch {
            failureCount += 1
            lastFailureTime = Date()
            throw error
        }
    }
}

// MARK: - IAPLocalDataService

protocol IAPLocalDataService: AnyObject {}

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
        localDataService: IAPLocalDataService,
        circuitBreaker: CircuitBreaker? = nil
    ) {
        self.localDataService = localDataService
        self.persistenceManager = TransactionPersistenceManager(
            localDataService: localDataService
        )
        self.circuitBreaker = circuitBreaker ?? CircuitBreaker()
    }

    func initialize() async {
        do {
            try await persistenceManager.recoverOrphanedTransactions()
        } catch {
            IAPLogger.error("Recovery failed: \(error)")
            self.error = .recoveryFailed(error)
        }
        startTransactionObserver()
    }

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

    private func startTransactionObserver() {
        transactionListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransactionUpdate(result)
            }
        }
    }

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

    func restorePurchases() async throws {
        try await AppStore.sync()
    }
}