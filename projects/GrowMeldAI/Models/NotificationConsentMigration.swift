import Foundation

class NotificationConsentMigration {
    static func migrateIfNeeded(from oldData: Data) throws -> NotificationConsent {
        let decoder = JSONDecoder()
        do {
            // Try to decode as new format first
            return try decoder.decode(NotificationConsent.self, from: oldData)
        } catch {
            // Fall back to legacy format
            let legacyConsent = try decodeLegacyConsent(from: oldData)
            return NotificationConsent(
                userId: legacyConsent.userId,
                types: legacyConsent.types,
                timezone: legacyConsent.timezone ?? TimeZone.current.identifier,
                dataRetentionDays: 365
            )
        }
    }

    private static func decodeLegacyConsent(from data: Data) throws -> LegacyNotificationConsent {
        let decoder = JSONDecoder()
        return try decoder.decode(LegacyNotificationConsent.self, from: data)
    }
}

private struct LegacyNotificationConsent: Codable {
    let userId: String
    let types: Set<NotificationType>
    let timezone: String?
}