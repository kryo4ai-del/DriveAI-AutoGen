import Foundation
// Services are singletons; no need for [weak self]
// [FK-019 sanitized] group.addTask {
// [FK-019 sanitized]     try await self.readinessForCategory(category)
// [FK-019 sanitized] }

// Or if you must:
enum ServiceError: LocalizedError {
    case serviceUnavailable
    var errorDescription: String? { "Datenservice nicht verfügbar" }
}