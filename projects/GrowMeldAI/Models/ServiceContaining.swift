// Services/ServiceContainer.swift
protocol ServiceContaining {
    var authService: AuthServiceProtocol { get }
}

@MainActor
class ServiceContainer: ServiceContaining {
    var authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
}