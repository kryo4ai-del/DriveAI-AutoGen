@MainActor
final class IAPService: NSObject, ObservableObject {
    @Published private(set) var products: [IAPProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: IAPError?
    
    private let localDataService: LocalDataService
    private let persistenceManager: TransactionPersistenceManager
    private let circuitBreaker: CircuitBreaker
    private var transactionListenerTask: Task<Void, Never>?
    
    init(
        localDataService: LocalDataService,
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
        // Recover orphaned transactions first
        do {
            try await persistenceManager.recoverOrphanedTransactions()
        } catch {
            IAPLogger.error("Recovery failed: \(error)")
            self.error = .recoveryFailed(error)
        }
        
        // Then start observing new transactions
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
                let products = try await Product.products(
                    for: ["com.driveai.premium.monthly"]
                )
                return products.map { IAPProduct(storeKitProduct: $0) }
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
            // Don't finish—let StoreKit retry
        }
    }
    
    /// Purchase a product.
    func purchase(_ product: Product) async throws -> Transaction? {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Let transaction observer handle finishing
                return nil // Will be handled by observer
                
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
        // AppStore.sync() triggers Transaction.updates
    }
}