// ✅ Add App Store Server API validation layer
class ReceiptValidator {
    private let bundleID = "com.driveai.app"
    private let appStoreServerSecretKey: String  // From App Store Connect
    
    func validateReceipt(_ jwsRepresentation: String) async throws -> ValidatedReceipt {
        let request = URLRequest(url: URL(string: "https://api.storekit.itunes.apple.com/inApps/v1/transactions/\(jwsRepresentation)")!)
        
        var request = request
        request.httpMethod = "GET"
        request.setValue("Bearer \(appStoreServerSecretKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ReceiptValidationError.invalidReceipt
        }
        
        let decodedTransaction = try JSONDecoder().decode(DecodedTransaction.self, from: data)
        
        // Verify expiration date
        guard decodedTransaction.expirationDate > Date() else {
            throw ReceiptValidationError.subscriptionExpired
        }
        
        return ValidatedReceipt(
            productID: decodedTransaction.productID,
            purchaseDate: decodedTransaction.purchaseDate,
            expirationDate: decodedTransaction.expirationDate,
            isRevoked: decodedTransaction.isRevoked
        )
    }
}