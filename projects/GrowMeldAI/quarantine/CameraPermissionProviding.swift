import AVFoundation
import Combine

// MARK: - Protocol (for dependency injection & testability)
protocol CameraPermissionProviding: Sendable {
    var statusPublisher: AnyPublisher<CameraPermissionStatus, Never> { get }
    var currentStatus: CameraPermissionStatus { get }
    func requestPermission() async -> Bool
    func openSettings() -> Bool
}

// MARK: - Camera Permission Status
enum CameraPermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

// MARK: - Implementation
@MainActor
final class CameraPermissionProvider: CameraPermissionProviding {
    private let statusSubject = CurrentValueSubject<CameraPermissionStatus, Never>(.notDetermined)

    var statusPublisher: AnyPublisher<CameraPermissionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    var currentStatus: CameraPermissionStatus {
        statusSubject.value
    }

    init() {
        updateStatus()
    }

    func requestPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        updateStatus()
        return granted
    }

    func openSettings() -> Bool {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
        UIApplication.shared.open(url)
        return true
    }

    private func updateStatus() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            statusSubject.send(.notDetermined)
        case .authorized:
            statusSubject.send(.authorized)
        case .denied:
            statusSubject.send(.denied)
        case .restricted:
            statusSubject.send(.restricted)
        @unknown default:
            statusSubject.send(.denied)
        }
    }
}