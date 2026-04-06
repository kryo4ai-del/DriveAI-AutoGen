class SecureSubscriptionStorage {
    private let keychain = KeychainService.shared
    
    func saveReceiptData(_ receipt: Data) throws {
        try keychain.store(
            receipt,
            forKey: "subscription_receipt",
            attributes: [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock]
        )
    }
    
    func getReceiptData() -> Data? {
        try? keychain.retrieve(forKey: "subscription_receipt")
    }
}