import Foundation

protocol PurchaseLocalRepository: AnyObject, Sendable {
    /// Save a transaction to local cache
    func saveTransaction(_ transaction: PurchaseTransaction) async throws
    
    /// Save multiple transactions
    func saveTransactions(_ transactions: [PurchaseTransaction]) async throws
    
    /// Fetch all cached transactions
    func fetchAllTransactions() async throws -> [PurchaseTransaction]
    
    /// Fetch transactions for a specific feature
    func fetchTransactions(for feature: UnlockableFeature) async throws -> [PurchaseTransaction]
    
    /// Check if a feature is purchased and active
    func isFeaturePurchased(_ feature: UnlockableFeature) async throws -> Bool
    
    /// Delete a specific transaction
    func deleteTransaction(id: String) async throws
    
    /// Delete expired transactions
    func deleteExpiredTransactions() async throws
    
    /// Clear all purchase cache
    func clearCache() async throws
}