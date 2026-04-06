// Core/DependencyInjection/ServiceContainer.swift
import Foundation

protocol ServiceContainerProtocol {
    var dataService: LocalDataService { get }
    func setDataServiceOverride(_ service: LocalDataService)
}

// MARK: - SwiftUI Environment Key
struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue: ServiceContainerProtocol = ServiceContainer.shared
}

extension EnvironmentValues {
    var serviceContainer: ServiceContainerProtocol {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}