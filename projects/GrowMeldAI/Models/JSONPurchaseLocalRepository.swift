// Services/Purchase/JSONPurchaseLocalRepository.swift
import Foundation

@MainActor
final class JSONPurchaseLocalRepository: PurchaseLocalRepository, Sendable {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(
        label: "com.driveai.purchase.repo",
        attributes: .concurrent
    )
    
    private var purchasesCache: [PurchaseTransaction] = []
    
    private var purchasesFileURL: URL {
        let documentsURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documentsURL.appendingPathComponent("purchases.json")
    }
    
    init() {
        Task { try? await loadFromDisk() }
    }
    
    // MARK: - PurchaseLocalRepository
    
    func saveTransaction(_ transaction: PurchaseTransaction) async throws {
        try await queue.async(flags: .barrier) { [weak self] in
            guard var cached = self?.purchasesCache else { return }
            
            // Remove duplicate (idempotent)
            cached.removeAll { $0.id == transaction.id }
            cached.append(transaction)
            
            self?.purchasesCache = cached
            
            // Persist to disk
            do {
                let data = try self?.encoder.encode(cached) ?? Data()
                try data.write(to: self?.purchasesFileURL ?? URL(fileURLWithPath: "/"), options: .atomic)
            } catch {
                throw PurchaseError.localStorageError("Failed to persist: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTransactions(_ transactions: [PurchaseTransaction]) async throws {
        for transaction in transactions {
            try await saveTransaction(transaction)
        }
    }
    
    func fetchAllTransactions() async throws -> [PurchaseTransaction] {
        try await queue.async { [weak self] in
            self?.purchasesCache ?? []
        }
    }
    
    func fetchTransactions(for feature: UnlockableFeature) async throws -> [PurchaseTransaction] {
        let all = try await fetchAllTransactions()
        return all.filter { $0.feature == feature }
    }
    
    func isFeaturePurchased(_ feature: UnlockableFeature) async throws -> Bool {
        let transactions = try await fetchTransactions(for: feature)
        return transactions.contains { $0.isActive }
    }
    
    func deleteTransaction(id: String) async throws {
        try await queue.async(flags: .barrier) { [weak self] in
            self?.purchasesCache.removeAll { $0.id == id }
            try? self?.persistToDisk()
        }
    }
    
    func deleteExpiredTransactions() async throws {
        try await queue.async(flags: .barrier) { [weak self] in
            self?.purchasesCache.removeAll { !$0.isActive }
            try? self?.persistToDisk()
        }
    }
    
    func clearCache() async throws {
        try await queue.async(flags: .barrier) { [weak self] in
            self?.purchasesCache = []
            try? self?.fileManager.removeItem(at: self?.purchasesFileURL ?? URL(fileURLWithPath: "/"))
        }
    }
    
    // MARK: - Private
    
    private func persistToDisk() throws {
        let data = try encoder.encode(purchasesCache)
        try data.write(to: purchasesFileURL, options: .atomic)
    }
    
    private func loadFromDisk() async throws {
        guard fileManager.fileExists(atPath: purchasesFileURL.path) else {
            return
        }
        
        let data = try Data(contentsOf: purchasesFileURL)
        let transactions = try decoder.decode([PurchaseTransaction].self, from: data)
        
        try await queue.async(flags: .barrier) { [weak self] in
            self?.purchasesCache = transactions
        }
    }
}