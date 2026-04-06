// Services/ServiceLocator.swift
class ServiceLocator {
    static let shared = ServiceLocator()
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ service: T, forKey key: String) {
        services[key] = service
    }
    
    func resolve<T>(_ key: String) -> T? {
        services[key] as? T
    }
}