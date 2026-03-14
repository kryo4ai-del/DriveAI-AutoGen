// Services are singletons; no need for [weak self]
group.addTask {
    try await self.readinessForCategory(category)
}

// Or if you must:
enum ServiceError: LocalizedError {
    case serviceUnavailable
    var errorDescription: String? { "Datenservice nicht verfügbar" }
}