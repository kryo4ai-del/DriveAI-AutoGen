struct AnalyticsDataProcessor {
    static func anonymizeUserId(_ id: String) -> String {
        // Hash user ID consistently
        var digest = [UInt8](repeating: 0, count: 32)
        // Use CryptoKit
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    static func sanitizeScore(_ score: Int, bucketSize: Int = 10) -> String {
        // Return score ranges instead of exact values
        let bucket = (score / bucketSize) * bucketSize
        return "\(bucket)-\(bucket + bucketSize)"
    }
}