// Services/ServiceContainer.swift
protocol ServiceContaining {
    var authService: AuthServiceProtocol { get }
}

@MainActor

// Usage in SwiftUI
@main