import StoreKit

/// Manages transaction persistence and recovery.
/// Responsibility: Ensure every verified transaction is either finished or recoverable.
@MainActor
actor TransactionPersistenceManager {
    private let localDataService: LocalDataService
    private let logger: IAPLogger
    
    init(localDataService: LocalDataService, logger: IAPLogger = IAPLogger.shared) {
        self.localDataService = localDataService
        self.logger = logger
    }
    
    /// Synchronize StoreKit's transaction queue with local persistence.
    /// Call once at app launch to recover any orphaned transactions.
    func recoverOrphanedTransactions() async throws {
        logger.info("Recovering orphaned transactions...")
        
        for await result in Transaction.all {
            let transaction: Transaction
            
            switch result {
            case .verified(let tx):
                transaction = tx
            case .unverified(let tx, _):
                logger.warning("Skipping unverified transaction: \(tx.id)")
                continue
            }
            
            // Check if already persisted
            let exists = await localDataService.hasTransaction(id: transaction.id)
            
            if exists {
                // Already in our DB, just finish it
                await finishTransaction(transaction, reason: .alreadyPersisted)
            } else {
                // Orphaned—recover it
                logger.info("Recovering orphaned transaction: \(transaction.id)")
                try await persistAndFinish(transaction, isRecovery: true)
            }
        }
        
        logger.info("Recovery complete")
    }
    
    /// Persist a verified transaction and mark it finished in StoreKit.
    /// - Important: This is an atomic operation. If any step fails, the transaction remains unfinished.
    func persistAndFinish(
        _ transaction: Transaction,
        isRecovery: Bool = false
    ) async throws {
        let txId = transaction.id
        let metadata = makeMetadata(from: transaction)
        
        do {
            // 1. Persist to local DB (idempotent)
            try await localDataService.saveOrUpdateTransaction(metadata)
            logger.debug("Persisted transaction: \(txId)")
            
            // 2. Notify observers
            TransactionPersistenceNotification.send(
                transactionID: txId,
                isRecovery: isRecovery
            )
            
            // 3. Finish in StoreKit (acknowledge we handled it)
            await transaction.finish()
            logger.info("Finished transaction: \(txId)")
            
        } catch {
            // Don't finish if persistence fails—retry on next launch
            logger.error("Failed to persist transaction \(txId): \(error)")
            throw error
        }
    }
    
    /// Called when a transaction is already in our DB or skipped.
    private func finishTransaction(
        _ transaction: Transaction,
        reason: FinishReason
    ) async {
        let txId = transaction.id
        
        do {
            await transaction.finish()
            logger.debug("Finished transaction \(txId) (\(reason.rawValue))")
        } catch {
            logger.error("Failed to finish transaction \(txId): \(error)")
            // Silently continue—StoreKit will retry next launch
        }
    }
    
    private func makeMetadata(from transaction: Transaction) -> TransactionMetadata {
        TransactionMetadata(
            id: transaction.id,
            productID: transaction.productID,
            purchaseDate: transaction.purchaseDate,
            expirationDate: transaction.expirationDate,
            isActive: transaction.revocationDate == nil,
            finishedAt: Date()
        )
    }
    
    enum FinishReason: String {
        case alreadyPersisted
        case duplicate
    }
}

/// Notification helpers for transaction events.
struct TransactionPersistenceNotification {
    static func send(transactionID: UInt64, isRecovery: Bool) {
        NotificationCenter.default.post(
            name: NSNotification.Name("IAPTransactionUpdated"),
            object: nil,
            userInfo: ["transactionID": transactionID, "isRecovery": isRecovery]
        )
    }
}