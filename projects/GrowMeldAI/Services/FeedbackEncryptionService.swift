import Foundation
// Define encryption scope clearly:
protocol FeedbackEncryptionService {
    // At-rest: SQLite (use CryptoKit or SQLCipher)
    func encryptForStorage(_ feedback: UserFeedback) throws -> Data
    func decryptFromStorage(_ data: Data) throws -> UserFeedback
    
    // In-transit: TLS handled by URLSession (standard)
    // Optional: E2E encryption if custom backend
    func encryptForTransit(_ feedback: UserFeedback) throws -> Data
}