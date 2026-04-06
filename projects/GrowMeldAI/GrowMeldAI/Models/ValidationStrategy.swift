actor ReceiptValidator {
    enum ValidationStrategy {
        case local           // Validate locally (offline, faster, less secure)
        case serverSide      // Validate via backend (slower, more secure)
    }
    
    private let strategy: ValidationStrategy
    
    init(strategy: ValidationStrategy = .local) {
        self.strategy = strategy
    }
    
    // Called by IAPService after transaction verified by StoreKit 2
    func validate(transaction: Transaction) async throws -> Bool {
        switch strategy {
        case .local:
            // StoreKit 2 already verified cryptographic signature
            // Additional validation optional (check expiration, etc.)
            return transaction.revocationDate == nil
            
        case .serverSide:
            // TODO: Call backend endpoint to validate receipt
            // POST /api/validate-receipt { transactionID, ... }
            // This ensures subscription is valid on server too
            return try await validateOnServer(transaction: transaction)
        }
    }
    
    private func validateOnServer(transaction: Transaction) async throws -> Bool {
        // Placeholder: implement backend call
        // Example:
        // let result = try await URLSession.shared.post(
        //     to: URL(string: "https://api.driveai.app/validate-receipt")!,
        //     body: ["transactionID": transaction.id]
        // )
        // return result.isValid
        return true
    }
}