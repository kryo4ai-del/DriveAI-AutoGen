@MainActor
final class PurchaseDataService: ObservableObject {
    @Published var userPurchaseState: UserPurchaseState
    
    private let writeLock = NSLock()
    
    func savePurchase(_ transaction: PurchaseTransaction) async throws {
        userPurchaseState.addPurchase(transaction)
        try await persistToDisk()
    }
    
    private func persistToDisk() async throws {
        let data = try JSONEncoder().encode(userPurchaseState)
        
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: PurchaseError.unknown)
                    return
                }
                
                self.writeLock.lock()
                defer { self.writeLock.unlock() }
                
                do {
                    // Atomic write (replace entire file)
                    try data.write(to: self.storageURL, options: .atomic)
                    continuation.resume()
                } catch {
                    continuation.resume(
                        throwing: PurchaseError.encodeFailure(underlying: error)
                    )
                }
            }
        }
    }
}