// MARK: - Services/Analytics/AnalyticsDataSanitizer.swift

import Foundation
import CryptoKit

struct AnalyticsDataSanitizer {
    
    /// Hash user ID consistently for cross-session identification without PII exposure
    static func hashUserId(_ userId: String) -> String {
        let data = userId.data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        return digest.withUnsafeBytes { buf in
            buf.map { String(format: "%02x", $0) }.joined()
        }.prefix(16) + String(repeating: "x", count: 8)  // Truncate for privacy
    }
    
    /// Bucket scores into ranges (0-100 → "40-50") to prevent fingerprinting
    static func bucketScore(_ score: Int, bucketSize: Int = 10) -> String {
        let clamped = max(0, min(100, score))
        let bucket = (clamped / bucketSize) * bucketSize
        return "\(bucket)-\(bucket + bucketSize)"
    }
    
    /// Convert exam date to week-level granularity (no exact dates)
    static func dateToWeekBucket(_ date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: date)
    }
    
    /// Sanitize time durations into buckets (seconds → minute ranges)
    static func bucketDuration(_ seconds: Int, bucketSeconds: Int = 60) -> String {
        let bucket = max(0, (seconds / bucketSeconds) * bucketSeconds)
        return "\(bucket)-\(bucket + bucketSeconds)"
    }
}