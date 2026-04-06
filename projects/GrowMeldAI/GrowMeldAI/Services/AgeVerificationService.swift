struct AgeVerificationService {
    
    private let keychainService: KeychainService
    
    func saveVerification(_ verification: AgeVerification) throws {
        // Encode + encrypt in Keychain
        // Do NOT use UserDefaults (privacy risk)
    }
    
    func loadVerification() throws -> AgeVerification? {
        // Decrypt from Keychain
    }
    
    func isAgeVerified(minimumAge: Int) -> Bool {
        // Returns true only if verified age >= minimumAge
        // False for nil (unverified)
    }
}