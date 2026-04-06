import AVFoundation
import Combine

// MARK: - Protocol (for dependency injection & testability)
protocol CameraPermissionProviding: Sendable {
    var statusPublisher: AnyPublisher<CameraPermissionStatus, Never> { get }
    var currentStatus: CameraPermissionStatus { get }
    func requestPermission() async -> Bool
    func openSettings() -> Bool
}

// MARK: - Implementation
@MainActor